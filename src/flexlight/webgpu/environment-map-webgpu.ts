"use strict";

import { Vector } from "../common/lib/math";
import { Scene } from "../common/scene/scene";
import { Texture } from "../common/scene/texture";


export class EnvironmentMapWebGPU {
    private gpuTextureSize: Vector<2>;
    private _gpuTexture: GPUTexture;
    get gpuResource() { return this._gpuTexture.createView({ dimension: "2d" }); }

    private _gpuSampler: GPUSampler;
    get gpuSampler() { return this._gpuSampler; }
    
    private device: GPUDevice;
    // private environmentMapTexture: GPUTexture;
    private scene: Scene;
    private label: string;

    constructor(device: GPUDevice, scene: Scene, label: string = "") {
        // Save device for future use
        this.device = device;
        this.scene = scene;
        // Keep label for reference
        this.label = label;
        // Get size of first cube side image
        const source = this.scene.environmentMap;
        // this.gpuTextureSize = this.scene.environmentMap.imageSize;
        this.gpuTextureSize = new Vector(source ? source.imageSize.x : 1, source ? source.imageSize.y : 1);
        // Initialize GPUTexture
        this._gpuTexture = device.createTexture({
          //format: 'rgba32float',
          format: 'rgba16float',
          size: this.gpuTextureSize,
          usage: GPUTextureUsage.TEXTURE_BINDING |
                 GPUTextureUsage.COPY_DST |
                 GPUTextureUsage.RENDER_ATTACHMENT,
        });
        // Create sampler
        this._gpuSampler = device.createSampler({ magFilter: "linear", minFilter: "linear" });

        if (source) {
            console.log("EnvironmentMapWebGPU.constructor(): source is not null", source);
            // Copy image data to GPUTexture
            this.loadHDRImage(source.imageData, source.gamma);  
            // this.copySourcesToCubeMap(device, this.scene.environmentMap.cubeSideImages);
        }
    }

    async loadHDRImage(img: ImageData, gamma: number){
        const f16Array = new Float16Array(img.width * img.height * 4);
        const oneOverGamma = 1 / gamma;
    
        for (let i = 0; i < img.data.length; i += 4) {
            f16Array[i] = Math.pow(img.data[i]! / 0xff, oneOverGamma);
            f16Array[i + 1] = Math.pow(img.data[i + 1]! / 0xff, oneOverGamma);
            f16Array[i + 2] = Math.pow(img.data[i + 2]! / 0xff, oneOverGamma);
            f16Array[i + 3] = 1;
        }

        this._gpuTexture = this.device.createTexture({
            size: [img.width, img.height],
            format: 'rgba16float',
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT
        });

        this.device.queue.writeTexture(
            { texture: this._gpuTexture },
            f16Array.buffer,
            { bytesPerRow: img.width * 8 },
            { width: img.width, height: img.height }
        );
    }

   destroy = () => {
       // Destroy GPUTexture
       this._gpuTexture.destroy();
   }
}

