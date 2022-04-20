"use strict";

(function(search) {
	document.currentScript.remove();

	if (search.has("v")) {
		const script = document.createElement("script");
		script.src = "scripts/" + search.get("v") + ".js";
		document.head.appendChild(script);
		document.addEventListener("DOMContentLoaded", function() {
			while (document.body.childNodes.length > 0) document.body.firstChild.remove();
		}, {once: true});
		
		return;
	}

	window.addEventListener("DOMContentLoaded", function() {
		const form = document.getElementById("form");
		form.addEventListener("change", function() {
			console.log(this);
			if (this[0].value !== "Scenes") {
				this.submit();
			}
		});
	}, {once: true});
})(new URLSearchParams(location.search));
