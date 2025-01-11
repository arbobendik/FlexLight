"use strict";

import { TypedArray } from "../common/buffer/typed-array-view";
import { GPUBufferManager } from "../common/buffer/gpu-buffer-manager";
import { BufferManager } from "../common/buffer/buffer-manager";

export class WebGPUBufferManager<T extends TypedArray> extends GPUBufferManager {
    protected bufferManager: BufferManager<T>;

    private _gpuBuffer: GPUBuffer;
    get gpuBuffer() { return this._gpuBuffer; }
    
    private device: GPUDevice;
    private label: string;

    constructor(bufferManager: BufferManager<T>, device: GPUDevice, label: string = "") {
        super();
        // Save device for future use
        this.device = device;
        // Save buffer manager for future use
        this.bufferManager = bufferManager;
        // Save label for reference
        this.label = label;
        // Bind GPUBufferManager to BufferManager
        bufferManager.bindGPUBufferManager(this);
        // Create GPUBuffer
        this._gpuBuffer = device.createBuffer({ size: bufferManager.buffer.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST, label: label });
        // Copy data from buffer manager to GPUBuffer
        device.queue.writeBuffer(this._gpuBuffer, 0, this.bufferManager.bufferView);
    }

    // Reconstruct GPUBuffer from BufferManager, necessary if BufferManager is resized
    reconstruct = () => {
        // Destroy old GPUBuffer
        this._gpuBuffer.destroy();
        // Create GPUBuffer
        this._gpuBuffer = this.device.createBuffer({ size: this.bufferManager.buffer.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST, label: this.label });
        // Copy data from buffer manager to GPUBuffer
        this.device.queue.writeBuffer(this._gpuBuffer, 0, this.bufferManager.bufferView);
    }

    // Update GPUBuffer partially or fully from BufferManager if data has changed
    update = (byteOffset: number = 0, length: number = this.bufferManager.length) => {
        const elementOffset = byteOffset / this.bufferManager.viewConstructor.prototype.BYTES_PER_ELEMENT;
        this.device.queue.writeBuffer(this._gpuBuffer, byteOffset, this.bufferManager.bufferView, elementOffset, length);
    }

    destroy = () => {
        // Destroy GPUBuffer
        this._gpuBuffer.destroy();
        // Release GPUBufferManager from BufferManager
        this.bufferManager.releaseGPUBufferManager();
    }
}