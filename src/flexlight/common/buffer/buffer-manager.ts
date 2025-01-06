"use strict";

import { TypedArray, Constructor, TypedArrayView } from "./typed-array-view";
import { next_power_of_two } from "../lib/math";

// All @ts-expect-error in this class are used due to typescript not implementing ArrayBuffer.resize() and ArrayBuffer.maxByteLength yet.
// For reference, see: 
//  maxByteLength:  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer/maxByteLength
//  resize:         https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/ArrayBuffer/resize

export class BufferManager<T extends TypedArray> {
    // @ts-expect-error
    private buffer: ArrayBuffer = new ArrayBuffer(0, { maxByteLength: 1 });
    // TypedArrayConstructor for the buffer
    private ViewConstructor: Constructor<T>;
    // Keeps track of all ArrayViews
    private instances: Set<TypedArrayView<T>> = new Set();

    constructor(ViewConstructor: Constructor<T>) {
        this.ViewConstructor = ViewConstructor;
    }

    addArrayView (array: TypedArray | Array<number>): TypedArrayView<T> {
        const BYTES_PER_ELEMENT = this.ViewConstructor.prototype.BYTES_PER_ELEMENT;
        // Get array attributes
        const arrayLength: number = array.length;
        const arrayByteLength: number = arrayLength * BYTES_PER_ELEMENT;

        // New offset is old buffer byte length
        const arrayByteOffset: number = this.buffer.byteLength;
        const newBufferMaxByteLength = next_power_of_two(arrayByteOffset + arrayByteLength);
        // Test if buffer can be resized or needs to be recreated
        // @ts-expect-error
        if (newBufferMaxByteLength > this.buffer.maxByteLength) {
            // Recreate buffer if maxByteLength is exceeded
            const oldBuffer = this.buffer;
            this.buffer = new ArrayBuffer(newBufferMaxByteLength);
            // Copy data over to new buffer
            new Uint8Array(this.buffer).set(new Uint8Array(oldBuffer));
        } else {
            // Resize buffer if new length is still within maxByteLength
            // @ts-expect-error
            this.buffer.resize(newBufferMaxByteLength);
        }
        
        // Create a view of whole buffer
        const bufferView = new this.ViewConstructor(this.buffer, 0, this.buffer.byteLength / BYTES_PER_ELEMENT);
        // Insert array into buffer
        if (array instanceof this.ViewConstructor) {
            console.log("Array is a view");
            // Insert array into buffer by copying
            bufferView.set(array, arrayByteOffset / BYTES_PER_ELEMENT);
        } else if (array instanceof Array) {
            console.log("Array is an array");
            // Insert array into buffer iteratively
            let i: number = 0;
            for (let value of array) bufferView[i++] = value;
        } else {
            throw new Error("BufferManager.addArrayView(): Array is neither a view nor an array");
        }
        
        const typedArrayView = new TypedArrayView<T>(this.ViewConstructor, this.buffer, arrayByteOffset, arrayByteLength);
        // Add this buffer to the list of instances
        this.instances.add(typedArrayView);
        // Construct current buffer view
        return typedArrayView;
    }

    // Remove this buffer from the list of instances
    deleteArrayView(typedArrayView: TypedArrayView<T>) {
        if (!this.instances.has(typedArrayView)) {
            throw new Error("BufferManager.deleteArrayView(): TypedArrayView instance not found");
        }
        // Remove this buffer from the list of instances
        this.instances.delete(typedArrayView);
        // Get buffer attributes
        const arrayByteOffset = typedArrayView.byteOffset;
        const arrayByteLength = typedArrayView.byteLength;
        const bufferByteLength = this.buffer.byteLength;
        // Shift all memory after this one to the left by byteLength
        const uint8ArrayBufferView = new Uint8Array(this.buffer);
        uint8ArrayBufferView.copyWithin(arrayByteOffset, arrayByteOffset + arrayByteLength, bufferByteLength);
        // Readjust views
        // Shift all instances views to the right of current instance to the left by arrayByteLength
        for (let instance of this.instances) {
            // Check if instance is to the right of current instance and shift if so
            if (instance.byteOffset > arrayByteOffset) instance.shift(instance.byteOffset - arrayByteLength, instance.length);
        }
        // Resize buffer to remove unused space at the end by arrayByteLength
        // @ts-expect-error
        this.buffer.resize(bufferByteLength - arrayByteLength);
    }
}
