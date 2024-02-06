'use strict';


load();

function load() {
  
  if(document.currentScript !== null) document.currentScript.remove();
  
  const urlParams = new URLSearchParams(location.search);
  const script = document.createElement('script');
  let sceneName = urlParams.get('v') ?? 'wave';
  script.src = 'examples/' + sceneName + '.js';
  document.head.appendChild(script);

	window.addEventListener('load', function() {
    let renderer = engine.renderer;
    // Get form elements
    const scriptForm = document.getElementById('scriptForm');
    const parameterForm = document.getElementById('parameterForm');
    const tickBoxes = ['filter', 'temporal', 'hdr'];
    const sliders = ['renderQuality', 'samplesPerRay', 'maxReflections', 'minImportancy', 'antialiasing'];

    document.getElementById('pathtracing').checked = (localStorage.getItem('pathtracing') ?? 'true') === 'true';
    engine.renderer = document.getElementById('pathtracing').checked ? 'pathtracer' : 'rasterizer';
    renderer = engine.renderer;
    renderer.render();
    // Restore values in pathtracer
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

		if (urlParams.has('v')) {
			scriptForm[0].value = urlParams.get('v');
		} else {
			scriptForm.submit();
		}
    // Reload if scene changes
    scriptForm.addEventListener('change', () => {
      urlParams.set('v', scriptForm[0].value);
      location.search = urlParams.toString();
    });
    // Update gl quality params on form change
    parameterForm.addEventListener('change', () => {
      if ((localStorage.getItem('pathtracing') === 'true') !== document.getElementById('pathtracing').checked) {
        localStorage.setItem('pathtracing', document.getElementById('pathtracing').checked);
        engine.renderer = document.getElementById('pathtracing').checked ? 'pathtracer' : 'rasterizer';
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
