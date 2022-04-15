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

  rt.LIGHT = [[0.5, 1, 0.5], [0, 20, 0]];

	// Make light brighter.
	rt.LIGHT[0].strength = 200;
  rt.LIGHT[0].strength = 100;
	// Set skylight.
	rt.SKYBOX = [0.1,0.1,0.1];

	// Create varying roughness texture for the surface.
	let normalTex = new Image();
	normalTex.src = "./textures/normal.png";
	// Generate new more diffuse texture for the grass block.
	let diffuseTex = await rt.GENERATE_PBR_TEX([1, 0, 0], 1, 1);
  let diffuseGlowTex = await rt.GENERATE_PBR_TEX([1, 0, 0.5], 1, 1);
  let smoothMetallicTex = await rt.GENERATE_PBR_TEX([0, 0.5, 0], 1, 1);
	// Add those textures to render queue.
	rt.PBR_TEXTURE.push(normalTex, diffuseTex, diffuseGlowTex, smoothMetallicTex);

  // Generate translucency texture for cube.
  let translucencyTex = await rt.GENERATE_TRANSLUCENCY_TEX([1, 0, 1.3 / 4], 1, 1);
  rt.TRANSLUCENCY_TEXTURE.push(translucencyTex);

	// Set texture Sizes.
	rt.TEXTURE_SIZES = [12, 12];

  // Create large ground plane.
  let groundPlane = rt.PLANE([-10,-1,-10],[10,-1,-10],[10,-1,10],[-10,-1,10],[0,1,0]);
  let backPlane = rt.PLANE([10,19,10],[-10,19,10],[-10,-1,10],[10,-1,10],[0,0,1]);
  let sidePlane = rt.PLANE([-10,19,10],[-10,19,-10],[-10,-1,-10],[-10,-1,10],[1,0,0]);
	// Set normal texture for each plane.
	groundPlane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  backPlane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  sidePlane.textureNums = new Array(6).fill([-1,0,-1]).flat();

	// Generate a few cuboids on surface.
  let cuboids = [
    rt.CUBOID(-1.5, 4.5, -1, 2, 1.5, 2.5),
    rt.CUBOID(-1.5, 1.5, -1, 2, -2, -1),
    rt.CUBOID(0.5, 1.5, -1, 2, -1, 0),
    rt.CUBOID(-1.5, -0.5, -1, 2, - 1, 0)
  ];
  // Color all cuboid in center.
  for (let i = 0; i < 4; i++){
    let color = new Array(6).fill([Math.sqrt(Math.random()), Math.sqrt(Math.random()), Math.sqrt(Math.random())]).flat();
    for (let j = 1; j <= 6; j++) cuboids[i][j].colors = color;
  }

  for (let i = 1; i <= 6; i++){
    for (let j = 0; j < 4; j++) cuboids[j][i].textureNums = new Array(6).fill([-1,3,0]).flat();
  }
	// Spawn cube with grass block textures.
	let grassCube = rt.CUBOID(5.5, 6.5, 1.5, 2.5, 5.8, 6.8);
  // Spawn red glowing cube.
	let redCube = rt.CUBOID(4, 5, 1.5, 2.5, 5.2, 6.2);
  let wall = rt.CUBOID(2.5, 7.5, -1, 1.5, 5, 7);

  // Make redCube red and emissive.
  for (let i = 1; i <= 6; i++){
    redCube[i].textureNums = new Array(6).fill([-1,2,0]).flat();
    redCube[i].colors = new Array(6).fill([1,0,0]).flat();
  }

  wall[6].textureNums = new Array(6).fill([-1,1,-1]).flat();
  wall[1].textureNums = new Array(6).fill([-1,1,-1]).flat();
	// Set different textures for different sides of the array.
	// And make cube full diffuse.
	grassCube[1].textureNums = new Array(6).fill([0,1,-1]).flat();
	grassCube[2].textureNums = new Array(6).fill([1,1,-1]).flat();
	grassCube[3].textureNums = new Array(6).fill([1,1,-1]).flat();
	grassCube[4].textureNums = new Array(6).fill([2,1,-1]).flat();
	grassCube[5].textureNums = new Array(6).fill([1,1,-1]).flat();
	grassCube[6].textureNums = new Array(6).fill([1,1,-1]).flat();

  // Pack cuboids in tree structure to increase raytracing effiecency.
  let cuboidTree = [
    [-1.5, 4.5, -1, 2, -2, 2.5],
    cuboids[0],
    [
      [-1.5, 1.5, -1, 2, -2, 0],
      cuboids[1],
      [
        [-1.5, 1.5, -1, 2, -1, 0],
        cuboids[2],
        cuboids[3]
      ]
    ]
  ];
  // Pack cube and wall in tree structure.
  let cubeWallTree = [
    [2.5, 7.5, -1, 2.5, 5, 7],
    wall,
    [
      [4, 6.5, 1.5, 2.5, 5.2, 6.8],
      grassCube,
      redCube
    ]
  ];
  // Pack all trees together to one tree with all objects on the plane.
	let objectTree = [
	  [-1.5, 7.5, -1, 2.5, -2, 7],
	  cuboidTree,
	  cubeWallTree
	];
	// Append plane tree and object tree to render queue.
	rt.QUEUE.push(groundPlane, objectTree);
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
