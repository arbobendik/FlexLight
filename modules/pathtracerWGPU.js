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

  #engineState;
  #resizeEvent;

  #halt = true;
  // Create new PathTracer from canvas and setup movement
  constructor (canvas, scene, camera, config) {
    this.#canvas = canvas;
    this.camera = camera;
    this.scene = scene;
    this.config = config;
    console.log(this.config);
    // Check for WebGPU support first by seeing if navigator.gpu exists
    if (!navigator.gpu) return undefined;
    // Request webgpu context
    this.#context = canvas.getContext('webgpu');
    // Init canvas parameters and textures with resize
    this.#resizeEvent = window.addEventListener('resize', () => this.resize());
  }

  halt = () => {
    this.#halt = true;
    window.removeEventListener('resize',this.#resizeEvent);
  }

  async resize () {
    console.log(this.config);
    this.canvas.width = this.canvas.clientWidth * this.config.renderQuality;
    this.canvas.height = this.canvas.clientHeight * this.config.renderQuality;
    // this.#gl.viewport(0, 0, this.canvas.width, this.canvas.height);
    // Rebuild textures with every resize
    // renderTextureBuilder();
    // rt.updatePrimaryLightSources();
    // if (this.#AAObject !== undefined) this.#AAObject.buildTexture();

    this.config.firstPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 600), 3);
    this.config.secondPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 500), 3);
    this.render();
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
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

    this.resize();

    // Setup webgpu internal components
    this.#adapter = await navigator.gpu.requestAdapter();
    this.#device = await this.#adapter.requestDevice();
    this.#context.configure({
      device: this.#device,
      format: navigator.gpu.getPreferredCanvasFormat()
    });

    this.#prepareEngine();
    // Begin frame cycle
    requestAnimationFrame(() => this.#frameCycle());
  }

  #prepareEngine () {
    this.#engineState = {
      // Attributes to meassure frames per second
      intermediateFrames: 0,
      lastTimeStamp: performance.now(),
      // Count frames to match with temporal accumulation
      temporalFrame: 0,
      // Parameters to compare against current state of the engine and recompile shaders on change
      filter: this.config.filter,
      renderQuality: this.config.renderQuality
    };


    let shader = Network.fetchSync('shaders/pathtracer.wgsl');
    // Shaders are written in a language called WGSL.
    const shaderModule = this.#device.createShaderModule({
      code: shader
    });

    // Pipelines bundle most of the render state (like primitive types, blend
    // modes, etc) and shader entry points into one big object.
    this.#engineState.pipeline = this.#device.createRenderPipeline({
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

    this.#engineState.vertexBuffer = this.#device.createBuffer({
      // Buffers are given a size in bytes at creation that can't be changed.
      size: vertexData.byteLength,
      // Usage defines what this buffer can be used for
      // VERTEX = Can be passed to setVertexBuffer()
      // COPY_DST = You can write or copy data into it after creation
      usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
    });

    // writeBuffer is the easiest way to TypedArray data into a buffer.
    this.#device.queue.writeBuffer(this.#engineState.vertexBuffer, 0, vertexData);
  }

  // Internal render engine Functions
  #frameCycle () {
    if (this.#halt) return;
    let timeStamp = performance.now();
    // Update Textures
    // Check if recompile is required
    if (this.#engineState.filter !== this.config.filter || this.#engineState.renderQuality !== this.config.renderQuality) {
      this.resize();
      this.#prepareEngine();
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
    // Sumbit command buffer to device queue
    // Command encoders record commands for the GPU to execute.
    let commandEncoder = this.#device.createCommandEncoder();

    // All rendering commands happen in a render pass.
    let passEncoder = commandEncoder.beginRenderPass({
      // Render passes are given attachments to write into.
      colorAttachments: [{
        // By using a texture from the canvas context configured above as the
        // attachment, anything drawn in the pass will display in the canvas.
        view: this.#context.getCurrentTexture().createView(),
        // Clear the attachment when the render pass starts.
        loadOp: 'clear',
        // The color the attachment will be cleared to.
        clearValue: [0, 0, 0, 0],
        // When the pass is done, save the results in the attachment texture.
        storeOp: 'store',
      }]
    });
    
    passEncoder.setViewport(0, 0, this.canvas.width, this.canvas.height, 0, 0);
    // Set the pipeline to use when drawing.
    passEncoder.setPipeline(this.#engineState.pipeline);
    // Set the vertex buffer to use when drawing.
    // The `0` corresponds to the index of the `buffers` array in the pipeline.
    passEncoder.setVertexBuffer(0, this.#engineState.vertexBuffer);
    // Draw 3 vertices using the previously set pipeline and vertex buffer.
    passEncoder.draw(3);

    // End the render pass.
    passEncoder.end();

    // Finish recording commands, which creates a command buffer.
    let commandBuffer = commandEncoder.finish();
    this.#device.queue.submit([commandBuffer]);
  }
}
