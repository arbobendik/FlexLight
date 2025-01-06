"use strict";

import { Vector, Matrix, IdentityMatrix, matrix_scale, moore_penrose, vector_scale, ZeroVector } from "../lib/math";


export class Transform {
  private referenceNumber: number = 0;
  private rotationMatrix: Matrix<3, 3>;
  private position: Vector<3>;
  private scaleFactor: number = 1;
  // private transformedNodes = new Set();

  private static DEFAULT_TRANSFORM: Transform;
  private static used: Array<boolean> = [];
  private static transformList: Array<Transform | undefined> = [];

  static buildWGL2Arrays = (): { rotationBuffer: Float32Array, shiftBuffer: Float32Array } => {
    let length: number = Transform.transformList.length;
    // Create UBO buffer array
    let rotationBuffer: Float32Array = new Float32Array(24 * length);
    let shiftBuffer: Float32Array = new Float32Array(8 * length);
    // Iterate over set elements
    for (let i: number = 0; i < length; i++) {
      let transform: Transform = Transform.transformList[i] ?? Transform.DEFAULT_TRANSFORM;
      let matrix: Matrix<3, 3> = transform.matrix;
      let inverse: Matrix<3, 3> = moore_penrose(matrix);
      let pos: Vector<3> = transform.position;
      let invPos: Vector<3> = vector_scale(transform.position, - 1);
      rotationBuffer.set(matrix[0]!, i * 24);
      rotationBuffer.set(matrix[1]!, i * 24 + 4);
      rotationBuffer.set(matrix[2]!, i * 24 + 8);
      rotationBuffer.set(inverse[0]!, i * 24 + 12);
      rotationBuffer.set(inverse[1]!, i * 24 + 16);
      rotationBuffer.set(inverse[2]!, i * 24 + 20);
      shiftBuffer.set(pos, i * 8);
      shiftBuffer.set(invPos, i * 8 + 4);
    }

    return { rotationBuffer, shiftBuffer };
  }

  static buildWGPUArray = (): Float32Array => {
    let length: number = Transform.transformList.length;
    // Create UBO buffer array
    let transfromBuffer: Float32Array = new Float32Array(32 * length);
    // Iterate over set elements
    for (let i: number = 0; i < length; i++) {
      let transform: Transform = Transform.transformList[i] ?? Transform.DEFAULT_TRANSFORM;
      let matrix: Matrix<3, 3> = transform.matrix;
      let inverse: Matrix<3, 3> = moore_penrose(matrix);
      let pos: Vector<3> = transform.position;
      let invPos: Vector<3> = vector_scale(transform.position, - 1);
      transfromBuffer.set(matrix[0]!, i * 32);
      transfromBuffer.set(matrix[1]!, i * 32 + 4);
      transfromBuffer.set(matrix[2]!, i * 32 + 8);
      transfromBuffer.set(pos, i * 32 + 12);
      transfromBuffer.set(inverse[0]!, i * 32 + 16);
      transfromBuffer.set(inverse[1]!, i * 32 + 20);
      transfromBuffer.set(inverse[2]!, i * 32 + 24);
      transfromBuffer.set(invPos, i * 32 + 28);
    }

    return transfromBuffer;
  }

  get number (): number {
    return this.referenceNumber;
  }

  get matrix (): Matrix<3, 3> {
    return matrix_scale(this.rotationMatrix, this.scaleFactor);
  }

  move (x: number, y: number, z: number): void {
    this.position = new Vector(x, y, z);
  }

  rotateAxis (normal: Vector<3>, theta: number): void {
    let n: Vector<3> = normal;
    let sT: number = Math.sin(theta);
    let cT: number = Math.cos(theta);
    this.rotationMatrix = new Matrix(
      [n.x * n.x * (1 - cT) + cT,          n.x * n.y * (1 - cT) - n.z * sT,    n.x * n.z * (1 - cT) + n.y * sT],
      [n.x * n.y * (1 - cT) + n.z * sT,    n.y * n.y * (1 - cT) + cT,          n.y * n.z * (1 - cT) - n.x * sT],
      [n.x * n.z * (1 - cT) - n.y * sT,    n.y * n.z * (1 - cT) + n.x * sT,    n.z * n.z * (1 - cT) + cT]
    );
  }

  rotateSpherical (theta: number, psi: number): void {
    let sT: number = Math.sin(theta);
    let cT: number = Math.cos(theta);
    let sP: number = Math.sin(psi);
    let cP: number = Math.cos(psi);

    this.rotationMatrix = new Matrix(
      [cT,         0,      sT],
      [- sT * sP,  cP,     cT * sP],
      [- sT * cP,  - sP,   cT * cP]
    );
  }

  scale (s: number): void {
    this.scaleFactor = s;
  }

  /*

  addNode (n: Object3D): void {
    this.transformedNodes.add(n);
  }

  removeNode (n: Object3D): void {
    this.transformedNodes.delete(n);
  }

  */
  destroy (): void {
    Transform.used[this.referenceNumber] = false;
    Transform.transformList[this.referenceNumber] = undefined;
  }

  static staticConstructor = (function() {
    // Add one identity matrix transform at position 0 to default to.
    Transform.DEFAULT_TRANSFORM = new Transform();
  })();

  constructor () {
    // Default to identity matrix.
    this.rotationMatrix = new IdentityMatrix(3);
    this.position = new ZeroVector(3);
    // Assign next larger available number.
    for (let i = 0; i < Infinity; i++) {
      if (Transform.used[i]) continue;
      Transform.used[i] = true;
      this.referenceNumber = i;
      break;
    }
    // Set in transform list.
    Transform.transformList[this.referenceNumber] = this;
  }
}


