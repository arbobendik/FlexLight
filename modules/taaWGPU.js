'use strict';

import { Network } from './network.js';

const FRAMES = 4;

export class TAA {
    #shader = Network.fetchSync('shaders/taa.wgsl');
    #pipeline;
    #texture;
    #device;
    #canvas;
    frameIndex = 0;

    #randomVecs;
    #bindGroupLayout;
    #bindGroup;
    #uniformBuffer;

    constructor(device, canvas) {
        this.#device = device;
        this.#canvas = canvas;
        this.#randomVecs = this.genPseudoRandomVecsWith0Sum(FRAMES);

        this.#bindGroupLayout = device.createBindGroupLayout({
            entries: [
              { binding: 0, visibility: GPUShaderStage.COMPUTE, texture: { type: 'rgba32float', sampleType: 'unfilterable-float', viewDimension: '2d-array' } },
              { binding: 1, visibility: GPUShaderStage.COMPUTE, storageTexture: { access: 'write-only', format: 'rgba32float', viewDimension: '2d' } },
              { binding: 2, visibility: GPUShaderStage.COMPUTE, buffer: { type: "uniform" } }
            ]
        });
        
        // Create pipeline
        this.#pipeline = device.createComputePipeline({
            label: "taa pipeline",
            layout: device.createPipelineLayout({ bindGroupLayouts: [ this.#bindGroupLayout ] }),
            compute: {
                module: device.createShaderModule({ code: this.#shader }),
                entryPoint: "compute"
            }
        });

        this.#uniformBuffer = device.createBuffer({
            size: 16,
            usage: GPUBufferUsage.UNIFORM | GPUBufferUsage.COPY_DST
        });

        // Create textures and bind groups will be done in buildTexture()
        this.createTexture();
    }

    get textureInView() {
        return this.#texture.createView({ dimension: "2d", baseArrayLayer: this.frameIndex, arrayLayerCount: 1 });
    }

    get textureInView2dArray() {
        return this.#texture.createView({ dimension: "2d-array", baseArrayLayer: this.frameIndex, arrayLayerCount: 1 });
    }

    createTexture = () => {
        // Create texture
        this.#texture = this.#device.createTexture({
            size: [this.#canvas.width, this.#canvas.height, FRAMES],
            format: 'rgba32float',
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING | 
                   GPUTextureUsage.COPY_DST | GPUTextureUsage.COPY_SRC
        });
    };

    createBindGroup = (textureOut) => {
        this.#bindGroup = this.#device.createBindGroup({
            layout: this.#bindGroupLayout,
            entries: [
                { binding: 0, resource: this.#texture.createView({ dimension: "2d-array", arrayLayerCount: FRAMES }) },
                { binding: 1, resource: textureOut.createView() },
                { binding: 2, resource: { buffer: this.#uniformBuffer }}
            ]
        });
    };

    renderFrame = async (commandEncoder) => {
        // Rotate textures
        const computePass = commandEncoder.beginComputePass();
        computePass.setPipeline(this.#pipeline);
        computePass.setBindGroup(0, this.#bindGroup);

        // Dispatch workgroups (32x32 threads per workgroup)
        const workgroupsX = Math.ceil(this.#canvas.width / 8);
        const workgroupsY = Math.ceil(this.#canvas.height / 8);
        computePass.dispatchWorkgroups(workgroupsX, workgroupsY);
        computePass.end();
    }

    // Jitter and genPseudoRandomVecsWith0Sum methods remain the same
    jitter = () => {
        // Cycle through random vecs
        this.frameIndex = (this.frameIndex + 1) % FRAMES;
        const taaParams = new Float32Array([
            this.frameIndex,
            FRAMES,
            this.#randomVecs[this.frameIndex][0],
            this.#randomVecs[this.frameIndex][1]
        ]);

        this.#device.queue.writeBuffer(this.#uniformBuffer, 0, taaParams);
        // Scaling factor
        let scale = 0.3 / Math.min(this.#canvas.width, this.#canvas.height);
        // Return as easy to handle 2-dimensional vector
        return { x: this.#randomVecs[this.frameIndex][0] * scale, y: this.#randomVecs[this.frameIndex][1] * scale};
    }

    // Generate n d-dimensional pseudo random vectors that all add up to 0.
    genPseudoRandomVecsWith0Sum = (n) => {
        let vecs = new Array(n).fill(0).map(() => new Array(2));
        vecs[0] = [0, 1];
        vecs[1] = [1, 0];
        let combined = [1, 1];
        
        for (let i = 2; i < n; i++) {
            for (let j = 0; j < 2; j++) {
                let min = Math.max(- Math.min(i + 1, n - 1 - i), combined[j] - 1);
                let max = Math.min(Math.min(i + 1, n - 1 - i), combined[j] + 1);
                vecs[i][j] = 0.5 * ((max + min) + (max - min) * Math.sign(Math.random() - 0.5) * (Math.random() * 0.5) ** (1 / 2)) - combined[j];
                combined[j] += vecs[i][j];
            }
        }

        return vecs;
    }
}