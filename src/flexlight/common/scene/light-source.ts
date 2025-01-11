"use strict";

import { Vector } from "../lib/math";

export class LightSource {
    position: Vector<3>;
    intensity: number;
    variance: number;

    constructor(position: Vector<3>, intensity: number = 200, variance: number = 1) {
        this.position = position;
        this.intensity = intensity;
        this.variance = variance;
    }
}