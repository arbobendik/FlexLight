'use strict';

import { Network } from './network.js';
import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';
import { Transform } from './scene.js';
import { Arrays, Float16Array } from './arrays.js';

export class PathTracerWGPU {
  type = 'pathtracer';
  // Configurable runtime properties of the pathtracer (public attributes)
  config;
  // Performance metric
  fps = 0;
  fpsLimit = Infinity;
  // Make gl object inaccessible from outside the class
  #context;
  #adapter;
  #device;
  #canvas;
  #preferedCanvasFormat

  #engineState = {};
  #renderPassDescriptor;
  #resizeEvent;

  #halt = true;
  // Create new PathTracer from canvas and setup movement
  constructor (canvas, scene, camera, config) {
    this.#canvas = canvas;
    console.log(this.#canvas);
    this.camera = camera;
    this.scene = scene;
    this.config = config;
    // console.log(this.config);
    // Check for WebGPU support first by seeing if navigator.gpu exists
    if (!navigator.gpu) return undefined;
  }

  halt = () => {
    this.#halt = true;
    window.removeEventListener('resize',this.#resizeEvent);
  }

  resize () {
    // console.log(this.config);
    this.#canvas.width = this.#canvas.clientWidth * this.config.renderQuality;
    this.#canvas.height = this.#canvas.clientHeight * this.config.renderQuality;

    let canvasTexture = this.#context.getCurrentTexture();
    
    if (this.#engineState.depthTexture) {
      this.#engineState.depthTexture.destroy();
    }
    
    this.#engineState.depthTexture = this.#device.createTexture({
      size: [canvasTexture.width, canvasTexture.height],
      format: 'depth24plus',
      usage: GPUTextureUsage.RENDER_ATTACHMENT,
    });
 
    // this.#gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    // Rebuild textures with every resize
    // this.renderTextureBuilder();
    // rt.updatePrimaryLightSources();
    // if (this.#AAObject !== undefined) this.#AAObject.buildTexture();

    this.config.firstPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 600), 3);
    this.config.secondPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 500), 3);
    // this.render();
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }
  
  
  updateScene () {
    // Generate texture arrays and buffers
    let builtScene = this.scene.generateArraysFromGraph();
    console.log(builtScene);
    
    this.#engineState.bufferLength = builtScene.bufferLength;
    this.#engineState.idBuffer = this.#device.createBuffer({ size: builtScene.idBuffer.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST});
    this.#device.queue.writeBuffer(this.#engineState.idBuffer, 0, builtScene.idBuffer);
    
    // Set geometry buffer in VRAM
    this.#engineState.geometryBuffer = this.#device.createBuffer({ size: builtScene.geometryBuffer.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST});
    this.#device.queue.writeBuffer(this.#engineState.geometryBuffer, 0, builtScene.geometryBuffer);
    
    // Send scene buffer to GPU
    this.#engineState.sceneBuffer = this.#device.createBuffer({ size: builtScene.sceneBuffer.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST});
    this.#device.queue.writeBuffer(this.#engineState.sceneBuffer, 0, builtScene.sceneBuffer);
    
    this.#engineState.bindGroup = this.#device.createBindGroup({
      layout: this.#engineState.pipeline.getBindGroupLayout(0),
      entries: [
        { binding: 0, resource: { buffer: this.#engineState.uniformBuffer }},
        { binding: 1, resource: { buffer: this.#engineState.idBuffer }},
        { binding: 2, resource: { buffer: this.#engineState.geometryBuffer }},
        { binding: 3, resource: { buffer: this.#engineState.sceneBuffer }}
      ],
    });
  }
  
  async render() {
    
    if (!this.#halt) {
      console.warn('Renderer already up and running!');
      return;
    }
    // Allow frame rendering
    this.#halt = false;

    // Request webgpu context
    this.#context = this.#canvas.getContext('webgpu');
    // Setup webgpu internal components
    this.#adapter = await navigator.gpu.requestAdapter();
    this.#device = await this.#adapter.requestDevice();
    
    // Get prefered canvas format
    this.#preferedCanvasFormat = await navigator.gpu.getPreferredCanvasFormat();

    this.#context.configure({
      device: this.#device,
      format: this.#preferedCanvasFormat,
    });

    this.#engineState.intermediateFrames = 0;
    // Attributes to meassure frames per second
    
    this.#engineState.lastTimeStamp = performance.now();
    // Count frames to match with temporal accumulation
    this.#engineState.temporalFrame = 0;
    
    this.#prepareEngine();
  }
  
  #prepareEngine () {
    let shader = Network.fetchSync('shaders/pathtracer.wgsl');
    // Shaders are written in a language called WGSL.
    let shaderModule = this.#device.createShaderModule({
      code: shader
    });
    
    // Parameters to compare against current state of the engine and recompile shaders on change
    this.#engineState.filter = this.config.filter;
    this.#engineState.renderQuality = this.config.renderQuality;
    // Internal Webgpu parameters
    this.#engineState.bufferLength = 0;
    // Pipelines bundle most of the render state (like primitive types, blend
    // modes, etc) and shader entry points into one big object.
    this.#engineState.pipeline = this.#device.createRenderPipeline({
      layout: 'auto',
      // Vertex shader
      vertex: {
        module: shaderModule,
        entryPoint: 'vsMain',
      },
      // Fragment shader
      fragment: {
        module: shaderModule,
        entryPoint: 'fsMain',
        targets: [{
          format: this.#preferedCanvasFormat,
        }],
      },
      // Culling config
      primitive: {
        topology: 'triangle-list',
        cullMode: 'back',
      },
      
      // Depth buffer
      depthStencil: {
        depthWriteEnabled: true,
        depthCompare: 'greater',
        format: 'depth24plus',
      }
    });

    // Initialize render pass decriptor
    this.#renderPassDescriptor = {
      // Render passes are given attachments to write into.
      colorAttachments: [{
        // The color the attachment will be cleared to.
        clearValue: [0, 0, 0, 0],
        // Clear the attachment when the render pass starts.
        loadOp: 'clear',
        // When the pass is done, save the results in the attachment texture.
        storeOp: 'store',
      }],
      
      depthStencilAttachment: {
        depthClearValue: 0,
        depthLoadOp: 'clear',
        depthStoreOp: 'store'
      }
    };
    // Create uniform buffer for shader uniforms
    this.#engineState.uniformBuffer = this.#device.createBuffer({ size: 64, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
    // Build / Rebuild scene graph for GPU into storage buffer
    this.updateScene();
    // Init canvas parameters and textures with resize
    this.resize();
    // this.#renderFrame();
    this.#resizeEvent = window.addEventListener('resize', () => this.resize());
    // Begin frame cycle
    requestAnimationFrame(() => this.#frameCycle());
  }

  // Internal render engine Functions
  #frameCycle () {
    // console.log(this.#halt);
    if (this.#halt) return;
    let timeStamp = performance.now();
    // Check if recompile is required
    if (this.#engineState.filter !== this.config.filter || this.#engineState.renderQuality !== this.config.renderQuality) {
      // Update Textures
      requestAnimationFrame(() => this.#prepareEngine());
      return;
    }
    
    // Swap antialiasing programm if needed
    if (this.#engineState.antialiasing !== this.config.antialiasing) {
      this.#engineState.antialiasing = this.config.antialiasing;
      // Use internal antialiasing variable for actual state of antialiasing.
      let val = this.config.antialiasing.toLowerCase();
      switch (val) {
        case 'fxaa':
          break;
        case 'taa':
          break;
        default:
      }
    }
    // Render new Image, work through queue
    this.#renderFrame();
    // Update frame counter
    this.#engineState.intermediateFrames ++;
    this.#engineState.temporalFrame = (this.#engineState.temporalFrame + 1) % this.config.temporalSamples;
    // Calculate Fps
    let timeDifference = timeStamp - this.#engineState.lastTimeStamp;
    if (timeDifference > 500) {
      this.fps = (1000 * this.#engineState.intermediateFrames / timeDifference).toFixed(0);
      this.#engineState.lastTimeStamp = timeStamp;
      this.#engineState.intermediateFrames = 0;
    }
    // Request browser to render frame with hardware acceleration
    setTimeout(() => {
      requestAnimationFrame(() => this.#frameCycle())
    }, 1000 / this.fpsLimit);
  }

  async #renderFrame () {
    // Calculate camera offset and projection matrix
    let dir = {x: this.camera.fx, y: this.camera.fy};
    let invFov = 1 / this.camera.fov;
    let heightInvWidthFov = this.#canvas.height * invFov / this.#canvas.width;

    let viewMatrix = [
      [   Math.cos(dir.x) * heightInvWidthFov,            0,                          Math.sin(dir.x) * heightInvWidthFov         ],
      [ - Math.sin(dir.x) * Math.sin(dir.y) * invFov,     Math.cos(dir.y) * invFov,   Math.cos(dir.x) * Math.sin(dir.y) * invFov  ],
      [ - Math.sin(dir.x) * Math.cos(dir.y),            - Math.sin(dir.y),            Math.cos(dir.x) * Math.cos(dir.y)           ]
    ];

    // Transpose view matrix in buffer
    let uniformValues = new Float32Array([
      viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0], 0,
      viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1], 0,
      viewMatrix[0][2], viewMatrix[1][2], viewMatrix[2][2], 0,
      this.camera.x, this.camera.y, this.camera.z, 0
    ]);
    // Update uniform values on GPU
    this.#device.queue.writeBuffer(this.#engineState.uniformBuffer, 0, uniformValues);
    // Sumbit command buffer to device queue
    // console.log([this.#context.getCurrentTexture().width, this.#context.getCurrentTexture().height]);
    // Command encoders record commands for the GPU to execute.
    let commandEncoder = this.#device.createCommandEncoder();

    this.#renderPassDescriptor.colorAttachments[0].view = this.#context.getCurrentTexture().createView();
    this.#renderPassDescriptor.depthStencilAttachment.view = this.#engineState.depthTexture.createView();
    // All rendering commands happen in a render pass.
    let passEncoder = commandEncoder.beginRenderPass(this.#renderPassDescriptor);
    // Set the pipeline to use when drawing.
    passEncoder.setPipeline(this.#engineState.pipeline);
    // Set the vertex buffer to use when drawing.
    // passEncoder.setVertexBuffer(0, this.#engineState.geometryBuffer);
    passEncoder.setBindGroup(0, this.#engineState.bindGroup);
    // Draw vertices using the previously set pipeline and vertex buffer.
    // console.log(this.#engineState.bufferLength)
    passEncoder.draw(3, this.#engineState.bufferLength);
    // End the render pass.
    passEncoder.end();

    // Finish recording commands, which creates a command buffer.
    let commandBuffer = commandEncoder.finish();
    this.#device.queue.submit([commandBuffer]);
  }
}
