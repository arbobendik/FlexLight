"use strict";

// Declare RayTracer global
var rt;
// Start scene buider
buildScene();
// Build example scene
async function buildScene() {
	// Create new canvas
	var canvas = document.createElement("canvas");
	// Append it to body
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas
  let fl = new FlexLight (canvas);
	rt = fl.renderer;
	// Set Textures 0, 1, 2, 3, 4
	[
		"textures/grass.jpg",     // 0
		"textures/dirt_side.jpg", // 1
	  "textures/dirt.jpeg",     // 2
    "textures/redstone.png",   // 3
    "textures/lamp.jpg"    //4
	].forEach((item, i) => {
		let img = new Image();
	  img.src = item;
	  rt.textures.push(img);
	});

  [
		"textures/redstone_pbr.png"     // 0
	].forEach((item, i) => {
		let img = new Image();
	  img.src = item;
	  rt.pbrTextures.push(img);
	});

	// Set camera perspective and position
	[fl.camera.x, fl.camera.y, fl.camera.z] = [-8, 7, -11];
	[fl.camera.fx, fl.camera.fy] = [0.440, 0.55];

  rt.primaryLightSources = [[0.5, 1, 0.5], [0, 15, 2]];

	// Make light dimmer (default = 200)
  rt.primaryLightSources[0].intensity = 70;
  rt.primaryLightSources[0].variation = 0.2;
  rt.primaryLightSources[1].intensity = 100;
	// Set ambient illumination
	rt.ambientLight = [0.05,0.05,0.05];

	// Create varying roughness texture for the surface
	let normalTex = new Image();
	normalTex.src = "./textures/normal.png";
	// Generate new more diffuse texture for the grass block
	let diffuseTex = await rt.textureFromRME([1, 0, 0], 1, 1);
  let diffuseGlowTex = await rt.textureFromRME([1, 0, 0.5], 1, 1);
  let smoothMetallicTex = await rt.textureFromRME([0, 0.2, 0], 1, 1);
	// Add those textures to render queue
	rt.pbrTextures.push(normalTex, diffuseTex, smoothMetallicTex, diffuseGlowTex);

  // Generate translucency texture for cube
  let translucencyTex = await rt.textureFromTPO([1, 0, 1.3 / 4], 1, 1);
  rt.translucencyTextures.push(translucencyTex);

	// Set texture Sizes
	rt.standardTextureSizes = [16, 16];

  // Create large ground plane
  let groundPlane = rt.plane([-10,-1,-10],[10,-1,-10],[10,-1,10],[-10,-1,10],[0,1,0]);

	// Set normal texture for each plane
	groundPlane.textureNums = new Array(6).fill([-1,1,-1]).flat();

	// Generate a few cuboids on surface
  let cuboids = [
    rt.cuboid(-1.5, 4.5, -1, 2, 1.5, 2.5),
    rt.cuboid(-1.5, 1.5, -1, 2, -2, -1),
    rt.cuboid(0.5, 1.5, -1, 2, -1, 0),
    rt.cuboid(-1.5, -0.5, -1, 2, - 1, 0)
  ];

  // Color all cuboid in center
  for (let i = 0; i < 4; i++){
    let color = new Array(6).fill([Math.random(), Math.random(), Math.random()]).flat();
    for (let j = 1; j <= 6; j++) cuboids[i][j].colors = color;
  }

  for (let i = 1; i <= 6; i++){
    for (let j = 0; j < 4; j++) cuboids[j][i].textureNums = new Array(6).fill([-1,3,0]).flat();
  }
	// Spawn cubes with grass block textures
	let grassCube = rt.cuboid(5.5, 6.5, 1.5, 2.5, 5.8, 6.8);
  let grassCube2 = rt.cuboid(-3, -2, -1, 0, -5.2, -4.2);
  // Spawn redstone cube
	let redCube = rt.cuboid(4, 5, 1.5, 2.5, 5.2, 6.2);
  // Spawn red glowing cube
  let lantern = rt.cuboid(-2.5, -1.5, -1, 0, -3.8, -2.8);
  let wall = rt.cuboid(2.5, 7.5, -1, 1.5, 5, 7);

  // Make redCube red and emissive
  for (let i = 1; i <= 6; i++){
    redCube[i].textureNums = new Array(6).fill([3,0,-1]).flat();

    lantern[i].textureNums = new Array(6).fill([4,4,-1]).flat();
  }

  wall[6].textureNums = new Array(6).fill([-1,2,-1]).flat();
  wall[1].textureNums = new Array(6).fill([-1,2,-1]).flat();
	// Set different textures for different sides of the array
	// And make cube full diffuse
  [grassCube, grassCube2].forEach((item, i) => {
    item[1].textureNums = new Array(6).fill([0,2,-1]).flat();
    item[2].textureNums = new Array(6).fill([1,2,-1]).flat();
    item[3].textureNums = new Array(6).fill([1,2,-1]).flat();
    item[4].textureNums = new Array(6).fill([2,2,-1]).flat();
    item[5].textureNums = new Array(6).fill([1,2,-1]).flat();
    item[6].textureNums = new Array(6).fill([1,2,-1]).flat();
  });


  // Pack cuboids in tree structure to increase raytracing effiecency
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
  // Pack cube and wall in tree structure
  let cubeWallTree = [
    [2.5, 7.5, -1, 2.5, 5, 7],
    wall,
    [
      [4, 6.5, 1.5, 2.5, 5.2, 6.8],
      grassCube,
      redCube
    ]
  ];

  let cubeTree = [
    [-3, -0.5, -1, 0, -5.2, -2.8],
    grassCube2,
    lantern
  ];
  // Pack all trees together to one tree with all objects on the plane
	let objectTree = [
	  [-6.5, 7.5, -1, 2.5, -5.2, 7],
	  cuboidTree,
	  cubeWallTree,
    cubeTree
	];
	// Append plane tree and object tree to render queue
	rt.queue.push(groundPlane, objectTree);
  // Increase max reflections, because translucent objects need more reflections to look good
  rt.maxReflections = 4;
	// Start render engine
	rt.render();

	// Add FPS counter to top-right corner
	var fpsCounter = document.createElement("div");
	// Append it to body
	document.body.appendChild(fpsCounter);
	// Update Counter periodically
	setInterval(function(){
		fpsCounter.textContent = rt.fps;
		// Update textures every second
		rt.updateTextures();
    rt.updatePbrTextures();
    rt.updateTranslucencyTextures();
	},1000);
};
