"use strict";

import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";

type Channels = 1 | 2 | 3 | 4;


interface TextureTypeProperties<T extends Channels> {
    channels: T;
    textureTypeInstances: Set<Texture<T>>;
    textureInstanceManager: BufferManager<Uint32Array>;
    textureDataManager: BufferManager<Uint8Array>;
}

class Texture<T extends Channels> {
    readonly texture: HTMLImageElement;
    readonly width: number;
    readonly height: number;

    // Save texture type properties
    private readonly properties: TextureTypeProperties<T>;
    // Width, height, channels, dataOffset
    private _textureInstanceBuffer: TypedArrayView<Uint32Array> | undefined;
    get textureInstanceBuffer(): TypedArrayView<Uint32Array> | undefined { return this._textureInstanceBuffer; }
    // Texture data buffer
    private _textureDataBuffer: TypedArrayView<Uint8Array> | undefined;
    // get textureDataBuffer(): TypedArrayView<Uint8Array> | undefined { return this._textureDataBuffer; }

    private static async getTextureData(texture: HTMLImageElement, width: number, height: number, channels: Channels): Promise<Uint8Array> {
        // Create canvas, draw image and return bitmap
        const canvas = document.createElement("canvas");
        const ctx: CanvasRenderingContext2D | null = canvas.getContext("2d"); 
        if (!ctx) throw new Error("Failed to get canvas context");
        canvas.width = width;
        canvas.height = height;
        // Disable image smoothing to get non-blury pixel values in given resolution
        ctx.imageSmoothingEnabled = false;
        ctx.drawImage(texture, 0, 0, width, height);
        // Read pixels from canvas
        const imageData = ctx.getImageData(0, 0, width, height);
        // Construct array of pixel values
        const array: Array<number> = [];
        for (let i = 0; i < imageData.data.length; i += 4) for (let j = 0; j < channels; j++) array.push(imageData.data[i + j]!);
        // Return as Uint8Array view.
        return new Uint8Array(array);
    }

    constructor (properties: TextureTypeProperties<T>, texture: HTMLImageElement, width: number | undefined = undefined, height: number | undefined = undefined) {
        this.texture = texture;
        this.width = width ?? texture.width;
        this.height = height ?? texture.height;
        // Save texture type properties
        this.properties = properties;
        // Get texture data
        Texture.getTextureData(texture, this.width, this.height, properties.channels).then((array: Uint8Array) => {
            this._textureDataBuffer = properties.textureDataManager.allocateArray(array);
            this._textureInstanceBuffer = properties.textureInstanceManager.allocateArray(new Uint32Array([this.width, this.height, properties.channels, this._textureDataBuffer.offset]));
        });
        // Add texture instance to texture type instances
        properties.textureTypeInstances.add(this);
    }

    destroy() {
        // Remove texture instance from texture type instances
        this.properties.textureTypeInstances.delete(this);
        // Substract length of this texture from all saved offsets of textures after this one
        for (let instance of this.properties.textureTypeInstances) {
            if (this._textureInstanceBuffer && instance._textureInstanceBuffer && instance._textureInstanceBuffer.offset > this._textureInstanceBuffer.offset) {
                instance._textureInstanceBuffer[3]! -= this._textureInstanceBuffer.length;   
            }
        }
        // Free buffers if they exist
        if (this._textureDataBuffer) this.properties.textureDataManager.freeArray(this._textureDataBuffer);
        if (this._textureInstanceBuffer) this.properties.textureInstanceManager.freeArray(this._textureInstanceBuffer);
    }
}


export class NormalTexture extends Texture<3> {
    private static textureTypeProperties: TextureTypeProperties<3> = {
        channels: 3,
        textureTypeInstances: new Set(),
        textureInstanceManager: new BufferManager(Uint32Array),
        textureDataManager: new BufferManager(Uint8Array),
    }

    constructor(texture: HTMLImageElement, width: number, height: number) {
        super(NormalTexture.textureTypeProperties, texture, width, height);
    }
}

export class AlbedoTexture extends Texture<3> {
    private static textureTypeProperties: TextureTypeProperties<3> = {
        channels: 3,
        textureTypeInstances: new Set(),
        textureInstanceManager: new BufferManager(Uint32Array),
        textureDataManager: new BufferManager(Uint8Array),
    }

    constructor(texture: HTMLImageElement, width: number, height: number) {
        super(AlbedoTexture.textureTypeProperties, texture, width, height);
    }
}

export class EmissiveTexture extends Texture<3> {
    private static textureTypeProperties: TextureTypeProperties<3> = {
        channels: 3,
        textureTypeInstances: new Set(),
        textureInstanceManager: new BufferManager(Uint32Array),
        textureDataManager: new BufferManager(Uint8Array),
    }

    constructor(texture: HTMLImageElement, width: number, height: number) {
        super(EmissiveTexture.textureTypeProperties, texture, width, height);
    }
}

export class RoughnessTexture extends Texture<1> {
    private static textureTypeProperties: TextureTypeProperties<1> = {
        channels: 1,
        textureTypeInstances: new Set(),
        textureInstanceManager: new BufferManager(Uint32Array),
        textureDataManager: new BufferManager(Uint8Array),
    }

    constructor(texture: HTMLImageElement, width: number, height: number) {
        super(RoughnessTexture.textureTypeProperties, texture, width, height);
    }
}

export class MetallicTexture extends Texture<1> {
    private static textureTypeProperties: TextureTypeProperties<1> = {
        channels: 1,
        textureTypeInstances: new Set(),
        textureInstanceManager: new BufferManager(Uint32Array),
        textureDataManager: new BufferManager(Uint8Array),
    }

    constructor(texture: HTMLImageElement, width: number, height: number) {
        super(MetallicTexture.textureTypeProperties, texture, width, height);
    }
}