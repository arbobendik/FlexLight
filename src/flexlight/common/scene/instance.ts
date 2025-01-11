"use strict";

import { Transform } from "./transform";
import { Material } from "./material";
import { Prototype } from "./prototype";
import { NormalTexture } from "./texture";

export class Instance {
    readonly prototype: Prototype;
    transform: Transform | undefined = undefined;
    material: Material | undefined = undefined;

    // Texture instances
    normal: NormalTexture | undefined = undefined;
    albedo: Texture<3> | undefined = undefined;
    emissive: Texture<3> | undefined = undefined;
    roughness: Texture<1> | undefined = undefined;
    metallic: Texture<1> | undefined = undefined;

    constructor(prototype: Prototype) {
        // Set prototype
        this.prototype = prototype;
    }
}