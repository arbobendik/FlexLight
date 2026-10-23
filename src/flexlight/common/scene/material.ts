"use strict";

import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";
import { Vector } from "../lib/math";


export class Material {
    color: Vector<3>;
    emissive: Vector<3>;
    roughness: number;
    metallic: number;
    transmission: number;
    ior: number;
    absorption: Vector<3>;
    // Tint of the dielectric's reflectance at normal incidence and the factor scaling it, which change nothing at 1
    specularTint: Vector<3>;
    specularLevel: number;

    constructor(color: Vector<3> = new Vector(1, 1, 1), emissive: Vector<3> = new Vector(0, 0, 0), roughness: number = 0.5, metallic: number = 0, transmission: number = 0, ior: number = 1.5, absorption: Vector<3> = new Vector(1, 1, 1), specularTint: Vector<3> = new Vector(1, 1, 1), specularLevel: number = 1) {
        this.color = color;
        this.emissive = emissive;
        this.roughness = roughness;
        this.metallic = metallic;
        this.transmission = transmission;
        this.ior = ior;
        this.absorption = absorption;
        this.specularTint = specularTint;
        this.specularLevel = specularLevel;
    }
}

export class InstanceMaterial implements Material {
    // ColorR, ColorG, ColorB, EmissiveR, EmissiveG, EmissiveB, Roughness, Metallic, Transmission, IOR, AbsorptionR, AbsorptionG, AbsorptionB, SpecularTintR, SpecularTintG, SpecularTintB, SpecularLevel
    private readonly _materialFloatManager: BufferManager<Float32Array>;
    readonly materialArray: TypedArrayView<Float32Array>;

    constructor(materialFloatManager: BufferManager<Float32Array>, material: Material) {
        this._materialFloatManager = materialFloatManager;
        this.materialArray = this._materialFloatManager.allocateArray([
            // Color
            material.color.x, material.color.y, material.color.z, 0,

            // Emissive
            material.emissive.x, material.emissive.y, material.emissive.z,
            // Roughness
            material.roughness,

            // Metallic
            material.metallic,
            // Transmission
            material.transmission,
            // IOR
            material.ior, 0,

            // Absorption
            material.absorption.x, material.absorption.y, material.absorption.z, 0,

            // Specular tint
            material.specularTint.x, material.specularTint.y, material.specularTint.z,
            // Specular level
            material.specularLevel
        ]);
    }

    destroy(): void {
        this._materialFloatManager.freeArray(this.materialArray);
    }

    set color(color: Vector<3>) {
        this.materialArray[0] = color.x;
        this.materialArray[1] = color.y;
        this.materialArray[2] = color.z;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset, 3);
    }

    get color(): Vector<3> {
        return new Vector<3>(this.materialArray[0] ?? 1, this.materialArray[1] ?? 1, this.materialArray[2] ?? 1);
    }

    set emissive(emissive: Vector<3>) {
        this.materialArray[4] = emissive.x;
        this.materialArray[5] = emissive.y;
        this.materialArray[6] = emissive.z;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 4 * this.materialArray.BYTES_PER_ELEMENT, 3);
    }

    get emissive(): Vector<3> {
        return new Vector<3>(this.materialArray[4] ?? 0, this.materialArray[5] ?? 0, this.materialArray[6] ?? 0);
    }

    set roughness(roughness: number) {
        this.materialArray[7] = roughness;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 7 * this.materialArray.BYTES_PER_ELEMENT, 1);
    }

    get roughness(): number {
        return this.materialArray[7] ?? 0.5;
    }

    set metallic(metallic: number) {
        this.materialArray[8] = metallic;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 8 * this.materialArray.BYTES_PER_ELEMENT, 1);
    }

    get metallic(): number {
        return this.materialArray[8] ?? 0;
    }

    set transmission(transmission: number) {
        this.materialArray[9] = transmission;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 9 * this.materialArray.BYTES_PER_ELEMENT, 1);
    }

    get transmission(): number {
        return this.materialArray[9] ?? 0;
    }

    set ior(ior: number) {
        this.materialArray[10] = ior;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 10 * this.materialArray.BYTES_PER_ELEMENT, 1);
    }

    get ior(): number {
        return this.materialArray[10] ?? 1.5;
    }

    set absorption(absorption: Vector<3>) {
        this.materialArray[12] = absorption.x;
        this.materialArray[13] = absorption.y;
        this.materialArray[14] = absorption.z;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 12 * this.materialArray.BYTES_PER_ELEMENT, 3);
    }

    get absorption(): Vector<3> {
        return new Vector<3>(this.materialArray[12] ?? 1, this.materialArray[13] ?? 1, this.materialArray[14] ?? 1);
    }

    set specularTint(specularTint: Vector<3>) {
        this.materialArray[16] = specularTint.x;
        this.materialArray[17] = specularTint.y;
        this.materialArray[18] = specularTint.z;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 16 * this.materialArray.BYTES_PER_ELEMENT, 3);
    }

    get specularTint(): Vector<3> {
        return new Vector<3>(this.materialArray[16] ?? 1, this.materialArray[17] ?? 1, this.materialArray[18] ?? 1);
    }

    set specularLevel(specularLevel: number) {
        this.materialArray[19] = specularLevel;
        // Update gpu buffer if it exists
        this._materialFloatManager.gpuBufferManager?.update(this.materialArray.byteOffset + 19 * this.materialArray.BYTES_PER_ELEMENT, 1);
    }

    get specularLevel(): number {
        return this.materialArray[19] ?? 1;
    }
}