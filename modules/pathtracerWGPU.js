'use strict';

import { Network } from './network.js';
import { GLLib } from './gllib.js';
import { FXAA } from './fxaa.js';
import { TAA } from './taa.js';
import { Transform } from './scene.js';
import { Arrays, Float16Array } from './arrays.js';


const PathtracingUniformLocationIdentifiers = [
  'cameraPosition', 'viewMatrix',
  'samples', 'maxReflections', 'minImportancy', 'useFilter', 'isTemporal',
  'ambient', 'randomSeed', 'textureWidth',
  'geometryTex', 'sceneTex', 'pbrTex', 'translucencyTex', 'tex', 'lightTex'
];

const PathtracingUniformFunctionTypes = [
  'uniform3f', 'uniformMatrix3fv',
  'uniform1i', 'uniform1i', 'uniform1f', 'uniform1i', 'uniform1i',
  'uniform3f', 'uniform1f', 'uniform1i',
  'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i', 'uniform1i'
];

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

  #halt = true;
  // Create new PathTracer from canvas and setup movement
  constructor (canvas, scene, camera, config) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.config = config;
    // Check for WebGPU support first by seeing if navigator.gpu exists
    if (!navigator.gpu) return undefined;
    // Request webgpu context
    this.#context = canvas.getContext('webgpu');
  }

  halt = () => {
    this.#halt = true;
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }

  // Functions to update vertex and light source data textures
  async updatePrimaryLightSources () {
  }

  async updateScene () {
  }

  async render() {
    if (!this.#halt) {
      console.warn('Renderer already up and running!');
      return;
    }
    // Allow frame rendering
    this.#halt = false;

    // Setup webgpu internal components
    this.#adapter = await navigator.gpu.requestAdapter();
    console.log(this.#adapter);
    this.#device = await this.#adapter.requestDevice();
    this.#context.configure({
      device: this.#device,
      format: navigator.gpu.getPreferredCanvasFormat()
    });

    // Shaders are written in a language called WGSL.
    const shaderModule = this.#device.createShaderModule({
      code: `
        // Every vertex attribute input is identified by a @location, which
        // matches up with the shaderLocation specified during pipeline creation.
        struct VertexIn {
          @location(0) pos: vec3f,
          @location(1) color: vec4f,
        }

        struct VertexOut {
          // Every vertex shader must output a value with @builtin(position)
          @builtin(position) pos: vec4f,

          // Other outputs are given a @location so that they can map to the
          // fragment shader inputs.
          @location(0) color: vec4f,
        }

        // Shader entry points can be named whatever you want, and you can have
        // as many as you want in a single shader module.
        @vertex
        fn vertexMain(in: VertexIn) -> VertexOut {
          var out: VertexOut;
          out.pos = vec4f(in.pos, 1);
          out.color = in.color;
          return out;
        }

        // Every fragment shader has to output one vector per pipeline target.
        // The @location corresponds to the target index in the array.
        @fragment
        fn fragmentMain(@location(0) color: vec4f) -> @location(0) vec4f {
          return color;
        }`
    });

    // Pipelines bundle most of the render state (like primitive types, blend
    // modes, etc) and shader entry points into one big object.
    const pipeline = this.#device.createRenderPipeline({
      // All pipelines need a layout, but if you don't need to share data between
      // pipelines you can use the 'auto' layout to have it generate one for you!
      layout: 'auto',
      vertex: {
        module: shaderModule,
        entryPoint: 'vertexMain',
        // `buffers` describes the layout of the attributes in the vertex buffers.
        buffers: [{
          arrayStride: 28, // Bytes per vertex (3 floats + 4 floats)
          attributes: [{
            shaderLocation: 0, // VertexIn.pos in the shader
            offset: 0, // Starts at the beginning of the buffer
            format: 'float32x3' // Data is 3 floats
          }, {
            shaderLocation: 1, // VertexIn.color in the shader
            offset: 12, // Starts 12 bytes (3 floats) in to the buffer
            format: 'float32x4' // Data is 4 floats
          }]
        }],
      },
      fragment: {
        module: shaderModule,
        entryPoint: 'fragmentMain',
        // `targets` indicates the format of each render target this pipeline
        // outputs to. It must match the colorAttachments of any renderPass it's
        // used with.
        targets: [{
          format: navigator.gpu.getPreferredCanvasFormat(),
        }],
      },
    });

    // It's easiest to specify vertex data with TypedArrays, like a Float32Array
    // You are responsible for making sure the layout of the data matches the
    // layout that you describe in the pipeline `buffers`.
    const vertexData = new Float32Array([
    // X,  Y, Z   R, G, B, A,
      0,  1, 1,  1, 0, 0, 1,
      -1, -1, 1,  0, 1, 0, 1,
      1, -1, 1,  0, 0, 1, 1,
    ]);
    const vertexBuffer = this.#device.createBuffer({
      // Buffers are given a size in bytes at creation that can't be changed.
      size: vertexData.byteLength,
      // Usage defines what this buffer can be used for
      // VERTEX = Can be passed to setVertexBuffer()
      // COPY_DST = You can write or copy data into it after creation
      usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
    });

    // writeBuffer is the easiest way to TypedArray data into a buffer.
    this.#device.queue.writeBuffer(vertexBuffer, 0, vertexData);

    // Command encoders record commands for the GPU to execute.
    const commandEncoder = this.#device.createCommandEncoder();

    // All rendering commands happen in a render pass.
    const passEncoder = commandEncoder.beginRenderPass({
      // Render passes are given attachments to write into.
      colorAttachments: [{
        // By using a texture from the canvas context configured above as the
        // attachment, anything drawn in the pass will display in the canvas.
        view: this.#context.getCurrentTexture().createView(),
        // Clear the attachment when the render pass starts.
        loadOp: 'clear',
        // The color the attachment will be cleared to.
        clearValue: [0, 0, 0.2, 1],
        // When the pass is done, save the results in the attachment texture.
        storeOp: 'store',
      }]
    });

    // Set the pipeline to use when drawing.
    passEncoder.setPipeline(pipeline);
    // Set the vertex buffer to use when drawing.
    // The `0` corresponds to the index of the `buffers` array in the pipeline.
    passEncoder.setVertexBuffer(0, vertexBuffer);
    // Draw 3 vertices using the previously set pipeline and vertex buffer.
    passEncoder.draw(3);

    // End the render pass.
    passEncoder.end();

    // Finish recording commands, which creates a command buffer.
    const commandBuffer = commandEncoder.finish();

    // Command buffers don't execute right away, you have to submit them to the
    // device queue.
    this.#device.queue.submit([commandBuffer]);
  }
}
