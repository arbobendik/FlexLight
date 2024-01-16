'use strict';

export class Arrays {
    static compare = (a1, a2) => {
        if (a1.length !== a2.length) return false;
        // Compare elements
        for (let i = 0; i < a1.length; i++) if (a1 !== a2) return false;
        return true;
    }

    static push = (a1, a2) => {
        if (a2.length > 256) {
            return a1.concat(a2);
        } else {
            let a1Length = a1.length;
            // Pre allocate size of a1
            a1.length = a1Length + a2.length;
            // Append items of a2 to a1
            for(let i = 0; i < a2.length; i++) a1[a1Length + i] = a2[i];
            return a1;
        }
    }
}

export class Float16Array extends Uint16Array {
    constructor (array) {
        super(array.length);
        // Create view arrays to convert array
        let floatView = new Float32Array(array);
        let int32View = new Int32Array(floatView.buffer);
        for (let i = 0; i < array.length; i++) {
            let x = int32View[i];
            let bits = (x >> 16) & 0x8000; /* Get the sign */
            let m = (x >> 12) & 0x07ff; /* Keep one extra bit for rounding */
            let e = (x >> 23) & 0xff; /* Using int is faster here */

            /* If zero, or denormal, or exponent underflows too much for a denormal
            * half, return signed zero. */
            if (e < 103) {
                this[i] = bits;
                continue;
            }

            /* If NaN, return NaN. If Inf or exponent overflow, return Inf. */
            if (e > 142) {
                bits |= 0x7c00;
                /* If exponent was 0xff and one mantissa bit was set, it means NaN,
                    * not Inf, so make sure we set one mantissa bit too. */
                bits |= ((e == 255) ? 0 : 1) && (x & 0x007fffff);
                this[i] = bits;
                continue;
            }

            /* If exponent underflows but not too much, return a denormal */
            if (e < 113) {
                m |= 0x0800;
                /* Extra rounding may overflow and set mantissa to 0 and exponent
                    * to 1, which is OK. */
                bits |= (m >> (114 - e)) + ((m >> (113 - e)) & 1);
                this[i] = bits;
                continue;
            }

            bits |= ((e - 112) << 10) | (m >> 1);
            /* Extra rounding. An overflow will set mantissa to 0 and increment
            * the exponent, which is OK. */
            bits += m & 1;
            this[i] = bits;
        }
    }
}