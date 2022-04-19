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
	// Make plane defuser.
	let normal_tex = await rt.textureFromRME([0.5, 0.5, 0], 1, 1);
	let cuboid_tex = await rt.textureFromRME([0.5, 0.5, 0.05], 1, 1);
	rt.pbrTextures.push(normal_tex, cuboid_tex);
	// Set light source.
	rt.primaryLightSources = [[0, 10, 0]];
	// Modify brightness.
	rt.primaryLightSources[0].intensity = 100;
	// Generate plane.
	let this_plane = rt.plane([-100,-1,-100],[100,-1,-100],[100,-1,100],[-100,-1,100],[0,1,0]);
	this_plane.textureNums = new Array(6).fill([-1,0,-1]).flat();
	// Push both objects to render queue.
	rt.queue.push(this_plane);
	// Start render engine.
	rt.render();
	// Add FPS counter to top-right corner.
	var fpsCounter = document.createElement("div");
	// Append it to body.
	document.body.appendChild(fpsCounter);
	// Update Counter periodically.
	setInterval(function(){
		fpsCounter.textContent = rt.FPS;
		// Update texture atlases.
		rt.updatePbrTextures();
	},1000);

	// Set power of 2 square length.
	let power = 2;
	let sideLength = 2 ** power;
	// Set camera perspective and position.
	[rt.x, rt.y, rt.z] = [-4 - sideLength, 3 + power, -4];
	[rt.fx, rt.fy] = [0.25 * Math.PI, 0.6];
	// Colors.
	let colors = [];
	// assign each pillar a color.
	for (let i = 0; i < sideLength; i++){
		let row = [];
		for (let j = 0; j < sideLength; j++) row.push([Math.random(), Math.random(), Math.random()]);
		colors.push(row);
	}

	// Declare recursive function to build recursive structure for maximal bounding box performance increase.
	var drawMap = (pot, x, y, notSquare) => {
		// Base case.
		if (pot == 0){
			let cuboid = rt.cuboid(x, x + 1 , -1, 0.1 + Math.sin(t + x * 0.5 + y), y, y + 1);
			// Set PBR properties and colors for blocks.
			for (let i = 1; i <= 6; i++){
				cuboid[i].textureNums = new Array(6).fill([-1,1,-1]).flat();
				cuboid[i].colors = new Array(6).fill(colors[x][y]).flat();
			}
			return cuboid;
		}
		// Decide to split vertically or horizontally.
		if (notSquare){
			// Get side length of next smaller square.
			let sideLength = (2 ** (pot - 1)) ** 0.5;
			// Create object.
			return [
				[x, x + sideLength, -1, 1.1, y, y + 2 * sideLength],
				drawMap(pot - 1, x, y, false),
				drawMap(pot - 1, x, y + sideLength, false)
			];
		}else{
			let sideLength = (2 ** pot) ** 0.5;
			return [
				[x, x + sideLength, -1, 1.1, y, y + sideLength],
				drawMap(pot - 1, x, y, true),
				drawMap(pot - 1, x + sideLength * 0.5, y, true)
			];
		}
	};

	// Init iterator variable for simple animations.
	let t = 0;

	setInterval(function(){
		// Increase iterator.
		t += 0.02;
		// Package cuboids together in a shared bounding volume.
		rt.queue[1] = drawMap(2 * power, 0, 0, false);
	}, 100/6);
});