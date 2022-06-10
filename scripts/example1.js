"use strict";
// Declare engine global
var engine;
// Start scene buider
buildScene();
// Build example scene
async function buildScene() {
	// Create new canvas
	var canvas = document.createElement("canvas");
	// Append it to body
	document.body.appendChild(canvas);
	// Create new engine object for canvas
  engine = new FlexLight (canvas);
  engine.io = 'web';

  let camera = engine.camera;
  let scene = engine.scene;
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
	  scene.textures.push(img);
	});

  [
		"textures/redstone_pbr.png"     // 0
	].forEach((item, i) => {
		let img = new Image();
	  img.src = item;
	  scene.pbrTextures.push(img);
	});

	// Set camera perspective and position
	[camera.x, camera.y, camera.z] = [-8, 7, -11];
	[camera.fx, camera.fy] = [0.440, 0.55];

  scene.primaryLightSources = [[0.5, 1, 0.5], [0, 15, 2]];

	// Make light dimmer (default = 200)
  scene.primaryLightSources[0].intensity = 70;
  scene.primaryLightSources[0].variation = 0.2;
  scene.primaryLightSources[1].intensity = 100;
	// Set ambient illumination
	scene.ambientLight = [0.05, 0.05, 0.05];

	// Create varying roughness texture for the surface
	let normalTex = new Image();
	normalTex.src = "./textures/normal.png";
	// Generate new more diffuse texture for the grass block
	let diffuseTex = await scene.textureFromRME([1, 0, 0], 1, 1);
  let diffuseGlowTex = await scene.textureFromRME([1, 0, 0.5], 1, 1);
  let smoothMetallicTex = await scene.textureFromRME([0, 0.2, 0], 1, 1);
	// Add those textures to render queue
	scene.pbrTextures.push(normalTex, diffuseTex, smoothMetallicTex, diffuseGlowTex); // 1 2 3 4

  // Generate translucency texture for cube
  let translucencyTex = await scene.textureFromTPO([1, 0, 1.3 / 4], 1, 1);
  scene.translucencyTextures.push(translucencyTex); // 0

	// Set texture Sizes
	scene.standardTextureSizes = [16, 16];

  // Create large ground plane
  let groundPlane = scene.Plane([-10,-1,-10],[10,-1,-10],[10,-1,10],[-10,-1,10],[0,1,0]);

	// Set normal texture for each plane
  groundPlane.setTextureNums(-1, 1, -1);

	// Generate a few cuboids on surface
  let cuboids = [
    scene.Cuboid(-1.5, 4.5, -1, 2, 1.5, 2.5),
    scene.Cuboid(-1.5, 1.5, -1, 2, -2, -1),
    scene.Cuboid(0.5, 1.5, -1, 2, -1, 0),
    scene.Cuboid(-1.5, -0.5, -1, 2, - 1, 0)
  ];

  // Color all cuboid in center

  for (let i = 0; i < 4; i++) {
    cuboids[i].setColor(Math.random() * 255, Math.random() * 255, Math.random() * 255);
    cuboids[i].setTextureNums(-1, 3, 0);
  }

	// Spawn cubes with grass block textures
	let grassCube = scene.Cuboid(5.5, 6.5, 1.5, 2.5, 5.8, 6.8);
  let grassCube2 = scene.Cuboid(-3, -2, -1, 0, -5.2, -4.2);
  // Spawn redstone cube
	let redCube = scene.Cuboid(4, 5, 1.5, 2.5, 5.2, 6.2);
  // Spawn red glowing cube
  let lantern = scene.Cuboid(-2.5, -1.5, -1, 0, -3.8, -2.8);
  let wall = scene.Cuboid(2.5, 7.5, -1, 1.5, 5, 7);

  // Make red cube red and emissive and lantern emissive
  redCube.setTextureNums(3, 0, -1);
  lantern.setTextureNums(4, 4, -1);

  // Change diffusion properties of wall on specific sides
  wall.top.setTextureNums(-1, 2, -1);
  wall.left.setTextureNums(-1, 2, -1);
	// Set different textures for different sides of the array
	// And make cube full diffuse
  [grassCube, grassCube2].forEach((item) => {
    item.setTextureNums(1, 2, -1);
    // Set different textures for top and bottom.
    item.top.setTextureNums(0, 2, -1);
    item.bottom.setTextureNums(2, 2, -1);
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
	scene.queue.push(groundPlane, objectTree);
  // Increase max reflections, because translucent objects need more reflections to look good
  engine.renderer.maxReflections = 4;
	// Start render engine
	engine.renderer.render();

	// Add FPS counter to top-right corner
	var fpsCounter = document.createElement("div");
	// Append it to body
	document.body.appendChild(fpsCounter);
	// Update Counter periodically
	setInterval(function(){
		fpsCounter.textContent = engine.renderer.fps;
		// Update textures every second
		engine.renderer.updateTextures();
    engine.renderer.updatePbrTextures();
    engine.renderer.updateTranslucencyTextures();
	},1000);
};
