'use strict';

load(new URLSearchParams(location.search));

function load(search) {

	if(document.currentScript !== null) document.currentScript.remove();

	if (search.has('v')) {
		const script = document.createElement('script');
		script.src = 'examples/' + search.get('v') + '.js';
		document.head.appendChild(script);
	}

	window.addEventListener('load', function() {

    let renderer = engine.renderer;
    // Get form elements
		const scriptForm = document.getElementById('scriptForm');
    const parameterForm = document.getElementById('parameterForm');
    const tickBoxes = ['filter', 'hdr'];
    const sliders = ['renderQuality', 'samplesPerRay', 'maxReflections', 'minImportancy', 'antialiasing'];

    document.getElementById('raytracing').checked = (localStorage.getItem('raytracing') ?? 'true') === 'true';
    engine.renderer = document.getElementById('raytracing').checked ? 'raytracer' : 'rasterizer';
    renderer = engine.renderer;
    renderer.render();
    // Restore values in raytracer
    tickBoxes.forEach((item) => {
      renderer[item] = (localStorage.getItem(item) ?? 'true') === 'true';
      parameterForm.children[item].checked = renderer[item];
    });

    sliders.forEach((item) => {
      renderer[item] = (item === 'antialiasing') ? localStorage.getItem(item) ?? renderer[item] : Number(localStorage.getItem(item) ?? renderer[item]);
      parameterForm.children[item].value = renderer[item];
    });
    // Load slider variables
    document.querySelectorAll('output').forEach((item, i) => {
      item.value = renderer[sliders[i]];
      // Define silder
      var slider = document.getElementById(sliders[i]);
      // Live update slider variables
      slider.addEventListener('input', () => item.value = slider.value);
    });

		if (search.has('v')) {
			scriptForm[0].value = search.get('v');
		} else {
			scriptForm.submit();
		}
    // Reload if scene changes
    scriptForm.addEventListener('change', () => location.search = '?v=' + scriptForm[0].value);
    // Update gl quality params on form change
    parameterForm.addEventListener('change', () => {
      if ((localStorage.getItem('raytracing') === 'true') !== document.getElementById('raytracing').checked) {
        localStorage.setItem('raytracing', document.getElementById('raytracing').checked);
        engine.renderer = document.getElementById('raytracing').checked ? 'raytracer' : 'rasterizer';
        renderer = engine.renderer;
        renderer.render();
      }

      tickBoxes.forEach((item) => {
        renderer[item] = parameterForm.children[item].checked;
        localStorage.setItem(item, renderer[item]);
      });

      sliders.forEach((item) => {
        renderer[item] = (item === 'antialiasing') ? parameterForm.children[item].value : Number(parameterForm.children[item].value);
        localStorage.setItem(item, renderer[item]);
      });
    });

	}, {once: true});
}