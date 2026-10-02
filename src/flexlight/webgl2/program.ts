"use strict";

// Ignore all shader imports, the bundler will handle them as intended.
// @ts-ignore
import FullscreenVertexShader from "./shaders/fullscreen-vertex.glsl";

export type TextureBinding = [name: string, target: GLenum, texture: WebGLTexture];

const compileShader = (gl: WebGL2RenderingContext, type: GLenum, source: string): WebGLShader => {
    const shader = gl.createShader(type)!;
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) throw new Error("Failed to compile shader: " + gl.getShaderInfoLog(shader));
    return shader;
};

export const createProgram = (gl: WebGL2RenderingContext, vertexSource: string, fragmentSource: string): WebGLProgram => {
    const program = gl.createProgram();
    gl.attachShader(program, compileShader(gl, gl.VERTEX_SHADER, vertexSource));
    gl.attachShader(program, compileShader(gl, gl.FRAGMENT_SHADER, fragmentSource));
    gl.linkProgram(program);
    if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error("Failed to link program: " + gl.getProgramInfoLog(program));
    return program;
};

// Programs of fullscreen passes draw one attribute-less triangle covering the viewport
export const createFullscreenProgram = (gl: WebGL2RenderingContext, fragmentSource: string): WebGLProgram => createProgram(gl, FullscreenVertexShader, fragmentSource);

// Bind textures to consecutive texture units and point the samplers of the active program at them
export const bindTextures = (gl: WebGL2RenderingContext, program: WebGLProgram, ...textures: Array<TextureBinding>) => {
    textures.forEach(([name, target, texture], unit) => {
        gl.activeTexture(gl.TEXTURE0 + unit);
        gl.bindTexture(target, texture);
        gl.uniform1i(gl.getUniformLocation(program, name), unit);
    });
};
