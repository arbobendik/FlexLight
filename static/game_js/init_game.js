"use strict";

///////////////////////////////////////// RENDER_ENGINE
// Initialize Canvas and Gl-Context.
var Canvas = document.createElement("canvas");
var Gl = Canvas.getContext("webgl2");
// Transition in x and y direction.
var X = -12;
var Y = 5;
var Z = -18;
// Create resize event to resize canvas.
var RESIZE = document.createEvent("UIEvent");
RESIZE.initUIEvent ("resize", false, false);
// Initialize performance metric globals.
var FpsCounter = document.createElement("div");
var Samples = 1;
var Scale = 1.0;
var Reflections = 3;
var Fps = 0;
var Frame = 0;
var Filter = true;
// The micros variable is needed to calculate fps.
var Micros = window.performance.now();
// Set Fov for RENDER_ENGINE
var Fov = Math.PI;
var Ratio = window.innerWidth / window.innerHeight;
// Internal GL objects.
var Program;
var PlayerPosition;
var Perspective;
var RenderConf;
var SamplesLocation;
var ReflectionsLocation;
var FilterLocation;
var WorldTex;
var RandomTex;
var NormalTex;
var ColorTex;
// Init Buffers.
var PositionBuffer;
var NormalBuffer;
var TexBuffer;
var ColorBuffer;
var TexSizeBuffer;
var TexNumBuffer;
var SurfaceBuffer;
var TriangleBuffer;
// Init Texture elements.
var WorldTexture;
var RandomTexture;
var NormalTexture;
var ColorTexture;
var Random;
// Linkers for GLATTRIBARRAYS.
const Position = 0;
const Normal = 1;
const TexCoord = 2;
const Color = 3;
const TexNum = 4;
// List of all vertices currently in world space.
var Data = [];
var DataHeight = 0;
// List of all textures currently used.
var Texture = [];
var RoughnessTexture = [];
// Post Program.
var Framebuffer;
var PostProgram;
var PostPosition = 0;
var PostVertexBuffer;
var ColorRenderTexture;
var ColorRenderTex;
var NormalRenderTexture;
var NormalRenderTex;
var OriginalRenderTexture;
var OriginalRenderTex;
var IdRenderTexture;
var IdRenderTex;
var DepthTexture;
// Convolution-kernel program.
var PostFramebuffer;
var KernelProgram;
var KernelPosition = 0;
var KernelVertexBuffer;
var KernelTexture;
var KernelTex;
// Create render queue QUEUE for all elemnts that exist in the scene. This variable stores all currently displayed objects.
var QUEUE = [];
// Globals to store all currently used textures / normal maps.
var TEXTURE = [];
var NORMAL_TEXTURE = [];
// Create different VAOs for different rendering/filtering steps in pipeline.
var VAO = Gl.createVertexArray();
var POST_VAO = Gl.createVertexArray();
var KERNEL_VAO = Gl.createVertexArray();

//////////////////////////////////////// ENVIRONMENT
// Define Keymap.
var KeyMap = [["w", 0, 0, 1], ["s", 0, 0, -1], ["a", 1, 0, 0], ["d", -1, 0, 0], [" ", 0, 1, 0], ["shift", 0, -1, 0]];
// Speed is handled on the backend as well.
const Pull = 500;
const Speed = 0.02;

var DeltaX = 0;
var DeltaY = 0;
var DeltaZ = 0;
// Store pressed keys in this to handle multikey input.
var KeysPressed = [];
// List of other players.
var Players = [];
// current pointer lock state.
var PointerLocked = false;
// Current player frustum rotation.
var Fx = 0.440;
var Fy = 0.235;
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
	Canvas.width = Canvas.clientWidth * Scale;
	Canvas.height = Canvas.clientHeight * Scale;
	Ratio = window.innerWidth / window.innerHeight;
	Gl.viewport(0, 0, Gl.canvas.width, Gl.canvas.height);
	// Build random texture.
	Random = [];
	for (let i = 0; i < Gl.canvas.width * Gl.canvas.height * 3; i++) Random.push(Math.random() * 256);
	// Rebuild textures on every resize.
	randomTextureBuilder();
	renderTextureBuilder();
	postRenderTextureBuilder();
});

// Preload most textures to prevent lags.
var ImageURL = [
	"static/textures/stone.svg",
	"static/textures/gras.jpg",
	"static/textures/dirt_side.jpg"
];

var IMAGE = [];
// Preload all Images
async function preloadImages()
{
	ImageURL.forEach((item, i) => {
		IMAGE[item]=new Image();
    IMAGE[item].src=item;
	});
	TEXTURE.push(IMAGE["static/textures/dirt_side.jpg"]);
	// Push images in local storage
}
