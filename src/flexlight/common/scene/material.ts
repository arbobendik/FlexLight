"use strict";

import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";
import { Vector } from "../lib/math";


export class Material {
    // ColorR, ColorG, ColorB, Roughness, Metallic, Emissive, Transmission, IOR
    private static materialManager = new BufferManager(Float32Array);
    static readonly DEFAULT_MATERIAL: Material = new Material();
    readonly materialArray: TypedArrayView<Float32Array>;

    constructor(color: Vector<3> = new Vector<3>(255, 255, 255), roughness: number = 0.5, metallic: number = 0, emissive: number = 0, transmission: number = 0, ior: number = 1.5) {
        this.materialArray = Material.materialManager.allocateArray([color.x, color.y, color.z, roughness, metallic, emissive, transmission, ior]);
    }

    destroy(): void {
        Material.materialManager.freeArray(this.materialArray);
    }

    set color(color: Vector<3>) {
        this.materialArray[0] = color.x;
        this.materialArray[1] = color.y;
        this.materialArray[2] = color.z;
    }

    get color(): Vector<3> {
        return new Vector<3>(this.materialArray[0] ?? 255, this.materialArray[1] ?? 255, this.materialArray[2] ?? 255);
    }

    set roughness(roughness: number) {
        this.materialArray[3] = roughness;
    }

    get roughness(): number {
        return this.materialArray[3] ?? 0.5;
    }

    set metallic(metallic: number) {
        this.materialArray[4] = metallic;
    }

    get metallic(): number {
        return this.materialArray[4] ?? 0;
    }

    set emissive(emissive: number) {
        this.materialArray[5] = emissive;
    }

    get emissive(): number {
        return this.materialArray[5] ?? 0;
    }

    set transmission(transmission: number) {
        this.materialArray[6] = transmission;
    }

    get transmission(): number {
        return this.materialArray[6] ?? 0;
    }

    set ior(ior: number) {
        this.materialArray[7] = ior;
    }

    get ior(): number {
        return this.materialArray[7] ?? 1.5;
    }
}