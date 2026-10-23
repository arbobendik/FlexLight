// Furnace test of the WebGPU path tracer, headless on Dawn after `bash ./build-script`: a closed, lossless prism of
// glass or of a perfect mirror (argument glass or mirror), faceted with smooth normals, under white ambient light only,
// must come out white, path traced or through ReSTIR (argument pt or restir), which keeps only the mirror exact. Rays
// sampled to the wrong side of a facet lose no energy, so no pixel gains light, the image's mean stays at one and no
// pixel turns black. A square of white metal of roughness 0.5 (argument metal), facing the camera at a cosine of
// 0.5 across its narrow view, scatters each ray once: each pixel holds GGX's single-scatter albedo under exact Smith
// masking at that cosine, 0.8551, integrated numerically, which the image's mean meets within four standard errors of
// its pixels', and pixel 0 draws other random numbers each frame. A square of a white opaque dielectric of IOR 1.5 and
// roughness 0.2 (argument dielectric) in its place holds the diffuse of what its Fresnel does not reflect beside that
// reflection's single-scatter albedo, 0.9990, no more light than it receives, which the mean meets likewise. Its
// diffuse samples each carry all of the light, so its pixel 0 need not vary. The rasterizer shading a white
// square in a sphere light's random points (argument raster) has pixel 0 draw other random numbers each frame as well.
import { create, globals } from "webgpu";

const SIZE = 64, FRAMES = 64, SIDES = 6, METAL = 0.8551, DIELECTRIC = 0.9990, [MATERIAL, MODE] = process.argv.slice(2);
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
    // The rasterizer's own estimate, the last of its 2D float textures
    if (desc.format !== "rgba32float" || !Array.isArray(size)
      || (MATERIAL === "raster" ? size.length !== 2 : size[2] !== 3)) return createTexture({ ...desc, size });
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
// The square of the metal, dielectric and raster cases, in the plane of normal (0, sqrt(3) / 2, 1 / 2) through the
// origin
const tilt = Math.sqrt(3) / 2, metal = [[-0.5, -0.5, tilt], [0.5, -0.5, tilt], [0.5, 0.5, -tilt], [-0.5, 0.5, -tilt]];
const square = MATERIAL === "metal" || MATERIAL === "dielectric" || MATERIAL === "raster";
if (square) triangles.length = 0, [[0, 1, 2], [0, 2, 3]].forEach((t) => push(t.map((k) => metal[k]),
  t.map(() => [0, tilt, 0.5])));
const material = MATERIAL === "mirror" ? new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0, 1, 0)
  : MATERIAL === "metal" ? new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0.5, 1, 0)
  : MATERIAL === "dielectric" ? new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0.2, 0, 0, 1.5)
  : MATERIAL === "raster" ? new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 1, 0, 0)
  : new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0, 0, 1, 1.5);
const engine = new F.FlexLight(canvas);
Object.assign(engine.config, { temporal: true, restir: MODE === "restir", antialiasing: undefined, samplesPerPixel: 1, maxBounces: 32 });
engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles, material, label: "prism" }));
engine.scene.ambientLight = new F.Vector(1, 1, 1);
engine.camera.position = new F.Vector(0, 0.5, 3);
engine.camera.direction = new F.Vector(0, 0.15);
if (MATERIAL === "raster") engine.renderer = "rasterizer",
  engine.scene.addPointLight(new F.PointLight(new F.Vector(0, 1, 2), new F.Vector(1, 1, 1), 10, 0.5));
if (square) engine.camera.position = new F.Vector(0, 0, 3), engine.camera.direction = new F.Vector(0, 0),
  engine.camera.fov = 1;

// Each frame's estimate summed per pixel, then the bounds checked over their mean
const sum = new Float64Array(SIZE * SIZE), row = Math.ceil(SIZE * 16 / 256) * 256, first = new Set();
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
  first.add(data[0]);
  buffer.destroy();
  if (++read < FRAMES) return result;
  const pixels = Array.from(sum, (s) => s / FRAMES), mean = pixels.reduce((a, b) => a + b) / pixels.length;
  const brightest = Math.max(...pixels), black = pixels.filter((v) => v < 0.5).length / pixels.length;
  const error = Math.sqrt(pixels.reduce((a, v) => a + (v - mean) ** 2, 0) / pixels.length / pixels.length);
  console.log(`mean ${mean.toFixed(4)}, standard error ${error.toFixed(4)}, brightest ${brightest.toFixed(4)}, ` +
    `black share ${(100 * black).toFixed(2)}%, pixel 0 took ${first.size} values`);
  if (MATERIAL === "raster") process.exit(first.size > 1 ? 0 : 1);
  process.exit((MATERIAL === "metal" ? Math.abs(mean - METAL) < 4 * error && first.size > 1
    : MATERIAL === "dielectric" ? Math.abs(mean - DIELECTRIC) < 4 * error : mean > 0.98)
    && brightest < 1.05 && black === 0 ? 0 : 1);
};
engine.renderer.render();
