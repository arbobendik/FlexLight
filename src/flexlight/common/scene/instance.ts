"use strict";

import { Transform } from "./transform";
import { Material } from "./material";
import { Prototype } from "./prototype";
import { Vector } from "../lib/math";

export class Instance {
    transform: Transform | undefined = undefined;
    material: Material = {
        color: new Vector<3>(255, 255, 255),
        roughness: 0.5, metallic: 0, emissive: 0,
        transmission: 0, ior: 1.5
    };
    prototype: Prototype;

    constructor(prototype: Prototype) {
        this.prototype = prototype;
    }
}