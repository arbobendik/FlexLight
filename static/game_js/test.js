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
normal_tex.src = "static/textures/normal.jpg"
NORMAL_TEXTURE.push(normal_tex);
// Set texture Sizes.
var TEXTURE_SIZES = [16, 16];
// Update textures.
updateTexture();
// Spawn dice with textures.
let dice = cuboid(-0.5, 1, -0.5);
dice = dice(dice);
// Set different textures for different sides of the array.
dice[1].textureNums = new Array(6).fill([0,0]).flat();
dice[2].textureNums = new Array(6).fill([1,0]).flat();
dice[3].textureNums = new Array(6).fill([1,0]).flat();
dice[4].textureNums = new Array(6).fill([2,0]).flat();
dice[5].textureNums = new Array(6).fill([1,0]).flat();
dice[6].textureNums = new Array(6).fill([1,0]).flat();

// Create flat surface.
let flat_surface = surface([-20,1,-20],[20,1,-20],[20,1,20],[-20,1,20],[0,1,0]);

// Append both objects to render queue.
QUEUE.push(dice, flat_surface);
