// Furnace test of the WebGPU path tracer, headless on Dawn after `bash ./build-script`: a closed, lossless prism of
// glass or of a perfect mirror (argument glass or mirror), faceted with smooth normals, under white ambient light only,
// must come out white, path traced or through ReSTIR (argument pt or restir), which keeps only the mirror exact. Rays
// sampled to the wrong side of a facet lose no energy, so no pixel gains light, the image's mean stays at one and no
// pixel turns black.
import { create, globals } from "webgpu";

const SIZE = 64, FRAMES = 64, SIDES = 6, [MATERIAL, MODE] = process.argv.slice(2);
// ReSTIR shuffles its pairings with Math.random, seeded here so that every run is the same
let seed = 1;
Math.random = () => (seed = (seed * 1664525 + 1013904223) >>> 0) / 4294967296;
Object.assign(globalThis, globals);
const gpu = create([]);
let device, estimate;
// The renderer's own estimate of each frame, layer 0 of its temporal input, kept readable
const hookDevice = (d) => {
  const createTexture = d.createTexture.bind(d);
  d.createTexture = (desc) => {
    const size = ArrayBuffer.isView(desc.size) ? Array.from(desc.size) : desc.size;
    if (desc.format !== "rgba32float" || !Array.isArray(size) || size[2] !== 3) return createTexture({ ...desc, size });
    return estimate = createTexture({ ...desc, size, usage: desc.usage | GPUTextureUsage.COPY_SRC });
  };
  const queue = d.queue, writeBuffer = queue.writeBuffer.bind(queue), writeTexture = queue.writeTexture.bind(queue);
  const bytes = (data) => data instanceof Float16Array ? new Uint8Array(data.buffer, data.byteOffset, data.byteLength) : data;
  queue.writeBuffer = (buffer, offset, data, start = 0, length) => data instanceof Float16Array
    ? writeBuffer(buffer, offset, bytes(data), start * 2, length === undefined ? undefined : length * 2) : writeBuffer(buffer, offset, data, start, length);
  queue.writeTexture = (texture, data, layout, size) => writeTexture(texture, bytes(data), layout, ArrayBuffer.isView(size) ? Array.from(size) : size);
  d.addEventListener("uncapturederror", (e) => { console.error(e.error.message); process.exit(1); });
};
Object.defineProperty(globalThis, "navigator", { value: { gpu: {
  requestAdapter: async () => {
    const adapter = await gpu.requestAdapter();
    const requestDevice = adapter.requestDevice.bind(adapter);
    adapter.requestDevice = async (desc) => { hookDevice(device = await requestDevice(desc)); return device; };
    return adapter;
  },
  getPreferredCanvasFormat: () => "rgba8unorm"
} } });
// No window: frames follow the queue, the canvas is an offscreen texture, WebGL2's constants are read but unused
globalThis.requestAnimationFrame = (cb) => { (device?.queue.onSubmittedWorkDone() ?? Promise.resolve()).then(() => setTimeout(() => cb(0), 0)); return 0; };
globalThis.window = globalThis;
globalThis.addEventListener = globalThis.removeEventListener = () => {};
globalThis.document = { addEventListener: () => {} };
globalThis.WebGL2RenderingContext = globalThis.WebGLRenderingContext = new Proxy({}, { get: () => 0 });
const context = { configure(config) { this.config = config; }, unconfigure() {},
  getCurrentTexture() { return this.texture ??= device.createTexture({ size: [canvas.width, canvas.height], format: this.config.format, usage: this.config.usage }); } };
const canvas = { clientWidth: SIZE, clientHeight: SIZE, width: SIZE, height: SIZE, style: {}, getContext: () => context,
  addEventListener: () => {}, removeEventListener: () => {}, requestPointerLock: () => {}, focus: () => {}, blur: () => {} };
const F = await import("../public/build/flexlight/flexlight.js");

// Hexagonal prism: flat facets whose corners carry the radial normal, flat caps; positions, normals, uvs per triangle
const corner = (i, y) => [Math.cos(2 * Math.PI * i / SIDES), y, Math.sin(2 * Math.PI * i / SIDES)];
const radial = (i) => [Math.cos(2 * Math.PI * i / SIDES), 0, Math.sin(2 * Math.PI * i / SIDES)];
const triangles = [];
const push = (p, n) => triangles.push(...p.flat(), ...n.flat(), 0, 0, 0, 0, 0, 0);
for (let i = 0; i < SIDES; i++) {
  push([corner(i, -1), corner(i, 1), corner(i + 1, 1)], [radial(i), radial(i), radial(i + 1)]);
  push([corner(i, -1), corner(i + 1, 1), corner(i + 1, -1)], [radial(i), radial(i + 1), radial(i + 1)]);
  push([[0, 1, 0], corner(i + 1, 1), corner(i, 1)], [[0, 1, 0], [0, 1, 0], [0, 1, 0]]);
  push([[0, -1, 0], corner(i, -1), corner(i + 1, -1)], [[0, -1, 0], [0, -1, 0], [0, -1, 0]]);
}
const material = MATERIAL === "mirror" ? new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0, 1, 0)
  : new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0, 0, 1, 1.5);
const engine = new F.FlexLight(canvas);
Object.assign(engine.config, { temporal: true, restir: MODE === "restir", antialiasing: undefined, samplesPerPixel: 1, maxBounces: 32 });
engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles, material, label: "prism" }));
engine.scene.ambientLight = new F.Vector(1, 1, 1);
engine.camera.position = new F.Vector(0, 0.5, 3);
engine.camera.direction = new F.Vector(0, 0.15);

// Each frame's estimate summed per pixel, then the bounds checked over their mean
const sum = new Float64Array(SIZE * SIZE), row = Math.ceil(SIZE * 16 / 256) * 256;
let frame = 0, read = 0;
const renderFrame = engine.renderer.renderFrame.bind(engine.renderer);
engine.renderer.renderFrame = async (...args) => {
  if (frame === FRAMES) return;
  const result = renderFrame(...args);
  const buffer = device.createBuffer({ size: row * SIZE, usage: GPUBufferUsage.COPY_DST | GPUBufferUsage.MAP_READ });
  const encoder = device.createCommandEncoder();
  encoder.copyTextureToBuffer({ texture: estimate }, { buffer, bytesPerRow: row }, [SIZE, SIZE, 1]);
  device.queue.submit([encoder.finish()]);
  frame++;
  await buffer.mapAsync(GPUMapMode.READ);
  const data = new Float32Array(buffer.getMappedRange());
  for (let p = 0, i; p < SIZE * SIZE; p++) i = (p / SIZE | 0) * row / 4 + p % SIZE * 4, sum[p] += (data[i] + data[i + 1] + data[i + 2]) / 3;
  buffer.destroy();
  if (++read < FRAMES) return result;
  const pixels = Array.from(sum, (s) => s / FRAMES), mean = pixels.reduce((a, b) => a + b) / pixels.length;
  const brightest = Math.max(...pixels), black = pixels.filter((v) => v < 0.5).length / pixels.length;
  console.log(`mean ${mean.toFixed(4)}, brightest ${brightest.toFixed(4)}, black share ${(100 * black).toFixed(2)}%`);
  process.exit(mean > 0.98 && brightest < 1.05 && black === 0 ? 0 : 1);
};
engine.renderer.render();
