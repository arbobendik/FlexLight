"use strict";
// Declare engine global.
var engine;
// Start scene buider
buildScene();
// Build example scene
async function buildScene() {
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
  document.body.appendChild(canvas);
  engine = new FlexLight(canvas);
  engine.io = 'web';

  let camera = engine.camera;
  let scene = engine.scene;
  // Create pbr textures.
	let roughTex = await scene.textureFromRME([0, 0, 0], 1, 1);
  let smoothTex = await scene.textureFromRME([0.3, 0.5, 0], 1, 1);

	scene.pbrTextures.push(roughTex, smoothTex);
  // Move camera out of center.
  camera.z = -20;

	// Set primary light source.
	scene.primaryLightSources = [[0, 4, 0]];
	// Modify brightness of first one to be dimmer
	scene.primaryLightSources[0].intensity = 5;
  scene.primaryLightSources[0].variation = 0;
	// Generate side planes of box.
	let bottom_plane = scene.Plane([-5,-5,-15],[5,-5,-15],[5,-5,5],[-5,-5,5],[0,1,0]);
  let top_plane = scene.Plane([-5,5,-15],[-5,5,5],[5,5,5],[5,5,-15],[0,-1,0]);
  let back_plane = scene.Plane([-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5],[0,0,-1]);
	let front_plane = scene.Plane([-5,-5,-15],[-5,5,-15],[5,5,-15],[5,-5,-15],[0,0,1]);
  let left_plane = scene.Plane([-5,-5,-15],[-5,-5,5],[-5,5,5],[-5,5,-15],[1,0,0]);
  let right_plane = scene.Plane([5,-5,-15],[5,5,-15],[5,5,5],[5,-5,5],[-1,0,0]);

  // Make planes diffuse.
  [bottom_plane, top_plane, back_plane, front_plane, left_plane, right_plane].forEach((item) => item.setTextureNums(-1, 0, -1));
	// Generate a few cuboids in the box with respective bounding box.
	let c = [];
  var [x, x2, y, y2, z, z2] = [-3, 0, -5, -5 + Math.sqrt(5), -1, 2];
	var [b0, b1, b2, b3] = [[x+1,  y, z], [x2,  y, z+1], [x2-1,  y, z2], [x,  y, z2-1]]
	var [t0, t1, t2, t3] = [[x+1, y2, z], [x2, y2, z+1], [x2-1, y2, z2], [x, y2, z2-1]]
	// Generate rotated cube object from planes.
  c = scene.Cuboid(x, x2, y, y2, z, z2);
  c[0] = scene.Plane(t0,t1,t2,t3,[0,1,0]);
  c[1] = scene.Plane(t1,b1,b2,t2,[1,0,0]);
  c[2] = scene.Plane(t2,b2,b3,t3,[0,0,1]);
  c[3] = scene.Plane(b3,b2,b1,b0,[0,-1,0]);
  c[4] = scene.Plane(t3,b3,b0,t0,[-1,0,0]);
  c[5] = scene.Plane(t0,b0,b1,t1,[0,0,-1]);

	// Set textures for cube.
  let cube_colors = [
    [255, 255, 0], // yellow
    [255, 127, 0], // orange
    [0, 0, 255], // blue
    [255, 255, 255], // white
    [255, 0, 0], // red
    [0, 255, 0] // green
  ];

	for (let i = 1; i <= 6; i++){
    c[i].setColor(cube_colors[i-1]);
    c[i].setTextureNums(-1, 1, -1);
  }

	let box = [bottom_plane, top_plane, back_plane, front_plane, left_plane, right_plane];
	// Push both objects to render queue.
	scene.queue.push(box, c);
	// Start render engine.
	engine.renderer.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(async function(){
		fpsCounter.textContent = engine.renderer.fps;

    // Update textures every second.
		engine.renderer.updateTextures();
		engine.renderer.updatePbrTextures();
    engine.renderer.updateTranslucencyTextures();
	},1000);
}
