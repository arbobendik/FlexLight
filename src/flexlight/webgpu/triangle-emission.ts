"use strict";

import { Scene } from "../common/scene/scene.js";

const INSTANCE_UINT_SIZE = 9;

// Mean emission per triangle over emissive textures, of the path tracer's triangle_emissions entry point, read back into
// the scene whose light BVH waits for it
export class TriangleEmission {
  private device: GPUDevice;
  private layouts: Array<GPUBindGroupLayout>;
  private pipeline: GPUComputePipeline;

  constructor(device: GPUDevice, shader: string) {
    this.device = device;
    // The bindings of groups 0 to 3 the entry point uses: its output, texture data and instances, triangles and instances
    this.layouts = [
      [{ binding: 21, buffer: { type: "storage" } }],
      [{ binding: 0, texture: { sampleType: "uint", viewDimension: "2d-array" } }, { binding: 1, buffer: { type: "read-only-storage" } }],
      [{ binding: 0, texture: { sampleType: "unfilterable-float", viewDimension: "2d-array" } }],
      [{ binding: 3, buffer: { type: "read-only-storage" } }]
    ].map(entries => device.createBindGroupLayout({ entries: entries.map(entry => ({ visibility: GPUShaderStage.COMPUTE, ...entry }) as GPUBindGroupLayoutEntry) }));
    this.pipeline = device.createComputePipeline({
      label: "triangle emission pipeline",
      layout: device.createPipelineLayout({ bindGroupLayouts: this.layouts }),
      compute: { module: device.createShaderModule({ code: shader }), entryPoint: "triangle_emissions" }
    });
  }

  // Means of the instances the scene last wrote to the GPU, one row of workgroups per instance
  async compute(scene: Scene, textureData: GPUTextureView, textureInstances: GPUBuffer, triangles: GPUTextureView, instanceUint: GPUBuffer, triangleCount: number): Promise<void> {
    const instances: Array<number> = Array.from(scene.instanceUintManager.bufferView), key: Array<number> = scene.emissiveTextureKey;
    let widest = 0;
    for (let i = 0; i < instances.length; i += INSTANCE_UINT_SIZE) widest = Math.max(widest, (instances[i + INSTANCE_UINT_SIZE + 8] ?? triangleCount) - instances[i + 8]!);
    const size = Math.max(triangleCount, 1) * 4;
    const output = this.device.createBuffer({ size, usage: GPUBufferUsage.STORAGE | GPUBufferUsage.COPY_SRC });
    const readback = this.device.createBuffer({ size, usage: GPUBufferUsage.MAP_READ | GPUBufferUsage.COPY_DST });
    const encoder = this.device.createCommandEncoder();
    const pass = encoder.beginComputePass();
    pass.setPipeline(this.pipeline);
    [
      [{ binding: 21, resource: { buffer: output } }],
      [{ binding: 0, resource: textureData }, { binding: 1, resource: { buffer: textureInstances } }],
      [{ binding: 0, resource: triangles }],
      [{ binding: 3, resource: { buffer: instanceUint } }]
    ].forEach((entries, group) => pass.setBindGroup(group, this.device.createBindGroup({ layout: this.layouts[group]!, entries: entries as Array<GPUBindGroupEntry> })));
    pass.dispatchWorkgroups(Math.ceil(widest / 64), instances.length / INSTANCE_UINT_SIZE);
    pass.end();
    encoder.copyBufferToBuffer(output, 0, readback, 0, size);
    this.device.queue.submit([encoder.finish()]);
    await readback.mapAsync(GPUMapMode.READ);
    scene.triangleEmission = new Float32Array(readback.getMappedRange().slice(0));
    scene.triangleEmissionKey = key;
    output.destroy();
    readback.destroy();
  }
}
