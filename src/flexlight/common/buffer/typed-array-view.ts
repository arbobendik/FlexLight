"use strict";

export type TypedArray = Uint8Array | Uint16Array | Uint32Array | Int8Array | Int16Array | Int32Array | Float32Array | Float64Array;

export interface Constructor<T extends TypedArray> {
    new (buffer: ArrayBuffer, byteOffset: number, length: number): T;
}

type StringTag<T extends TypedArray> = 
    T extends Uint8Array ? "Uint8Array" :
    T extends Uint16Array ? "Uint16Array" :
    T extends Uint32Array ? "Uint32Array" :
    T extends Int8Array ? "Int8Array" :
    T extends Int16Array ? "Int16Array" :
    T extends Int32Array ? "Int32Array" :
    T extends Float32Array ? "Float32Array" :
    T extends Float64Array ? "Float64Array" : never;

// Reimplementation to allow Views to implement typed arrays
export class TypedArrayView<T extends TypedArray> {
    private readonly TypedArrayConstructor: Constructor<T>;
    private readonly stringTag: StringTag<T>;

    readonly BYTES_PER_ELEMENT: number;
    readonly buffer: ArrayBuffer;
    arrayView: T;
    length: number;

    byteOffset: number;
    byteLength: number;

    every: T["every"];
    filter: T["filter"];
    find: T["find"];
    findIndex: T["findIndex"];
    forEach: T["forEach"];
    includes: T["includes"];
    indexOf: T["indexOf"];
    join: T["join"];
    lastIndexOf: T["lastIndexOf"];
    map: T["map"];
    reduce: T["reduce"];
    reduceRight: T["reduceRight"];
    set: T["set"];
    slice: T["slice"];
    some: T["some"];
    subarray: T["subarray"];
    toLocaleString: T["toLocaleString"];
    toString: T["toString"];
    values: T['values'];

    entries: T["entries"];
    keys: T["keys"];

    [n: number]: number;  // Add numeric index signature
    
    constructor(TypedArrayConstructor: Constructor<T>, buffer: ArrayBuffer, byteOffset: number, length: number) {
        this.TypedArrayConstructor = TypedArrayConstructor;
        // Set array view
        const arrayView: T = new TypedArrayConstructor(buffer, byteOffset, length);
        this.stringTag = arrayView[Symbol.toStringTag] as StringTag<T>;
        // Set string tag
        this.BYTES_PER_ELEMENT = arrayView.BYTES_PER_ELEMENT;
        // Set buffer properties
        this.buffer = buffer;
        this.arrayView = arrayView;
        // Set array properties
        this.length = arrayView.length;
        this.byteOffset = arrayView.byteOffset;
        this.byteLength = arrayView.byteLength;
        // Set array methods
        this.every = arrayView.every;
        this.filter = arrayView.filter;
        this.find = arrayView.find;
        this.findIndex = arrayView.findIndex;
        this.forEach = arrayView.forEach;
        this.includes = arrayView.includes;
        this.indexOf = arrayView.indexOf;
        this.join = arrayView.join;
        this.lastIndexOf = arrayView.lastIndexOf;
        this.map = arrayView.map;
        this.reduce = arrayView.reduce;
        this.reduceRight = arrayView.reduceRight;
        this.set = arrayView.set;
        this.slice = arrayView.slice;
        this.some = arrayView.some;
        this.subarray = arrayView.subarray;
        this.toLocaleString = arrayView.toLocaleString;
        this.toString = arrayView.toString;
        this.values = arrayView.values;
        this.entries = arrayView.entries;
        this.keys = arrayView.keys;
    }

    private setArrayView(arrayView: T) {
        this.arrayView = arrayView;

        this.byteOffset = arrayView.byteOffset;
        this.length = arrayView.length;
        this.byteLength = arrayView.byteLength;
        // Set array methods
        this.every = arrayView.every;
        this.filter = arrayView.filter;
        this.find = arrayView.find;
        this.findIndex = arrayView.findIndex;
        this.forEach = arrayView.forEach;
        this.includes = arrayView.includes;
        this.indexOf = arrayView.indexOf;
        this.join = arrayView.join;
        this.lastIndexOf = arrayView.lastIndexOf;
        this.map = arrayView.map;
        this.reduce = arrayView.reduce;
        this.reduceRight = arrayView.reduceRight;
        this.set = arrayView.set;
        this.slice = arrayView.slice;
        this.some = arrayView.some;
        this.subarray = arrayView.subarray;
        this.toLocaleString = arrayView.toLocaleString;
        this.toString = arrayView.toString;
        this.values = arrayView.values;
        this.entries = arrayView.entries;
        this.keys = arrayView.keys;
    }

    // Custom methods
    shift(byteOffset: number, length: number) {
        this.setArrayView(new this.TypedArrayConstructor(this.buffer, byteOffset, length));
    }

    // Reimplementation of certain array methods
    valueOf(): T {
        return this.arrayView;
    }

    copyWithin(target: number, start: number, end?: number): this {
        this.arrayView.copyWithin(target, start, end);
        return this;
    }

    reverse(): this {
        this.arrayView.reverse();
        return this;
    }

    fill(value: number, start?: number, end?: number): this {
        this.arrayView.fill(value, start, end);
        return this;
    }

    sort(compareFn?: (a: number, b: number) => number): this {
        this.arrayView.sort(compareFn);
        return this;
    }

    *[Symbol.iterator](): IterableIterator<number> {
        // Iterate over elements
        for (let i = 0; i < this.length; i++) yield this.arrayView[i]!;
    }

    get [Symbol.toStringTag]() {
        return this.stringTag;
    }
}

