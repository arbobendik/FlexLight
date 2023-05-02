
'use strict';

import { GLLib } from './gllib.js';

const FRAMES = 9;

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
    uniform sampler2D cache_5;
    uniform sampler2D cache_6;
    uniform sampler2D cache_7;
    uniform sampler2D cache_8;
    out vec4 out_color;

    void main () {
        ivec2 texel = ivec2(vec2(textureSize(cache_0, 0)) * clip_space);

        mat4 c0 = mat4(
            texelFetch(cache_1, texel, 0), 
            texelFetch(cache_2, texel, 0),
            texelFetch(cache_3, texel, 0),
            texelFetch(cache_4, texel, 0)
        );

        mat4 c1 = mat4(
            texelFetch(cache_5, texel, 0), 
            texelFetch(cache_6, texel, 0),
            texelFetch(cache_7, texel, 0),
            texelFetch(cache_8, texel, 0)
        );

        vec4 minRGB = vec4(1.0);
        vec4 maxRGB = vec4(0.0);
        
        for (int i = 0; i < 5; i++) {
            for (int j = 0; j < 5; j++) {
                if (length(vec2(i - 2, j - 2)) > 2.0) continue;
                vec4 p = texelFetch(cache_0, texel + ivec2(i - 2, j - 2), 0);
                minRGB = min(minRGB, p);
                maxRGB = max(maxRGB, p);
            }
        }
        
        out_color = texelFetch(cache_0, texel, 0);
        for (int i = 0; i < 4; i++) out_color += min(max(c0[i], minRGB), maxRGB);
        for (int i = 0; i < 4; i++) out_color += min(max(c1[i], minRGB), maxRGB);
        out_color /= 9.0;
    }
    `;
    #program;
    #tex = new Array (FRAMES);
    #textures = new Array (FRAMES);
    #vao;
    #vertexBuffer;
    #gl;

    #currentNum = 0;
    #randomVecs;

    constructor (gl) {
        this.#gl = gl;
        // Compile shaders and link them into program
        this.#program = GLLib.compile (gl, GLLib.postVertex, this.#shader);
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

        // Generate pseudo random vectors to prevent shaking.
        this.#randomVecs = this.genPseudoRandomVecsWith0Sum(FRAMES);
    }

    buildTexture = () => {
        this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.textureIn);
        this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
        GLLib.setTexParams(this.#gl);
        
        for (let i = 0; i < FRAMES; i++) {
            this.#gl.bindTexture(this.#gl.TEXTURE_2D, this.#textures[i]);
            this.#gl.texImage2D(this.#gl.TEXTURE_2D, 0, this.#gl.RGBA, this.#gl.canvas.width, this.#gl.canvas.height, 0, this.#gl.RGBA, this.#gl.UNSIGNED_BYTE, null);
            GLLib.setTexParams(this.#gl);
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

    jitter = (canvas) => {
        // Cycle through random vecs
        this.#currentNum = (this.#currentNum + 1) % FRAMES;
        // Scaling factor
        let scale = 0.3 / Math.min(canvas.width, canvas.height);
        // Return as easy to handle 2-dimensional vector
        return { x: this.#randomVecs[this.#currentNum][0] * scale, y: this.#randomVecs[this.#currentNum][1] * scale};
    }

    // Generate n d-dimensional pseudo random vectors that all add up to 0.
    genPseudoRandomVecsWith0Sum = (n) => {
        let vecs = new Array(n).fill(0).map(() => new Array(2));
        vecs[0] = [0, 1];
        vecs[1] = [1, 0];
        let combined = [1, 1];
        
        for (let i = 2; i < n; i++) {
            for (let j = 0; j < 2; j++) {
                let min = Math.max(- Math.min(i + 1, n - 1 - i), combined[j] - 1);
                let max = Math.min(Math.min(i + 1, n - 1 - i), combined[j] + 1);
                vecs[i][j] = 0.5 * ((max + min) + (max - min) * Math.sign(Math.random() - 0.5) * (Math.random() * 0.5) ** (1 / 2)) - combined[j];
                combined[j] += vecs[i][j];
            }
        }

        return vecs;
    }
}