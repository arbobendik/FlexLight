"use strict";

import { AntialiasingModule } from "./antialiasing-module";
import { WebGPUAntialiasingType } from "../../webgpu/antialiasing/antialiasing-module";
import { bindTextures, createFullscreenProgram } from "../program";
// Ignore all shader imports, the bundler will handle them as intended.
// @ts-ignore
import FXAAShader from "../shaders/fxaa-fragment.glsl";

export class FXAA extends AntialiasingModule {
    readonly type: WebGPUAntialiasingType = "fxaa";
    private gl: WebGL2RenderingContext;
    private program: WebGLProgram;

    constructor(gl: WebGL2RenderingContext) {
        super();
        this.gl = gl;
        this.program = createFullscreenProgram(gl, FXAAShader);
    }

    // FXAA reads its input directly and owns no canvas size dependent textures
    createTexture = () => {};

    renderFrame = (textureIn: WebGLTexture, framebufferOut: WebGLFramebuffer) => {
        const gl = this.gl;
        gl.bindFramebuffer(gl.FRAMEBUFFER, framebufferOut);
        gl.useProgram(this.program);
        bindTextures(gl, this.program, ["input_texture", gl.TEXTURE_2D, textureIn]);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
    }
}
