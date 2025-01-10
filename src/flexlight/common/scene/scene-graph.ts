"use strict";

import { IndexedInstanceBVH, BVHArrays, BVH } from "./bvh";
import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";
import { Instance } from "./instance";


export interface SceneGraphBufferViews {
    instanceView: TypedArrayView<Uint32Array>;
    boundingVerticesView: TypedArrayView<Float32Array>;
    bvhView: TypedArrayView<Uint32Array>;
}

export class SceneGraph {
    // Vertex Offset, Bounding Vertex Offset, Normal Offset, UV Offset, BVH Offset, Triangle Offset, Transform Offset, Material Offset, Global Vertex Offset
    private instanceManager: BufferManager<Uint32Array>;
    // Bounding vertices: Bx By Bz
    private boundingVertexManager: BufferManager<Float32Array>;
    // BVH structure: 0|1 BV BV B|I B|I B|I B|I
    private BVHManager: BufferManager<Uint32Array>;
    // readonly instance: TypedArrayView<Uint32Array>;
    
    readonly instances: Array<Instance> = [];

    constructor(instances: Array<Instance> = []) {
        this.instances = instances;
        this.instanceManager = new BufferManager(Uint32Array);
        this.boundingVertexManager = new BufferManager(Float32Array);
        this.BVHManager = new BufferManager(Uint32Array);
    }

    toBufferViews = (): SceneGraphBufferViews => {
        // Free all buffers, keep buffers itself to avoid expensive reallocation
        this.instanceManager.freeAll();
        this.boundingVertexManager.freeAll();
        this.BVHManager.freeAll();
        // Keep track of global vertex offset
        let globalVertexOffset: number = 0;
        // Construct instance buffer
        for (let instance of this.instances) {
            this.instanceManager.allocateArray([
                instance.prototype.vertices.offset, instance.prototype.boundingVertices.offset, instance.prototype.normals.offset,
                instance.prototype.uvs.offset, instance.prototype.bvh.offset, instance.prototype.triangles.offset,
                instance.transform?.transformArray.offset ?? 0, instance.material?.materialArray.offset ?? 0, globalVertexOffset
            ]);
            // Increment global vertex offset by instance vertex count
            globalVertexOffset += instance.prototype.vertices.length;
        }

        // Generate BVH
        const bvh: IndexedInstanceBVH = IndexedInstanceBVH.fromInstances(this.instances);
        // Generate bounding vertices and BVH structure
        const bvhArrays: BVHArrays = bvh.toArrays();
        // Allocate BVH buffers
        this.boundingVertexManager.allocateArray(bvhArrays.boundingVertices);
        this.BVHManager.allocateArray(bvhArrays.bvh);
        // Return full view of all buffers
        return {
            instanceView: this.instanceManager.bufferView,
            boundingVerticesView: this.boundingVertexManager.bufferView,
            bvhView: this.BVHManager.bufferView
        };
    }

    addInstance(instance: Instance) {
        this.instances.push(instance);
    }

    removeInstance(instance: Instance) {
        this.instances.splice(this.instances.indexOf(instance), 1);
    }
}