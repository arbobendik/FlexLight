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
    // Restore values in raytracer
    ["filter", "antialiasing"].forEach((item) => {
      rt[item] = (localStorage.getItem(item) ?? rt[item].toString()) === "true";
      parameterForm.children[item].checked = rt[item];
    });
    var sliderVariables = ["samplesPerRay", "renderQuality", "maxReflections", "minImportancy"];
    sliderVariables.forEach((item) => {
      rt[item] = Number(localStorage.getItem(item) ?? rt[item]);
      parameterForm.children[item].value = rt[item];
    });
    // Load slider variables
    document.querySelectorAll("output").forEach((item, i) => {
      item.value = rt[sliderVariables[i]];
      // Define silider
      var slider = parameterForm.children[sliderVariables[i]];
      // Live update slider variables
      slider.addEventListener("input", () => {
        console.log(slider.value);
        item.value = slider.value;
      });
    });
		if (search.has("v")) {
			scriptForm[0].value = search.get("v");
		} else {
			scriptForm.submit();
		}
    // Reload if scene changes
    scriptForm.addEventListener("change", () => location.search = "?v=" + scriptForm[0].value);
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
