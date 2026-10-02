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
import PathtracerShader from "./shaders/pathtracer-fragment.glsl";

export class PathTracerWGL2 extends RendererWGL2 {
  readonly type: RendererType = "pathtracer";
  protected readonly shadingShader: string = CommonShader + PathtracerShader;
  protected readonly accumulate: boolean = true;

  // Create new PathTracer from canvas
  constructor (canvas: HTMLCanvasElement, scene: Scene, camera: Camera, config: Config) {
    super(scene, canvas, camera, config);
  }
}
