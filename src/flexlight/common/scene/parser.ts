import { BIAS, normalize, vector_difference, cross, dot, Vector } from "../lib/math";
import { Material } from "./material";
import { Prototype, TRIANGLE_SIZE } from "./prototype";


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


export interface Parser {
    parse: (path: string, materials: Map<string, Material>, asSeperateObjects: boolean) => AsyncGenerator<ObjectPrototype>,
    loadMaterial: (path: string) => Promise<Map<string, Material>>
}

export class Parser implements Parser {

    protected static earClipTriangulate(vertices: Array<Vertex>, normal: Vector<3>): Array<Triangle> | undefined {
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

    
    protected static isEar(vertices: Array<Vertex>, normal: Vector<3>, i: number, prev: number, next: number): boolean {
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
    protected static isVertexConvex(vertices: Array<Vertex>, normal: Vector<3>, i: number, prev: number, next: number): boolean {
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
    protected static isPointInTriangle(p: Vector<3>, a: Vector<3>, b: Vector<3>, c: Vector<3>): boolean {
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
    };

    /*
    protected static fanTriangulate(vertices: Array<Vertex>): Array<Triangle> {
        let triangles: Array<Triangle> = [];
        for (let i = 2; i < vertices.length; i++) {
            triangles.push([vertices[0]!, vertices[i - 1]!, vertices[i]!]);
        }
        return triangles;
    }
    */
}