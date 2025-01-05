"use strict";

import { Vector } from "../lib/math";

export class VertexBuffer {
    private static buffer: ArrayBuffer;
    private static bufferView: Float32Array;
    // List of all instances using this buffer
    private static instancesList: Array<VertexBuffer> = [];
    // Global length of the buffer
    private static length: number = 0;

    // Length of local view
    length: number;
    // Offset of local view
    offset: number;


    get Float32Array() {
        return new Float32Array(VertexBuffer.buffer, this.offset, this.length);
    }

    static staticConstructor = (function() {
        // Add one identity matrix transform at position 0 to default to.
        VertexBuffer.buffer = new ArrayBuffer(0);
        VertexBuffer.bufferView = new Float32Array(VertexBuffer.buffer);
    })();

    constructor(array: Float32Array | Array<number>) {
        this.length = array.length;
        this.offset = VertexBuffer.length;

        VertexBuffer.length += this.length;
        VertexBuffer.instancesList.push(this);

        if (array instanceof Float32Array) {
            // this.buffer = array;
            VertexBuffer.buffer.set(array, this.offset);
        } else if (array instanceof Array) {
            // this.buffer = new Float32Array(array);
        }
    }

    // Remove this buffer from the list of instances
    destroy() {
        VertexBuffer.instancesList = VertexBuffer.instancesList.filter(instance => instance !== this);

    }
}