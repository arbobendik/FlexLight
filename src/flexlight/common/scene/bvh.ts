"use strict";

import { matrix_vector_mul, Vector, vector_add, vector_difference, vector_scale } from "../lib/math";
import { Instance } from "./instance";
import { PrototypeArrays } from "./prototype";
import { Transform } from "./transform";

const BVH_MAX_LEAVES_PER_NODE = 4;

export interface Bounding {
    min: Vector<3>;
    max: Vector<3>;
}

export class Triangle {
    a: Vector<3>;
    b: Vector<3>;
    c: Vector<3>;
    id: number;

    constructor(a: Vector<3>, b: Vector<3>, c: Vector<3>, id: number) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.id = id;
    }

    *[Symbol.iterator]() {
        yield this.a;
        yield this.b;
        yield this.c;
    }
}

export class IndexedInstance {
    instance: Instance;
    bounding: Bounding;
    id: number;

    constructor(instance: Instance, bounding: Bounding, id: number) {
        this.instance = instance;
        this.bounding = bounding;
        this.id = id;
    }
}

export class BVHLeaf<T extends Triangle | IndexedInstance> {
    children: Array<T>;
    bounding: Bounding;
    id: number;

    constructor(children: Array<T>, bounding: Bounding, id: number) {
        this.children = children;
        this.bounding = bounding;
        this.id = id;
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

    constructor(children: Array<BVHNode<T> | BVHLeaf<T>>, bounding: Bounding, id: number) {
        this.children = children;
        this.bounding = bounding;
        this.id = id;
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


export class BVH<T extends Triangle | IndexedInstance> {
    root: BVHNode<T> | BVHLeaf<T>;

    constructor(root: BVHNode<T> | BVHLeaf<T>) {
        this.root = root;
    }

    dfsTraverse(node: BVHNode<T> | BVHLeaf<T>, callbackNode: (node: BVHNode<T>) => void, callbackLeaf: (leaf: BVHLeaf<T>) => void) {
        if (node instanceof BVHLeaf) {
            callbackLeaf(node);
        } else if (node instanceof BVHNode) {
            callbackNode(node);
            for (let child of node.children) this.dfsTraverse(child, callbackNode, callbackLeaf);
        }
    }

    toArrays(): BVHArrays {
        const boundingVertices: Array<number> = [];
        const bvh: Array<number> = [];
        // Traverse tree using depth first search starting from root
        this.dfsTraverse(this.root, 
            (node: BVHNode<T>) => {
                boundingVertices.push(node.bounding.min.x, node.bounding.min.y, node.bounding.min.z, node.bounding.max.x, node.bounding.max.y, node.bounding.max.z);
                bvh.push(1, node.children[0]?.id ?? 0, node.children[1]?.id ?? 0, node.children[2]?.id ?? 0, node.children[3]?.id ?? 0);
            },
            (leaf: BVHLeaf<T>) => {
                bvh.push(0, leaf.children[0]?.id ?? 0, leaf.children[1]?.id ?? 0, leaf.children[2]?.id ?? 0, leaf.children[3]?.id ?? 0);
            }
        );
        return { boundingVertices, bvh };
    }

    protected static isVertexInBounding(vertex: Vector<3>, bound: Bounding): boolean {
        return bound.min.x <= vertex.x && bound.min.y <= vertex.y && bound.min.z <= vertex.z &&
               bound.max.x >= vertex.x && bound.max.y >= vertex.y && bound.max.z >= vertex.z;
    }

    protected static longestAxis(bounding: Bounding): "x" | "y" | "z" {
        const diff = vector_difference(bounding.max, bounding.min);
        return diff.x > diff.y && diff.x > diff.z ? "x" : diff.y > diff.z ? "y" : "z";
    }
}


// Triangle BVH class for constructing static BVHs for triangle meshes
export class TriangleBVH extends BVH<Triangle> {
    constructor(triangles: Array<Triangle>) {
        super(TriangleBVH.subdivideTree(triangles));
    }

    private static isTriangleInBounding(triangle: Triangle, bound: Bounding): boolean {
        return super.isVertexInBounding(triangle.a, bound) && super.isVertexInBounding(triangle.b, bound) && super.isVertexInBounding(triangle.c, bound);
    }

    private static tightenBounding(triangles: Array<Triangle>): Bounding {
        let bounding: Bounding = { min: new Vector(Infinity, Infinity, Infinity), max: new Vector(-Infinity, -Infinity, -Infinity) };
        for (let triangle of triangles) {
            for (let vertex of triangle) {
                bounding.min.x = Math.min(bounding.min.x, vertex.x);
                bounding.min.y = Math.min(bounding.min.y, vertex.y);
                bounding.min.z = Math.min(bounding.min.z, vertex.z);
                bounding.max.x = Math.max(bounding.max.x, vertex.x);
                bounding.max.y = Math.max(bounding.max.y, vertex.y);
                bounding.max.z = Math.max(bounding.max.z, vertex.z);
            }
        }
        return bounding;
    }

    private static subdivideTree(triangles: Array<Triangle>, maxDepth: number = Infinity, depth: number = 0, startingId: number = 0): BVHNode<Triangle> | BVHLeaf<Triangle> {
        // Tighten bounding
        const bounding = TriangleBVH.tightenBounding(triangles);

        if (triangles.length <= BVH_MAX_LEAVES_PER_NODE || depth > maxDepth) return new BVHLeaf(triangles, bounding, 0);
        // Split bounding into two sub bounding volumes along the longest axis
        const longestAxis = TriangleBVH.longestAxis(bounding);
        const center = vector_scale(vector_add(bounding.min, bounding.max), 0.5);

        const bounding0Max = new Vector(bounding.max);
        const bounding1Min = new Vector(bounding.min);
        bounding0Max[longestAxis] = center[longestAxis];
        bounding1Min[longestAxis] = center[longestAxis];

        const bounding0 = { min: bounding.min, max: bounding0Max };
        const bounding1 = { min: bounding1Min, max: bounding.max };

        // Sort triangles into bounding volumes
        const trianglesOnCutoff = [];
        const trianglesInBound0 = [];
        const trianglesInBound1 = [];

        for (let triangle of triangles) {
            const in0 = TriangleBVH.isTriangleInBounding(triangle, bounding0);
            const in1 = TriangleBVH.isTriangleInBounding(triangle, bounding1);

            if (in0 && in1) trianglesOnCutoff.push(triangle);
            else if (in0) trianglesInBound0.push(triangle);
            else trianglesInBound1.push(triangle);
        }

        let children: Array<BVHNode<Triangle> | BVHLeaf<Triangle>> = [];
        // Assign ids to children
        let nextId = startingId + 1;
        // Recursively subdivide bounding volumes if respective bounding volumes contain triangles
        if (trianglesInBound0.length > 0) {
            const child = TriangleBVH.subdivideTree(trianglesInBound0, maxDepth, depth + 1, nextId);
            children.push(child);
            nextId = child.id + 1;
        }
        if (trianglesOnCutoff.length > 0) {
            const child = TriangleBVH.subdivideTree(trianglesOnCutoff, maxDepth, depth + 1, nextId);
            children.push(child);
            nextId = child.id + 1;
        }

        if (trianglesInBound1.length > 0) {
            const child = TriangleBVH.subdivideTree(trianglesInBound1, maxDepth, depth + 1, nextId);
            children.push(child);
        }

        return new BVHNode<Triangle>(children, bounding, startingId);
    }

    static fromPrototypeArrays(prototypeArrays: PrototypeArrays): TriangleBVH {
        let triangles: Array<Triangle> = [];
        // Iterate over triangles in format V V V N N N UV UV UV
        for (let i = 0; i < prototypeArrays.triangles.length; i += 9) {
            // Offset by one to keep ids 1-indexed
            const id = i / 9 + 1;
            triangles.push(new Triangle(
                new Vector(
                    prototypeArrays.vertices[prototypeArrays.triangles[i]!]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i]! + 1]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i]! + 2]!
                ),
                new Vector(
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 1]!]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 1]! + 1]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 1]! + 2]!
                ),
                new Vector(
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 2]!]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 2]! + 1]!,
                    prototypeArrays.vertices[prototypeArrays.triangles[i + 2]! + 2]!
                ),
                id
            ));
        }
        // Subdivide tree
        return new TriangleBVH(triangles);
    }
}

// Indexed Instance BVH class for constructing dynamic BVHs for instances
export class IndexedInstanceBVH extends BVH<IndexedInstance> {
    constructor(instances: Array<IndexedInstance>) {
        super(IndexedInstanceBVH.subdivideTree(instances));
    }

    private static isInstanceInBounding(instance: IndexedInstance, bound: Bounding): boolean {
        return super.isVertexInBounding(instance.bounding.min, bound) && super.isVertexInBounding(instance.bounding.max, bound);
    }

    private static tightenBoundingInstances(instances: Array<IndexedInstance>): Bounding {
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

    private static subdivideTree(instances: Array<IndexedInstance>, maxDepth: number = Infinity, depth: number = 0, startingId: number = 0): BVHNode<IndexedInstance> | BVHLeaf<IndexedInstance> {
        // Tighten bounding
        const bounding = IndexedInstanceBVH.tightenBoundingInstances(instances);

        if (instances.length <= BVH_MAX_LEAVES_PER_NODE || depth > maxDepth) return new BVHLeaf(instances, bounding, 0);
        // Split bounding into two sub bounding volumes along the longest axis
        const longestAxis = TriangleBVH.longestAxis(bounding);
        const center = vector_scale(vector_add(bounding.min, bounding.max), 0.5);

        const bounding0Max = new Vector(bounding.max);
        const bounding1Min = new Vector(bounding.min);
        bounding0Max[longestAxis] = center[longestAxis];
        bounding1Min[longestAxis] = center[longestAxis];

        const bounding0 = { min: bounding.min, max: bounding0Max };
        const bounding1 = { min: bounding1Min, max: bounding.max };

        // Sort triangles into bounding volumes
        const instancesOnCutoff = [];
        const instancesInBound0 = [];
        const instancesInBound1 = [];

        for (let instance of instances) {
            const in0 = IndexedInstanceBVH.isInstanceInBounding(instance, bounding0);
            const in1 = IndexedInstanceBVH.isInstanceInBounding(instance, bounding1);

            if (in0 && in1) instancesOnCutoff.push(instance);
            else if (in0) instancesInBound0.push(instance);
            else instancesInBound1.push(instance);
        }

        let children: Array<BVHNode<IndexedInstance> | BVHLeaf<IndexedInstance>> = [];
        // Assign ids to children
        let nextId = startingId + 1;
        // Recursively subdivide bounding volumes if respective bounding volumes contain triangles
        if (instancesInBound0.length > 0) {
            const child = IndexedInstanceBVH.subdivideTree(instancesInBound0, maxDepth, depth + 1, nextId);
            children.push(child);
            nextId = child.id + 1;
        }
        if (instancesOnCutoff.length > 0) {
            const child = IndexedInstanceBVH.subdivideTree(instancesOnCutoff, maxDepth, depth + 1, nextId);
            children.push(child);
            nextId = child.id + 1;
        }

        if (instancesInBound1.length > 0) {
            const child = IndexedInstanceBVH.subdivideTree(instancesInBound1, maxDepth, depth + 1, nextId);
            children.push(child);
        }

        return new BVHNode<IndexedInstance>(children, bounding, startingId);
    }

    static fromInstances(instances: Array<Instance>): IndexedInstanceBVH {
        let indexedInstances: Array<IndexedInstance> = [];
        let id: number = 0;
        // Iterate over instances, assigning ids and calculate boundings
        for (let instance of instances) {
            const untransformedBounding: Bounding = {
                min: new Vector(instance.prototype.boundingVertices[0]!, instance.prototype.boundingVertices[1]!, instance.prototype.boundingVertices[2]!),
                max: new Vector(instance.prototype.boundingVertices[3]!, instance.prototype.boundingVertices[4]!, instance.prototype.boundingVertices[5]!)
            };
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
            const transform: Transform = instance.transform ?? Transform.DEFAULT_TRANSFORM;
            const transformedBounding: Bounding = { min: new Vector(Infinity, Infinity, Infinity), max: new Vector(-Infinity, -Infinity, -Infinity) };
            // Transform all corners
            for (let corner of corners) {
                const transformedCorner = vector_add(matrix_vector_mul(transform.matrix, corner), transform.position);
                transformedBounding.min.x = Math.min(transformedBounding.min.x, transformedCorner.x);
                transformedBounding.min.y = Math.min(transformedBounding.min.y, transformedCorner.y);
                transformedBounding.min.z = Math.min(transformedBounding.min.z, transformedCorner.z);
                transformedBounding.max.x = Math.max(transformedBounding.max.x, transformedCorner.x);
                transformedBounding.max.y = Math.max(transformedBounding.max.y, transformedCorner.y);
                transformedBounding.max.z = Math.max(transformedBounding.max.z, transformedCorner.z);
            }
            // Push indexed instance
            indexedInstances.push(new IndexedInstance(instance, transformedBounding, id ++));
        }
        // Return indexed instance BVH
        return new IndexedInstanceBVH(indexedInstances);
    }
}