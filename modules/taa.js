
'use strict';

import { GLLib } from './gllib.js';

const FRAMES = 5;

export class TAA {
    textureIn;
    #shader = `#version 300 es
    precision highp float;
    in vec2 clip_space;
    uniform sampler2D cache_0;
    uniform sampler2D cache_1;
    uniform sampler2D cache_2;
    uniform sampler2D cache_3;
    uniform sampler2D cache_4;
    out vec4 out_color;

    void main () {
        ivec2 texel = ivec2(vec2(textureSize(cache_0, 0)) * clip_space);

        mat4 c = mat4(
            texelFetch(cache_1, texel + ivec2(0, 0), 0), 
            texelFetch(cache_2, texel + ivec2(0, 0), 0),
            texelFetch(cache_3, texel + ivec2(0, 0), 0),
            texelFetch(cache_4, texel + ivec2(0, 0), 0)
        );

        vec4 minRGB = vec4(1.0);
        vec4 maxRGB = vec4(0.0);
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                vec4 p = texelFetch(cache_0, texel + ivec2(i - 1, j - 1), 0);
                minRGB = min(minRGB, p);
                maxRGB = max(maxRGB, p);
            }
        }
        
        out_color = texelFetch(cache_0, texel, 0);
        for (int i = 0; i < 4; i++) out_color += min(max(c[i], minRGB), maxRGB);
        out_color /= 5.0;
    }
    `;
    #program;
    #tex = new Array (FRAMES);
    #textures = new Array (FRAMES);
    #vao;
    #vertexBuffer;
    #gl;

    constructor (gl) {
        this.#gl = gl;
        // Compile shaders and link them into program
        this.#program = GLLib.buildProgram(gl, [
            { source: GLLib.blankGlsl, type: gl.VERTEX_SHADER },
            { source: this.#shader, type: gl.FRAGMENT_SHADER }
        ]);
        // Create post program buffers and uniforms
        this.#vao = gl.createVertexArray();
        this.textureIn = gl.createTexture();
        gl.bindVertexArray(this.#vao);
        gl.useProgram(this.#program);

        for (let i = 0; i < FRAMES; i++) this.#textures[i] = gl.createTexture();
        for (let i = 0; i < FRAMES; i++) this.#tex[i] = gl.getUniformLocation(this.#program, 'cache_' + i);
        this.#vertexBuffer = gl.createBuffer();

        gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices
        gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), gl.DYNAMIC_DRAW);

        this.buildTexture();
    }

    buildTexture = () => {
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
        this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
        this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
        this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
        this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
        this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);

        for (let i = 0; i < FRAMES; i++) {
            this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textures[i]);
            this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
            this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MIN_FILTER, this.#gl.NEAREST);
            this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_MAG_FILTER, this.#gl.NEAREST);
            this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_S, this.#gl.CLAMP_TO_EDGE);
            this.#gl.texParameteri(this.#gl.TEXTURE_2D, this.#gl.TEXTURE_WRAP_T, this.#gl.CLAMP_TO_EDGE);
        }
    };

    renderFrame = () => {
        // Rotate textures, delete last, add new
        this.#textures.unshift(this.textureIn);
        this.textureIn = this.#textures.pop();
        // Render to canvas now
        this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
        for (let i = 0; i < FRAMES; i++) {
            // Make pre rendered texture TEXTUREI
            this.#gl.activeTexture(this.#gl.TEXTURE0 + i);
            this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textures[i]);
        }
        // Switch program and vao
        this.#gl.useProgram(this.#program);
        this.#gl.bindVertexArray(this.#vao);
        // Pass pre rendered texture to shader
        for (let i = 0; i < FRAMES; i++) this.#gl.uniform1i(this.#tex[i], i);
        // Post processing drawcall
        this.#gl.drawArrays(this.#gl.TRIANGLES, 0, 6);
    }
}