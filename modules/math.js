'use strict';

export var Math = window.Math;

// Extend standard Math Object
Object.assign(Math, {
  // Floating point bias for unstable mathods
  BIAS: 2 ** (-32),
  // Make results numerically stable
  stabilize: (x) => (Math.abs(x) % 1 < Math.BIAS || Math.abs(x) % 1 > 1 - Math.BIAS) ? Math.round(x) : x,
  // Sum up list of parameters
  sum: function () { return Array.prototype.slice.call(arguments).reduce((p, c) => p + c, 0)},
  // Multiplies matrices, vectors elementwise or with scalar
  mul: (a, b) => {
    const matMul = (A, B) => {
      let BT = Math.transpose(B);
      let C = new Array(A.length).fill(0).map(() => new Array(B[0].length).fill(0));
      return C.map((row, i) => row.map((e, j) => Math.dot(A[i], BT[j])));
    };
    const dim = (obj) => (Array.isArray(obj)) ? dim(obj[0]) + 1 : 0;
    const dimA = dim(a);
    const dimB = dim(b);
    if (dimA === 2 && dimB === 2) return matMul(a, b);
    if (dimA === 2 && dimB === 1) return matMul(a, b.map((e) => [e]));
    if (dimA === 2 && dimB === 0) return a.map((row) => row.map((e) => e * b));
    if (dimA === 0 && dimB === 2) return b.map((row) => row.map((e) => e * a));
    if (dimA === 1 && dimB === 1) return a.map((e, i) => Math.stabilize(e* b[i]));
    if (dimA === 1 && dimB === 0) return a.map((e) => Math.stabilize(e * b));
    if (dimA === 0 && dimB === 1) return b.map((e) => Math.stabilize(e * a));
    return Math.stabilize(a * b);
  },
  // Calculate dot product
  dot: (a, b) => Math.stabilize(Math.mul(a, b).reduce((p, c) => p + c, 0)),
  // Calculate cross product for vec3
  cross: (a, b) => [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]],
  // Adds two vectors
  add: (a, b) => a.map((e, i) => e + b[i]),
  // Determines vector between 2 points
  diff: (a, b) => a.map((e, i) => e - b[i]),
  // Normalize vector
  normalize: (a) => {
    let length = Math.stabilize(Math.sqrt(a.reduce((p, c) => p + c ** 2, 0)));
    return a.map((e) => Math.stabilize(length) < Math.BIAS ? 0 : Math.stabilize(e / length));
  },
  // Orthogonalization
  gramSchmidt: (A, dot = Math.dot) => {
    let B = [];
    A.forEach((row) => {
      B.push(Math.add(row, Math.mul(- 1, B.reduce((p, c) => {
        return Math.add(p, Math.mul(dot(c, row) / dot(c, c), c))
      }, new Array(A[0].length).fill(0)))))
    });
    return B;
  },
  // transpose matrix
  transpose: (A) => {
    let C = new Array(A[0].length).fill(0).map(() => new Array(A.length).fill(0));
    return C.map((row, i) => row.map((e, j) => A[j][i]));
  },
  // QR decomposition
  qr: (A) => {
    let QT = Math.gramSchmidt(Math.transpose(A)).map((row) => Math.normalize(row));
    return {
      Q: Math.transpose(QT),
      R: Math.mul(QT, A)
    };
  },
  // find Moore Penrose pseudo inverse of A
  moorePenrose: (A) => {
    let AT = Math.transpose(A);
    // Invert (A^T A) via QR decomposition
    let QR = Math.qr(Math.mul(AT, A));
    let Rinv = new Array(QR.R.length);
    for (let i = QR.R.length - 1; i >= 0; i--) {
      Rinv[i] = new Array(QR.R.length).fill(0).map((e, j) => i === j ? 1 : 0);
      for (let j = QR.R.length - 1; j > i; j--) {
        Rinv[i] = Math.add(Rinv[i], Math.mul(Rinv[j], - QR.R[i][j] / QR.R[j][j]));
      }
    }
    for (let i = 0; i < QR.R.length; i++) Rinv[i] = Math.mul(Rinv[i], 1 / QR.R[i][i]);
    // If current result doesn't work try Moore Penrose for AT
    if (Number.isNaN(Rinv[0][0])) return Math.transpose(Math.moorePenrose(AT));
    return Math.mul(Math.mul(Rinv, Math.transpose(QR.Q)), AT);
  }
});

/*
// Test if ray intersects triangle and return intersection
rayTriangle: function (l, rayOrigin, rayDirection, tA, tB, tC, n) {
  const BIAS = 2 ** (-12);
  // Get distance to intersection point
  const s = Math.dot(n, Math.diff(t[0], rayOrigin)) / Math.dot(n, Math.normalize(rayDirection));
  // Ensure that ray triangle intersection is between light source and texture
  if (s > l || s <= BIAS) null;
  // Calculate intersection point
  let d = Math.mul(s, Math.normalize(rayDirection)) + rayOrigin;
  // Test if point on plane is in Triangle by looking for each edge if point is in or outside
  let v0 = Math.diff(tB, tA);
  let v1 = Math.diff(tC, tA);
  let v2 = Math.diff(d, tA);
  let d00 = Math.dot(v0, v0);
  let d01 = Math.dot(v0, v1);
  let d11 = Math.dot(v1, v1);
  let d20 = Math.dot(v2, v0);
  let d21 = Math.dot(v2, v1);
  let denom = d00 * d11 - d01 * d01;
  let v = (d11 * d20 - d01 * d21) / denom;
  let w = (d00 * d21 - d01 * d20) / denom;
  let u =  1 - v - w;
  if (Math.min(u, v) <= BIAS || u + v >= 1.0 - BIAS) null;
  // Return u v w.
  return [u, v, w];
}
*/