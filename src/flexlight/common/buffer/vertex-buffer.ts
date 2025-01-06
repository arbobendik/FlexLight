"use strict";

import { next_power_of_two, Vector } from "../lib/math";
import { Float32View } from "./buffer-view";

// All @ts-expect-error in this file are used due to typescript not implementing ArrayBuffer.resize() and ArrayBuffer.maxByteLength yet.
// For reference, see: 
//  maxByteLength:  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer/maxByteLength
//  resize:         https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer/resize

export class VertexBuffer extends Float32View {
    // @ts-expect-error
    private static buffer: ArrayBuffer = new ArrayBuffer(0, { maxByteLength: 1 });
    // Keeps track of all instances of VertexBuffer
    private static instances: Set<VertexBuffer> = new Set();

    constructor(array: Float32Array | Array<number>) {
        const BYTES_PER_ELEMENT = Float32Array.BYTES_PER_ELEMENT;
        // Get array attributes
        const arrayLength: number = array.length;
        const arrayByteLength: number = arrayLength * BYTES_PER_ELEMENT;

        // New offset is old buffer byte length
        const arrayByteOffset: number = VertexBuffer.buffer.byteLength;
        const newBufferMaxByteLength = next_power_of_two(arrayByteOffset + arrayByteLength);
        // Test if buffer can be resized or needs to be recreated
        // @ts-expect-error
        if (newBufferMaxByteLength > VertexBuffer.buffer.maxByteLength) {
            // Recreate buffer if maxByteLength is exceeded
            const oldBuffer = VertexBuffer.buffer;
            VertexBuffer.buffer = new ArrayBuffer(newBufferMaxByteLength);
            // Copy data over to new buffer
            new Uint8Array(VertexBuffer.buffer).set(new Uint8Array(oldBuffer));
        } else {
            // Resize buffer if new length is still within maxByteLength
            // @ts-expect-error
            VertexBuffer.buffer.resize(newBufferMaxByteLength);
        }
        
        // Create a Float32Array view of buffer
        const float32BufferView = new Float32Array(VertexBuffer.buffer);
        // Insert array into buffer
        if (array instanceof Float32Array) {
            float32BufferView.set(array, arrayByteOffset / BYTES_PER_ELEMENT);
        } else if (array instanceof Array) {
            float32BufferView.set(new Float32Array(array), arrayByteOffset / BYTES_PER_ELEMENT);
        }
        
        // Construct current buffer view
        super(VertexBuffer.buffer, arrayByteOffset, arrayByteLength);
        // Add this buffer to the list of instances
        VertexBuffer.instances.add(this);
    }

    // Remove this buffer from the list of instances
    destroy() {
        // Remove this buffer from the list of instances
        VertexBuffer.instances.delete(this);
        // Get buffer attributes
        const arrayByteOffset = this.byteOffset;
        const arrayByteLength = this.byteLength;
        const bufferByteLength = VertexBuffer.buffer.byteLength;
        // Shift all memory after this one to the left by byteLength
        const uint8ArrayBufferView = new Uint8Array(VertexBuffer.buffer);
        uint8ArrayBufferView.copyWithin(arrayByteOffset, arrayByteOffset + arrayByteLength, bufferByteLength);
        // Readjust views
        // Shift all instances views to the right of current instance to the left by arrayByteLength
        for (let instance of VertexBuffer.instances) {
            // Check if instance is to the right of current instance and shift if so
            if (instance.byteOffset > arrayByteOffset) instance.shift(instance.byteOffset - arrayByteLength, instance.length);
        }
        // Resize buffer to remove unused space at the end by arrayByteLength
        // @ts-expect-error
        VertexBuffer.buffer.resize(bufferByteLength - arrayByteLength);

    }
}
