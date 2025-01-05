"use strict";

import { Vector } from "../lib/math";

export interface Material {
    color: Vector<3>;
    roughness: number;
    metallic: number;
    emissive: number;

    transmission: number;
    // density: number;
    ior: number;
}