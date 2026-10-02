"use strict";

import { Scene } from "../common/scene/scene";
import { EnvironmentMap } from "../common/scene/environment-map";

export class EnvironmentMapWebGL2 {
    private _texture: WebGLTexture;
    get gpuResource() { return this._texture; }

    private _mipLevelCount: number;
    get mipLevelCount() { return this._mipLevelCount; }
    // Environment map the texture was created from
    readonly source: EnvironmentMap;

    constructor(gl: WebGL2RenderingContext, scene: Scene) {
        const source = scene.environmentMap;
        this.source = source;
        const width = source.imageSize.x;
        const height = source.imageSize.y;
        // Expand RGB to RGBA, as only RGBA16F is color renderable for mipmap generation
        const rgba = new Float16Array(width * height * 4);
        for (let i = 0, j = 0; i < source.imageArray.length; i += 3, j += 4) {
            rgba[j] = source.imageArray[i]!;
            rgba[j + 1] = source.imageArray[i + 1]!;
            rgba[j + 2] = source.imageArray[i + 2]!;
            rgba[j + 3] = 1;
        }
        // Mip levels below base level, matching the WebGPU implementation
        this._mipLevelCount = Math.floor(Math.log2(Math.max(width, height)));

        this._texture = gl.createTexture();
        gl.bindTexture(gl.TEXTURE_2D, this._texture);
        // WebGL2 expects half floats as their Uint16Array bit pattern
        gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA16F, width, height, 0, gl.RGBA, gl.HALF_FLOAT, new Uint16Array(rgba.buffer));
        gl.generateMipmap(gl.TEXTURE_2D);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
        gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
    }
}
