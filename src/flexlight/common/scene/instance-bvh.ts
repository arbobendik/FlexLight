"use strict";

import { BVH, BVHArrays, BVHLeaf, BVHNode, Bounding } from "./bvh";
import { BIAS, POW32M1, Vector, matrix_vector_mul, vector_add, vector_difference } from "../lib/math";
import { Instance } from "./instance";
import { Transform } from "./transform";

const USE_BFS = false;

export class IndexedInstance {
    instance: Instance;
    bounding: Bounding;
    id: number;

    area: number;

    constructor(instance: Instance, bounding: Bounding, id: number) {
        this.instance = instance;
        this.bounding = bounding;
        this.id = id;

        // Calculate area of instance
        let boundingDiff = vector_difference(bounding.max, bounding.min);
        this.area = boundingDiff.x * boundingDiff.y + boundingDiff.y * boundingDiff.z + boundingDiff.z * boundingDiff.x * 2;
    }

    *[Symbol.iterator]() {
        yield this.bounding.min;
        yield this.bounding.max;
    }
}

// Indexed Instance BVH class for constructing dynamic BVHs for instances
export class IndexedInstanceBVH extends BVH<IndexedInstance> {
    _instanceIDMap: Map<number, IndexedInstance> = new Map();

    constructor(instances: Array<IndexedInstance>) {
        super(instances, USE_BFS);
        for (let instance of instances) this._instanceIDMap.set(instance.id, instance); 
    }

    getInstanceById(id: number): IndexedInstance | null {
        return this._instanceIDMap.get(id) ?? null;
    }

    toArrays(): BVHArrays {
        const boundingVertices: Array<number> = [];
        const bvh: Array<number> = [];

        const nodeHook = (node: BVHNode<IndexedInstance>) => {
            // boundingVertices.push(node.bounding.min.x, node.bounding.min.y, node.bounding.min.z, node.bounding.max.x, node.bounding.max.y, node.bounding.max.z);
            boundingVertices.push(  ...(node.children[0]?.bounding.min ?? new Vector(0, 0, 0)), ...(node.children[0]?.bounding.max ?? new Vector(0, 0, 0)),
                                ...(node.children[1]?.bounding.min ?? new Vector(0, 0, 0)), ...(node.children[1]?.bounding.max ?? new Vector(0, 0, 0)));
            bvh.push(1, node.children[0]?.id ?? POW32M1, node.children[1]?.id ?? POW32M1);
        }

        const leafHook = (leaf: BVHLeaf<IndexedInstance>) => {
            // boundingVertices.push(leaf.bounding.min.x, leaf.bounding.min.y, leaf.bounding.min.z, leaf.bounding.max.x, leaf.bounding.max.y, leaf.bounding.max.z);
            boundingVertices.push(  ...(leaf.children[0]?.bounding.min ?? new Vector(0, 0, 0)), ...(leaf.children[0]?.bounding.max ?? new Vector(0, 0, 0)),
                                    ...(leaf.children[1]?.bounding.min ?? new Vector(0, 0, 0)), ...(leaf.children[1]?.bounding.max ?? new Vector(0, 0, 0)));
            bvh.push(0, leaf.children[0]?.id ?? POW32M1, leaf.children[1]?.id ?? POW32M1);
        }
        
        // Traverse tree using dfs or bfs starting from root
        if (USE_BFS) this.bfsTraverse(nodeHook, leafHook, this.root);
        else this.dfsTraverse(nodeHook, leafHook, this.root);

        return { boundingVertices, bvh };
    }

    protected isObjectInBounding(instance: IndexedInstance, bound: Bounding): boolean {
        return BVH.isVertexInBounding(instance.bounding.min, bound) && BVH.isVertexInBounding(instance.bounding.max, bound);
    }

    protected tightenBounding(instances: Array<IndexedInstance>): Bounding {
        let vertices: Array<Vector<3>> = [];
        for (let instance of instances) vertices.push(instance.bounding.min, instance.bounding.max);
        // Construct bounding
        let bounding: Bounding = { min: new Vector(Infinity, Infinity, Infinity), max: new Vector(-Infinity, -Infinity, -Infinity) };
        // Iterate over vertices, tightening bounding
        for (let vertex of vertices) {
            bounding.min.x = Math.min(bounding.min.x, vertex.x);
            bounding.min.y = Math.min(bounding.min.y, vertex.y);
            bounding.min.z = Math.min(bounding.min.z, vertex.z);
            bounding.max.x = Math.max(bounding.max.x, vertex.x);
            bounding.max.y = Math.max(bounding.max.y, vertex.y);
            bounding.max.z = Math.max(bounding.max.z, vertex.z);
        }
        return bounding;
    }

    static fromInstances(instances: Array<Instance> | Set<Instance>): IndexedInstanceBVH {
        let indexedInstances: Array<IndexedInstance> = [];
        let id: number = 0;
        // Iterate over instances, assigning ids and calculate boundings
        for (let instance of instances) {
            const untransformedBounding: Bounding = instance.prototype.bounding;
            // Get all corners of bounding volume
            const corners: Array<Vector<3>> = [
                new Vector(untransformedBounding.min.x, untransformedBounding.min.y, untransformedBounding.min.z),
                new Vector(untransformedBounding.min.x, untransformedBounding.min.y, untransformedBounding.max.z),
                new Vector(untransformedBounding.min.x, untransformedBounding.max.y, untransformedBounding.min.z),
                new Vector(untransformedBounding.min.x, untransformedBounding.max.y, untransformedBounding.max.z),
                new Vector(untransformedBounding.max.x, untransformedBounding.min.y, untransformedBounding.min.z),
                new Vector(untransformedBounding.max.x, untransformedBounding.min.y, untransformedBounding.max.z),
                new Vector(untransformedBounding.max.x, untransformedBounding.max.y, untransformedBounding.min.z),
                new Vector(untransformedBounding.max.x, untransformedBounding.max.y, untransformedBounding.max.z)
            ];

            // Get transform
            const transform: Transform = instance.transform;
            const transformedBounding: Bounding = { min: new Vector(Infinity, Infinity, Infinity), max: new Vector(-Infinity, -Infinity, -Infinity) };
            // Transform all corners
            for (let corner of corners) {
                const transformedCorner = vector_add(matrix_vector_mul(transform.matrix, corner), transform.position);
                transformedBounding.min.x = Math.min(transformedBounding.min.x, transformedCorner.x) - BIAS;
                transformedBounding.min.y = Math.min(transformedBounding.min.y, transformedCorner.y) - BIAS;
                transformedBounding.min.z = Math.min(transformedBounding.min.z, transformedCorner.z) - BIAS;
                transformedBounding.max.x = Math.max(transformedBounding.max.x, transformedCorner.x) + BIAS;
                transformedBounding.max.y = Math.max(transformedBounding.max.y, transformedCorner.y) + BIAS;
                transformedBounding.max.z = Math.max(transformedBounding.max.z, transformedCorner.z) + BIAS;
            }
            // Push indexed instance
            indexedInstances.push(new IndexedInstance(instance, transformedBounding, id ++));
        }
        // Return indexed instance BVH
        return new IndexedInstanceBVH(indexedInstances);
    }
}