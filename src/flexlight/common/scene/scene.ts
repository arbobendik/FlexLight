"use strict";

import { BVHArrays } from "./bvh.js";
import { IndexedInstanceBVH } from "./instance-bvh.js";
import { BufferManager } from "../buffer/buffer-manager.js";
import { Instance } from "./instance.js";
import { PointLight } from "./point-light.js";
import { POW32M1, Vector } from "../lib/math.js";

// 24 (3 vertices per triangle, 3 normals per triangle, 3 UVs per triangle)
const TRIANGLE_SIZE = 24;

export class Scene {
    // Triangle Offset, Vertex Offset, BVH Offset, Bounding Vertex Offset, Normal Offset, UV Offset, Transform Offset, Material Offset,
    // Normal Texture Offset, Albedo Texture Offset, Emissive Texture Offset, Roughness Texture Offset, Metallic Texture Offset
    // Global Triangle Offset
    private _instanceManager: BufferManager<Uint32Array>;
    get instanceManager () { return this._instanceManager; }
    // BVH structure: 0|1 BV BV B|I B|I B|I B|I
    private _instanceBVHManager: BufferManager<Uint32Array>;
    get instanceBVHManager () { return this._instanceBVHManager; }
    // Bounding vertices: Bx By Bz
    private _instanceBoundingVertexManager: BufferManager<Float32Array>;
    get instanceBoundingVertexManager () { return this._instanceBoundingVertexManager; }
    // Px Py Pz, intensity, variance
    private _pointLightManager: BufferManager<Float32Array>;
    get pointLightManager () { return this._pointLightManager; }
    
    private readonly instances: Set<Instance> = new Set();

    ambientLight: Vector<3> = new Vector(0.2, 0.2, 0.2);
    private readonly pointLights: Set<PointLight> = new Set();

    constructor(instances: Array<Instance> = []) {
        for (const instance of instances) this.instances.add(instance);
        this._instanceManager = new BufferManager(Uint32Array);
        this._instanceBVHManager = new BufferManager(Uint32Array);
        this._instanceBoundingVertexManager = new BufferManager(Float32Array);
        this._pointLightManager = new BufferManager(Float32Array);
    }

    updateBuffers = (): number => {
        const instanceArray: Array<number> = [];
        let globalTriangleIndexOffset: number = 0;

        // Add debug logging
        // console.log("Instance buffer construction:");
        
        for (let instance of this.instances) {
            const triangleCount = instance.prototype.triangles.length / TRIANGLE_SIZE;
            
            // Debug log for each instance
            /*
            console.log(`Instance:
                Triangle offset: ${instance.prototype.triangles.offset}
                Triangle count: ${triangleCount}
                Global index offset: ${globalTriangleIndexOffset}
            `);
            */

            instanceArray.push(
                instance.prototype.triangles.offset,
                instance.prototype.bvh.offset,
                instance.prototype.boundingVertices.offset,
                instance.transform?.transformArray.offset ?? 0,
                instance.material?.materialArray.offset ?? 0,
                instance.normal?.textureInstanceBuffer?.offset ?? POW32M1,
                instance.albedo?.textureInstanceBuffer?.offset ?? POW32M1,
                instance.emissive?.textureInstanceBuffer?.offset ?? POW32M1,
                instance.roughness?.textureInstanceBuffer?.offset ?? POW32M1,
                instance.metallic?.textureInstanceBuffer?.offset ?? POW32M1,
                globalTriangleIndexOffset  // Store first triangle index
            );

            globalTriangleIndexOffset += triangleCount;
        }

        // Debug log final buffer
        // console.log("Final instance array:", instanceArray);
        // console.log("Total triangle count:", globalTriangleIndexOffset);

        this._instanceManager.overwriteAll(instanceArray);
        return globalTriangleIndexOffset;
    }

    // Add instance to scene
    addInstance(instance: Instance) {
        this.instances.add(instance);
    }

    // Remove instance from scene
    removeInstance(instance: Instance) {
        this.instances.delete(instance);
    }

    // Add point light to scene
    addPointLight(pointLight: PointLight) {
        this.pointLights.add(pointLight);
    }

    // Remove point light from scene
    removePointLight(pointLight: PointLight) {
        this.pointLights.delete(pointLight);
    }
}