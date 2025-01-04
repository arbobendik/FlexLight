"use strict";
export const BIAS = 1e-10;
export const E = 2.718281828459045;
export const PI = 3.141592653589793;
export class Vector extends Float32Array {
    // Getters for components
    get x() {
        if (this.length > 0)
            return this[0];
        else
            throw new Error('Vector has no x component');
    }
    get y() {
        if (this.length > 1)
            return this[1];
        else
            throw new Error('Vector has no y component');
    }
    get z() {
        if (this.length > 2)
            return this[2];
        else
            throw new Error('Vector has no z component');
    }
    get w() {
        if (this.length > 3)
            return this[3];
        else
            throw new Error('Vector has no w component');
    }
    // Setters for components
    set x(value) { this[0] = value; }
    set y(value) { this[1] = value; }
    set z(value) { this[2] = value; }
    set w(value) { this[3] = value; }
    // Constructor for the Vector class
    constructor(...args) {
        let all_numbers = true;
        for (let arg of args)
            if (typeof arg !== 'number')
                all_numbers = false;
        if (args.length === 1 && !all_numbers) {
            // Test if first argument is a VectorDimensions object
            if ('vector_length' in args[0]) {
                // Attribute is vector_length
                super(args[0].vector_length);
            }
            else {
                // Otherwise, initialize vector with tuple
                super(args[0]);
            }
        }
        else if (all_numbers) {
            // Otherwise, initialize vector with spread tuple
            super(args);
        }
        else {
            throw new Error('Invalid arguments for Vector constructor.');
        }
    }
    *[Symbol.iterator]() {
        for (let i = 0; i < this.length; i++)
            yield this[i];
    }
}
export class ZeroVector extends Vector {
    constructor(n) {
        super({ vector_length: n });
        for (let i = 0; i < n; i++)
            this[i] = 0;
    }
}
export class Matrix extends Array {
    get(x, y) {
        return this[x][y];
    }
    set(x, y, value) {
        this[x][y] = value;
    }
    // Constructor for the Matrix class
    constructor(...rows) {
        // Type assertion for size attributes, matrix is row major
        Object.defineProperty(this, "height", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        Object.defineProperty(this, "width", {
            enumerable: true,
            configurable: true,
            writable: true,
            value: void 0
        });
        let all_arrays = true;
        for (let row of rows)
            if (!Array.isArray(row))
                all_arrays = false;
        if (rows.length === 1 && 'matrix_height' in rows[0] && 'matrix_width' in rows[0]) {
            let dims = rows[0];
            // Initialize matrix with zeros
            super(dims.matrix_height);
            // Initialize height and width
            this.height = dims.matrix_height;
            this.width = dims.matrix_width;
            // Initialize row vectors
            for (let i = 0; i < dims.matrix_height; i++) {
                this[i] = new Vector({ vector_length: dims.matrix_width });
            }
        }
        else if (!all_arrays) {
            // Initialize matrix with given row vector tuple
            super(...rows);
            // Initialize height and width
            this.height = this.length;
            this.width = this[0].length;
        }
        else if (all_arrays) {
            // Initialize matrix with given number values.
            let vectors = rows.map(row => new Vector(row));
            super(...vectors);
            // Initialize height and width
            this.height = this.length;
            this.width = this[0].length;
        }
        else {
            // Invalid number of rows
            throw new Error('Invalid number of rows');
        }
    }
    *[Symbol.iterator]() {
        // Iterate over row vectors
        for (let i = 0; i < this.length; i++)
            yield this[i];
    }
}
export class IdentityMatrix extends Matrix {
    constructor(n) {
        super({ matrix_height: n, matrix_width: n });
        for (let i = 0; i < n; i++) {
            let row = this[i];
            row[i] = 1;
        }
    }
}
export class ZeroMatrix extends Matrix {
    constructor(m, n) {
        super({ matrix_height: m, matrix_width: n });
        for (let i = 0; i < m; i++)
            this[i] = new ZeroVector(n);
    }
}
export class HouseholderMatrix extends IdentityMatrix {
    constructor(v) {
        // Create identity matrix
        super(v.length);
        // Calculate 2(v⊗v)/(v·v)
        let outer_product = outer(v, v);
        let scale = 2.0 / dot(v, v);
        // H = I - 2(v⊗v)/(v·v)
        for (let i = 0; i < this.height; i++)
            for (let j = 0; j < this.width; j++)
                this[i][j] -= scale * outer_product[i][j];
    }
}
export class SphericalRotationMatrix extends Matrix {
    constructor(theta, psi) {
        let sT = Math.sin(theta);
        let cT = Math.cos(theta);
        let sP = Math.sin(psi);
        let cP = Math.cos(psi);
        super([cT, 0, sT], [-sT * sP, cP, cT * sP], [-sT * cP, -sP, cT * cP]);
    }
}
// Vector operations
export function vector_add(a, b) {
    let result = new Vector({ vector_length: a.length });
    for (let i = 0; i < a.length; i++)
        result[i] = a[i] + b[i];
    return result;
}
export function vector_difference(a, b) {
    let result = new Vector({ vector_length: a.length });
    for (let i = 0; i < a.length; i++)
        result[i] = a[i] - b[i];
    return result;
}
export function vector_distance(a, b) {
    let result = 0;
    for (let i = 0; i < a.length; i++)
        result += (a[i] - b[i]) ** 2;
    return Math.sqrt(result);
}
export function vector_hadamard(a, b) {
    let result = new Vector({ vector_length: a.length });
    for (let i = 0; i < a.length; i++)
        result[i] = a[i] * b[i];
    return result;
}
export function vector_scale(a, b) {
    let result = new Vector({ vector_length: a.length });
    for (let i = 0; i < a.length; i++)
        result[i] = a[i] * b;
    return result;
}
export function dot(a, b) {
    let result = 0;
    for (let i = 0; i < a.length; i++)
        result += a[i] * b[i];
    return result;
}
export function normalize(a) {
    let result = new ZeroVector(a.length);
    let denominator = Math.sqrt(dot(a, a));
    // Return zero vector if denominator is too small
    if (Math.abs(denominator) < BIAS)
        return result;
    for (let i = 0; i < a.length; i++)
        result[i] = a[i] / denominator;
    return result;
}
export function cross(a, b) {
    return new Vector(a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]);
}
export function outer(a, b) {
    let result = new Matrix({ matrix_height: a.length, matrix_width: b.length });
    for (let i = 0; i < result.height; i++)
        for (let j = 0; j < result.width; j++)
            result[i][j] = a[i] * b[j];
    return result;
}
// Matrix operations
export function transpose(A) {
    let result = new Matrix({ matrix_height: A.width, matrix_width: A.height });
    for (let i = 0; i < result.height; i++)
        for (let j = 0; j < result.width; j++)
            result[i][j] = A[j][i];
    return result;
}
export function matrix_add(A, B) {
    let result = new Matrix({ matrix_height: A.height, matrix_width: A.width });
    for (let i = 0; i < result.height; i++)
        result[i] = vector_add(A[i], B[i]);
    return result;
}
export function matrix_hadamard(A, B) {
    let result = new Matrix({ matrix_height: A.height, matrix_width: A.width });
    for (let i = 0; i < result.height; i++)
        result[i] = vector_hadamard(A[i], B[i]);
    return result;
}
export function matrix_scale(A, b) {
    let result = new Matrix({ matrix_height: A.height, matrix_width: A.width });
    for (let i = 0; i < result.height; i++)
        result[i] = vector_scale(A[i], b);
    return result;
}
export function matrix_mul(A, B) {
    let result = new Matrix({ matrix_height: A.height, matrix_width: B.width });
    for (let i = 0; i < result.height; i++)
        for (let j = 0; j < result.width; j++)
            for (let k = 0; k < A.width; k++)
                result[i][j] += A[i][k] * B[k][j];
    return result;
}
export function lu(A) {
    // Initialize L and U matrices
    let n = A.height;
    let L = new IdentityMatrix(n);
    let U = new ZeroMatrix(n, n);
    // Copy first row of A to U
    for (let j = 0; j < n; j++)
        U[0][j] = A[0][j];
    // Calculate first column of L
    for (let i = 1; i < n; i++)
        L[i][0] = A[i][0] / U[0][0];
    // Calculate remaining elements
    for (let i = 1; i < n; i++) {
        // Calculate U's row i
        for (let j = i; j < n; j++) {
            let sum = 0;
            for (let k = 0; k < i; k++)
                sum += L[i][k] * U[k][j];
            U[i][j] = A[i][j] - sum;
        }
        // Calculate L's column i
        for (let j = i + 1; j < n; j++) {
            let sum = 0;
            for (let k = 0; k < i; k++)
                sum += L[j][k] * U[k][i];
            L[j][i] = (A[j][i] - sum) / U[i][i];
        }
    }
    return { L, U };
}
export function qr(A) {
    // Initialize Q as identity and R as copy of A
    let Q = new IdentityMatrix(A.height);
    let R = new Matrix({ matrix_height: A.height, matrix_width: A.width });
    for (let i = 0; i < A.height; i++)
        for (let j = 0; j < A.width; j++)
            R[i][j] = A[i][j];
    // For each column
    for (let j = 0; j < Math.min(A.width, A.height - 1); j++) {
        // Extract the column vector below diagonal
        let x = new ZeroVector(A.height);
        for (let i = j; i < A.height; i++)
            x[i] = R[i][j];
        // Calculate vector norm
        let xnorm = Math.sqrt(dot(x, x));
        if (Math.abs(xnorm) < BIAS)
            continue;
        // First component sign
        let s = -Math.sign(x[j] || 1);
        // Construct Householder vector
        let u = new ZeroVector(A.height);
        u[j] = s * xnorm;
        let v = normalize(vector_add(x, u));
        // Skip if vector is zero
        let vnorm = Math.sqrt(dot(v, v));
        if (vnorm < BIAS)
            continue;
        // Normalize v
        for (let i = j; i < A.height; i++)
            v[i] = v[i] / vnorm;
        // Construct and apply Householder matrix
        let H = new HouseholderMatrix(v);
        // Update R = HR
        R = matrix_mul(H, R);
        // Update Q = QH^T
        Q = matrix_mul(Q, transpose(H));
    }
    return { Q, R };
}
// find Moore Penrose pseudo inverse of A
export function moore_penrose(A) {
    const n = A.width;
    let AT = transpose(A);
    // Invert (A^T A) via QR decomposition
    const ATA = matrix_mul(AT, A);
    const QR = qr(ATA);
    let Rinv = new Matrix({ matrix_height: n, matrix_width: n });
    // Calculate R inverse.
    for (let i = n - 1; i >= 0; i--) {
        Rinv[i][i] = 1;
        for (let j = n - 1; j > i; j--)
            Rinv[i] = vector_add(Rinv[i], vector_scale(Rinv[j], -QR.R[i][j] / QR.R[j][j]));
    }
    // Divide by diagonal elements.
    for (let i = 0; i < n; i++)
        Rinv[i] = vector_scale(Rinv[i], 1 / QR.R[i][i]);
    // Calculate Moore Penrose pseudo inverse.
    return matrix_mul(matrix_mul(Rinv, transpose(QR.Q)), AT);
}
export function ray_triangle(ray_origin, ray_direction, triangle, normal) {
    const BIAS = 2 ** (-12);
    // Get distance to intersection point
    const s = dot(normal, vector_difference(triangle[0], ray_origin)) / dot(normal, normalize(ray_direction));
    // Ensure that ray triangle intersection is between light source and texture
    if (s <= BIAS)
        return Infinity;
    // Calculate intersection point
    const d = vector_add(vector_scale(normalize(ray_direction), s), ray_origin);
    // Test if point on plane is in Triangle by looking for each edge if point is in or outside
    const v0 = vector_difference(triangle[1], triangle[0]);
    const v1 = vector_difference(triangle[2], triangle[0]);
    const v2 = vector_difference(d, triangle[0]);
    const d00 = dot(v0, v0);
    const d01 = dot(v0, v1);
    const d11 = dot(v1, v1);
    const d20 = dot(v2, v0);
    const d21 = dot(v2, v1);
    const denom = d00 * d11 - d01 * d01;
    const v = (d11 * d20 - d01 * d21) / denom;
    const w = (d00 * d21 - d01 * d20) / denom;
    const u = 1 - v - w;
    if (Math.min(u, v) <= BIAS || u + v >= 1.0 - BIAS)
        return Infinity;
    // Return point of intersection.
    return s;
}
