// Math types and functions
export * from './common/lib/math';

// Main FlexLight class
export class FlexLight {
    constructor(canvas: HTMLCanvasElement);

    // Properties
    get canvas(): HTMLCanvasElement;
    get api(): string;
    get camera(): Camera;
    get config(): Config;
    get scene(): Scene;
    get renderer(): PathTracerWGL2 | PathTracerWGPU | RasterizerWGL2 | RasterizerWGPU;
    get io(): WebIo;

    set canvas(canvas: HTMLCanvasElement);
    set api(api: string);
    set config(config: Config);
    set camera(camera: Camera);
    set scene(scene: Scene);
    set renderer(renderer: string | PathTracerWGL2 | PathTracerWGPU | RasterizerWGL2 | RasterizerWGPU);
    set io(io: string | WebIo);

    screenshot(): void;
}

// Scene related classes
export class Scene {
    primaryLightSources: [number, number, number][];
    defaultLightIntensity: number;
    defaultLightVariation: number;
    ambientLight: [number, number, number];
    textures: HTMLImageElement[];
    pbrTextures: HTMLImageElement[];
    translucencyTextures: HTMLImageElement[];
    standardTextureSizes: [number, number];
    queue: Object3D[];

    static textureFromRGB(array: number[], width: number, height: number): Promise<HTMLImageElement>;
    static textureFromRME(array: number[], width: number, height: number): Promise<HTMLImageElement>;
    textureFromRGB(array: number[], width: number, height: number): Promise<HTMLImageElement>;
    textureFromRME(array: number[], width: number, height: number): Promise<HTMLImageElement>;
    textureFromTPO(array: number[], width: number, height: number): Promise<HTMLImageElement>;

    generateBVH(): any;
    updateBoundings(): any;
    generateArraysFromGraph(): any;

    Transform(matrix: Matrix<number, number>): Transform;
    Cuboid(x: number, x2: number, y: number, y2: number, z: number, z2: number): Cuboid;
    Plane(c0: [number, number, number], c1: [number, number, number], c2: [number, number, number], c3: [number, number, number]): Plane;
    Triangle(a: [number, number, number], b: [number, number, number], c: [number, number, number]): Triangle;
    Bounding(array: any[]): Bounding;
}

export class Transform {
    constructor(matrix: Matrix<number, number>);
}

export class Object3D {
    length: number;
    constructor(length: number);
}

export class Primitive extends Object3D {
    constructor();
}

export class Triangle extends Primitive {
    constructor(a: [number, number, number], b: [number, number, number], c: [number, number, number]);
}

export class Plane extends Primitive {
    constructor(c0: [number, number, number], c1: [number, number, number], c2: [number, number, number], c3: [number, number, number]);
}

export class Cuboid extends Object3D {
    constructor(x: number, x2: number, y: number, y2: number, z: number, z2: number);
    bounding: [number, number, number, number, number, number];
}

export class Bounding extends Object3D {
    constructor(array: any[]);
}

// Config class
export class Config {
    samplesPerRay: number;
    renderQuality: number;
    maxReflections: number;
    minImportancy: number;
    firstPasses: number;
    secondPasses: number;
    temporal: boolean;
    temporalSamples: number;
    filter: boolean;
    hdr: boolean;
    antialiasing: string;
}

// Camera class
export class Camera {
    position: Vector<3>;
    direction: Vector<2>;
    fov: number;
}
