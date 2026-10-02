"use strict";

import { Vector, vector_scale } from "../../common/lib/math";
import { AntialiasingModule } from "./antialiasing-module";
import { WebGPUAntialiasingType } from "../../webgpu/antialiasing/antialiasing-module";
import { bindTextures, createFullscreenProgram } from "../program";
// Ignore all shader imports, the bundler will handle them as intended.
// @ts-ignore
import TAAShader from "../shaders/taa-fragment.glsl";

const FRAMES: number = 8;

const halton = (index: number, base: number): number => {
    let result: number = 0;
    let f: number = 1;
    while (index > 0) {
        f = f / base;
        result = result + f * (index % base);
        index = Math.floor(index / base);
    }
    return result;
};

export class TAA extends AntialiasingModule {
    readonly type: WebGPUAntialiasingType = "taa";
    private gl: WebGL2RenderingContext;
    private canvas: HTMLCanvasElement;
    private program: WebGLProgram;
    private frameIndex: number = 0;
    // Halton sequence with base 2 for x and base 3 for y coordinate
    private randomVecs: Array<Vector<2>> = Array.from({ length: FRAMES }, (_, i) => new Vector(halton(i, 2) - 0.5, halton(i, 3) - 0.5));
    // History of the last FRAMES frames, one per layer
    private texture: WebGLTexture;
    // Framebuffers to blit the current frame into its history layer
    private readFramebuffer: WebGLFramebuffer;
    private drawFramebuffer: WebGLFramebuffer;

    constructor(gl: WebGL2RenderingContext, canvas: HTMLCanvasElement) {
        super();
        this.gl = gl;
        this.canvas = canvas;
        this.program = createFullscreenProgram(gl, TAAShader);
        this.texture = gl.createTexture();
        this.readFramebuffer = gl.createFramebuffer();
        this.drawFramebuffer = gl.createFramebuffer();
        this.createTexture();
    }

    createTexture = () => {
        const gl = this.gl;
        gl.bindTexture(gl.TEXTURE_2D_ARRAY, this.texture);
        gl.texImage3D(gl.TEXTURE_2D_ARRAY, 0, gl.RGBA32F, this.canvas.width, this.canvas.height, FRAMES, 0, gl.RGBA, gl.FLOAT, null);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
        gl.texParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
    };

    renderFrame = (textureIn: WebGLTexture, framebufferOut: WebGLFramebuffer) => {
        const gl = this.gl;
        this.frameIndex = (this.frameIndex + 1) % FRAMES;
        // Copy current frame into its history layer
        gl.bindFramebuffer(gl.READ_FRAMEBUFFER, this.readFramebuffer);
        gl.framebufferTexture2D(gl.READ_FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, textureIn, 0);
        gl.bindFramebuffer(gl.DRAW_FRAMEBUFFER, this.drawFramebuffer);
        gl.framebufferTextureLayer(gl.DRAW_FRAMEBUFFER, gl.COLOR_ATTACHMENT0, this.texture, 0, this.frameIndex);
        gl.blitFramebuffer(0, 0, this.canvas.width, this.canvas.height, 0, 0, this.canvas.width, this.canvas.height, gl.COLOR_BUFFER_BIT, gl.NEAREST);
        // Blend history into output
        gl.bindFramebuffer(gl.FRAMEBUFFER, framebufferOut);
        gl.useProgram(this.program);
        bindTextures(gl, this.program, ["input_texture", gl.TEXTURE_2D_ARRAY, this.texture]);
        gl.uniform1i(gl.getUniformLocation(this.program, "frame_index"), this.frameIndex);
        gl.uniform1i(gl.getUniformLocation(this.program, "frames"), FRAMES);
        gl.drawArrays(gl.TRIANGLES, 0, 3);
    }

    // Jitter of the frame rendered next, which renderFrame will store at frameIndex + 1
    jitter = (): Vector<2> => {
        let frameIndex = (this.frameIndex + 1) % FRAMES;
        let scale = 0.4 / Math.min(this.canvas.width, this.canvas.height);
        return vector_scale(this.randomVecs[frameIndex]!, scale);
    }
}
