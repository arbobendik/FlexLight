"use strict";

///////////////////////////////////////// RENDER_ENGINE
// Initialize Canvas and Gl-Context.
var Canvas = document.createElement("canvas");
var Gl = Canvas.getContext("webgl2", {antialias: true});
// Transition in x and y direction
var X = 0;
var Y = 0;
var Z = 0;
// Create resize event to resize canvas.
var RESIZE = document.createEvent("UIEvent");
RESIZE.initUIEvent ("resize", false, false);
// Initialize performance metric globals.
var FpsCounter = document.createElement("div");
var Fps = 0;
var Frame = 0;
// The micros variable is needed to calculate fps.
var Micros = window.performance.now();
// Set Fov for RENDER_ENGINE
var Fov = Math.PI;
var Ratio = window.innerWidth / window.innerHeight;
// Internal GL objects.
var Program;
var PositionBuffer;
var NormalBuffer;
var WorldTexBuffer;
var PlayerPosition;
var Perspective;
var RenderConf;
var RenderColor;
var WorldTex;
// Linkers for GLATTRIBARRAYS.
const Position = 0;
const Normal = 1;
const WorldTexCoord = 2;
// Create renderQueue QUEUE for MAIN canvas. In this variable stores all currently displayed objects.
var QUEUE = [];
var VAO = Gl.createVertexArray();

//////////////////////////////////////// ENVIRONMENT
// Define Keymap.
var KeyMap = [["w", 0, 0, 1], ["s", 0, 0, -1], ["a", 1, 0, 0], ["d", -1, 0, 0], [" ", 0, 1, 0], ["shift", 0, -1, 0]];
// Speed is handled on the backend as well.
const Pull = 500;
const Speed = 0.02;

var DeltaX = 0;
var DeltaY = 0;
var DeltaZ = 0;
// Store pressed keys in this to handle multikey input
var KeysPressed = [];
// List of other players.
var Players = [];
// current pointer lock state.
var PointerLocked = false;
// Current player frustum rotation
var Fx = 0;
var Fy = 0;
// Mouse Speed.
var Mouse_y = 1 / 200;
var Mouse_x = 1 / 200;

//////////////////////////////////////// SOCKET
// Initialize socket object and global KEYS variable.
var KEYS;
// Websocket must be initialized before it is open.
var WS = {open: false };

window.addEventListener("load", async function (){
	// Wait until all images are loaded.
	await preloadImages();
  // Create canvas element.
	document.body.appendChild(Canvas);
	// Create FpsCounter element.
	document.body.appendChild(FpsCounter);
	// Dispatch resize event to initialize canvas.
	window.dispatchEvent (RESIZE);
	// Start RENDER_ENGINE, socket to server and listen for keyboard input.
	initSocket();
	initEngine();
}, {capture: false, once: true});

window.addEventListener ("resize", function (){
	Canvas.width = window.innerWidth;
	Canvas.height = window.innerHeight;
	Ratio = window.innerWidth / window.innerHeight;
	Gl.viewport(0, 0, Gl.canvas.width, Gl.canvas.height);
});

// Preload most textures to prevent lags.
var ImageURL = [
	"static/textures/stone.svg",
	"static/textures/gras.jpg"
];

var IMAGE = [];
// Preload all Images
async function preloadImages()
{
	ImageURL.forEach((item, i) => {
		IMAGE[item]=new Image();
    IMAGE[item].src=item;
	});
	// Push images in local storage
}
