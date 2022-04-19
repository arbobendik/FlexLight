"use strict";
// Declare RayTracer global.
var rt;
// Wait until DOM is loaded.
window.addEventListener("load", async function(){
	// Create new canvas.
	var canvas = document.createElement("canvas");
	// Append it to body.
	document.body.appendChild(canvas);
	// Create new RayTracer (rt) for canvas.
	rt = new rayTracer(canvas);
	// Create 2 pbr metallic textures.
	let roughTex = await rt.textureFromRME([0,0, 0], 1, 1);
  let smoothTex = await rt.textureFromRME([0.3, 0.5, 0], 1, 1);

	rt.pbrTextures.push(roughTex, smoothTex);
  // Move camera out of center.
  rt.z = -20;

  rt.maxReflections = 8;
	// Set primary light source.
	rt.primaryLightSources = [[0, 4, 0]];
	// Modify brightness of first one to be dimmer
	rt.primaryLightSources[0].intensity = 5;
	// Generate side planes of box.
	let bottom_plane = rt.plane([-5,-5,-15],[5,-5,-15],[5,-5,5],[-5,-5,5],[0,1,0]);
  let top_plane = rt.plane([-5,5,-15],[-5,5,5],[5,5,5],[5,5,-15],[0,-1,0]);
  let back_plane = rt.plane([-5,-5,5],[5,-5,5],[5,5,5],[-5,5,5],[0,0,-1]);
	let front_plane = rt.plane([-5,-5,-15],[-5,5,-15],[5,5,-15],[5,-5,-15],[0,0,1]);
  let left_plane = rt.plane([-5,-5,-15],[-5,-5,5],[-5,5,5],[-5,5,-15],[1,0,0]);
  let right_plane = rt.plane([5,-5,-15],[5,5,-15],[5,5,5],[5,-5,5],[-1,0,0]);

  // Make planes diffuse.
	bottom_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  top_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	back_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	front_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  left_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
  right_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	// Generate a few cuboids in the box with respective bounding box.
	let c = [];
  var [x, x2, y, y2, z, z2] = [-3, 0, -5, -5 + Math.sqrt(5), -1, 2];
	var [b0, b1, b2, b3] = [[x+1,  y, z], [x2,  y, z+1], [x2-1,  y, z2], [x,  y, z2-1]]
	var [t0, t1, t2, t3] = [[x+1, y2, z], [x2, y2, z+1], [x2-1, y2, z2], [x, y2, z2-1]]
	// Generate rotated cube object from planes.
  c[0] = [x, x2, y, y2, z, z2];
  c[1] = rt.plane(t0,t1,t2,t3,[0,1,0]);
  c[2] = rt.plane(t1,b1,b2,t2,[1,0,0]);
  c[3] = rt.plane(t2,b2,b3,t3,[0,0,1]);
  c[4] = rt.plane(b3,b2,b1,b0,[0,-1,0]);
  c[5] = rt.plane(t3,b3,b0,t0,[-1,0,0]);
  c[6] = rt.plane(t0,b0,b1,t1,[0,0,-1]);

	// Set textures for cube.
  let cube_colors = [
    [1, 1, 0], // yelllow
    [1, 0.5, 0], // orange
    [0, 0, 1], // blue
    [1, 1, 1], // white
    [1, 0, 0], // red
    [0, 1, 0] // green
  ];

	for (let i = 1; i <= 6; i++){
    c[i].colors = new Array(6).fill(cube_colors[i-1]).flat();
    c[i].textureNums = new Array(6).fill([-1,1,-1]).flat();
  }

	let box = [
		[-5, 5, -5, 5, -15, 5],
		bottom_plane, top_plane, back_plane, front_plane, left_plane, right_plane
	];
	// Push both objects to render queue.
	rt.queue.push(box, c);
	// Start render engine.
	rt.render();

	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(async function(){
		fpsCounter.textContent = rt.fps;
    // Update textures every second.
		rt.updateTextures();
		rt.updatePbrTextures();
    rt.updateTranslucencyTextures();
	},1000);
});