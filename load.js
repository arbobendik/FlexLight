"use strict";

(function(select) {
	document.currentScript.remove();

	const options = select.options;
	if (options.selectedIndex !== 0) {
		start();
		return;
	}

	select.addEventListener("change", function() {
		location.reload();
	}, {once: true});

	function start() {
		while (document.body.childNodes.length > 0) document.body.firstChild.remove();
		const styleSheet = document.createElement("link");
		styleSheet.href = "style.css";
		styleSheet.rel = "stylesheet";
		document.head.appendChild(styleSheet);
		
		const ioScript = document.createElement("script");
		ioScript.src = "io.js";
		document.head.appendChild(ioScript);

		const rayTracerScript = document.createElement("script");
		rayTracerScript.src = "raytracer.js";
		document.head.appendChild(rayTracerScript);

		const script = document.createElement("script");
		script.src = "scripts/" + select.value + ".js";
		document.head.appendChild(script);

		document.title = options[options.selectedIndex].textContent;
	}
})(document.getElementById("select"));