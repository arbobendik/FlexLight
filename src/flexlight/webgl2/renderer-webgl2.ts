"use strict";

import { ApiType, Renderer } from "../common/renderer";
import { Prototype } from "../common/scene/prototype";
import { Texture } from "../common/scene/texture";
import { Matrix, moore_penrose, Vector, vector_scale } from "../common/lib/math";
import { WebGPUAntialiasingType } from "../webgpu/antialiasing/antialiasing-module";
import { BufferToTexture, R32UI, RGBA16F, RGBA32F, RGBA32UI, RGBA8UI } from "./buffer-to-gpu/buffer-to-texture";
import { EnvironmentMapWebGL2 } from "./environment-map-webgl2";
import { AntialiasingModule } from "./antialiasing/antialiasing-module";
import { FXAA } from "./antialiasing/fxaa";
import { TAA } from "./antialiasing/taa";
import { bindTextures, createFullscreenProgram, createProgram } from "./program";
// Ignore all shader imports, the bundler will handle them as intended.
// @ts-ignore
import RasterVertexShader from "./shaders/raster-vertex.glsl";
// @ts-ignore
import RasterFragmentShader from "./shaders/raster-fragment.glsl";
// @ts-ignore
import CanvasShader from "./shaders/canvas-fragment.glsl";


interface RendererWGL2Programs {
  rasterProgram: WebGLProgram;
  shadingProgram: WebGLProgram;
  canvasProgram: WebGLProgram;
}


interface CanvasSizeDependentResources {
  depthBuffer: WebGLRenderbuffer;
  absolutePositionTexture: WebGLTexture;
  // Instance index, triangle index, uv bits
  offsetTexture: WebGLTexture;
  rasterFramebuffer: WebGLFramebuffer;
  // Shading pass alternates between both targets, so the other one holds the previous frame
  renderTextures: [WebGLTexture, WebGLTexture];
  renderFramebuffers: [WebGLFramebuffer, WebGLFramebuffer];
  // Antialiasing output
  canvasIn: WebGLTexture;
  canvasInFramebuffer: WebGLFramebuffer;
}


interface RendererWGL2GPUBufferManagers {
  // Prototype GPU Managers
  triangleGPUManager: BufferToTexture<Float16Array<ArrayBuffer>>;
  BVHGPUManager: BufferToTexture<Uint32Array<ArrayBuffer>>;
  boundingVertexGPUManager: BufferToTexture<Float16Array<ArrayBuffer>>;
  // Light GPU Managers
  lightGPUManager: BufferToTexture<Float32Array<ArrayBuffer>>;
  // Texture GPU Managers
  textureInstanceGPUManager: BufferToTexture<Uint32Array<ArrayBuffer>>;
  textureDataGPUManager: BufferToTexture<Uint8Array<ArrayBuffer>>;
  environmentMapGPUManager: EnvironmentMapWebGL2;
  // Scene GPU Managers
  instanceUintGPUManager: BufferToTexture<Uint32Array<ArrayBuffer>>;
  instanceTransformGPUManager: BufferToTexture<Float32Array<ArrayBuffer>>;
  instanceMaterialGPUManager: BufferToTexture<Float32Array<ArrayBuffer>>;
  instanceBVHGPUManager: BufferToTexture<Uint32Array<ArrayBuffer>>;
  instanceBoundingVertexGPUManager: BufferToTexture<Float32Array<ArrayBuffer>>;
}

interface EngineState {
  renderResolution: number;
  antialiasing: WebGPUAntialiasingType;
}

const INSTANCE_UINT_SIZE: number = 9;

// Rasterizes a geometry buffer and shades it in a fullscreen pass, subclasses provide the shading shader
export abstract class RendererWGL2 extends Renderer {
  readonly api: ApiType = "webgl2";
  // Fragment shader shading each pixel of the geometry buffer
  protected abstract readonly shadingShader: string;
  // Average frames while temporal is enabled and the camera is still
  protected abstract readonly accumulate: boolean;

  // Track if engine is running
  protected isRunning: boolean = false;

  private resizeHook: (() => void) | undefined;

  private antialiasingModule: AntialiasingModule | undefined;
  private engineState: EngineState = { renderResolution: 0, antialiasing: undefined };
  // Count of previous frames the last frame has accumulated and camera state they were rendered with
  private accumulationCount: number = 0;
  private accumulationCameraState: Array<number> = [];

  halt = (): boolean => {
    // Unbind GPUBuffers
    Prototype.triangleManager.releaseGPUBuffer();
    Prototype.BVHManager.releaseGPUBuffer();
    Prototype.boundingVertexManager.releaseGPUBuffer();
    Texture.textureInstanceBufferManager.releaseGPUBuffer();
    Texture.textureDataBufferManager.releaseGPUBuffer();
    this.scene.instanceUintManager.releaseGPUBuffer();
    this.scene.instanceTransformManager.releaseGPUBuffer();
    this.scene.instanceMaterialManager.releaseGPUBuffer();
    this.scene.instanceBVHManager.releaseGPUBuffer();
    this.scene.instanceBoundingVertexManager.releaseGPUBuffer();
    this.scene.lightManager.releaseGPUBuffer();
    // Also release environment map
    this.scene.environmentMapManager.releaseGPUBuffer();

    let wasRunning = this.isRunning;
    this.isRunning = false;
    if (this.resizeHook) window.removeEventListener("resize", this.resizeHook);
    return wasRunning;
  }

  render() {
    // Check if renderer is already running
    if (this.isRunning) throw new Error("Renderer already up and running!");
    // Opaque canvas like the WebGPU implementation, depth is handled by the geometry buffer
    const gl = this.canvas.getContext("webgl2", { alpha: false, antialias: false, depth: false });
    if (!gl) throw new Error("Failed to get webgl2 context");
    // Float render targets are required for the geometry buffer and accumulation
    if (!gl.getExtension("EXT_color_buffer_float")) throw new Error("EXT_color_buffer_float not supported");
    // Prepare engine
    this.prepareEngine(gl);
  }

  private resize (gl: WebGL2RenderingContext, resources: CanvasSizeDependentResources): void {
    let width = Math.round(this.canvas.clientWidth * this.config.renderResolution);
    let height = Math.round(this.canvas.clientHeight * this.config.renderResolution);

    this.canvas.width = width;
    this.canvas.height = height;
    // Respecify storage of all canvas size dependent resources, framebuffer attachments stay valid
    const allocate = (texture: WebGLTexture, internalFormat: GLenum, format: GLenum, type: GLenum) => {
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.texImage2D(gl.TEXTURE_2D, 0, internalFormat, width, height, 0, format, type, null);
    };
    allocate(resources.absolutePositionTexture, gl.RGBA32F, gl.RGBA, gl.FLOAT);
    allocate(resources.offsetTexture, gl.RGBA32UI, gl.RGBA_INTEGER, gl.UNSIGNED_INT);
    for (const texture of resources.renderTextures) allocate(texture, gl.RGBA32F, gl.RGBA, gl.FLOAT);
    allocate(resources.canvasIn, gl.RGBA32F, gl.RGBA, gl.FLOAT);
    gl.bindRenderbuffer(gl.RENDERBUFFER, resources.depthBuffer);
    gl.renderbufferStorage(gl.RENDERBUFFER, gl.DEPTH_COMPONENT32F, width, height);
    // Init antialiasing module texture if antialiasing module exists
    if (this.antialiasingModule) this.antialiasingModule.createTexture();
    // Respecified render targets lost all previous frames, so restart accumulation
    this.accumulationCameraState = [];
  }

  private createCanvasSizeDependentResources(gl: WebGL2RenderingContext): CanvasSizeDependentResources {
    const createTexture = (): WebGLTexture => {
      const texture = gl.createTexture();
      gl.bindTexture(gl.TEXTURE_2D, texture);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
      gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
      return texture;
    };
    const createFramebuffer = (...colorAttachments: Array<WebGLTexture>): WebGLFramebuffer => {
      const framebuffer = gl.createFramebuffer();
      gl.bindFramebuffer(gl.FRAMEBUFFER, framebuffer);
      colorAttachments.forEach((texture, i) => gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0 + i, gl.TEXTURE_2D, texture, 0));
      gl.drawBuffers(colorAttachments.map((_texture, i) => gl.COLOR_ATTACHMENT0 + i));
      return framebuffer;
    };

    const depthBuffer = gl.createRenderbuffer();
    gl.bindRenderbuffer(gl.RENDERBUFFER, depthBuffer);
    const absolutePositionTexture = createTexture();
    const offsetTexture = createTexture();
    const rasterFramebuffer = createFramebuffer(absolutePositionTexture, offsetTexture);
    gl.framebufferRenderbuffer(gl.FRAMEBUFFER, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, depthBuffer);

    const renderTextures: [WebGLTexture, WebGLTexture] = [createTexture(), createTexture()];
    const renderFramebuffers: [WebGLFramebuffer, WebGLFramebuffer] = [createFramebuffer(renderTextures[0]), createFramebuffer(renderTextures[1])];
    const canvasIn = createTexture();
    const canvasInFramebuffer = createFramebuffer(canvasIn);

    return {
      depthBuffer, absolutePositionTexture, offsetTexture, rasterFramebuffer,
      renderTextures, renderFramebuffers, canvasIn, canvasInFramebuffer
    };
  }

  private prepareEngine(gl: WebGL2RenderingContext) {
    // Halt renderer if still running
    this.halt();
    // Allow frame rendering
    this.isRunning = true;

    const programs: RendererWGL2Programs = {
      rasterProgram: createProgram(gl, RasterVertexShader, RasterFragmentShader),
      shadingProgram: createFullscreenProgram(gl, this.shadingShader),
      canvasProgram: createFullscreenProgram(gl, CanvasShader)
    };
    // Link GPUBufferManagers to BufferManagers
    const gpuManagers: RendererWGL2GPUBufferManagers = {
      // Prototype GPU Managers
      triangleGPUManager: new BufferToTexture<Float16Array<ArrayBuffer>>(Prototype.triangleManager, gl, RGBA16F),
      BVHGPUManager: new BufferToTexture<Uint32Array<ArrayBuffer>>(Prototype.BVHManager, gl, RGBA32UI),
      boundingVertexGPUManager: new BufferToTexture<Float16Array<ArrayBuffer>>(Prototype.boundingVertexManager, gl, RGBA16F),
      // Texture GPU Managers
      textureInstanceGPUManager: new BufferToTexture<Uint32Array<ArrayBuffer>>(Texture.textureInstanceBufferManager, gl, R32UI),
      textureDataGPUManager: new BufferToTexture<Uint8Array<ArrayBuffer>>(Texture.textureDataBufferManager, gl, RGBA8UI),
      // Environment Map GPU Manager
      environmentMapGPUManager: new EnvironmentMapWebGL2(gl, this.scene),
      // Scene GPU Managers
      instanceUintGPUManager: new BufferToTexture<Uint32Array<ArrayBuffer>>(this.scene.instanceUintManager, gl, R32UI),
      instanceTransformGPUManager: new BufferToTexture<Float32Array<ArrayBuffer>>(this.scene.instanceTransformManager, gl, RGBA32F),
      instanceMaterialGPUManager: new BufferToTexture<Float32Array<ArrayBuffer>>(this.scene.instanceMaterialManager, gl, RGBA32F),
      instanceBVHGPUManager: new BufferToTexture<Uint32Array<ArrayBuffer>>(this.scene.instanceBVHManager, gl, R32UI),
      instanceBoundingVertexGPUManager: new BufferToTexture<Float32Array<ArrayBuffer>>(this.scene.instanceBoundingVertexManager, gl, RGBA32F),
      lightGPUManager: new BufferToTexture<Float32Array<ArrayBuffer>>(this.scene.lightManager, gl, RGBA32F),
    }
    // Storage is allocated by resize on first frame
    const resources = this.createCanvasSizeDependentResources(gl);
    this.engineState.renderResolution = 0;
    this.resizeHook = () => this.resize(gl, resources);
    window.addEventListener("resize", this.resizeHook);
    // Begin frame cycle
    requestAnimationFrame(() => this.frameCycle(gl, programs, resources, gpuManagers));
  }

  // Internal render engine Functions
  private frameCycle (gl: WebGL2RenderingContext, programs: RendererWGL2Programs, resources: CanvasSizeDependentResources, gpuManagers: RendererWGL2GPUBufferManagers) {
    if (!this.isRunning) return;
    // Check if resize is required
    if (this.engineState.renderResolution !== this.config.renderResolution) {
      this.engineState.renderResolution = this.config.renderResolution;
      this.resize(gl, resources);
    }
    // Request browser to render frame with hardware acceleration
    requestAnimationFrame(() => {
      setTimeout(() => {
        this.frameCycle(gl, programs, resources, gpuManagers);
      }, 1000 / this.fpsLimit);
    });

    // Swap antialiasing program if needed
    if (this.engineState.antialiasing !== this.config.antialiasing) {
      // Use internal antialiasing variable for actual state of antialiasing.
      this.engineState.antialiasing = this.config.antialiasing;
      switch (this.config.antialiasing) {
        case "fxaa":
          this.antialiasingModule = new FXAA(gl);
          break;
        case "taa":
          this.antialiasingModule = new TAA(gl, this.canvas);
          break;
        default:
          this.antialiasingModule = undefined;
      }
    }
    // Rebuild environment map texture if the scene got a new environment map, e.g. after loading asynchronously
    if (gpuManagers.environmentMapGPUManager.source !== this.scene.environmentMap) {
      gl.deleteTexture(gpuManagers.environmentMapGPUManager.gpuResource);
      gpuManagers.environmentMapGPUManager = new EnvironmentMapWebGL2(gl, this.scene);
      this.accumulationCameraState = [];
    }
    // Render new Image
    this.renderFrame(gl, programs, resources, gpuManagers);
    // Update frame counter
    this.updatePerformanceMetrics();
  }

  private renderFrame (gl: WebGL2RenderingContext, programs: RendererWGL2Programs, resources: CanvasSizeDependentResources, gpuManagers: RendererWGL2GPUBufferManagers) {
    // Calculate jitter for temporal antialiasing
    let jitter = { x: 0, y: 0 };
    if (this.antialiasingModule instanceof TAA) jitter = this.antialiasingModule.jitter();
    let dirJitter = { x: this.camera.direction.x + jitter.x, y: this.camera.direction.y + jitter.y };

    // Update scene buffers on CPU and sync to GPU
    const totalTriangleCount: number = this.scene.updateBuffers();

    // Calculate camera offset and projection matrix
    const aspect: number = this.canvas.width / this.canvas.height;
    const fov_x_rad: number = this.camera.fov * Math.PI / 180.0;
    const focal_x: number = 1.0 / Math.tan(fov_x_rad / 2.0);
    const focal_y: number = focal_x * aspect;
    // 2. View matrix (camera orientation)
    const cos_x: number = Math.cos(dirJitter.x);
    const sin_x: number = Math.sin(dirJitter.x);
    const cos_y: number = Math.cos(dirJitter.y);
    const sin_y: number = Math.sin(dirJitter.y);
    // Camera basis vectors in world space.
    const right_vec: Vector<3> = new Vector<3>(cos_x, 0, -sin_x);
    const up_vec: Vector<3> = new Vector<3>(-sin_x * sin_y, cos_y, -cos_x * sin_y);
    const forward_vec: Vector<3> = new Vector<3>(sin_x * cos_y, sin_y, cos_x * cos_y);

    // World-to-camera rotation matrix has camera basis vectors as rows.
    const worldToCamera: Matrix<3, 3> = new Matrix<3, 3>(
      right_vec,
      up_vec,
      vector_scale(forward_vec, -1)
    );

    const viewMatrix: Matrix<3, 3> = new Matrix<3, 3>(
      vector_scale(worldToCamera[0]!, focal_x),
      vector_scale(worldToCamera[1]!, focal_y),
      worldToCamera[2]!
    );

    const invViewMatrix: Matrix<3, 3> = moore_penrose(viewMatrix);
    const temporalCount = this.config.temporal ? this.frameCounter : 0;

    // Reuse previous frames only while the camera is still, jitter is excluded as it antialiases the accumulated image
    const cameraState: Array<number> = [
      this.camera.position.x, this.camera.position.y, this.camera.position.z,
      this.camera.direction.x, this.camera.direction.y, this.camera.fov
    ];
    const cameraMoved: boolean = cameraState.some((value, i) => value !== this.accumulationCameraState[i]);
    this.accumulationCameraState = cameraState;
    this.accumulationCount = (this.accumulate && this.config.temporal && !cameraMoved) ? this.accumulationCount + 1 : 0;
    // Alternate render targets, so the previous frame can be read while rendering the current one
    const target: number = this.frameCounter % 2;

    gl.viewport(0, 0, this.canvas.width, this.canvas.height);

    // Raster pass, fill geometry buffer with closest triangle per pixel
    gl.bindFramebuffer(gl.FRAMEBUFFER, resources.rasterFramebuffer);
    gl.clearBufferfv(gl.COLOR, 0, [0, 0, 0, 0]);
    gl.clearBufferuiv(gl.COLOR, 1, [0, 0, 0, 0]);
    gl.clearBufferfv(gl.DEPTH, 0, [1]);
    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.CULL_FACE);
    gl.useProgram(programs.rasterProgram);
    bindTextures(gl, programs.rasterProgram,
      ["triangles", gl.TEXTURE_2D_ARRAY, gpuManagers.triangleGPUManager.gpuResource],
      ["instance_uint", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceUintGPUManager.gpuResource],
      ["instance_transform", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceTransformGPUManager.gpuResource]
    );
    // Matrices are uploaded column major, matching the WebGPU uniform layout without padding
    gl.uniformMatrix3fv(gl.getUniformLocation(programs.rasterProgram, "view_matrix"), false, [
      viewMatrix[0]![0]!, viewMatrix[1]![0]!, viewMatrix[2]![0]!,
      viewMatrix[0]![1]!, viewMatrix[1]![1]!, viewMatrix[2]![1]!,
      viewMatrix[0]![2]!, viewMatrix[1]![2]!, viewMatrix[2]![2]!
    ]);
    gl.uniform3f(gl.getUniformLocation(programs.rasterProgram, "camera_position"), this.camera.position.x, this.camera.position.y, this.camera.position.z);
    gl.uniform1ui(gl.getUniformLocation(programs.rasterProgram, "instance_count"), this.scene.instanceUintManager.length / INSTANCE_UINT_SIZE);
    gl.drawArraysInstanced(gl.TRIANGLES, 0, 3, totalTriangleCount);
    gl.disable(gl.DEPTH_TEST);
    gl.disable(gl.CULL_FACE);

    // Shading pass, path trace or rasterize from geometry buffer
    let envMapSize: Vector<2> = this.scene.environmentMap.imageSize;
    gl.bindFramebuffer(gl.FRAMEBUFFER, resources.renderFramebuffers[target]!);
    gl.useProgram(programs.shadingProgram);
    bindTextures(gl, programs.shadingProgram,
      ["texture_absolute_position", gl.TEXTURE_2D, resources.absolutePositionTexture],
      ["texture_offset", gl.TEXTURE_2D, resources.offsetTexture],
      ["accumulated", gl.TEXTURE_2D, resources.renderTextures[1 - target]!],
      ["texture_data", gl.TEXTURE_2D_ARRAY, gpuManagers.textureDataGPUManager.gpuResource],
      ["texture_instance", gl.TEXTURE_2D_ARRAY, gpuManagers.textureInstanceGPUManager.gpuResource],
      ["environment_map", gl.TEXTURE_2D, gpuManagers.environmentMapGPUManager.gpuResource],
      ["triangles", gl.TEXTURE_2D_ARRAY, gpuManagers.triangleGPUManager.gpuResource],
      ["triangle_bvh", gl.TEXTURE_2D_ARRAY, gpuManagers.BVHGPUManager.gpuResource],
      ["triangle_bounding_vertices", gl.TEXTURE_2D_ARRAY, gpuManagers.boundingVertexGPUManager.gpuResource],
      ["lights", gl.TEXTURE_2D_ARRAY, gpuManagers.lightGPUManager.gpuResource],
      ["instance_uint", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceUintGPUManager.gpuResource],
      ["instance_transform", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceTransformGPUManager.gpuResource],
      ["instance_material", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceMaterialGPUManager.gpuResource],
      ["instance_bvh", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceBVHGPUManager.gpuResource],
      ["instance_bounding_vertices", gl.TEXTURE_2D_ARRAY, gpuManagers.instanceBoundingVertexGPUManager.gpuResource]
    );
    const location = (name: string) => gl.getUniformLocation(programs.shadingProgram, name);
    gl.uniformMatrix3fv(location("inv_view_matrix"), false, [
      invViewMatrix[0]![0]!, invViewMatrix[1]![0]!, invViewMatrix[2]![0]!,
      invViewMatrix[0]![1]!, invViewMatrix[1]![1]!, invViewMatrix[2]![1]!,
      invViewMatrix[0]![2]!, invViewMatrix[1]![2]!, invViewMatrix[2]![2]!
    ]);
    gl.uniform3f(location("camera_position"), this.camera.position.x, this.camera.position.y, this.camera.position.z);
    gl.uniform3f(location("ambient"), this.scene.ambientLight.x, this.scene.ambientLight.y, this.scene.ambientLight.z);
    gl.uniform2ui(location("render_size"), this.canvas.width, this.canvas.height);
    gl.uniform1ui(location("temporal_target"), temporalCount);
    gl.uniform1ui(location("samples"), this.config.samplesPerPixel);
    gl.uniform1ui(location("max_bounces"), this.config.maxBounces);
    gl.uniform2ui(location("environment_map_size"), envMapSize.x, envMapSize.y);
    gl.uniform1ui(location("light_count"), this.scene.lightCount);
    gl.uniform1ui(location("env_map_mip_level_count"), gpuManagers.environmentMapGPUManager.mipLevelCount);
    gl.uniform1f(location("accumulation_count"), this.accumulationCount);
    gl.drawArrays(gl.TRIANGLES, 0, 3);

    // Antialiasing pass into canvasIn
    if (this.antialiasingModule) this.antialiasingModule.renderFrame(resources.renderTextures[target]!, resources.canvasInFramebuffer);

    // Canvas pass, tonemap to canvas
    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.useProgram(programs.canvasProgram);
    bindTextures(gl, programs.canvasProgram, ["compute_out", gl.TEXTURE_2D, this.antialiasingModule ? resources.canvasIn : resources.renderTextures[target]!]);
    gl.uniform1ui(gl.getUniformLocation(programs.canvasProgram, "tonemapping_operator"), this.config.tonemapping ? 1 : 0);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  }
}
