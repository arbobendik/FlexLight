"use strict";

import { TypedArray } from "../../common/buffer/typed-array-view";
import { BufferToGPU } from "../../common/buffer/buffer-to-gpu";
import { BufferManager } from "../../common/buffer/buffer-manager";

type UploadArray = Uint8Array | Uint16Array | Uint32Array | Float32Array;

export interface TextureFormatWGL2 {
    internalFormat: GLenum;
    format: GLenum;
    type: GLenum;
    channels: number;
    // Typed array WebGL2 expects for type, half floats are uploaded as their Uint16Array bit pattern
    arrayConstructor: { new (length: number): UploadArray, new (buffer: ArrayBufferLike, byteOffset: number, length: number): UploadArray };
}

export const R32UI: TextureFormatWGL2 = { internalFormat: WebGL2RenderingContext.R32UI, format: WebGL2RenderingContext.RED_INTEGER, type: WebGL2RenderingContext.UNSIGNED_INT, channels: 1, arrayConstructor: Uint32Array };
export const RGBA8UI: TextureFormatWGL2 = { internalFormat: WebGL2RenderingContext.RGBA8UI, format: WebGL2RenderingContext.RGBA_INTEGER, type: WebGL2RenderingContext.UNSIGNED_BYTE, channels: 4, arrayConstructor: Uint8Array };
export const RGBA16F: TextureFormatWGL2 = { internalFormat: WebGL2RenderingContext.RGBA16F, format: WebGL2RenderingContext.RGBA, type: WebGL2RenderingContext.HALF_FLOAT, channels: 4, arrayConstructor: Uint16Array };
export const RGBA32UI: TextureFormatWGL2 = { internalFormat: WebGL2RenderingContext.RGBA32UI, format: WebGL2RenderingContext.RGBA_INTEGER, type: WebGL2RenderingContext.UNSIGNED_INT, channels: 4, arrayConstructor: Uint32Array };
export const RGBA32F: TextureFormatWGL2 = { internalFormat: WebGL2RenderingContext.RGBA32F, format: WebGL2RenderingContext.RGBA, type: WebGL2RenderingContext.FLOAT, channels: 4, arrayConstructor: Float32Array };

// Shaders address texel i at (i & 0x7FF, (i >> 11) & 0x7FF, i >> 22)
const TEXTURE_WIDTH: number = 2048;
const TEXTURE_HEIGHT: number = 2048;

// WebGL2 has no storage buffers, so every buffer is mirrored into a 2d array texture
export class BufferToTexture<T extends TypedArray> extends BufferToGPU {
    protected bufferManager: BufferManager<T>;

    private _texture: WebGLTexture;
    get gpuResource() { return this._texture; }

    private gl: WebGL2RenderingContext;
    private textureFormat: TextureFormatWGL2;
    // Allocated rows per layer and layer count, only as many rows as needed are allocated for single layer textures
    private rows: number = 0;
    private layers: number = 0;

    constructor(bufferManager: BufferManager<T>, gl: WebGL2RenderingContext, textureFormat: TextureFormatWGL2) {
        super();
        this.gl = gl;
        this.bufferManager = bufferManager;
        this.textureFormat = textureFormat;
        // Bind texture to BufferManager
        bufferManager.bindGPUBuffer(this);
        this._texture = gl.createTexture();
        this.reconstruct();
    }

    // Reallocate texture if BufferManager outgrew it and upload all data
    reconstruct = () => {
        const gl = this.gl;
        const rows = Math.max(1, Math.ceil(this.bufferManager.length / (this.textureFormat.channels * TEXTURE_WIDTH)));
        if (rows > this.rows * this.layers) {
            this.layers = Math.ceil(rows / TEXTURE_HEIGHT);
            this.rows = Math.min(rows, TEXTURE_HEIGHT);
            gl.bindTexture(gl.TEXTURE_2D_ARRAY, this._texture);
            gl.texImage3D(gl.TEXTURE_2D_ARRAY, 0, this.textureFormat.internalFormat, TEXTURE_WIDTH, this.rows, this.layers, 0, this.textureFormat.format, this.textureFormat.type, null);
            gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
            gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
        }
        this.update(0, this.bufferManager.length);
    }

    // Upload all texture rows touched by length elements starting at byteOffset
    update = (byteOffset: number = 0, length: number = this.bufferManager.length) => {
        const gl = this.gl;
        const { format, type, channels, arrayConstructor } = this.textureFormat;
        const rowLength = channels * TEXTURE_WIDTH;
        const view = this.bufferManager.bufferView;
        const elementOffset = byteOffset / view.BYTES_PER_ELEMENT;
        const firstRow = Math.floor(elementOffset / rowLength);
        const endRow = Math.max(firstRow + 1, Math.ceil((elementOffset + length) / rowLength));
        // Pad partial rows, as only whole rows are uploaded
        const source = new arrayConstructor((endRow - firstRow) * rowLength);
        source.set(new arrayConstructor(view.buffer, view.byteOffset, view.length).subarray(firstRow * rowLength, endRow * rowLength));

        gl.bindTexture(gl.TEXTURE_2D_ARRAY, this._texture);
        for (let row = firstRow; row < endRow;) {
            const y = row % TEXTURE_HEIGHT;
            const rowCount = Math.min(endRow - row, TEXTURE_HEIGHT - y);
            gl.texSubImage3D(gl.TEXTURE_2D_ARRAY, 0, 0, y, Math.floor(row / TEXTURE_HEIGHT), TEXTURE_WIDTH, rowCount, 1, format, type, source, (row - firstRow) * rowLength);
            row += rowCount;
        }
    }

    destroy = () => {
        // Delete texture
        this.gl.deleteTexture(this._texture);
        // Release texture from BufferManager
        this.bufferManager.releaseGPUBuffer();
    }
}
