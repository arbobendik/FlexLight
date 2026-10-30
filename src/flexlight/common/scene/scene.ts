"use strict";

import { BVHArrays } from "./bvh.js";
import { SceneBVH } from "./scene-bvh.js";
import { BufferManager } from "../buffer/buffer-manager.js";
import { Instance } from "./instance.js";
import { PointLight } from "./point-light.js";
import { POW32M1, Vector } from "../lib/math.js";
import { Prototype, TRIANGLE_SIZE } from "./prototype.js";
import { EnvironmentMap, EnvironmentMapManager } from "./environment-map.js";
import { packLightTree } from "./light-tree.js";

const sameNumbers = (a: Array<number>, b: Array<number>): boolean => a.length === b.length && a.every((value, i) => value === b[i]);

export class Scene {
    // Triangle Offset, Vertex Offset, BVH Offset, Bounding Vertex Offset, Normal Offset, UV Offset, Transform Offset, Material Offset,
    // Normal Texture Offset, Albedo Texture Offset, Emissive Texture Offset, Roughness Texture Offset, Metallic Texture Offset
    // Global Triangle Offset
    private _instanceUintManager: BufferManager<Uint32Array<ArrayBuffer>>;
    get instanceUintManager () { return this._instanceUintManager; }
    // Transform: Rotation, Shift
    private _instanceTransformManager: BufferManager<Float32Array<ArrayBuffer>>;
    get instanceTransformManager () { return this._instanceTransformManager; }
    // Material: Albedo, Roughness, Metallic, Emissive, Translucency, IOR
    private _instanceMaterialManager: BufferManager<Float32Array<ArrayBuffer>>;
    get instanceMaterialManager () { return this._instanceMaterialManager; }
    // BVH structure: 0|1 BV BV B|I B|I B|I B|I
    private _instanceBVHManager: BufferManager<Uint32Array<ArrayBuffer>>;
    get instanceBVHManager () { return this._instanceBVHManager; }
    // Bounding vertices: Bx By Bz
    private _instanceBoundingVertexManager: BufferManager<Float32Array<ArrayBuffer>>;
    get instanceBoundingVertexManager () { return this._instanceBoundingVertexManager; }
    // Px Py Pz, intensity, variance
    private _lightManager: BufferManager<Float32Array<ArrayBuffer>>;
    get lightManager () { return this._lightManager; }
    // Light BVH: header, nodes and trails as texels
    readonly lightTreeManager: BufferManager<Uint32Array<ArrayBuffer>> = new BufferManager(Uint32Array);
    // Instances, point lights, emission and transforms of emitting instances the light BVH was last built from
    private lightSignature: Array<number> = [];
    // Mean emission r + g + b per triangle of the instances with emissive textures, as the renderer computed it for the
    // triangles, emissive texture and first triangle of each, triangleEmissionKey. Stale while the instances' current
    // emissiveTextureKey differs, which holds the light BVH back until it is computed anew.
    triangleEmission: Float32Array = new Float32Array(0);
    triangleEmissionKey: Array<number> = [];
    emissiveTextureKey: Array<number> = [];
    triangleEmissionStale: boolean = false;
    // Light Count
    private _lightCount: number = 0;
    get lightCount () { return this._lightCount; }
    // Environment Map: Cube Side Images
    private _environmentMapManager: EnvironmentMapManager = new EnvironmentMapManager();
    get environmentMapManager () { return this._environmentMapManager; }

    // Point Light Count
    private _pointLightCount: number = 0;
    get pointLightCount () { return this._pointLightCount; }
    // Triangle Count
    // Whether an instance's material is translucent, which the path tracer compiles translucency in for alone
    get translucent () {
        for (const instance of this.instances) if (instance._material.translucent.x + instance._material.translucent.y + instance._material.translucent.z > 0) return true;
        return false;
    }

    // Whether an instance's material has a sheen, which the path tracer compiles sheen in for alone
    get sheen () {
        for (const instance of this.instances) if (instance._material.sheen.x + instance._material.sheen.y + instance._material.sheen.z > 0) return true;
        return false;
    }

    get triangleCount () {
        let count = 0;
        for (let instance of this.instances) count += instance.prototype.triangles.length / TRIANGLE_SIZE;
        return count;
    }

    private _instanceBVH: SceneBVH | undefined = undefined;
    get instanceBVH () {
        if (!this._instanceBVH) this._instanceBVH = SceneBVH.fromObjects(this.instances, this.pointLights);
        return this._instanceBVH;
    }
    
    private readonly instances: Set<Instance> = new Set();

    ambientLight: Vector<3> = new Vector(0.01, 0.01, 0.01);

    set environmentMap (environmentMap: EnvironmentMap) { this._environmentMapManager.environmentMap = environmentMap; }
    get environmentMap () { return this._environmentMapManager.environmentMap; }


    private readonly pointLights: Set<PointLight> = new Set([new PointLight(new Vector(0, 0, 0), new Vector(0, 0, 0), 0, 0)]);

    constructor(instances: Array<Instance> = []) {
        for (const instance of instances) this.instances.add(instance);
        this._instanceUintManager = new BufferManager(Uint32Array);
        this._instanceTransformManager = new BufferManager(Float32Array);
        this._instanceMaterialManager = new BufferManager(Float32Array);
        this._instanceBVHManager = new BufferManager(Uint32Array);
        this._instanceBoundingVertexManager = new BufferManager(Float32Array);
        this._lightManager = new BufferManager(Float32Array);
    }

    updateBuffers = (): number => {
        // Save emissive instances to append them to direct illumination buffer
        const emissiveInstanceList: Array<Instance> = [];
        const emissiveInstanceIDList: Array<number> = [];

        const instanceUintArray: Array<number> = [];
        const emissiveTextureKey: Array<number> = [];
        let globalTriangleIndexOffset: number = 0;

        // Construct instance uint array
        let instanceID: number = 0;
        for (let instance of this.instances) {
            const triangleCount = instance.prototype.triangles.length / TRIANGLE_SIZE;
            instanceUintArray.push(
                instance.prototype.triangles.offset / 4,
                instance.prototype.bvh.offset / 4,
                instance.prototype.boundingVertices.offset / 4,
                instance.albedo?.textureInstanceBufferId ?? POW32M1,
                instance.normal?.textureInstanceBufferId ?? POW32M1,
                instance.emissive?.textureInstanceBufferId ?? POW32M1,
                instance.roughness?.textureInstanceBufferId ?? POW32M1,
                instance.metallic?.textureInstanceBufferId ?? POW32M1,
                globalTriangleIndexOffset  // Store first triangle index
            );
            if (instance.emissive) emissiveTextureKey.push(instance.prototype.triangles.offset / 4, instance.emissive.textureInstanceBufferId, globalTriangleIndexOffset);
            globalTriangleIndexOffset += triangleCount;

            // If instance is emissive, save it to emissive instance list, ignore emissive textures for now.
            // TODO: Support emissive textures
            if (instance.material.emissive.x > 0 || instance.material.emissive.y > 0 || instance.material.emissive.z > 0) {
                emissiveInstanceList.push(instance);
                emissiveInstanceIDList.push(instanceID);
            }

            instanceID++;
        }

        // Allocate instance buffer
        this._instanceUintManager.overwriteAll(instanceUintArray);

        // Generate BVH
        this._instanceBVH = SceneBVH.fromObjects(this.instances, this.pointLights);

        // console.log(this._instanceBVH);
        // Generate bounding vertices and BVH structure
        const bvhArrays: BVHArrays = this._instanceBVH.toArrays();
        // Allocate BVH buffers
        this._instanceBVHManager.overwriteAll(bvhArrays.bvh);
        this._instanceBoundingVertexManager.overwriteAll(bvhArrays.boundingVertices);

        // Update light count
        this._lightCount = this.pointLightCount + emissiveInstanceList.length;

        // Construct point light buffer
        const lightArray: Array<number> = [];
        for (let pointLight of this.pointLights) lightArray.push(
            pointLight.position.x, pointLight.position.y, pointLight.position.z, 0,
            pointLight.color.x, pointLight.color.y, pointLight.color.z, pointLight.intensity,
            pointLight.variance, 0, 0, 0
        );
        // Append emissive instances to light buffer
        for (let i = 0; i < emissiveInstanceList.length; i++) {
            const instance = emissiveInstanceList[i]!;
            const instanceID = emissiveInstanceIDList[i]!;
            const triangleCount = instance.prototype.triangles.length / TRIANGLE_SIZE;

            // const scaleFa
            // const surfaceArea = instance.prototype.surfaceArea * instance.prototype.triangles.length / 3;
            lightArray.push(
                // instance ID, triangle count, 0, is_area_light_indicator
                // Maybe include area heuristic here later as well.
                instanceID, triangleCount, 0, 1,
                // Emissive color, 0
                instance.material.emissive.x, instance.material.emissive.y, instance.material.emissive.z, 0,
                0, 0, 0, 0
            );
        }
        // Allocate point light buffer
        this._lightManager.overwriteAll(lightArray);
        // Rebuild the light BVH when anything it is built from changed
        const lightSignature: Array<number> = [...instanceUintArray, ...lightArray];
        for (let instance of this.instances) {
            const emissive = instance.material.emissive, transform = instance.transform.transformArray;
            lightSignature.push(...emissive);
            if (emissive.x + emissive.y + emissive.z > 0 || instance.emissive) for (let i = 0; i < transform.length; i++) lightSignature.push(transform[i]!);
        }
        this.emissiveTextureKey = emissiveTextureKey;
        this.triangleEmissionStale = emissiveTextureKey.length > 0 && !sameNumbers(emissiveTextureKey, this.triangleEmissionKey);
        if (!this.triangleEmissionStale && !sameNumbers(lightSignature, this.lightSignature)) {
            this.lightTreeManager.overwriteAll(packLightTree(this.instances, this.pointLights, globalTriangleIndexOffset, this.triangleEmission));
            this.lightSignature = lightSignature;
        }

        // Return total triangle count to dispatch renderer with right amount of triangles.
        // console.log(this._instanceBVHManager.bufferView);
        return globalTriangleIndexOffset;
    }

    // Add instance to scene
    instance(prototype: Prototype): Instance {
        const instance = new Instance(this, prototype);
        this.instances.add(instance);
        return instance;
    }

    // Remove instance from scene
    remove(instance: Instance): boolean {
        if (this.instances.has(instance)) {
            instance.destroy();
            return this.instances.delete(instance);
        }
        return false;
    }

    // Add point light to scene
    addPointLight(pointLight: PointLight) {
        this.pointLights.add(pointLight);
        this._pointLightCount ++;
    }

    // Remove point light from scene
    removePointLight(pointLight: PointLight) {
        this.pointLights.delete(pointLight);
        this._pointLightCount --;
    }
}