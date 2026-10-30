// The WebGL2 path tracer in headless Chromium on SwiftShader, the CPU alone, after `bash ./build-script`: the furnace's
// sheet, its left half of Blender's Translucent BSDF alone, its right half half diffuse, its light emitting a half, so
// that no pixel clips in the 8-bit canvas. Lit only from behind by a black square of side 4 a quarter below it
// (argument backlit), each half's mean, the columns next to the middle aside, carries the square's view of the sheet's
// center, 4 / PI * s * atan(s) for s = 2 / hypot(2, 0.25), times a half and a quarter, within 2%. In the box of
// furnace.mjs emitting a half (argument furnace), its shading normals tilted to (0.95, 0, 0.3122499), the lossless sheet
// returns all of it, a half, within four standard errors of each half's pixels; white diffuse on both halves (argument
// diffuse) too. furnace.mjs's metal square, built in object space and turned by its instance's scale (1, 2, 1), its normals
// the object's (argument scaled), holds GGX's albedo there, 0.8551, under white light of 0.9 within 0.5%; the rasterizer's
// beside one built in world space (argument rasterscaled), lit by a sphere light above, the same mean: the halves'
// difference within four standard errors of it, which the mirror image's pairs of pixels give. After 4096 frames; it fails unless the renderer is SwiftShader.
// The page posts what it read back to the server that serves it; CHROMIUM names the browser, chromium by default.
import { createServer } from "node:http";
import { readFileSync, mkdtempSync, rmSync } from "node:fs";
import { spawn, spawnSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";

const SIZE = 64, FRAMES = 4096, S = 2 / Math.hypot(2, 0.25), [CASE = "backlit"] = process.argv.slice(2);
const SQUARE = CASE === "scaled" || CASE === "rasterscaled", RASTER = CASE === "rasterscaled";
const FURNACE = CASE !== "backlit" && !SQUARE, [LEFT, RIGHT] = SQUARE ? [0.9 * 0.8551, 0.9 * 0.8551] : FURNACE ? [0.5, 0.5] : [2, 1].map((k) => 1 / Math.PI * k * S * Math.atan(S));
const PAGE = `<!doctype html><style>canvas { width: ${SIZE}px; height: ${SIZE}px }</style><canvas></canvas><script type="module">
// The drawing buffer is kept for the readback after the last frame, of the canvas WebGL2 replaces the page's with,
// the frames cut off after a fixed count
const getContext = HTMLCanvasElement.prototype.getContext;
let gl, frames = 0;
HTMLCanvasElement.prototype.getContext = function (type, attributes) {
  const context = getContext.call(this, type, { ...attributes, preserveDrawingBuffer: true });
  if (type === "webgl2") gl = context;
  return context;
};
const requestFrame = requestAnimationFrame.bind(window);
window.requestAnimationFrame = (cb) => ++frames <= ${FRAMES} ? requestFrame(cb) : (frames === ${FRAMES} + 1 && done(), 0);
const done = () => {
  const pixels = new Uint8Array(${SIZE * SIZE * 4});
  gl.bindFramebuffer(gl.FRAMEBUFFER, null);
  gl.readPixels(0, 0, ${SIZE}, ${SIZE}, gl.RGBA, gl.UNSIGNED_BYTE, pixels);
  const info = gl.getExtension("WEBGL_debug_renderer_info");
  fetch("/result", { method: "POST", body: JSON.stringify({ pixels: Array.from(pixels), renderer: gl.getParameter(info.UNMASKED_RENDERER_WEBGL) }) });
};
const F = await import("/public/build/flexlight/flexlight.js");
// The sheet in the plane z = 0, its halves x < 0 and x > 0, smooth along n, positions, normals and uvs per triangle
const n = ${FURNACE ? "[0.95, 0, 0.3122499]" : "[0, 0, 1]"};
const half = (x) => [[[0, -3, 0], [x, -3, 0], [x, 3, 0]], [[0, -3, 0], [x, 3, 0], [0, 3, 0]]].flatMap((t) =>
  [...(x > 0 ? t : [t[0], t[2], t[1]]).flat(), ...n, ...n, ...n, 0, 0, 0, 0, 0, 0]);
// The box of furnace.mjs, its faces wound and smooth along the inward normal, or the square
const box = [];
for (let k = 0; k < 3; k++) for (const s of [-1, 1]) {
  const at = (a, b) => [0, 1, 2].map((j) => j === k ? 4 * s : j === (k + 1) % 3 ? -4 * a * s : 4 * b);
  const n = [0, 1, 2].map((j) => j === k ? -s : 0), q = [at(-1, -1), at(1, -1), at(1, 1), at(-1, 1)];
  for (const t of [[q[0], q[1], q[2]], [q[0], q[2], q[3]]]) box.push(...t.flat(), ...n, ...n, ...n, 0, 0, 0, 0, 0, 0);
}
const lamp = ${FURNACE} ? box : [[[-2, -2], [2, -2], [2, 2]], [[-2, -2], [2, 2], [-2, 2]]]
  .flatMap((t) => [...t.flatMap(([x, y]) => [x, y, -0.25]), 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0]);
const material = (albedo, translucent, emissive = 0) => new F.Material(new F.Vector(albedo, albedo, albedo),
  new F.Vector(emissive, emissive, emissive), 1, 0, 0, 1, undefined, undefined, undefined, new F.Vector(translucent, translucent, translucent));
const engine = new F.FlexLight(document.querySelector("canvas"));
engine.api = "webgl2";
Object.assign(engine.config, { temporal: true, antialiasing: undefined, tonemapping: false, samplesPerPixel: 1 });
// The square of furnace.mjs, shifted along x and built in object space under the scale k, its normal S^T n
const tilt = Math.sqrt(3) / 2, corners = [[-0.5, -0.5, tilt], [0.5, -0.5, tilt], [0.5, 0.5, -tilt], [-0.5, 0.5, -tilt]];
const square = (shift, k) => { const o = [0, tilt, 0.5].map((c, i) => c * k[i]), l = Math.hypot(...o);
  return [[0, 1, 2], [0, 2, 3]].flatMap((t) => [...t.flatMap((j) => corners[j].map((c, i) => (c + shift * (i === 0)) / k[i])), ...t.flatMap(() => o.map((c) => c / l)), 0, 0, 0, 0, 0, 0]); };
if (${SQUARE}) {
  const white = new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), ${RASTER ? "1, 0" : "0.5, 1"}, 0);
  engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles: square(${RASTER ? 0.6 : 0}, [1, 2, 1]), material: white, label: "scaled" })).transform.scale(new F.Vector(1, 2, 1));
  if (${RASTER}) engine.renderer = "rasterizer", engine.scene.addPointLight(new F.PointLight(new F.Vector(0, 1, 2), new F.Vector(1, 1, 1), 12, 0.5)),
    engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles: square(-0.6, [1, 1, 1]), material: white, label: "twin" }));
} else {
  engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles: half(-3), material: material(${CASE === "diffuse" ? "1, 0" : "0, 1"}), label: "translucent" }));
  engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles: half(3), material: material(${CASE === "diffuse" ? "1, 0" : "0.5, 0.5"}), label: "mix" }));
  engine.scene.instance(await F.Prototype.fromTriangleArray({ triangles: lamp, material: material(0, 0, 0.5), label: "lamp" }));
}
engine.scene.ambientLight = new F.Vector(${CASE === "scaled" ? "0.9, 0.9, 0.9" : "0, 0, 0"});
engine.camera.position = new F.Vector(0, 0, 3);
engine.camera.direction = new F.Vector(0, 0);
engine.camera.fov = ${RASTER ? 40 : 1};
engine.renderer.render();
</script>`;

const profile = mkdtempSync(join(tmpdir(), "flexlight-webgl2-"));
let browser;
// The browser and every process it started, in its own process group, then its profile
const stop = () => browser && spawnSync("pkill", ["-KILL", "-g", String(browser.pid)]);
const finish = (code) => { stop(); rmSync(profile, { recursive: true, force: true }); process.exit(code); };
process.on("exit", stop);
const server = createServer((req, res) => {
  if (req.method === "POST") {
    let body = "";
    req.on("data", (chunk) => body += chunk).on("end", () => {
      res.end();
      const { pixels, renderer } = JSON.parse(body);
      // Each half's mean of (r + g + b) / 3, of the columns more than two away from the middle, and its standard error
      const half = (x) => { let sum = 0, squares = 0, n = 0; for (let p = 0; p < SIZE * SIZE; p++) if (x * (p % SIZE + 0.5 - SIZE / 2) > 2) {
        const v = (pixels[4 * p] + pixels[4 * p + 1] + pixels[4 * p + 2]) / 765; sum += v, squares += v * v, n++; }
        return [sum / n, Math.sqrt((squares / n - (sum / n) ** 2) / n)]; };
      const [[left, leftError], [right, rightError]] = [half(-1), half(1)];
      console.log(`${renderer}: halves ${left.toFixed(4)} ± ${leftError.toFixed(4)} and ${right.toFixed(4)} ± ${rightError.toFixed(4)} of ${LEFT.toFixed(4)} and ${RIGHT.toFixed(4)}`);
      // The rasterizer's twins mirror each other across the middle: each left pixel less its mirror image on the right,
      // whose mean is the halves' difference, and its standard error
      const pairs = [], value = (p) => (pixels[4 * p] + pixels[4 * p + 1] + pixels[4 * p + 2]) / 765;
      for (let p = 0; p < SIZE * SIZE; p++) if (p % SIZE + 0.5 - SIZE / 2 < -2) pairs.push(value(p) - value(p + SIZE - 1 - 2 * (p % SIZE)));
      const difference = pairs.reduce((a, b) => a + b) / pairs.length;
      const differenceError = Math.sqrt(pairs.reduce((a, d) => a + (d - difference) ** 2, 0) / (pairs.length - 1) / pairs.length);
      if (RASTER) console.log(`halves differ by ${difference.toFixed(4)} ± ${differenceError.toFixed(4)}`);
      const within = (v, error, truth) => FURNACE ? Math.abs(v - truth) < 4 * error : Math.abs(v / truth - 1) < (SQUARE ? 0.005 : 0.02);
      finish(/SwiftShader/.test(renderer) && (RASTER ? Math.abs(difference) < 4 * differenceError
        : within(left, leftError, LEFT) && within(right, rightError, RIGHT)) ? 0 : 1);
    });
    return;
  }
  if (req.url === "/") return res.setHeader("Content-Type", "text/html"), res.end(PAGE);
  if (!req.url.startsWith("/public/build/")) return res.writeHead(404), res.end();
  res.setHeader("Content-Type", "text/javascript");
  res.end(readFileSync(new URL(".." + req.url, import.meta.url)));
}).listen(0, () => {
  browser = spawn(process.env.CHROMIUM ?? "chromium", ["--headless=new", "--ozone-platform=headless", "--disable-features=Vulkan",
    "--disable-vulkan-surface", "--use-gl=angle", "--use-angle=swiftshader", "--enable-unsafe-swiftshader", "--no-first-run",
    `--user-data-dir=${profile}`, `http://localhost:${server.address().port}/`], { stdio: "ignore", detached: true,
    // Without the Vulkan loader's variables, which a GPU's driver in them would let ANGLE render on in place of SwiftShader
    env: Object.fromEntries(Object.entries(process.env).filter(([name]) => !name.startsWith("VK_"))) });
});
setTimeout(() => { console.log("no result within 240 s"); finish(1); }, 240000);
