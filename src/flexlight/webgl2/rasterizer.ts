"use strict";

import { RendererType } from "../common/renderer.js";
import { RendererWGL2 } from "./renderer-webgl2.js";
import { Scene } from "../common/scene/scene.js";
import { Camera } from "../common/scene/camera.js";
import { Config } from "../common/config.js";
// Ignore all shader imports, the bundler will handle them as intended.
// @ts-ignore
import CommonShader from "./shaders/common.glsl";
// @ts-ignore
import RasterizerShader from "./shaders/rasterizer-fragment.glsl";

export class RasterizerWGL2 extends RendererWGL2 {
  readonly type: RendererType = "rasterizer";
  protected readonly shadingShader: string = CommonShader + RasterizerShader;
  // Like its WebGPU counterpart the rasterizer does not average frames
  protected readonly accumulate: boolean = false;

  // Create new Rasterizer from canvas
  constructor (canvas: HTMLCanvasElement, scene: Scene, camera: Camera, config: Config) {
    super(scene, canvas, camera, config);
  }
}
