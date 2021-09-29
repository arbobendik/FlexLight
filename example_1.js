"use strict";
// Declare RayTracer global.
var rt;
// Wait until DOM is loaded.
document.addEventListener("DOMContentLoaded", async function(){
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas.
	rt = RayTracer(canvas);
	// Set Textures 0, 1, 2.
	[
		"textures/grass.jpg",     // 0
		"textures/dirt_side.jpg", // 1
	  "textures/dirt.jpeg"      // 2
	].forEach((item, i) => {
		let img = new Image();
	  img.src = item;
	  rt.TEXTURE.push(img);
	});

	// Set sky-box illumination to 0.2.
	rt.SKYBOX = [0.2, 0.2, 0.2];

	let normalTex = new Image();
	normalTex.src = "./textures/normal.jpg";
	rt.NORMAL_TEXTURE.push(normalTex);

	let diffuseTex = await rt.GENERATE_NORMAL_TEX([200], 1, 1);
	console.log(diffuseTex);
	rt.NORMAL_TEXTURE.push(diffuseTex);
	// Set texture Sizes.
	rt.TEXTURE_SIZES = [32, 32];

	// Init surface element.
	let test_surface = [[-10, 10, -1, -0.9, -10, 10], [],[],[],[],[]];
	// Create 25 surface elements automatically.
	for (let i = 0; i < 25; i++)
	{
		let x = -10 + 4*(i%5);
		let z = -10 + 4*Math.floor(i / 5);
		let plane = rt.PLANE([x,-1,z],[x+4,-1,z],[x+4,-1,z+4],[x,-1,z+4],[0,1,0]);
		// Set normal texture.
		plane.textureNums = new Array(6).fill([-1,0]).flat();
	  // Push bounding volume.
	  if (i < 5) test_surface[i%5 + 1].push([-10 + 4*(i%5), -10 + 4*(i%5 + 1), -1, -0.9, -10, 10]);
	  // Push vertices.
	  test_surface[i%5 + 1].push(plane);
	}
	// Generate a few cuboids on surface.
	let r = [];
	r[0] = rt.CUBOID(-1.5, -1, 1.5, 6, 3, 1);
	r[1] = rt.CUBOID(-1.5, -1, -2, 3, 3, 1);
	r[2] = rt.CUBOID(0.5, -1, -1, 1, 3, 1);
	r[3] = rt.CUBOID(-1.5, -1, - 1, 1, 3, 1);
	// Color all cuboid in center.
	for (let i = 0; i < 4; i++){
		let color = new Array(6).fill([Math.random(), Math.random(), Math.random(), 1]).flat();
		for (let j = 1; j < 7; j++) r[i][j].colors = color;
	}
	// Spawn cube with textures.
	let cube = rt.CUBOID(5.5, 1.5, 5.5, 1, 1, 1);
	// Set different textures for different sides of the array.
	// And make cube full diffuse.
	cube[1].textureNums = new Array(6).fill([0,1]).flat();
	cube[2].textureNums = new Array(6).fill([1,1]).flat();
	cube[3].textureNums = new Array(6).fill([1,1]).flat();
	cube[4].textureNums = new Array(6).fill([2,1]).flat();
	cube[5].textureNums = new Array(6).fill([1,1]).flat();
	cube[6].textureNums = new Array(6).fill([1,1]).flat();

	// Create flat surface.
	let objects = [
	  [-1.5, 6.5, -1, 2.5, -2, 6.5],
	  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
	  cube
	];
	// Append both objects to render queue.
	rt.QUEUE.push(test_surface, objects);
	// Start render engine.
	rt.START();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = rt.FPS;
		// Update textures every second.
		rt.UPDATE_TEXTURE();
		rt.UPDATE_NORMAL_TEXTURE();
	},1000);
});
