"use strict";

import { Vector, vector_scale } from "../lib/math";
import { Material } from "./material";

export interface ObjArrays {
    vertices: Array<number>;
    normals: Array<number>;
    uvs: Array<number>;
    triangles: Array<number>;
}

export class Parser {
    // Create object from .obj file
    static obj = async (path: string, materials: Map<string, Material>): Promise<ObjArrays> => {
        // final object variable 
        let obj: ObjArrays = { vertices: [], normals: [], uvs: [], triangles: [] };
        // track current material
        let curMaterialName: string | undefined = undefined;
        // line interpreter
        let interpreteLine = (line: string) => {
            let words: Array<string> = [];
            // get array of words
            line.split(/[\t \s\s+]/g).forEach(word => { if (word.length) words.push(word) });
            // interpret current line
            switch (words[0]) {
                case "v":
                    // push vertex
                    obj.vertices.push(Number(words[1]), Number(words[2]), Number(words[3]));
                    break;
                case "vt":
                    // push uv
                    obj.uvs.push(Number(words[1]), Number(words[2]));
                    break;
                case "vn":
                    // push normal
                    obj.normals.push(Number(words[1]), Number(words[2]), Number(words[3]));
                    break;
                case "f":
                    // Discard first word
                    let dataString = words.slice(1, words.length).join(' ');
                    // "-" or space is sperating different vertices while "/" seperates different properties
                    // extract array indecies form string
                    let data = dataString.split(/[ ]/g).filter(vertex => vertex.length).map(vertex => vertex.split(/[/]/g).map(numStr => {
                        let num = Number(numStr);
                        if (num < 0) num = obj.vertices.length + num + 1;
                        return num;
                    }));
                
                    // test if new part should be a triangle or plane
                    if (data.length === 4 && data[1] && data[2] && data[3]) {
                        obj.triangles.push(
                            // Triangle 3 2 1
                            data[3]![0]!, data[2]![0]!, data[1]![0]!,
                            data[3]![1]!, data[2]![1]!, data[1]![1]!,
                            data[3]![2]!, data[2]![2]!, data[1]![2]!,
                            // Triangle 1 0 3
                            data[1]![0]!, data[0]![0]!, data[3]![0]!,
                            data[1]![1]!, data[0]![1]!, data[3]![1]!,
                            data[1]![2]!, data[0]![2]!, data[3]![2]!
                        );
                    } else if (data.length === 3 && data[1] && data[2] && data[3]) {
                        obj.triangles.push(
                            // Triangle 2 1 0
                            data[2]![0]!, data[1]![0]!, data[0]![0]!,
                            data[2]![1]!, data[1]![1]!, data[0]![1]!,
                            data[2]![2]!, data[1]![2]!, data[0]![2]!
                        );
                    } else {
                        console.warn('Invalid face data:', data);
                    }
                    break;
                case 'usemtl':
                    // Use material name for next vertices
                    if (materials[words[1] as keyof typeof materials]) {
                        curMaterialName = words[1];
                    } else {
                        console.warn('Couldn\'t resolve material', curMaterialName);
                    }
                    break;
            }
        };
        // fetch file and iterate over its lines
        let text = await (await fetch(path)).text();
        console.log('Parsing vertices ...');
        text.split(/\r\n|\r|\n/).forEach(line => interpreteLine(line));
        // return built object
        return obj;
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
              materials.set(currentMaterialName, { color: new Vector(255, 255, 255), roughness: 0, metallic: 0, emissive: 0, transmission: 0, ior: 0 });
              break;
            case 'Ka':
              materials.get(currentMaterialName)!.color = vector_scale(new Vector(Number(words[1]), Number(words[2]), Number(words[3])), 255);
              break;
            case 'Ke':
              let emissiveness = Math.max(Number(words[1]), Number(words[2]), Number(words[3]));
              // Replace color if emissiveness is not 0
              if (emissiveness > 0) {
                materials.get(currentMaterialName)!.emissive = emissiveness * 4;
                materials.get(currentMaterialName)!.color = vector_scale(new Vector(Number(words[1]), Number(words[2]), Number(words[3])), 255 / emissiveness);
              }
              break;
            case 'Ns':
              materials.get(currentMaterialName)!.metallic = Number(words[1]) / 1000;
              break;
            case 'd':
              // materials[currentMaterialName].translucency = Number(words[1]);
              // materials[currentMaterialName].roughness = 0;
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