"use strict";

import { Transform } from "./transform";
import { Material } from "./material";
import { Prototype } from "./prototype";

export class Instance {
    transform: Transform | undefined = undefined;
    material: Material | undefined = undefined;
    prototype: Prototype;

    constructor(prototype: Prototype) {
        this.prototype = prototype;
    }
}