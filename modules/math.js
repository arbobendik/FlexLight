'use strict';

export var Math = window.Math;

// Extend standard Math Object
Object.assign(Math, {
  sum: function () { return Array.prototype.slice.call(arguments).reduce((p, c) => p + c, 0)},
  // Calculate dot product
  dot: (a, b) => a.reduce((prev, curr, i) => prev + curr * b[i], 0),
  // Calculate cross product for vec3
  cross: (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]],
  // Multiplies vectors elementwise or with scalar
  mul: (a, b) => Array.isArray(a) ? a.map((item, i) => Array.isArray(b) ? item * b[i] : item * b) : b.map((item) => item * a),
  // Adds two vectors
  add: (a, b) => a.map((item, i) => item + b[i]),
  // Determines vector between 2 points
  diff: (a, b) => a.map((item, i) => item - b[i]),
  // Normalize vector
  normalize: (a) => a.map((item) => item / Math.sqrt(a.reduce((p, c) => p + c ** 2, 0))),
  // Test if ray intersects triangle and return intersection
  rayTriangle: (l, rayOrigin, rayDirection, tA, tB, tC, n) => {
    const BIAS = 2 ** (-12);
    // Get distance to intersection point
    const s = this.dot(n, this.diff(t[0], rayOrigin)) / this.dot(n, this.normalize(rayDirection));
    // Ensure that ray triangle intersection is between light source and texture
    if (s > l || s <= BIAS) null;
    // Calculate intersection point
    let d = this.mul(s, this.normalize(rayDirection)) + rayOrigin;
    // Test if point on plane is in Triangle by looking for each edge if point is in or outside
    let v0 = this.diff(tB, tA);
    let v1 = this.diff(tC, tA);
    let v2 = this.diff(d, tA);
    let d00 = this.dot(v0, v0);
    let d01 = this.dot(v0, v1);
    let d11 = this.dot(v1, v1);
    let d20 = this.dot(v2, v0);
    let d21 = this.dot(v2, v1);
    let denom = d00 * d11 - d01 * d01;
    let v = (d11 * d20 - d01 * d21) / denom;
    let w = (d00 * d21 - d01 * d20) / denom;
    let u =  1 - v - w;
    if (Math.min(u, v) <= BIAS || u + v >= 1.0 - BIAS) null;
    // Return u v w.
    return [u, v, w];
  }
});