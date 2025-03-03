"use strict";

import { BVH, BVHLeaf, BVHNode, Bounding, BVHArrays } from "./bvh";
import { cross, POW32M1, Vector, vector_difference, vector_length } from "../lib/math";
import { TRIANGLE_SIZE } from "./prototype";

const USE_BFS = false;


export class Triangle {
    a: Vector<3>;
    b: Vector<3>;
    c: Vector<3>;
    id: number;
    readonly area: number;

    constructor(a: Vector<3>, b: Vector<3>, c: Vector<3>, id: number) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.id = id;

        this.area = vector_length(cross(vector_difference(this.b, this.a), vector_difference(this.c, this.a))) * 0.5;
    }

    *[Symbol.iterator]() {
        yield this.a;
        yield this.b;
        yield this.c;
    }
}

// Triangle BVH class for constructing static BVHs for triangle meshes
export class TriangleBVH extends BVH<Triangle> {
    constructor(triangles: Array<Triangle>) {
        super(triangles, USE_BFS);
    }

    toArrays(): BVHArrays {
        const boundingVertices: Array<number> = [];
        const bvh: Array<number> = [];

        const nodeHook = (node: BVHNode<Triangle>) => {
            boundingVertices.push(  ...(node.children[0]?.bounding.min ?? new Vector(0, 0, 0)), ...(node.children[0]?.bounding.max ?? new Vector(0, 0, 0)),
                                    ...(node.children[1]?.bounding.min ?? new Vector(0, 0, 0)), ...(node.children[1]?.bounding.max ?? new Vector(0, 0, 0)),
                                    ... new Vector({ vector_length: 8 }));
            bvh.push(1, node.children[0]?.id ?? POW32M1, node.children[1]?.id ?? POW32M1, POW32M1);
        };


        const leafHook = (leaf: BVHLeaf<Triangle>) => {
            boundingVertices.push(  ...(leaf.children[0]?.a ?? new Vector(0, 0, 0)), ...(leaf.children[0]?.b ?? new Vector(0, 0, 0)), ...(leaf.children[0]?.c ?? new Vector(0, 0, 0)),
                                    ...(leaf.children[1]?.a ?? new Vector(0, 0, 0)), ...(leaf.children[1]?.b ?? new Vector(0, 0, 0)), ...(leaf.children[1]?.c ?? new Vector(0, 0, 0)),
                                    ... new Vector({ vector_length: 2 }));

            bvh.push(0, leaf.children[0]?.id ?? POW32M1, leaf.children[1]?.id ?? POW32M1, POW32M1);
        };
        
        // Traverse tree using dfs or bfs starting from root
        if (USE_BFS) this.bfsTraverse(nodeHook, leafHook, this.root);
        else this.dfsTraverse(nodeHook, leafHook, this.root);
        
        return { boundingVertices, bvh };
    }

    protected isObjectInBounding(triangle: Triangle, bound: Bounding): boolean {
        return BVH.isVertexInBounding(triangle.a, bound) && BVH.isVertexInBounding(triangle.b, bound) && BVH.isVertexInBounding(triangle.c, bound);
    }

    protected tightenBounding(triangles: Array<Triangle>): Bounding {
        const BIASFP16 = 0.0009765625;

        let bounding: Bounding = { min: new Vector(Infinity, Infinity, Infinity), max: new Vector(-Infinity, -Infinity, -Infinity) };
        for (let triangle of triangles) {
            for (let vertex of triangle) {
                bounding.min.x = Math.min(bounding.min.x, vertex.x - BIASFP16);
                bounding.min.y = Math.min(bounding.min.y, vertex.y - BIASFP16);
                bounding.min.z = Math.min(bounding.min.z, vertex.z - BIASFP16);
                bounding.max.x = Math.max(bounding.max.x, vertex.x + BIASFP16);
                bounding.max.y = Math.max(bounding.max.y, vertex.y + BIASFP16);
                bounding.max.z = Math.max(bounding.max.z, vertex.z + BIASFP16);
            }
        }
        return bounding;
    }
    /*
    private static subdivideTreeBFS(triangles: Array<Triangle>, startingId: number = 0, parentId: number = 0): BVHNode<Triangle> | BVHLeaf<Triangle> {
        // Initialize queue with root node data
        let queue: Array<{
            triangles: Array<Triangle>,
            startingId: number,
            parentId: number
        }> = [{triangles, startingId, parentId}];

        // Map to store constructed nodes by their id
        let constructedNodes: Map<number, BVHNode<Triangle> | BVHLeaf<Triangle>> = new Map();

        while (queue.length > 0) {
            const {triangles, startingId, parentId} = queue.shift()!;
            const parent = constructedNodes.get(parentId) as BVHNode<Triangle>;
            
            // Tighten bounding
            const bounding = TriangleBVH.tightenBounding(triangles);
            let node: BVHNode<Triangle> | BVHLeaf<Triangle>;

            // Base case: if there are less than BVH_MAX_TRIANGLES_PER_LEAF triangles, create a leaf
            if (triangles.length <= BVH_MAX_TRIANGLES_PER_LEAF) {
                node = new BVHLeaf(triangles, bounding, startingId, startingId + 1);
                constructedNodes.set(startingId, node);
                parent?.children.push(node);
                continue;
            }

            // Split bounding into two sub bounding volumes along the axis minimizing the cost
            const intervals = 2;
            let splitAlongAxis: "x" | "y" | "z" = "x";
            let splitAt: number = 0;
            let minCost: number = Infinity;

            // Find best split
            for (let axis of ["x", "y", "z"] as Array<"x" | "y" | "z">) {
                let splitDistIncrement = (bounding.max[axis] - bounding.min[axis]) / intervals;

                for (let i = 1; i < intervals; i++) {
                    const bounding0Max = new Vector(bounding.max);
                    const bounding1Min = new Vector(bounding.min);
                    bounding0Max[axis] = bounding.min[axis] + i * splitDistIncrement;
                    bounding1Min[axis] = bounding.min[axis] + i * splitDistIncrement;

                    const bounding0 = { min: bounding.min, max: bounding0Max };
                    const bounding1 = { min: bounding1Min, max: bounding.max };

                    const cost = TriangleBVH.evaluateSplitCost(triangles, bounding0, bounding1);
                    if (cost < minCost) {
                        minCost = cost;
                        splitAlongAxis = axis;
                        splitAt = bounding.min[axis] + i * splitDistIncrement;
                    }
                }
            }

            // If no subdivision is possible, create flat tree
            if (minCost === Infinity) {
                node = TriangleBVH.fillFlatTree(triangles, startingId, parentId);
                constructedNodes.set(startingId, node);
                parent?.children.push(node);
                continue;
            }

            // Create split bounding volumes
            const bounding0Max = new Vector(bounding.max);
            const bounding1Min = new Vector(bounding.min);
            bounding0Max[splitAlongAxis] = splitAt;
            bounding1Min[splitAlongAxis] = splitAt;

            const bounding0 = { min: bounding.min, max: bounding0Max };
            const bounding1 = { min: bounding1Min, max: bounding.max };

            // Sort triangles into bounding volumes
            const trianglesInBound0: Array<Triangle> = [];
            const trianglesInBound1: Array<Triangle> = [];

            for (let triangle of triangles) {
                const in0 = TriangleBVH.isTriangleInBounding(triangle, bounding0);
                const in1 = TriangleBVH.isTriangleInBounding(triangle, bounding1);
                if (in1) trianglesInBound1.push(triangle);
                else trianglesInBound0.push(triangle);
            }

            let children: Array<BVHNode<Triangle> | BVHLeaf<Triangle>> = [];
            let nextId = startingId + 1;

            // Add children to queue
            if (trianglesInBound0.length > 0) {
                queue.push({
                    triangles: trianglesInBound0,
                    startingId: nextId,
                    parentId: startingId
                });
                nextId += 1;
            }

            if (trianglesInBound1.length > 0) {
                queue.push({
                    triangles: trianglesInBound1,
                    startingId: nextId,
                    parentId: startingId
                });
                nextId += 1;
            }

            node = new BVHNode(children, bounding, startingId, nextId);
            constructedNodes.set(startingId, node);
            parent?.children.push(node);
        }

        return constructedNodes.get(startingId) as BVHNode<Triangle> | BVHLeaf<Triangle>;
    }
    */

    static fromPrototypeArray(prototypeArray: Array<number>): TriangleBVH {
        let triangles: Array<Triangle> = [];
        // Iterate over triangles in format V V V N N N UV UV UV
        for (let i = 0; i < prototypeArray.length; i += TRIANGLE_SIZE) {
            triangles.push(new Triangle(
                new Vector(
                    prototypeArray[i]!,
                    prototypeArray[i + 1]!,
                    prototypeArray[i + 2]!
                ),
                new Vector(
                    prototypeArray[i + 3]!,
                    prototypeArray[i + 4]!,
                    prototypeArray[i + 5]!
                ),
                new Vector(
                    prototypeArray[i + 6]!,
                    prototypeArray[i + 7]!,
                    prototypeArray[i + 8]!
                ),
                i / TRIANGLE_SIZE
            ));
        }
        // Subdivide tree
        return new TriangleBVH(triangles);
    }

    destroy() {
        this.root.destroy();
    }
}
