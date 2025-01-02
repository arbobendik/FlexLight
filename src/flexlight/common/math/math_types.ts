// Create number sequence from 0 to N
type BuildTuple<T, N extends number, R extends T[] = []> = R['length'] extends N ? R : BuildTuple<T, N, [...R, T]>;

// Modified Tuple type to allow array coercion
export type Tuple<T, N extends number> = N extends number 
    ? number extends N 
        ? T[] 
        : BuildTuple<T, N>
    : never;


// Convert type to number
class Read<N extends number> {
    readonly value!: N;
}

export class Vector<N extends number> extends Float32Array {
    // Type assertion for length
    override readonly length!: N;
    // Getters for components
    get x(): number | void { if (this.length > 0) return this[0] }
    get y(): number | void { if (this.length > 1) return this[1] }
    get z(): number | void { if (this.length > 2) return this[2] }
    // get w(): number | void { if (this.length > 3) return this[3] }
    // Setters for components
    set x(value: number) { if (this.length > 0) this[0] = value }
    set y(value: number) { if (this.length > 1) this[1] = value }
    set z(value: number) { if (this.length > 2) this[2] = value }
    // set w(value: number) { if (this.length > 3) this[3] = value }

    // Constructor for the Vector class
    constructor(... args: [ Tuple<number, N> ] | Tuple<number, N> | []) {
        // If no arguments are provided, initialize empty vector of size N
        if (args.length === 0) super(new Read<N>().value);
        // If one argument is provided and it's not a number, initialize vector with given tuple
        else if (args.length === 1 && typeof args[0] !== 'number') super(args[0]);
        // Otherwise, initialize vector with spread tuple
        else super(args as Tuple<number, N>);

        if (new Read<N>().value > 3) Object.defineProperty(this, 'w', {
            get() {
                return this[3];
            },
            set(newValue) {
                this[3] = newValue;
            },
            enumerable: true,
            configurable: true,
        });
    }
}



export class Matrix<N extends number, M extends number> extends Array<Vector<M>> {
    // Constructor for the Matrix class
    constructor(... rows: Tuple<Vector<M>, N>) { super(... rows) }
}