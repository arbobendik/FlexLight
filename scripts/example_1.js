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

	// Set camera perspective and position.
	[rt.X, rt.Y, rt.Z] = [-12, 5, -18];
	[rt.FX, rt.FY] = [0.440, 0.235];

	// Make light brighter.
	rt.LIGHT[0].strength = 8;
	// Set skylight.
	rt.SKYBOX = [0.2,0.2,0.2];

	// Create varying roughness texture for the surface.
	let normalTex = new Image();
	normalTex.src = "./textures/normal.png";
	// Generate new more diffuse texture for the grass block.
	let diffuseTex = await rt.GENERATE_PBR_TEX([1, 0, 0], 1, 1);
	let diffuseMetallicTex = await rt.GENERATE_PBR_TEX([0, 1, 0], 1, 1);
	// Add those textures to render queue.
	rt.PBR_TEXTURE.push(normalTex, diffuseTex, diffuseMetallicTex);

  // Generate translucency texture for cube.
  let translucencyTex = await rt.GENERATE_TRANSLUCENCY_TEX([1, 0, 1.3 / 4], 1, 1);
  rt.TRANSLUCENCY_TEXTURE.push(translucencyTex);

	// Set texture Sizes.
	rt.TEXTURE_SIZES = [32, 32];

	// Init surface element.
	let test_surface = [[-10, 10, -1, -0.9, -10, 10], [],[],[],[],[]];
	// Create 25 surface elements automatically.
	for (let i = 0; i < 5; i++){
		for (let j = 0; j < 5; j++){
			let x = -10 + 4 * j;
			let z = -10 + 4 * i;
			let plane = rt.PLANE([x,-1,z],[x+4,-1,z],[x+4,-1,z+4],[x,-1,z+4],[0,1,0]);
			// Set normal texture.
			plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
			// Push bounding volume.
			if (i === 0) test_surface[j + 1].push([-10 + 4 * j, -10 + 4 * (j + 1), -1, -0.9, -10, 10]);
			// Push vertices.
			test_surface[j + 1].push(plane);
		}
	}
	// Generate a few cuboids on surface.
	let r = [];
	r[0] = rt.CUBOID(-1.5, 4.5, -1, 2, 1.5, 2.5);
	r[1] = rt.CUBOID(-1.5, 1.5, -1, 2, -2, -1);
	r[2] = rt.CUBOID(0.5, 1.5, -1, 2, -1, 0);
	r[3] = rt.CUBOID(-1.5, -0.5, -1, 2, - 1, 0);
	// Color all cuboid in center.
	for (let i = 0; i < 4; i++){
		let color = new Array(6).fill(/*[1, 1, 1, 1]).flat();*/[Math.random(), Math.random(), Math.random(), 1]).flat();
		for (let j = 1; j < 7; j++) r[i][j].colors = color;
	}

	for (let i = 1; i <= 6; i++){
		for (let j = 0; j < 4; j++) r[j][i].textureNums = new Array(6).fill([-1,2,0]).flat();
	}
	// Spawn cube with textures.
	let cube = rt.CUBOID(5.5, 6.5, 1.5, 2.5, 5.5, 6.5);
	// Set different textures for different sides of the array.
	// And make cube full diffuse.
	cube[1].textureNums = new Array(6).fill([0,1,-1]).flat();
	cube[2].textureNums = new Array(6).fill([1,1,-1]).flat();
	cube[3].textureNums = new Array(6).fill([1,1,-1]).flat();
	cube[4].textureNums = new Array(6).fill([2,1,-1]).flat();
	cube[5].textureNums = new Array(6).fill([1,1,-1]).flat();
	cube[6].textureNums = new Array(6).fill([1,1,-1]).flat();

	// Create flat surface.
	let objects = [
	  [-1.5, 6.5, -1, 2.5, -2, 6.5],
	  [[-1.5, 4.5, -1, 2, -2, 2.5], r[0], r[1], r[2], r[3]],
	  cube
	];
	// Append both objects to render queue.
	rt.QUEUE.push(test_surface, objects);
  // Increase max reflections, because translucent objects need more reflections to look good.
  rt.REFLECTIONS = 7;
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
		rt.UPDATE_PBR_TEXTURE();
    rt.UPDATE_TRANSLUCENCY_TEXTURE();
	},1000);
});
