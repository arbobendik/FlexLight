"use strict";

import { cross, normalize, Vector, vector_difference } from "../lib/math";
import { Material } from "./material";
import { ObjectPrototype } from "./parser";
import { Parser } from "./parser";

// Basic GLTF type definitions
interface Gltf {
    scenes: { nodes: number[] }[];
    nodes: { mesh?: number; children?: number[]; name?: string }[];
    meshes: { primitives: GltfPrimitive[]; name?: string }[];
    materials?: {
        name?: string;
        pbrMetallicRoughness?: {
            baseColorFactor?: [number, number, number, number];
            metallicFactor?: number;
            roughnessFactor?: number;
        };
        emissiveFactor?: [number, number, number];
    }[];
    accessors: {
        bufferView?: number;
        byteOffset?: number;
        componentType: number;
        count: number;
        type: "SCALAR" | "VEC2" | "VEC3" | "VEC4";
    }[];
    bufferViews: {
        buffer: number;
        byteOffset?: number;
        byteLength: number;
    }[];
    buffers: { uri: string; byteLength: number }[];
}

interface GltfPrimitive {
    attributes: {
        POSITION?: number;
        NORMAL?: number;
        TEXCOORD_0?: number;
    };
    indices?: number;
    material?: number;
    mode?: number;
}

const componentTypeToSize = (componentType: number): number => {
    switch (componentType) {
        case 5120: return 1; // BYTE
        case 5121: return 1; // UNSIGNED_BYTE
        case 5122: return 2; // SHORT
        case 5123: return 2; // UNSIGNED_SHORT
        case 5125: return 4; // UNSIGNED_INT
        case 5126: return 4; // FLOAT
        default: throw new Error(`Unsupported componentType: ${componentType}`);
    }
}

const typeToComponentCount = (type: "SCALAR" | "VEC2" | "VEC3" | "VEC4"): number => {
    switch (type) {
        case "SCALAR": return 1;
        case "VEC2": return 2;
        case "VEC3": return 3;
        case "VEC4": return 4;
        default: throw new Error(`Unsupported type: ${type}`);
    }
}

const getAccessorData = (gltf: Gltf, accessorIndex: number, buffers: ArrayBuffer[]): Float32Array | Uint32Array | Uint16Array | Int16Array | Uint8Array | Int8Array => {
    const accessor = gltf.accessors[accessorIndex];
    if (!accessor) {
        throw new Error(`Accessor with index ${accessorIndex} not found.`);
    }
    if (accessor.bufferView === undefined) throw new Error("Accessor does not have a bufferView.");
    
    const bufferView = gltf.bufferViews[accessor.bufferView];
    if (!bufferView) {
        throw new Error(`BufferView with index ${accessor.bufferView} not found.`);
    }

    const buffer = buffers[bufferView.buffer];
    if (!buffer) {
        throw new Error(`Buffer with index ${bufferView.buffer} not found.`);
    }

    const byteOffset = (bufferView.byteOffset || 0) + (accessor.byteOffset || 0);
    const componentSize = componentTypeToSize(accessor.componentType);
    const componentCount = typeToComponentCount(accessor.type);
    const count = accessor.count;
    const length = count * componentCount;

    switch (accessor.componentType) {
        case 5126: // FLOAT
            return new Float32Array(buffer, byteOffset, length);
        case 5125: // UNSIGNED_INT
            return new Uint32Array(buffer, byteOffset, length);
        case 5123: // UNSIGNED_SHORT
            return new Uint16Array(buffer, byteOffset, length);
        case 5122: // SHORT
            return new Int16Array(buffer, byteOffset, length);
        case 5121: // UNSIGNED_BYTE
            return new Uint8Array(buffer, byteOffset, length);
        case 5120: // BYTE
            return new Int8Array(buffer, byteOffset, length);
        default:
            throw new Error(`Unsupported componentType for data extraction: ${accessor.componentType}`);
    }
}


export class GltfParser extends Parser {
    // Create object from .gltf file
    static async *parse(path: string): AsyncGenerator<ObjectPrototype> {
        console.log("Fetching GLTF file:", path);
        const gltfUrl = new URL(path, window.location.href);
        const gltfResponse = await fetch(gltfUrl);
        const gltf = await gltfResponse.json() as Gltf;
        console.log("Parsed GLTF JSON:", gltf);


        console.log("Loading buffers...");
        const buffers: ArrayBuffer[] = await Promise.all(gltf.buffers.map(async (bufferInfo, i) => {
            const bufferUrl = new URL(bufferInfo.uri, gltfUrl.href);
            console.log(`Fetching buffer ${i}:`, bufferUrl.href);
            const bufferResponse = await fetch(bufferUrl);
            const arrayBuffer = await bufferResponse.arrayBuffer();
            console.log(`Buffer ${i} loaded, size:`, arrayBuffer.byteLength);
            return arrayBuffer;
        }));
        console.log("All buffers loaded.");

        console.log("Parsing materials...");
        const materials: Material[] = (gltf.materials || []).map((mat, i) => {
            console.log(`Parsing material ${i}:`, mat);
            const material = new Material();
            if (mat.pbrMetallicRoughness?.baseColorFactor) {
                material.color = new Vector(...mat.pbrMetallicRoughness.baseColorFactor.slice(0, 3) as [number, number, number]);
            }
            if (mat.emissiveFactor) {
                material.emissive = new Vector(...mat.emissiveFactor);
            }
            if(mat.pbrMetallicRoughness?.roughnessFactor !== undefined) {
                material.roughness = mat.pbrMetallicRoughness.roughnessFactor;
            }
            console.log(`Created material ${i}:`, material);
            return material;
        });
        console.log("All materials parsed.");

        for (const [i, node] of gltf.nodes.entries()) {
            console.log(`Processing node ${i}:`, node);
            if (node.mesh === undefined) {
                console.log(`Node ${i} has no mesh, skipping.`);
                continue;
            }
            
            const mesh = gltf.meshes[node.mesh];
            if (!mesh) {
                console.log(`Mesh ${node.mesh} not found for node ${i}, skipping.`);
                continue;
            }
            console.log(`Processing mesh ${node.mesh} for node ${i}:`, mesh);

            for (const [j, primitive] of mesh.primitives.entries()) {
                console.log(`Processing primitive ${j} of mesh ${node.mesh}:`, primitive);
                if (primitive.mode !== undefined && primitive.mode !== 4) { // 4 is TRIANGLES
                    console.warn(`Unsupported primitive mode: ${primitive.mode}, skipping primitive.`);
                    continue;
                }

                const attributes = primitive.attributes;
                if (attributes.POSITION === undefined) {
                    console.warn("Primitive has no POSITION attribute, skipping.");
                    continue;
                }
                
                console.log("Getting position data...");
                const positionsAccessor = gltf.accessors[attributes.POSITION];
                if (!positionsAccessor) {
                    console.warn("Position accessor not found, skipping.");
                    continue;
                }

                const positions = getAccessorData(gltf, attributes.POSITION, buffers) as Float32Array;
                console.log("Got position data, count:", positionsAccessor.count);

                let normals: Float32Array | undefined;
                if (attributes.NORMAL !== undefined) {
                    console.log("Getting normal data...");
                    normals = getAccessorData(gltf, attributes.NORMAL, buffers) as Float32Array;
                    console.log("Got normal data.");
                }
                
                let uvs: Float32Array | undefined;
                if (attributes.TEXCOORD_0 !== undefined) {
                    console.log("Getting UV data...");
                    uvs = getAccessorData(gltf, attributes.TEXCOORD_0, buffers) as Float32Array;
                    console.log("Got UV data.");
                }

                let indices: ReturnType<typeof getAccessorData> | undefined;
                if (primitive.indices !== undefined) {
                    console.log("Getting indices data...");
                    indices = getAccessorData(gltf, primitive.indices, buffers);
                    console.log("Got indices data, length:", indices.length);
                }
                
                const triangles: number[] = [];
                console.log("Generating triangles...");

                if (indices) {
                    for (let i = 0; i < indices.length; i += 3) {
                        const i0 = indices[i];
                        const i1 = indices[i+1];
                        const i2 = indices[i+2];

                        if (i0 === undefined || i1 === undefined || i2 === undefined) {
                            console.warn("Incomplete triangle in indices array");
                            continue;
                        }

                        const p0 = positions.subarray(i0*3, i0*3+3);
                        const p1 = positions.subarray(i1*3, i1*3+3);
                        const p2 = positions.subarray(i2*3, i2*3+3);

                        triangles.push(...p0, ...p1, ...p2);
                        
                        if (normals) {
                            triangles.push(...normals.subarray(i0*3, i0*3+3));
                            triangles.push(...normals.subarray(i1*3, i1*3+3));
                            triangles.push(...normals.subarray(i2*3, i2*3+3));
                        } else {
                            const v0 = new Vector<3>(...Array.from(p0) as [number, number, number]);
                            const v1 = new Vector<3>(...Array.from(p1) as [number, number, number]);
                            const v2 = new Vector<3>(...Array.from(p2) as [number, number, number]);
                            const normal = normalize(cross(vector_difference(v1, v0), vector_difference(v2, v0)));
                            triangles.push(...normal, ...normal, ...normal);
                        }
                        if (uvs) {
                            triangles.push(...uvs.subarray(i0*2, i0*2+2));
                            triangles.push(...uvs.subarray(i1*2, i1*2+2));
                            triangles.push(...uvs.subarray(i2*2, i2*2+2));
                        } else {
                            triangles.push(0,0, 0,0, 0,0);
                        }
                    }
                } else {
                    for (let i = 0; i < positionsAccessor.count; i += 3) {
                        const i0 = i;
                        const i1 = i + 1;
                        const i2 = i + 2;

                        const p0 = positions.subarray(i0*3, i0*3+3);
                        const p1 = positions.subarray(i1*3, i1*3+3);
                        const p2 = positions.subarray(i2*3, i2*3+3);

                        triangles.push(...p0, ...p1, ...p2);

                        if(normals){
                            triangles.push(...normals.subarray(i0*3, i0*3+3));
                            triangles.push(...normals.subarray(i1*3, i1*3+3));
                            triangles.push(...normals.subarray(i2*3, i2*3+3));
                        } else {
                            const v0 = new Vector<3>(...Array.from(p0) as [number, number, number]);
                            const v1 = new Vector<3>(...Array.from(p1) as [number, number, number]);
                            const v2 = new Vector<3>(...Array.from(p2) as [number, number, number]);
                            const normal = normalize(cross(vector_difference(v1, v0), vector_difference(v2, v0)));
                            triangles.push(...normal, ...normal, ...normal);
                        }
                        if(uvs){
                            triangles.push(...uvs.subarray(i0*2, i0*2+2));
                            triangles.push(...uvs.subarray(i1*2, i1*2+2));
                            triangles.push(...uvs.subarray(i2*2, i2*2+2));
                        } else {
                            triangles.push(0,0, 0,0, 0,0);
                        }
                    }
                }
                
                let material: Material;
                if (primitive.material !== undefined && materials[primitive.material]) {
                    material = materials[primitive.material]!;
                    console.log(`Assigned material ${primitive.material} to primitive.`);
                } else {
                    material = new Material();
                    console.log("Assigned default material to primitive.");
                }
                const label = mesh.name ?? node.name ?? `mesh_${node.mesh}_primitive`;
                
                console.log(`Generated ${triangles.length / 24} triangles for primitive. Label: ${label}`);

                if (triangles.length > 0) {
                    console.log("Yielding object prototype.");
                    yield { triangles, material, label };
                }
            }
        }
        console.log("Finished parsing all nodes.");
    }
}