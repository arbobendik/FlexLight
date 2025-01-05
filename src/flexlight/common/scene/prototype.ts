"use strict";

import { Parser } from "./obj-parser";

export class Prototype {
    vertices: Float32Array;
    normals: Float32Array;
    uvs: Float32Array;
    triangles: Uint32Array;


    constructor(vertices: Float32Array, normals: Float32Array, uvs: Float32Array, triangles: Uint32Array) {
        this.vertices = vertices;
        this.normals = normals;
        this.uvs = uvs;
        this.triangles = triangles;
    }

    static async fromObj(path: string) {
        const materials = await Parser.mtl(path);
        const prototypeArrays = await Parser.obj(path, materials);

        let vertices = new Float32Array(prototypeArrays.vertices);
        let normals = new Float32Array(prototypeArrays.normals);
        let uvs = new Float32Array(prototypeArrays.uvs);
        let triangles = new Uint32Array(prototypeArrays.triangles);

        const prototype = new Prototype(vertices, normals, uvs, triangles);
        return prototype;
    }
}

