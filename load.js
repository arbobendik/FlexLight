"use strict";

load(new URLSearchParams(location.search));

function load(search) {
	document.currentScript.remove();

	if (search.has("v")) {
		const script = document.createElement("script");
		script.src = "scripts/" + search.get("v") + ".js";
		document.head.appendChild(script);
	}

	window.addEventListener("load", function() {
    // Get form elements
		const scriptForm = document.getElementById("scriptForm");
    const parameterForm = document.getElementById("parameterForm");
    // Restore values
    ["filter", "antialiasing"].forEach((item) => {
      rt[item] = (localStorage.getItem(item) ?? rt[item].toString()) === "true";
      parameterForm.children[item].checked = rt[item];
    });
    ["samplesPerRay", "renderQuality", "maxReflections", "minImportancy"].forEach((item) => {
      rt[item] = Number(localStorage.getItem(item) ?? rt[item]);
      parameterForm.children[item].value = rt[item];
    });
		if (search.has("v")) {
			scriptForm[0].value = search.get("v");
		} else {
			scriptForm.submit();
		}
    // Reload if scene changes
    scriptForm.addEventListener("change", scriptForm.submit);
    // Update gl quality params on form change
    parameterForm.addEventListener("change", () => {
      ["filter", "antialiasing"].forEach((item) => {
        rt[item] = parameterForm.children[item].checked;
        localStorage.setItem(item, rt[item]);
      });
      ["samplesPerRay", "renderQuality", "maxReflections", "minImportancy"].forEach((item) => {
        rt[item] = Number(parameterForm.children[item].value);
        localStorage.setItem(item, rt[item]);
      });
    });
	}, {once: true});
}
