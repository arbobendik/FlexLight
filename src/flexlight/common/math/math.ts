"use strict";

// import { vec2, vec3, vec4, vector, mat2, mat3, mat4, mat2x2, mat3x2, mat4x2, mat2x3, mat3x3, mat4x3, mat2x4, mat3x4, mat4x4, matrix } from "./math.d";
import { Vector, Matrix, Tuple } from "./math_types";
// Vector operations
export function vector_add<T extends Vector<N>, N extends number>(a: T, b: T): T {
    let result: Vector<N> = new Vector();
    for (let i = 0; i < a.length; i++) result[i] = a[i]! + b[i]!;
    return result as T;
}

export function vector_mul<T extends Vector<N>, N extends number>(a: T, b: T): T {
    let result: Vector<N> = new Vector();
    for (let i = 0; i < a.length; i++) result[i] = a[i]! * b[i]!;
    return result as T;
}

export function dot<T extends Vector<N>, N extends number>(a: T, b: T): number {
    let result = 0;
    for (let i = 0; i < a.length; i++) result += a[i]! * b[i]!;
    return result;
}


// Matrix operations


// Direct initialization
let v1: Vector<4> = new Vector(1, 2, 3, 4);

// Array initialization
let v2: Vector<3> = new Vector([1, 2, 3]);
let v3: Vector<3> = new Vector(new Array(3).fill(1) as Tuple<number, 3>);

//export function cross<T extends Vector<3>>(a: T, b: T): T {

// let m = new Matrix(v1, v3, v3);