"use strict";

import { Parser } from "./obj-parser";
import { BufferManager } from "../buffer/buffer-manager";
import { TypedArrayView } from "../buffer/typed-array-view";
import { TriangleBVH, BVHArrays } from "./bvh";
import { Material } from "./material";

export interface PrototypeArrays {
    vertices: Array<number>;
    normals: Array<number>;
    uvs: Array<number>;
    triangles: Array<number>;
}

export class Prototype {
    // Buffer managers

    // Triangle vertices: X Y Z
    private static vertexManager = new BufferManager(Float32Array);
    // Bounding vertices: Bx By Bz
    private static boundingVertexManager = new BufferManager(Float32Array);
    // Triangle normals: Nx Ny Nz
    private static normalManager = new BufferManager(Float32Array);
    // Triangle uvs: U V
    private static uvManager = new BufferManager(Float32Array);
    // BVH structure: 0|1 BV BV B|T B|T B|T B|T
    private static BVHManager = new BufferManager(Uint32Array)
    // Triangle data: V V V N N N UV UV UV
    private static triangleManager = new BufferManager(Uint32Array);


    // Buffers
    readonly vertices: TypedArrayView<Float32Array>;
    readonly boundingVertices: TypedArrayView<Float32Array>;
    readonly normals: TypedArrayView<Float32Array>;
    readonly uvs: TypedArrayView<Float32Array>;
    readonly bvh: TypedArrayView<Uint32Array>;
    readonly triangles: TypedArrayView<Uint32Array>;

    // Construct using arrays
    constructor(
        vertices: Float32Array | Array<number>,
        boundingVertices: Float32Array | Array<number>,
        normals: Float32Array | Array<number>,
        uvs: Float32Array | Array<number>,
        bvh: Uint32Array | Array<number>,
        triangles: Uint32Array | Array<number>
    ) {
        this.vertices = Prototype.vertexManager.allocateArray(vertices);
        this.boundingVertices = Prototype.boundingVertexManager.allocateArray(boundingVertices);
        this.normals = Prototype.normalManager.allocateArray(normals);
        this.uvs = Prototype.uvManager.allocateArray(uvs);
        this.bvh = Prototype.BVHManager.allocateArray(bvh);
        this.triangles = Prototype.triangleManager.allocateArray(triangles);
    }

    // Construct from OBJ file
    static async fromObj(path: string) {
        const materials: Map<string, Material> = await Parser.mtl(path);
        const prototypeArrays: PrototypeArrays = await Parser.obj(path, materials);
        // TODO: Add bounding vertices and BVH structure
        const bvh: TriangleBVH = TriangleBVH.fromPrototypeArrays(prototypeArrays);
        const bvhArrays: BVHArrays = bvh.toArrays();
        return new Prototype(prototypeArrays.vertices, bvhArrays.boundingVertices, prototypeArrays.normals, prototypeArrays.uvs, bvhArrays.bvh, prototypeArrays.triangles);
    }

    destroy() {
        // Free all buffers
        Prototype.vertexManager.freeArray(this.vertices);
        Prototype.boundingVertexManager.freeArray(this.boundingVertices);
        Prototype.normalManager.freeArray(this.normals);
        Prototype.uvManager.freeArray(this.uvs);
        Prototype.BVHManager.freeArray(this.bvh);
        Prototype.triangleManager.freeArray(this.triangles);
    }
}
