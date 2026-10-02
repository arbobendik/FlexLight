"use strict";

import { WebGPUAntialiasingType } from "../../webgpu/antialiasing/antialiasing-module";

export abstract class AntialiasingModule {
    abstract type: WebGPUAntialiasingType;

    // (Re)create canvas size dependent textures
    abstract createTexture(): void;
    // Antialias textureIn into the color attachment of framebufferOut
    abstract renderFrame(textureIn: WebGLTexture, framebufferOut: WebGLFramebuffer): void;
}
