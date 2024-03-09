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

  #staticBuffers;
  #dynamicBuffers;

  #uniformBuffer;
  #lightBuffer;
  #transformBuffer;

  #staticBindGroup;
  #dynamicBindGroup;

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

    // this.config.firstPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 600), 3);
    // this.config.secondPasses = 3;//Math.max(Math.round(Math.min(canvas.width, canvas.height) / 500), 3);
    // this.render();
  }
  
  // Make canvas read only accessible
  get canvas () {
    return this.#canvas;
  }
  
  updateScene () {
    // Generate texture arrays and buffers
    let builtScene = this.scene.generateArraysFromGraph();
    
    this.#engineState.bufferLength = builtScene.bufferLength;

    let staticBufferArrays = [
      builtScene.idBuffer,
      builtScene.geometryBuffer,
      builtScene.sceneBuffer,
    ];

    this.#staticBuffers = staticBufferArrays.map(array => {
      let buffer = this.#device.createBuffer({ size: array.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST});
      this.#device.queue.writeBuffer(buffer, 0, array);
      return buffer;
    });
    
    this.#staticBindGroup = this.#device.createBindGroup({
      label: 'static binding group',
      layout: this.#engineState.pipeline.getBindGroupLayout(0),
      entries: this.#staticBuffers.map((buffer, i) => ({ binding: i, resource: { buffer }})),
    });
  }

  // Functions to update vertex and light source data textures
  #updatePrimaryLightSources () {
    var lightTexArray = [];
		// Don't update light sources if there is none
		if (this.scene.primaryLightSources.length === 0) {
			lightTexArray = [0, 0, 0, 0, 0, 0, 0, 0];
		} else {
      // Iterate over light sources
      this.scene.primaryLightSources.forEach(lightSource => {
        // Set intensity to lightSource intensity or default if not specified
        const intensity = Object.is(lightSource.intensity)? this.scene.defaultLightIntensity : lightSource.intensity;
        const variation = Object.is(lightSource.variation)? this.scene.defaultLightVariation : lightSource.variation;
        // push location of lightSource and intensity to texture, value count has to be a multiple of 3 rgb format
        lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], 0, intensity, variation, 0, 0);
      });
    }


    let lightArray = new Float32Array(lightTexArray);
    // Reallocate buffer if size changed
    if (this.#engineState.lightSourceLength !== lightArray.length) {
      this.#engineState.lightSourceLength = lightArray.length;
      this.#lightBuffer = this.#device.createBuffer({ size: lightArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST})
    }
    // Write data into buffer
    this.#device.queue.writeBuffer(this.#lightBuffer, 0, lightArray);
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
    this.#uniformBuffer = this.#device.createBuffer({ size: 64, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
    // Create uniform buffer for transforms in shader
    // this.#engineState.transformBuffer = this.#device.createBuffer({ size: 64, usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST });
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
    this.#device.queue.writeBuffer(this.#uniformBuffer, 0, uniformValues);
    // Update primary light source buffer
    this.#updatePrimaryLightSources();
    // Update transform matrices on GPU
    let transformArray = Transform.buildWGPUArray();
    this.#transformBuffer = this.#device.createBuffer({ size: transformArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST})
    this.#device.queue.writeBuffer(this.#transformBuffer, 0, transformArray);


    this.#dynamicBuffers = [
      this.#uniformBuffer,
      this.#lightBuffer,
      this.#transformBuffer,
    ];

    // Assemble dynamic bind group
    this.#dynamicBindGroup = this.#device.createBindGroup({
      label: 'dynamic binding group',
      layout: this.#engineState.pipeline.getBindGroupLayout(1),
      entries: this.#dynamicBuffers.map((buffer, i) => ({ binding: i, resource: { buffer }})),
    });

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
    passEncoder.setBindGroup(0, this.#staticBindGroup);
    passEncoder.setBindGroup(1, this.#dynamicBindGroup);
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
