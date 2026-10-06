"use strict";

// Reuse texture sizes, different per neighbor to avoid repeating patterns (Sec. 3.2)
const PAIRING_SIZES = [254, 230, 210];
// Gaussian standard deviation with the mean distance of a 30 pixel uniform disk (Sec. 7)
const PAIRING_SIGMA = 16;
// Layers 0 - 5 previous frame reservoirs, 6 - 10 temporal reservoirs, 11 - 15 initial reservoirs or paired shifts, 16 duplication map,
// 17 - 18 shifts of temporal reuse
const LAYERS: Record<number, [number, number]> = { 6: [0, 6], 7: [6, 5], 8: [6, 5], 9: [0, 6], 10: [11, 3], 11: [11, 3], 12: [16, 1], 13: [16, 1], 15: [11, 5], 16: [11, 5], 17: [17, 2], 20: [17, 2] };
// Entry points and the group 0 bindings each of them uses. The temporal and spatial round of the shift queue each count,
// queue and then run the shifts over the compacted queue.
const PASSES: Array<[string, Array<number>]> = [
  ["restir_initial", [1, 2, 3, 16]],
  ["restir_temporal_count", [2, 3, 6, 15, 18]],
  ["restir_temporal_prepass", [2, 3, 6, 15, 17, 18]],
  ["restir_temporal_shift", [2, 3, 6, 15, 17, 19]],
  ["restir_temporal", [1, 2, 3, 6, 8, 12, 15, 20]],
  ["restir_count", [2, 3, 7, 14, 18]],
  ["restir_prepass", [2, 3, 7, 11, 14, 18]],
  ["restir_shift", [2, 3, 7, 11, 14, 19]],
  ["restir_spatial", [0, 1, 2, 3, 7, 9, 10, 14]],
  ["restir_duplicates", [6, 13]]
];
// Bytes of the indirect dispatch size, shift counts and write cursors of the 40 bins ahead of the queued shifts
const QUEUE_HEADER = (3 + 2 * 40) * 4;

export interface ReSTIRResources {
  // Per pixel reservoirs, paired shifts and duplication map
  reservoirs: GPUTexture;
  shiftQueue: GPUBuffer;
}

// Pair pixels by random 2 x 2 shuffles of consecutive link indices, giving Gaussian distributed offsets (Sec. 3.1)
const pairingTexture = (size: number): Int8Array => {
  const link = new Uint32Array(size * size).map((_, i) => i >> 1);
  const shuffles = Math.floor(PAIRING_SIGMA ** 2 / 2 + 1.46 / PAIRING_SIGMA + 1.76 / PAIRING_SIGMA ** 2 + 0.656 / PAIRING_SIGMA ** 3 + 0.5);
  const block = new Uint32Array(4);
  for (let s = 0; s < shuffles; s++) {
    // Every other shuffle is offset diagonally by one, looping over the edge
    for (let y = s % 2; y < size + s % 2; y += 2) for (let x = s % 2; x < size + s % 2; x += 2) {
      for (let c = 0; c < 4; c++) block[c] = ((y + (c >> 1)) % size) * size + (x + (c & 1)) % size;
      for (let c = 3; c > 0; c--) {
        const a = block[c]!, b = block[Math.floor(Math.random() * (c + 1))]!;
        [link[a], link[b]] = [link[b]!, link[a]!];
      }
    }
  }
  // Store the offset to the pixel sharing the link index, wrapped to keep the texture tileable
  const wrap = (d: number) => d > size / 2 ? d - size : d < - size / 2 ? d + size : d;
  const first = new Int32Array(size * size / 2).fill(-1);
  const deltas = new Int8Array(size * size * 2);
  link.forEach((l, i) => {
    const j = first[l]!;
    if (j < 0) first[l] = i;
    else {
      const dx = wrap(j % size - i % size), dy = wrap(Math.floor(j / size) - Math.floor(i / size));
      deltas.set([dx, dy], i * 2);
      deltas.set([- dx, - dy], j * 2);
    }
  });
  return deltas;
};

export class ReSTIR {
  private device: GPUDevice;
  private passes: Array<{ pipeline: GPUComputePipeline, layout: GPUBindGroupLayout, bindings: Array<number> }>;
  private pairing: GPUTexture;

  constructor(device: GPUDevice, shader: string, sharedLayouts: Array<GPUBindGroupLayout>) {
    this.device = device;
    const texture = (sampleType: GPUTextureSampleType, viewDimension: GPUTextureViewDimension = "2d-array") => ({ texture: { sampleType, viewDimension } });
    const storage = (format: GPUTextureFormat) => ({ storageTexture: { access: "write-only" as const, format, viewDimension: "2d-array" as const } });
    const entries: Record<number, Omit<GPUBindGroupLayoutEntry, "binding" | "visibility">> = {
      0: storage("rgba32float"), 1: { buffer: { type: "read-only-storage" } }, 2: texture("unfilterable-float", "2d"), 3: texture("unfilterable-float", "2d"),
      6: texture("uint"), 7: texture("uint"), 8: storage("rgba32uint"), 9: storage("rgba32uint"), 10: texture("uint"),
      11: storage("rgba32uint"), 12: texture("uint"), 13: storage("rgba32uint"), 14: texture("sint"), 15: texture("uint"), 16: storage("rgba32uint"),
      17: storage("rgba32uint"), 18: { buffer: { type: "storage" } }, 19: { buffer: { type: "read-only-storage" } }, 20: texture("uint")
    };
    const module = device.createShaderModule({ code: shader });
    this.passes = PASSES.map(([entryPoint, bindings]) => {
      const layout = device.createBindGroupLayout({ entries: bindings.map(binding => ({ binding, visibility: GPUShaderStage.COMPUTE, ...entries[binding] })) });
      const pipeline = device.createComputePipeline({
        label: entryPoint,
        layout: device.createPipelineLayout({ bindGroupLayouts: [layout, ...sharedLayouts] }),
        compute: { module, entryPoint }
      });
      return { pipeline, layout, bindings };
    });
    // Reuse textures, one layer each
    this.pairing = device.createTexture({ size: [PAIRING_SIZES[0]!, PAIRING_SIZES[0]!, PAIRING_SIZES.length], format: "rg8sint", usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.COPY_DST });
    PAIRING_SIZES.forEach((size, layer) => device.queue.writeTexture({ texture: this.pairing, origin: [0, 0, layer] }, pairingTexture(size), { bytesPerRow: size * 2 }, [size, size]));
  }

  // Per pixel reservoirs and the queue holding up to three shifts per pixel
  createResources(width: number, height: number): ReSTIRResources {
    return {
      reservoirs: this.device.createTexture({ size: [width, height, 19], format: "rgba32uint", usage: GPUTextureUsage.TEXTURE_BINDING | GPUTextureUsage.STORAGE_BINDING }),
      shiftQueue: this.device.createBuffer({ size: QUEUE_HEADER + width * height * 12, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.INDIRECT | GPUBufferUsage.COPY_DST })
    };
  }

  // Record initial sampling, temporal reuse, the paired spatial reuse passes with shading and the duplication map
  encode(commandEncoder: GPUCommandEncoder, target: GPUTextureView, offsetBuffer: GPUBuffer, absolutePosition: GPUTexture, uv: GPUTexture, { reservoirs, shiftQueue }: ReSTIRResources, sharedGroups: Array<GPUBindGroup>, width: number, height: number) {
    const resources: Record<number, GPUBindingResource> = { 0: target, 1: { buffer: offsetBuffer }, 2: absolutePosition.createView(), 3: uv.createView(), 14: this.pairing.createView(), 18: { buffer: shiftQueue }, 19: { buffer: shiftQueue } };
    for (const [binding, [baseArrayLayer, arrayLayerCount]] of Object.entries(LAYERS)) resources[Number(binding)] = reservoirs.createView({ dimension: "2d-array", baseArrayLayer, arrayLayerCount });
    for (const { pipeline, layout, bindings } of this.passes) {
      const group = this.device.createBindGroup({ layout, entries: bindings.map(binding => ({ binding, resource: resources[binding]! })) });
      if (pipeline.label.endsWith("count")) commandEncoder.clearBuffer(shiftQueue, 0, QUEUE_HEADER);
      const encoder = commandEncoder.beginComputePass({ label: pipeline.label });
      encoder.setPipeline(pipeline);
      [group, ...sharedGroups].forEach((bindGroup, index) => encoder.setBindGroup(index, bindGroup));
      if (pipeline.label.endsWith("shift")) encoder.dispatchWorkgroupsIndirect(shiftQueue, 0);
      else encoder.dispatchWorkgroups(Math.ceil(width / 8), Math.ceil(height / 8));
      encoder.end();
    }
  }
}
