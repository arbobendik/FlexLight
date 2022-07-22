'use strict';

load(new URLSearchParams(location.search));

function load(search) {

	if(document.currentScript !== null) document.currentScript.remove();

	if (search.has('v')) {
		const script = document.createElement('script');
		script.src = 'scripts/' + search.get('v') + '.js';
		document.head.appendChild(script);
	}

	window.addEventListener('load', function() {

    let renderer = engine.renderer;
    // Get form elements
		const scriptForm = document.getElementById('scriptForm');
    const parameterForm = document.getElementById('parameterForm');

    parameterForm.children['raytracing'].checked = (localStorage.getItem('raytracing') ?? 'true') === 'true';
    engine.renderer = parameterForm.children['raytracing'].checked ? 'raytracer' : 'rasterizer';
    renderer = engine.renderer;
    renderer.render();
    // Restore values in raytracer
    ['filter', 'antialiasing', 'hdr'].forEach((item) => {
      renderer[item] = (localStorage.getItem(item) ?? renderer[item].toString()) === 'true';
      parameterForm.children[item].checked = renderer[item];
    });

    var sliderVariables = ['renderQuality', 'samplesPerRay', 'maxReflections', 'minImportancy'];
    sliderVariables.forEach((item) => {
      renderer[item] = Number(localStorage.getItem(item) ?? renderer[item]);
      parameterForm.children[item].value = renderer[item];
    });
    // Load slider variables
    document.querySelectorAll('output').forEach((item, i) => {
      item.value = renderer[sliderVariables[i]];
      // Define silider
      var slider = parameterForm.children[sliderVariables[i]];
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
      if ((localStorage.getItem('raytracing') === 'true') !== parameterForm.children['raytracing'].checked) {
        localStorage.setItem('raytracing', parameterForm.children['raytracing'].checked);
        engine.renderer = parameterForm.children['raytracing'].checked ? 'raytracer' : 'rasterizer';
        renderer = engine.renderer;
        renderer.render();
      }

      ['filter', 'antialiasing', 'hdr'].forEach((item) => {
        renderer[item] = parameterForm.children[item].checked;
        localStorage.setItem(item, renderer[item]);
      });
      ['renderQuality', 'samplesPerRay', 'maxReflections', 'minImportancy'].forEach((item) => {
        renderer[item] = Number(parameterForm.children[item].value);
        localStorage.setItem(item, renderer[item]);
      });
    });

	}, {once: true});
}
