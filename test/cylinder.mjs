// The cylinder case of furnace.mjs and webgl2.mjs: white metal of roughness 0.5 and anisotropy 1 on two cylinders about
// their z of radius 0.4 and height 1.6, stood up along y at x = -0.6 and 0.6 under the white light and seen from 3 along
// z at a field of view of 40 degrees: 16 smooth segments about their UV map's tangent, u running around, on the left,
// 256 about Blender's default tangent, radial about z, on the right. The UV map's tangent of the triangles made normal
// to the smooth normal is not cut along the coarse cylinder's faces: each column of the right one's middle, x from 0.35
// to 0.85 and the middle 32 rows, reads within 2% of its mirror image's on the left.

// Positions, normals and uvs per triangle of the cylinder of the given segments, wound outward
export const cylinder = (segments) => {
  const triangles = [], angle = (k) => 2 * Math.PI * k / segments;
  for (let i = 0; i < segments; i++) for (const q of [[[i, -0.8], [i + 1, -0.8], [i + 1, 0.8]], [[i, -0.8], [i + 1, 0.8], [i, 0.8]]])
    triangles.push(...q.flatMap(([k, z]) => [0.4 * Math.cos(angle(k)), 0.4 * Math.sin(angle(k)), z]),
      ...q.flatMap(([k]) => [Math.cos(angle(k)), Math.sin(angle(k)), 0]), ...q.flatMap(([k, z]) => [k / segments, z / 1.6 + 0.5]));
  return triangles;
};

// The worst relative difference of the columns' means between the right cylinder and the left mirrored, of the
// pixels' values, row by row from either side, the image square of the given size
export const deviation = (value, size) => {
  let worst = 0;
  for (let c = 0; c < size; c++) {
    const x = ((c + 0.5) / size * 2 - 1) * 3 * Math.tan(Math.PI / 9);
    if (x < 0.35 || x > 0.85) continue;
    let right = 0, left = 0;
    for (let r = size / 2 - 16; r < size / 2 + 16; r++) right += value(r * size + c), left += value(r * size + size - 1 - c);
    worst = Math.max(worst, Math.abs(left / right - 1));
  }
  return worst;
};

// The two cylinders of furnace.mjs' and webgl2.mjs' engine F in its scene
export const instanceCylinders = async (F, scene) => {
  for (const [segments, x, tangentSource] of [[16, -0.6, "uv"], [256, 0.6, "radial"]]) {
    const material = new F.Material(new F.Vector(1, 1, 1), new F.Vector(0, 0, 0), 0.5, 1, 0, 1.5, undefined, undefined,
      undefined, undefined, undefined, undefined, 1, 0, tangentSource);
    const instance = scene.instance(await F.Prototype.fromTriangleArray({ triangles: cylinder(segments), material, label: `cylinder ${segments}` }));
    instance.transform.rotateAxis(new F.Vector(1, 0, 0), Math.PI / 2);
    instance.transform.move(x, 0, 0);
  }
};
