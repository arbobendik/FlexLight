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
    readonly label: string;

    private _mipLevelCount: number = 0;
    get mipLevelCount() { return this._mipLevelCount; }

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
          format: 'rgba16float',
          size: this.gpuTextureSize,
          usage: GPUTextureUsage.TEXTURE_BINDING |
                 GPUTextureUsage.COPY_DST |
                 GPUTextureUsage.RENDER_ATTACHMENT,
          mipLevelCount: 8
        });
        // Create sampler with mipmap filtering
        this._gpuSampler = device.createSampler({ 
            magFilter: "linear", 
            minFilter: "linear", 
            mipmapFilter: "linear" 
        });

        if (source) {
            console.log("EnvironmentMapWebGPU.constructor(): source is not null", source);
            // Copy image data to GPUTexture
            this.loadHDRImage(source.imageData, source.gamma);  
            // this.copySourcesToCubeMap(device, this.scene.environmentMap.cubeSideImages);
        }
    }

    loadHDRImage(img: ImageData, gamma: number) {
        const f16Array = new Float16Array(img.width * img.height * 4);
        const oneOverGamma = 1 / gamma;
    
        for (let i = 0; i < img.data.length; i += 4) {
            f16Array[i] = Math.pow(img.data[i]! / 0xff, oneOverGamma);
            f16Array[i + 1] = Math.pow(img.data[i + 1]! / 0xff, oneOverGamma);
            f16Array[i + 2] = Math.pow(img.data[i + 2]! / 0xff, oneOverGamma);
            f16Array[i + 3] = 1;
        }

        // Helper functions for bilinear filtering
        const lerp = (a: number, b: number, t: number): number => a + (b - a) * t;
        const mix = (a: Float16Array, b: Float16Array, t: number): Float16Array => {
            const result = new Float16Array(a.length);
            for (let i = 0; i < a.length; i++) {
                result[i] = lerp(a[i] as number, b[i] as number, t);
            }
            return result;
        };
        const bilinearFilter = (tl: Float16Array, tr: Float16Array, bl: Float16Array, br: Float16Array, t1: number, t2: number): Float16Array => {
            const t = mix(tl, tr, t1);
            const b = mix(bl, br, t1);
            return mix(t, b, t2);
        };

        // Generate mipmaps
        const generateMips = (src: Float16Array, width: number, height: number): Array<{data: Float16Array, width: number, height: number}> => {
            const mips: Array<{data: Float16Array, width: number, height: number}> = [];
            let currentWidth = width;
            let currentHeight = height;
            let currentData = src;

            while (currentWidth > 1 || currentHeight > 1) {
                const nextWidth = Math.max(1, currentWidth / 2 | 0);
                const nextHeight = Math.max(1, currentHeight / 2 | 0);
                const nextData = new Float16Array(nextWidth * nextHeight * 4);

                const getSrcPixel = (x: number, y: number): Float16Array => {
                    const offset = (y * currentWidth + x) * 4;
                    return currentData.slice(offset, offset + 4);
                };

                for (let y = 0; y < nextHeight; ++y) {
                    for (let x = 0; x < nextWidth; ++x) {
                        // Compute texcoord of the center of the destination texel
                        const u = (x + 0.5) / nextWidth;
                        const v = (y + 0.5) / nextHeight;

                        // Compute the same texcoord in the source - 0.5 a pixel
                        const au = (u * currentWidth - 0.5);
                        const av = (v * currentHeight - 0.5);

                        // Compute the src top left texel coord
                        const tx = au | 0;
                        const ty = av | 0;

                        // Compute the mix amounts between pixels
                        const t1 = au % 1;
                        const t2 = av % 1;

                        // Get the 4 pixels
                        const tl = getSrcPixel(tx, ty);
                        const tr = getSrcPixel(tx + 1, ty);
                        const bl = getSrcPixel(tx, ty + 1);
                        const br = getSrcPixel(tx + 1, ty + 1);

                        // Copy the "sampled" result into the dest
                        const dstOffset = (y * nextWidth + x) * 4;
                        const filtered = bilinearFilter(tl, tr, bl, br, t1, t2);
                        nextData.set(filtered, dstOffset);
                    }
                }

                mips.push({ data: nextData, width: nextWidth, height: nextHeight });
                currentWidth = nextWidth;
                currentHeight = nextHeight;
                currentData = nextData;
            }

            return mips;
        };
        
        // Generate all mip levels
        const mips = generateMips(f16Array, img.width, img.height);
        this._mipLevelCount = mips.length;

        // Create texture with all mip levels
        this._gpuTexture = this.device.createTexture({
            size: [img.width, img.height],
            format: 'rgba16float',
            usage: GPUTextureUsage.TEXTURE_BINDING | 
            GPUTextureUsage.COPY_DST | 
            GPUTextureUsage.RENDER_ATTACHMENT,
            mipLevelCount: mips.length + 1 // +1 for base level
        });

        // Write base level
        this.device.queue.writeTexture(
            { texture: this._gpuTexture },
            f16Array.buffer,
            { bytesPerRow: img.width * 8 },
            { width: img.width, height: img.height }
        );

        // Write mip levels
        mips.forEach((mip, level) => {
            this.device.queue.writeTexture(
                { texture: this._gpuTexture, mipLevel: level + 1 },
                mip.data.buffer,
                { bytesPerRow: mip.width * 8 },
                { width: mip.width, height: mip.height }
            );
        });
    }

    /*

    async createRGBA16fFromRGBEData(data: HDRImageData) {

        
    
        const f16Buffer = new Float16Array(data.width * data.height * 4);
    
        let j = 0;
        for (let i = 0; i < data.data.length; i += 3) {
            f16Buffer[j + 0] = data.data[i + 0]!;
            f16Buffer[j + 1] = data.data[i + 1]!;
            f16Buffer[j + 2] = data.data[i + 2]!;
            f16Buffer[j + 3] = 1;
            j += 4;
        }
    
        this.device.queue.writeTexture(
            { texture: this._gpuTexture },
            f16Buffer.buffer,
            { bytesPerRow: data.width * 8 },
            { width: data.width, height: data.height }
        );
    
        await this.device.queue.onSubmittedWorkDone();
    }
    */


    /*

    private async copySourcesToCubeMap(device: GPUDevice, sources: Array<HTMLImageElement>) {

        let promises = Array<Promise<HTMLCanvasElement>>();
        sources.forEach((source, layer) => {
            promises[layer] = Texture.getTextureData(source, 4, Math.max(source.width, 1), Math.max(source.height, 1));
        });

        sources.forEach(async (source, layer) => {
            // Convert image to GPUCanvasContext
            const canvas = await promises[layer];
            
            device.queue.copyExternalImageToTexture(
                { source: canvas!, flipY: false },
                { texture: this._gpuTexture, origin: [0, 0, layer] },
                { width: source.width, height: source.height },
            );
        });
    }

    // Reconstruct GPUBuffer from BufferManager, necessary if BufferManager is resized
    reconstruct = () => {
        // Get size of first cube side image
        const source = this.scene.environmentMap.cubeSideImages[0];
        this.gpuTextureSize = new Vector(source ? source.width : 1, source ? source.height : 1, 6);

        this._gpuTexture = this.device.createTexture({
          format: 'rgba32float',
          size: this.gpuTextureSize,
          usage: GPUTextureUsage.TEXTURE_BINDING |
                 GPUTextureUsage.COPY_DST |
                 GPUTextureUsage.RENDER_ATTACHMENT,
        });

        this.copySourcesToCubeMap(this.device, this.scene.environmentMap.cubeSideImages);
    }

    */
   destroy = () => {
       // Destroy GPUTexture
       this._gpuTexture.destroy();
   }
}

