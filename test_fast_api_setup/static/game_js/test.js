"use strict";

// Set Textures 0, 1, 2.
[
	"static/textures/grass.jpg",     // 0
	"static/textures/dirt_side.jpg", // 1
  "static/textures/dirt.jpeg"      // 2
].forEach((item, i) => {
	let img = new Image();
  img.src = item;
  TEXTURE.push(img);
});

let normal_tex = new Image();
normal_tex.src = "static/textures/normal.jpg";
NORMAL_TEXTURE.push(normal_tex);
// Set texture Sizes.
var TEXTURE_SIZES = [16, 16];
// Update textures.
updateTexture();

// Init surface element.
let test_surface = [[-10, 10, -1, -0.9, -10, 10], [],[],[],[],[]];
// Create 25 surface elements automatically.
for (let i = 0; i < 25; i++)
{
  let plane = cuboid(-10 + 4*(i%5), -1, -10 + 4*Math.floor(i / 5));
	let x = -10 + 4*(i%5);
	let z = -10 + 4*Math.floor(i / 5);
	plane = surface([x,-1,z],[x+4,-1,z],[x+4,-1,z+4],[x,-1,z+4],[0,1,0]);
	// Set normal texture.
	plane.textureNums = new Array(6).fill([-1,0]).flat();
  // Push bounding volume.
  if (i < 5) test_surface[i%5 + 1].push([-10 + 4*(i%5), -10 + 4*(i%5 + 1), -1, -0.9, -10, 10]);
  // Push vertices.
  test_surface[i%5 + 1].push(plane);
}
// Generate a few cuboids on surface.
let r = [];
r[0] = cuboid(-1.5, -1, 1.5);
r[0].width = 6;
r[0].height = 3;
r[1] = cuboid(-1.5, -1, -2);
r[1].width = 3;
r[1].height = 3;
r[2] = cuboid(0.5, -1, -1);
r[2].height = 3;
r[3] = cuboid(-1.5, -1, - 1);
r[3].height = 3;
// Activate cuboids.
r.forEach((item, i) => {
  r[i] = item(item);
});
// Spawn dice with textures.
let dice = cuboid(5.5, 1.5, 5.5);
dice = dice(dice);
// Set different textures for different sides of the array.
dice[1].textureNums = new Array(6).fill([0,-1]).flat();
dice[2].textureNums = new Array(6).fill([1,-1]).flat();
dice[3].textureNums = new Array(6).fill([1,-1]).flat();
dice[4].textureNums = new Array(6).fill([2,-1]).flat();
dice[5].textureNums = new Array(6).fill([1,-1]).flat();
dice[6].textureNums = new Array(6).fill([1,-1]).flat();

// Create flat surface.
//let flat_surface = surface([-20,1,-20],[20,1,-20],[20,1,20],[-20,1,20],[0,1,0]);
let objects = [
  [-1.5, 6.5, -1, 2.5, -2, 6.5],
  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
  dice
];
// Append both objects to render queue.
QUEUE.push(test_surface, objects);
