"use strict";

import { cross, normalize, Vector, vector_difference, vector_scale, dot, BIAS, vector_length } from "../lib/math";
import { Material } from "./material";


export interface ObjectPrototype {
    triangles: Array<number>;
    material: Material;
    label: string;
}

export interface Vertex {
    position: Vector<3>;
    normal: Vector<3> | undefined;
    uv: Vector<2> | undefined;
}

export type Triangle = [Vertex, Vertex, Vertex];


export class Parser {
    /*
    private static fanTriangulate(vertices: Array<Vertex>): Array<Triangle> {
        let triangles: Array<Triangle> = [];
        for (let i = 2; i < vertices.length; i++) {
            triangles.push([vertices[0]!, vertices[i - 1]!, vertices[i]!]);
        }
        return triangles;
    }
    */

    private static earClipTriangulate(vertices: Array<Vertex>, normal: Vector<3>): Array<Triangle> | undefined {
        // Need at least 3 vertices to form a triangle
        if (vertices.length < 3) {
            return [];
        }
        
        // If we have exactly 3 vertices, return a single triangle
        if (vertices.length === 3) {
            return [[vertices[0]!, vertices[1]!, vertices[2]!]];
        }
        
        // Create a working copy of the vertices
        const remainingVertices = [...vertices];
        
        // Array to store the resulting triangles
        const triangles: Array<Triangle> = [];
        
        // Continue until we have reduced the polygon to a triangle
        while (remainingVertices.length > 3) {
            let earFound = false;
            
            // Try to find an ear
            for (let i = 0; i < remainingVertices.length; i++) {
                const prev = (i === 0) ? remainingVertices.length - 1 : i - 1;
                const next = (i === remainingVertices.length - 1) ? 0 : i + 1;
                
                // Check if vertex i forms an ear
                if (Parser.isEar(remainingVertices, normal, i, prev, next)) {
                    // Create a triangle from the ear
                    triangles.push([
                        remainingVertices[prev]!,
                        remainingVertices[i]!,
                        remainingVertices[next]!
                    ]);
                    
                    // Remove the ear vertex
                    remainingVertices.splice(i, 1);
                    
                    earFound = true;
                    break;
                }
            }
            
            // If no ear is found (shouldn't happen in a simple polygon), break to avoid infinite loop
            if (!earFound) {
                console.warn("No ear found in polygon triangulation. Polygon may be malformed.");
                console.log(normal);
                // console.warn("No ear found in polygon triangulation. Polygon may be malformed.");
                return undefined;

            }
        }
        
        // Add the final triangle
        if (remainingVertices.length === 3) {
            triangles.push([
                remainingVertices[0]!,
                remainingVertices[1]!,
                remainingVertices[2]!
            ]);
        }
        
        return triangles;
    }

    
    private static isEar(vertices: Array<Vertex>, normal: Vector<3>, i: number, prev: number, next: number): boolean {
        // First check if the vertex is convex
        if (!Parser.isVertexConvex(vertices, normal, i, prev, next)) {
            return false;
        }
        
        // Create the triangle
        const a = vertices[prev]!.position;
        const b = vertices[i]!.position;
        const c = vertices[next]!.position;
        
        // Check if any other vertex is inside this triangle
        for (let j = 0; j < vertices.length; j++) {
            // Skip the vertices that form the ear
            if (j === i || j === prev || j === next) {
                continue;
            }
            
            // Check if vertex j is inside the triangle
            if (Parser.isPointInTriangle(vertices[j]!.position, a, b, c)) {
                return false;
            }
        }
        
        return true;
    }

    // Checks if a vertex is convex (internal angle < 180 degrees).
    private static isVertexConvex(vertices: Array<Vertex>, normal: Vector<3>, i: number, prev: number, next: number): boolean {
        const a = vertices[prev]!.position;
        const b = vertices[i]!.position;
        const c = vertices[next]!.position;
        
        // Calculate vectors
        const v1 = normalize(vector_difference(a, b));
        const v2 = normalize(vector_difference(c, b));
        
        // Calculate the cross product
        const crossProduct = cross(v1, v2);
        
        // If the dot product of the cross product and normal is positive,
        // the vertex is convex 
        return dot(crossProduct, normal) >= BIAS;
    }

    // Checks if a point is inside a triangle using barycentric coordinates.
    private static isPointInTriangle(p: Vector<3>, a: Vector<3>, b: Vector<3>, c: Vector<3>): boolean {
        // Compute vectors
        const v0 = vector_difference(c, a);
        const v1 = vector_difference(b, a);
        const v2 = vector_difference(p, a);
        // Compute dot products
        const dot00 = dot(v0, v0);
        const dot01 = dot(v0, v1);
        const dot02 = dot(v0, v2);
        const dot11 = dot(v1, v1);
        const dot12 = dot(v1, v2);
        // Compute barycentric coordinates
        const invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
        const u = (dot11 * dot02 - dot01 * dot12) * invDenom;
        const v = (dot00 * dot12 - dot01 * dot02) * invDenom;
        
        // Check if point is in triangle
        return Math.min(u, v) > BIAS && u + v < 1.0 - BIAS;
        // return (u >= 0) && (v >= 0) && (u + v <= 1);
    }

    // Create object from .obj file
    static async *obj(path: string, materials: Map<string, Material>, asSeperateObjects: boolean = true): AsyncGenerator<ObjectPrototype> {
        // Use counters to keep track of the current index of the vertices, normals and uvs
        let vertexOffset = 1;
        let normalOffset = 1;
        let uvOffset = 1;
        // Create Map for vertices, normals and uvs
        let accumulateVertices: Map<number, [number, number, number]> = new Map();
        let accumulateNormals: Map<number, [number, number, number]> = new Map();
        let accumulateUvs: Map<number, [number, number]> = new Map();
        // Create Map for vertices, normals and uvs that are used in the current object
        let oldVertices: Map<number, [number, number, number]> = new Map();
        let oldNormals: Map<number, [number, number, number]> = new Map();
        let oldUvs: Map<number, [number, number]> = new Map();
        // track current material
        let curMaterialName: string | undefined = undefined;
        let curObjectName: string | undefined = undefined;
        // final object variable 
        let triangleCount = 0;
        let triangles: Array<number> = [];

        // fetch file and iterate over its lines
        const text = await (await fetch(path)).text();
        console.log('Parsing vertices ...');

        const lines = text.split(/\r\n|\r|\n/);
        const lineNumber = lines.length;

        const addTriangle = (v1: Vertex, v2: Vertex, v3: Vertex, normal: Vector<3>) => {
            if (!v1 || !v2 || !v3) {
                console.warn("Invalid triangle", v1, v2, v3);
                return;
            }
            triangles.push(...v1.position, ...v2.position, ...v3.position);
            // Test if normals are defined, otherwise compute from vertices
            if (v1.normal && v2.normal && v3.normal) {
                triangles.push(...normalize(v1.normal), ...normalize(v2.normal), ...normalize(v3.normal));
            } else {
                triangles.push(...normal, ...normal, ...normal);
            }
            // Test if uvs are defined, otherwise use default uvs
            if (v1.uv && v2.uv && v3.uv) {
                triangles.push(...v1.uv, ...v2.uv, ...v3.uv);
            } else {
                triangles.push(1, 1, 1, 1, 1, 1);
            }
            triangleCount += 1;

            // console.log(triangles, triangleCount);
        }

        const objectReference = (line: number, objectName: string): ObjectPrototype | undefined => {
            let result: ObjectPrototype | undefined = undefined;
            // Only yeild object if this is not the first object
            if (triangleCount > 0) {
                console.log("Line:", line);
                // Clear old maps
                oldVertices.clear();
                oldNormals.clear();
                oldUvs.clear();
                // Copy old maps to reuse them as new maps without new reallocation
                /*
                let tempVertices = oldVertices;
                let tempNormals = oldNormals;
                let tempUvs = oldUvs;
                // Copy accumulated maps to use maps
                oldVertices = accumulateVertices;
                oldNormals = accumulateNormals;
                oldUvs = accumulateUvs;
                // Clear accumulate maps
                accumulateVertices = tempVertices;
                accumulateNormals = tempNormals;
                accumulateUvs = tempUvs;
                */
                // Log object name and triangle count
                console.log("Object name:", objectName);
                console.log("Triangle count:", triangleCount);

                const material = curMaterialName ? materials.get(curMaterialName)! : new Material();
                console.log("Material:", curMaterialName, material);
                // Reset material name
                curMaterialName = undefined;
                curObjectName = undefined;
                // Return object
                result = { triangles, material, label: objectName };
            }
            // Clear triangle array in any case
            triangleCount = 0;
            triangles = [];
            // Yield triangles
            return result;
        }
        // Iterate over lines
        for (let i = 0; i < lineNumber; i++) {
            // Fetch line
            const line: string = lines[i] ?? "";
            // Convert line to array of words
            let words: Array<string> = [];
            line.split(/[\t \s\s+]/g).forEach(word => { if (word.length) words.push(word) });
            // interpret current line
            switch (words[0]) {
                
                case "o":
                    if (asSeperateObjects) {
                        let result = objectReference(i, curObjectName ?? "");
                        curObjectName = words[1] ?? "";
                        if (result) yield result;
                    }
                    break;
                case "g":
                    if (asSeperateObjects) {
                        let result = objectReference(i, curObjectName ?? "");
                        curObjectName = words[1] ?? "";
                        if (result) yield result;
                    }
                    break;
                case "v":
                    // push vertex
                    accumulateVertices.set(vertexOffset++, [Number(words[1]!), Number(words[2]!), Number(words[3]!)]);
                    break;
                case "vt":
                    // push uv
                    accumulateUvs.set(uvOffset++, [Number(words[1]), Number(words[2])]);
                    break;
                case "vn":
                    // push normal
                    accumulateNormals.set(normalOffset++, [Number(words[1]), Number(words[2]), Number(words[3])]);
                    break;
                case "f":
                    // Discard first word
                    let dataString = words.slice(1, words.length).join(' ');
                    // "-" or space is sperating different vertices while "/" seperates different properties
                    // extract array indecies form string
                    let data = dataString.split(/[ ]/g).filter(vertex => vertex.length).map(vertex => vertex.split(/[/]/g).map((numStr, index) => {
                        let num: number = Number(numStr);
                        if (num < 0 && index === 0) num += vertexOffset;
                        if (num < 0 && index === 1) num += uvOffset;
                        if (num < 0 && index === 2) num += normalOffset;
                        return num;
                    }));

                    let allValid = data.reduce((acc, curr) => acc && !!curr, true);


                    if (data.length < 3 || !allValid) {
                        console.warn('Invalid face data:', data);
                        console.warn(i, line);
                        break;
                    }

                    let vertices: Array<Vertex> = [];
                    
                    for (let j = 0; j < data.length; j++) {
                        let posVec: [number, number, number] | undefined = oldVertices.get(data[j]![0]!) ?? accumulateVertices.get(data[j]![0]!);
                        let normalVec: [number, number, number] | undefined = oldNormals.get(data[j]![2]!) ?? accumulateNormals.get(data[j]![2]!);
                        let uvVec: [number, number] | undefined = oldUvs.get(data[j]![1]!) ?? accumulateUvs.get(data[j]![1]!);
                        
                        if (!posVec) {
                            console.warn('Invalid vertex data:', data[j]);
                            console.warn(i, line);
                            continue;
                        } else {
                            vertices.push({
                                position: new Vector<3>(posVec),
                                normal: normalVec ? new Vector<3>(normalVec) : undefined,
                                uv: uvVec ? new Vector<2>(uvVec) : undefined
                            });
                        }
                    }
                    
                    let geometryNormal = new Vector<3>(0, 0, 0);

                    for (let j = 2; j < data.length; j++) {
                        if (!vertices[0] || !vertices[j] || !vertices[j - 1]) {
                            console.warn("Malformed vertices:", vertices[0], vertices[j], vertices[j - 1]);
                            continue;
                        }

                        let v0 = vector_difference(vertices[0]!.position, vertices[j]!.position);
                        let v1 = vector_difference(vertices[0]!.position, vertices[j - 1]!.position);
                        geometryNormal = normalize(cross(v1, v0));
                        // If all vectors are non-zero, break
                        if (vector_length(v0) > BIAS && vector_length(v1) > BIAS && vector_length(geometryNormal) > BIAS) break;
                    }

                    if (vector_length(geometryNormal) <= BIAS) {
                        console.warn("All vertices are on a line or polygon is degenerate.");
                        break;
                    }

                    // Set all unset normals to the geometry normal
                    for (let j = 0; j < vertices.length; j++) {
                        if (!vertices[j]!.normal) vertices[j]!.normal = geometryNormal;
                    }

                    let invertedNormal: Vector<3> = vector_scale(geometryNormal, -1);
                    // Use ear clipping for potentially concave polygons
                    let triangulated = Parser.earClipTriangulate(vertices, invertedNormal);
                    // If success, add triangles
                    if (triangulated) {
                        for (const triangle of triangulated) addTriangle(triangle[0], triangle[1], triangle[2], invertedNormal);
                        break;
                    }

                    // Try again to triangulate with invertedNormal
                    triangulated = Parser.earClipTriangulate(vertices, geometryNormal);
                    if (triangulated) {
                        for (const triangle of triangulated) addTriangle(triangle[0], triangle[1], triangle[2], geometryNormal);
                        break;
                    }

                    console.warn("Failed to triangulate polygon.");
                    break;
                case 'usemtl':
                    // Use material name for next vertices
                    if (materials.get(words[1]!)) {
                        curMaterialName = words[1];
                    } else {
                        console.warn('Couldn\'t resolve material', words[1]);
                    }
                    // If we are not parsing seperate objects, yield the object
                    if (asSeperateObjects) {
                        let result = objectReference(i, curObjectName ?? "");
                        curObjectName = words[1] ?? "";
                        console.log("next object:", curObjectName);
                        if (result) yield result;
                    }
                    break;
            }
        }

        // Yeild final object till end of file
        let result = objectReference(lineNumber, curObjectName ?? "");
        if (result) yield result;
    }

    static mtl = async (path: string): Promise<Map<string, Material>> => {
        // Accumulate information
        let materials = new Map<string, Material>();
        let currentMaterialName: string = "";
        // line interpreter
        let interpreteLine = (line: string) => {
            let words: Array<string> = [];
            // get array of words
            line.split(/[\t \s\s+]/g).forEach(word => { if (word.length) words.push(word) });

            // interpret current line
            switch (words[0]) {
                case 'newmtl':
                    currentMaterialName = words[1] ?? "";
                    materials.set(currentMaterialName, new Material());
                    break;
                case 'Kd':
                    materials.get(currentMaterialName)!.color = new Vector(Number(words[1]), Number(words[2]), Number(words[3]));
                    break;
                case 'Ke':
                    let emissiveness: Vector<3> = new Vector(Number(words[1]), Number(words[2]), Number(words[3]));
                    materials.get(currentMaterialName)!.emissive = emissiveness;
                    // Replace color if emissiveness is not 0
                    break;
                case 'Ns':
                    materials.get(currentMaterialName)!.roughness = 1 - Number(words[1]) / 1000;
                    break;
                case 'd':
                    materials.get(currentMaterialName)!.transmission = 1 - Number(words[1]);
                    break;
                case 'Ni':
                    materials.get(currentMaterialName)!.ior = Number(words[1]);
                    break;
            }
        };
        // fetch file and iterate over its lines
        let text = await (await fetch(path)).text();
        console.log('Parsing materials ...');
        text.split(/\r\n|\r|\n/).forEach(line => interpreteLine(line));
        // Log materials
        console.log(materials);
        // return filled materials array
        return materials;
    }
}