"use strict";

import { Transform } from "./transform";
import { Material } from "./material";
import { Prototype } from "./prototype";

export class Instance {
    readonly prototype: Prototype;
    transform: Transform | undefined = undefined;
    material: Material | undefined = undefined;

    constructor(prototype: Prototype) {
        // Set prototype
        this.prototype = prototype;
    }
}