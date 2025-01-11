"use strict";

import { IndexedInstanceBVH, BVHArrays } from "./bvh";
import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";
import { Instance } from "./instance";
import { POW32M1 } from "../lib/math";


export interface SceneGraphFrameData {
    instanceView: TypedArrayView<Uint32Array>;
    boundingVerticesView: TypedArrayView<Float32Array>;
    bvhView: TypedArrayView<Uint32Array>;
    totalVertexOffset: number;
}

export class SceneGraph {
    // Vertex Offset, Bounding Vertex Offset, Normal Offset, UV Offset, BVH Offset, Triangle Offset, Transform Offset, Material Offset, Global Vertex Offset
    private instanceManager: BufferManager<Uint32Array>;
    // Bounding vertices: Bx By Bz
    private instanceBoundingVertexManager: BufferManager<Float32Array>;
    // BVH structure: 0|1 BV BV B|I B|I B|I B|I
    private instanceBVHManager: BufferManager<Uint32Array>;
    
    private readonly instances: Set<Instance> = new Set();

    constructor(instances: Array<Instance> = []) {
        for (const instance of instances) this.instances.add(instance);
        this.instanceManager = new BufferManager(Uint32Array);
        this.instanceBoundingVertexManager = new BufferManager(Float32Array);
        this.instanceBVHManager = new BufferManager(Uint32Array);
    }

    toFrameData = (): SceneGraphFrameData => {
        const instanceArray: Array<number> = [];
        // Keep track of global vertex offset
        let globalVertexOffset: number = 0;
        // Construct instance buffer
        for (let instance of this.instances) {
            instanceArray.push(
                // Prototype buffer references
                instance.prototype.vertices.offset, instance.prototype.boundingVertices.offset, instance.prototype.normals.offset,
                instance.prototype.uvs.offset, instance.prototype.bvh.offset, instance.prototype.triangles.offset,
                // Transform buffer and material buffer references
                instance.transform?.transformArray.offset ?? 0, instance.material?.materialArray.offset ?? 0,
                // Texture buffer references
                instance.normal?.textureInstanceBuffer?.offset ?? POW32M1, instance.albedo?.textureInstanceBuffer?.offset ?? POW32M1, instance.emissive?.textureInstanceBuffer?.offset ?? POW32M1,
                instance.roughness?.textureInstanceBuffer?.offset ?? POW32M1, instance.metallic?.textureInstanceBuffer?.offset ?? POW32M1,
                globalVertexOffset
            );
            // Increment global vertex offset by instance vertex count
            globalVertexOffset += instance.prototype.vertices.length;
        }
        // Allocate instance buffer
        this.instanceManager.overwriteAll(instanceArray);
        // Generate BVH
        const bvh: IndexedInstanceBVH = IndexedInstanceBVH.fromInstances(this.instances);
        // Generate bounding vertices and BVH structure
        const bvhArrays: BVHArrays = bvh.toArrays();
        // Allocate BVH buffers
        this.instanceBoundingVertexManager.overwriteAll(bvhArrays.boundingVertices);
        this.instanceBVHManager.overwriteAll(bvhArrays.bvh);
        // Return full view of all buffers
        return {
            instanceView: this.instanceManager.bufferView,
            boundingVerticesView: this.instanceBoundingVertexManager.bufferView,
            bvhView: this.instanceBVHManager.bufferView,
            totalVertexOffset: globalVertexOffset
        };
    }

    addInstance(instance: Instance) {
        this.instances.add(instance);
    }

    removeInstance(instance: Instance) {
        this.instances.delete(instance);
    }
}