'use strict';

import { GLLib } from './gllib.js';
import { Network } from './network.js';

export class FXAA {
    textureIn;

    #shader = Network.fetchSync("shaders/fxaa.glsl");
    #canvas;
    #program;
    #tex;
    #vao;
    #vertexBuffer;
    #gl;

    constructor (gl, canvas) {
        this.#gl = gl;
        this.#canvas = canvas;
        // Compile shaders and link them into program
        this.#program = GLLib.compile (gl, GLLib.postVertex, this.#shader);

        // Create post program buffers and uniforms
        this.#vao = gl.createVertexArray();
        this.textureIn = gl.createTexture();
        gl.bindVertexArray(this.#vao);
        gl.useProgram(this.#program);

        this.#tex = gl.getUniformLocation(this.#program, 'preRender');
        this.#vertexBuffer = gl.createBuffer();

        gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 2, gl.FLOAT, false, 0, 0);
        // Fill buffer with data for two verices
        gl.bindBuffer(gl.ARRAY_BUFFER, this.#vertexBuffer);
        gl.bufferData(gl.ARRAY_BUFFER, Float32Array.from([0,0,1,0,0,1,1,1,0,1,1,0]), gl.DYNAMIC_DRAW);

        this.createTexture();
    }

    createTexture = () => {
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
        this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#canvas.width, this.#canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
        GLLib.setTexParams(this.#gl);
    };

    renderFrame = () => {
        // Render to canvas now
        this.#gl.bindFramebuffer(this.#gl.FRAMEBUFFER, null);
        // Make pre rendered texture TEXTURE0
        this.#gl.activeTexture(this.#gl.TEXTURE0);
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
        // Switch program and vao
        this.#gl.useProgram(this.#program);
        this.#gl.bindVertexArray(this.#vao);
        // Pass pre rendered texture to shader
        this.#gl.uniform1i(this.#tex, 0);
        // Post processing drawcall
        this.#gl.drawArrays(this.#gl.TRIANGLES, 0, 6);
    }
}