"use strict";

import { BufferToGPU } from "../buffer/buffer-to-gpu";
import { Vector } from "../lib/math";
import { decodeRGBE } from "./hdri";


export interface EnvironmentMap {
    // imageData: ImageData;
    imageArray: Float16Array;
    imageSize: Vector<2>;
    gamma: number;
    exposure: number;
}

export class EnvironmentMap implements EnvironmentMap {
    constructor(dataView: DataView, exposure: number = 1, gamma: number = 1, whitePoint: number = 16) {

        // console.log(DataView.prototype.buffer);
        
        const hdriData = decodeRGBE(dataView);
        this.exposure = exposure * hdriData.exposure;
        this.gamma = gamma * hdriData.gamma;
        this.imageArray = new Float16Array(hdriData.data.length);

        for (let i = 0, j = 0; i < hdriData.data.length; i += 3, j += 3) {
            this.imageArray[j] = Math.pow(hdriData.data[i]! * this.exposure, 1 / this.gamma);
            this.imageArray[j + 1] = Math.pow(hdriData.data[i + 1]! * this.exposure, 1 / this.gamma);
            this.imageArray[j + 2] = Math.pow(hdriData.data[i + 2]! * this.exposure, 1 / this.gamma);
        }

        // Clamp to max float16
        for (let i = 0; i < this.imageArray.length; i ++) this.imageArray[i] = Math.min(Math.min(this.imageArray[i]!, whitePoint), 65519);

        // this.imageData = new ImageData(imageArray, hdriData.width, hdriData.height);
        this.imageSize = new Vector(hdriData.width, hdriData.height);
        /*
        var canvas = document.createElement('canvas');
        var ctx = canvas.getContext('2d')!;
        canvas.width = this.imageData.width;
        canvas.height = this.imageData.height;
        ctx.putImageData(this.imageData, 0, 0);

        var image = new Image();
        image.src = canvas.toDataURL();
        
        console.log("Environment map image: ", image);
        */
    }
}

export class EnvironmentMapManager {
    private _environmentMap: EnvironmentMap; 
    private _gpuBuffer: BufferToGPU | undefined = undefined;

    get environmentMap () { return this._environmentMap; }
    set environmentMap (environmentMap: EnvironmentMap) { 
        this._environmentMap = environmentMap;
    }

    constructor(environmentMap: EnvironmentMap | undefined = undefined) {
        this._environmentMap = environmentMap ?? { imageArray: new Float16Array([1, 1, 1]), imageSize: new Vector(1, 1), gamma: 1, exposure: 1 };
    }

    bindGPUBuffer(gpuBuffer: BufferToGPU) {
        if (this._gpuBuffer) throw new Error("EnvironmentMapManager.bindGPUBuffer(): GPUBuffer already bound");
        this._gpuBuffer = gpuBuffer;
    }

    releaseGPUBuffer() {
        this._gpuBuffer = undefined;
    }
}