"use strict";

import { Triangle } from "./triangle-bvh";
import { IndexedInstance } from "./instance-bvh";
import { BIAS, Vector, vector_difference } from "../lib/math";


const BVH_MAX_INSTANCES_PER_LEAF = 2;
const BVH_MAX_CHILDREN_PER_NODE = 2;


export interface Bounding {
    min: Vector<3>;
    max: Vector<3>;
}

export class BVHLeaf<T extends Triangle | IndexedInstance> {
    children: Array<T>;
    bounding: Bounding;
    id: number;
    private _offset: number | undefined;
    
    constructor(children: Array<T>, bounding: Bounding, id: number) {
        this.children = children;
        this.bounding = bounding;
        this.id = id;
    }

    set offset(offset: number) {
        this._offset = offset;
    }

    get offset(): number {
        if (this._offset) return this._offset;
        else throw new Error("Offset not set for BVHLeaf with id: " + this.id);
    }

    destroy() {
        // Dereference children
        this.children = [];
    }

    *[Symbol.iterator]() {
        for (let child of this.children) {
            yield child;
        }
    }
}

export class BVHNode<T extends Triangle | IndexedInstance> {
    children: Array<BVHNode<T> | BVHLeaf<T>>;
    bounding: Bounding;
    id: number;
    private _offset: number | undefined;

    constructor(children: Array<BVHNode<T> | BVHLeaf<T>>, bounding: Bounding, id: number) {
        this.children = children;
        this.bounding = bounding;
        this.id = id;
    }

    set offset(offset: number) {
        this._offset = offset;
    }

    get offset(): number {
        if (this._offset) return this._offset;
        else throw new Error("Offset not set for BVHNode with id: " + this.id);
    }

    destroy() {
        // Dereference children
        for (let child of this.children) child.destroy();
        this.children = [];
    }

    *[Symbol.iterator]() {
        for (let child of this.children) {
            yield child;
        }
    }
}

export interface BVHArrays {
    boundingVertices: Array<number>;
    bvh: Array<number>;
}


export abstract class BVH<T extends Triangle | IndexedInstance> {
    root: BVHNode<T> | BVHLeaf<T>;

    constructor(objects: Array<T>, useBFS: boolean = false) {
        this.root = useBFS ? this.subdivideTreeBFS(objects, 32) : this.subdivideTreeDFS(objects, 32);
    }

    // protected abstract evaluateSplitCost(objects: Array<T>, bounding0: Bounding, bounding1: Bounding): number;
    protected abstract tightenBounding(objects: Array<T>): Bounding;
    protected abstract isObjectInBounding(object: T, bound: Bounding): boolean;


    private evaluateSplitCost(objects: Array<T>, _bounding0: Bounding, bounding1: Bounding): number {
        // Calculate the number of instances that are in both bounding volumes
        let instancesIn0 = 0;
        let instancesIn0Area = 0;
        let instancesIn1 = 0;
        let instancesIn1Area = 0;
        for (let object of objects) {
            // const in0 = IndexedInstanceBVH.isObjectInBounding(instance, bounding0);
            const in1 = this.isObjectInBounding(object, bounding1);
            if (in1) {
                instancesIn1++;
                instancesIn1Area += object.area;
            } else {
                instancesIn0++;
                instancesIn0Area += object.area;
            }
        }
        // If one box contains all instances, the cost is Infinity as no subdivision is happening.
        if (instancesIn0 === 0 || instancesIn1 === 0) return Infinity;
        // Minimize for minimum triangles on cutoff and equal distribution of triangles across bounding0 and bounding1.
        return Math.abs(instancesIn0Area - instancesIn1Area);
    }

    private split(objects: Array<T>, bounding: Bounding): { objectsInBound0: Array<T>, objectsInBound1: Array<T>} | undefined {
        // Split bounding into two sub bounding volumes along the axis minimizing the cost of instance split
        const intervals: number = 2;
        let splitAlongAxis: "x" | "y" | "z" = "x";
        let splitAt: number = 0;
        let minCost: number = Infinity;
        for (let axis of ["x", "y", "z"] as Array<"x" | "y" | "z">) {
            let splitDistIncrement = (bounding.max[axis] - bounding.min[axis]) / intervals;
    
            for (let i = 1; i < intervals; i++) {
                const bounding0Max = new Vector(bounding.max);
                const bounding1Min = new Vector(bounding.min);
                bounding0Max[axis] = bounding.min[axis] + i * splitDistIncrement;
                bounding1Min[axis] = bounding.min[axis] + i * splitDistIncrement;
                // Define two bounding volumes
                const bounding0 = { min: bounding.min, max: bounding0Max };
                const bounding1 = { min: bounding1Min, max: bounding.max };
    
                const cost = this.evaluateSplitCost(objects, bounding0, bounding1);
                if (cost < minCost) {
                    minCost = cost;
                    splitAlongAxis = axis;
                    splitAt = bounding.min[axis] + i * splitDistIncrement;
                }
            }
        }
        // If no subdivision is happening, return flat tree to avoid infinite recursion and unnecessary 
        if (minCost === Infinity) {
            return undefined;
        }
    
        const bounding0Max = new Vector(bounding.max);
        const bounding1Min = new Vector(bounding.min);
        bounding0Max[splitAlongAxis] = splitAt;
        bounding1Min[splitAlongAxis] = splitAt;
    
        const bounding0 = { min: bounding.min, max: bounding0Max };
        const bounding1 = { min: bounding1Min, max: bounding.max };
    
        // Sort instances into bounding volumes
        const objectsInBound0: Array<T> = [];
        const objectsInBound1: Array<T> = [];
    
        for (let object of objects) {
            const in0 = this.isObjectInBounding(object, bounding0);
            const in1 = this.isObjectInBounding(object, bounding1);
            if (in0 && !in1) objectsInBound0.push(object);
            else if (!in0 && in1) objectsInBound1.push(object);
            else objectsInBound0.push(object);
        }

        return { objectsInBound0, objectsInBound1 };
    }


    private subdivideTreeDFS(objects: Array<T>, maxDepth: number = Infinity): BVHNode<T> | BVHLeaf<T> {
        let fillFlatTreeDFS = (objects: Array<T>, startingId: number): { node: BVHNode<T> | BVHLeaf<T>, nextId: number } => {
            // Tighten bounding
            let vertices: Array<Vector<3>> = [];
            for (let object of objects) for (let vertex of object) vertices.push(vertex);
            const bounding = this.tightenBounding(objects);
            // Base case: if there are less than BVH_MAX_TRIANGLES_PER_LEAF triangles, return a leaf
            if (objects.length <= BVH_MAX_INSTANCES_PER_LEAF) return { node: new BVHLeaf(objects, bounding, startingId), nextId: startingId + 1 };
    
            const objectsPerChild: number = Math.ceil(objects.length / BVH_MAX_CHILDREN_PER_NODE);
    
            const children: Array<BVHNode<T> | BVHLeaf<T>> = [];
            // Assign ids to children
            let nextId = startingId + 1;
            for (let i = 0; i < objects.length; i += objectsPerChild) {
                const childObjects = objects.slice(i, Math.min(i + objectsPerChild, objects.length + 1));
                // const child = TriangleBVH.fillFlatTree(childTriangles, nextId, startingId);
                const child = fillFlatTreeDFS(childObjects, nextId);
                children.push(child.node);
                nextId = child.nextId;
            }
    
            return { node: new BVHNode(children, bounding, startingId), nextId: nextId };
        }

        let stepDFS = (objects: Array<T>, depth: number = 0, startingId: number = 0): { node: BVHNode<T> | BVHLeaf<T>, nextId: number } => {
            // Tighten bounding
            const bounding = this.tightenBounding(objects);
            // Base case: if there are less than BVH_MAX_INSTANCES_PER_LEAF instances, return a leaf
            if (objects.length <= BVH_MAX_INSTANCES_PER_LEAF || depth > maxDepth) return { node: new BVHLeaf(objects, bounding, startingId), nextId: startingId + 1 };

            const split = this.split(objects, bounding);
            // If no split is possible, return flat tree to avoid infinite recursion
            if (!split) return fillFlatTreeDFS(objects, startingId);
            const { objectsInBound0, objectsInBound1 } = split;

            let children: Array<BVHNode<T> | BVHLeaf<T>> = [];
            // Assign ids to children
            let nextId = startingId + 1;
            // Recursively subdivide bounding volumes if respective bounding volumes contain instances
            if (objectsInBound0.length > 0) {
                const child = stepDFS(objectsInBound0, depth + 1, nextId);
                children.push(child.node);
                nextId = child.nextId;
            }

            if (objectsInBound1.length > 0) {
                const child = stepDFS(objectsInBound1, depth + 1, nextId);
                children.push(child.node);
                nextId = child.nextId;
            }

            return { node: new BVHNode(children, bounding, startingId), nextId: nextId };
        }


        return stepDFS(objects, 0, 0).node;
    }

    private subdivideTreeBFS(objects: Array<T>, maxDepth: number = Infinity): BVHNode<T> | BVHLeaf<T> {
        // Helper type to track nodes that need processing
        type QueueItem = { objects: Array<T>, depth: number, parent: BVHNode<T> | undefined };
        // Initialize queue with root level
        const queue: Array<QueueItem> = [{ objects, depth: 0, parent: undefined }];
        // Map to store created nodes, keyed by their id
        const nodesMap = new Map<number, BVHNode<T> | BVHLeaf<T>>();
        let nextAvailableId = 0;


        let setNode = (bounding: Bounding, parent: BVHNode<T> | undefined): BVHNode<T> => {
            const id = nextAvailableId++;
            let node = new BVHNode<T>([], bounding, id);
            if (parent) parent.children.push(node);
            nodesMap.set(id, node);
            return node;
        }

        const setLeaf = (objects: Array<T>, bounding: Bounding, parent: BVHNode<T> | undefined): BVHLeaf<T> => {
            const id = nextAvailableId++;
            let leaf = new BVHLeaf(objects, bounding, id);
            if (parent) parent.children.push(leaf);
            nodesMap.set(id, leaf);
            return leaf;
        }

        while (queue.length > 0) {
            // const current = queue.shift()!;
            const { objects: currentObjects, depth, parent } = queue.shift()!;
            if (depth > maxDepth) throw new Error("Depth limit exceeded");
            // Get bounding box for current node
            const bounding = this.tightenBounding(currentObjects);

            // Check if we should create a leaf
            if (currentObjects.length <= BVH_MAX_INSTANCES_PER_LEAF || depth > maxDepth) {
                setLeaf(currentObjects, bounding, parent);
                continue;
            }

            // Try to split the node
            const split = this.split(currentObjects, bounding);
            // Create temporary node with empty children array
            const node = setNode(bounding, parent);
            // If split not possible, create flat tree
            if (!split) {
                const objectsPerChild: number = Math.ceil(currentObjects.length / BVH_MAX_CHILDREN_PER_NODE);
                for (let i = 0; i < currentObjects.length; i += objectsPerChild) {
                    const childObjects = currentObjects.slice(i, Math.min(i + objectsPerChild, currentObjects.length + 1));
                    queue.push({ objects: childObjects, depth: depth + 1, parent: node });
                }
            } else {
                const { objectsInBound0, objectsInBound1 } = split;
                if (objectsInBound0.length > 0) {
                    queue.push({ objects: objectsInBound0, depth: depth + 1, parent: node });
                }
    
                if (objectsInBound1.length > 0) {
                    queue.push({ objects: objectsInBound1, depth: depth + 1, parent: node });
                }
            }
        }
        return nodesMap.get(0)!;
    }

    
    dfsTraverse (nodeHook: (node: BVHNode<T>) => void, leafHook: (leaf: BVHLeaf<T>) => void, root: BVHNode<T> | BVHLeaf<T>) {
        if (root instanceof BVHLeaf) {
            leafHook(root);
        } else if (root instanceof BVHNode) {
            nodeHook(root);
            for (let child of root.children) this.dfsTraverse(nodeHook, leafHook, child);
        }
    }

    bfsTraverse (nodeHook: (node: BVHNode<T>) => void, leafHook: (leaf: BVHLeaf<T>) => void, root: BVHNode<T> | BVHLeaf<T>) {
        const queue: Array<BVHNode<T> | BVHLeaf<T>> = [root];
        while (queue.length > 0) {
            const current = queue.shift()!;
            if (current instanceof BVHLeaf) {
                leafHook(current);
            } else if (current instanceof BVHNode) {
                nodeHook(current);
                queue.push(...current.children);
            }
        }
    }

    protected static isVertexInBounding(vertex: Vector<3>, bound: Bounding): boolean {
        return bound.min.x - BIAS <= vertex.x && bound.min.y - BIAS <= vertex.y && bound.min.z - BIAS <= vertex.z &&
               bound.max.x + BIAS >= vertex.x && bound.max.y + BIAS >= vertex.y && bound.max.z + BIAS >= vertex.z;
    }

    protected static longestAxis(bounding: Bounding): "x" | "y" | "z" {
        const diff = vector_difference(bounding.max, bounding.min);
        return diff.x > diff.y && diff.x > diff.z ? "x" : diff.y > diff.z ? "y" : "z";
    }
}
