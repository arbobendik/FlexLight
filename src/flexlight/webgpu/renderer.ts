"use strict";

import { Vector } from "../common/lib/math";
import { LightSource } from "../common/scene/light-source";
import { SceneGraph } from "../common/scene/scene-graph";


export interface WebGPUReferences {
    context: GPUCanvasContext;
    device: GPUDevice;
}

export class RendererWGPU {
    readonly sceneGraph: SceneGraph;

    readonly canvas: HTMLCanvasElement;
    
    textureAtlas: GPUTexture | null = null;
    pbrAtlas: GPUTexture | null = null;
    translucencyAtlas: GPUTexture | null = null;

    textureList = [];
    pbrList = [];
    translucencyList = [];

    textureGroupLayout: GPUBindGroupLayout | null = null;
    textureGroup: GPUBindGroup | null = null;

    lightSourceLength = 0;
    lightBuffer: GPUBuffer | null = null;
    primaryLightSources: Set<LightSource> = new Set();

    // Track if engine is running
    protected isRunning = false;


    constructor(sceneGraph: SceneGraph, canvas: HTMLCanvasElement) {
        this.sceneGraph = sceneGraph;
        this.canvas = canvas;
    }
    
    async requestDevice(): Promise<WebGPUReferences> {
        let context = this.canvas.getContext("webgpu");
        if (!context) throw new Error("Failed to get webgpu context");
        let adapter = await navigator.gpu.requestAdapter();
        if (!adapter) throw new Error("Failed to request adapter");
        let device = await adapter.requestDevice();
        return { context, device };
    }

    async generateAtlasView (webGPUReferences: WebGPUReferences, list: Array<HTMLImageElement>) {
        let { x: width, y: height}: Vector<2> = this.scene.standardTextureSizes;
        let textureWidth = Math.floor(2048 / width);
        let canvas = document.createElement("canvas");
        let ctx: CanvasRenderingContext2D | null = canvas.getContext("2d"); 
        if (!ctx) throw new Error("Failed to get canvas context");
        // Test if there is even a texture
        if (list.length === 0) {
            canvas.width = width;
            canvas.height = height;
            ctx.imageSmoothingEnabled = false;
            ctx.fillRect(0, 0, width, height);
        } else {
            canvas.width = Math.min(width * list.length, 2048);
            canvas.height = height * (Math.floor((width * list.length) / 2048) + 1);
            console.log(canvas.width, canvas.height);
            ctx.imageSmoothingEnabled = false;
            // TextureWidth for third argument was 3 for regular textures
            list.forEach(async (texture, i) => ctx.drawImage(texture, width * (i % textureWidth), height * Math.floor(i / textureWidth), width, height));
        }

        let bitMap = await createImageBitmap(canvas);

        let atlasTexture = await webGPUReferences.device.createTexture({
            format: "rgba8unorm",
            size: [canvas.width, canvas.height],
            usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST | GPUTextureUsage.RENDER_ATTACHMENT,
        });

        webGPUReferences.device.queue.copyExternalImageToTexture(
            { source: bitMap, flipY: true },
            { texture: atlasTexture },
            { width: canvas.width, height: canvas.height },
        );

        this.lightSourceLength = 0;
        this.lightBuffer = webGPUReferences.device.createBuffer({ size: Float32Array.BYTES_PER_ELEMENT * 8, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST});

        return atlasTexture.createView();
    }

    async updateTextureAtlas (forceUpload = false) {
        // Don"t build texture atlas if there are no changes.
        if (
            !forceUpload
            && this.sceneGraph.textures.length === this.textureList.length
            && this.sceneGraph.textures.every((e, i) => e === this.textureList[i])
        ) return;

        this.textureList = this.scene.textures;
        this.textureAtlas = await this.generateAtlasView(this.scene.textures);
    }

    async updatePbrAtlas (forceUpload = false) {
        // Don"t build texture atlas if there are no changes.
        if (
            !forceUpload
            && this.scene.pbrTextures.length === this.pbrList.length
            && this.scene.pbrTextures.every((e, i) => e === this.pbrList[i])
        ) return;
        this.pbrList = this.scene.pbrTextures;
        this.pbrAtlas = await this.generateAtlasView(this.scene.pbrTextures);
    }

    async updateTranslucencyAtlas (forceUpload = false) {
        // Don"t build texture atlas if there are no changes.
        if (
            !forceUpload
            && this.scene.translucencyTextures.length === this.translucencyList.length
            && this.scene.translucencyTextures.every((e, i) => e === this.translucencyList[i])
        ) return;
        this.translucencyList = this.scene.translucencyTextures;
        this.translucencyAtlas = await this.generateAtlasView(this.scene.translucencyTextures);
    }

    async updateTextureGroup () {
        // Wait till all textures have finished updating
        let objects = [
            this.textureAtlas,
            this.pbrAtlas,
            this.translucencyAtlas
        ];

        this.textureGroup = this.device.createBindGroup({
            label: "texture binding group",
            layout: this.textureGroupLayout,
            entries: objects.map((object, i) => ({ binding: i, resource: object }))
        });
    }

    // Functions to update vertex and light source data textures
    updatePrimaryLightSources () {
        var lightTexArray = [];
        // Don"t update light sources if there is none
        if (this.scene.primaryLightSources.length === 0) {
            lightTexArray = [0, 0, 0, 0, 0, 0, 0, 0];
        } else {
            // Iterate over light sources
            this.scene.primaryLightSources.forEach(lightSource => {
                // Set intensity to lightSource intensity or default if not specified
                let intensity = Object.is(lightSource.intensity)? this.scene.defaultLightIntensity : lightSource.intensity;
                let variation = Object.is(lightSource.variation)? this.scene.defaultLightVariation : lightSource.variation;
                // push location of lightSource and intensity to texture, value count has to be a multiple of 3 rgb format
                lightTexArray.push(lightSource[0], lightSource[1], lightSource[2], 0, intensity, variation, 0, 0);
            });
        }

        let lightArray = new Float32Array(lightTexArray);
        // Reallocate buffer if size changed
        if (this.lightSourceLength !== lightArray.length) {
            this.lightSourceLength = lightArray.length;
            this.lightBuffer = this.device.createBuffer({ size: lightArray.byteLength, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_DST})
        }
        // Write data into buffer
        this.device.queue.writeBuffer(this.lightBuffer, 0, lightArray);
    }
}