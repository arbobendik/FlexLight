'use strict';

import { WebGPUAntialiasingType } from "../webgpu/antialiasing/antialiasing-module";

export type StringAntialiasingType = "undefined" | "fxaa" | "taa";

export class Config {

  // Quality settings
  private _antialiasing: WebGPUAntialiasingType = "undefined";
  // String getter / setter for config ui
  get antialiasingAsString(): StringAntialiasingType { return String(this._antialiasing) as StringAntialiasingType; }
  set antialiasingAsString(value: StringAntialiasingType) { 
    if (value === "undefined") {
      this._antialiasing = undefined;
    } else {
      this._antialiasing = value as WebGPUAntialiasingType; 
    }
  }
  // Set as regular getter / setter
  get antialiasing(): WebGPUAntialiasingType { return this._antialiasing; }
  set antialiasing(value: WebGPUAntialiasingType) { this._antialiasing = value; }

  temporal: boolean = true;
  restir: boolean = false;
  // Duplication based decorrelation of ReSTIR, trades correlation artifacts for bias
  restirDecorrelation: boolean = false;
  // Spatial neighbours of ReSTIR (1 - 3), fewer trade quality for speed
  restirNeighbours: number = 3;
  tonemapping: boolean = true;
  renderResolution: number = 1;
  samplesPerPixel: number = 1;
  maxBounces: number = 7;
  maxReprojections: number = 32;
}
