"use strict";

export function loadScript(url: string, type: string | undefined = undefined) {
    const script = document.createElement("script");
    script.src = url;
    if (type) script.type = type;
    document.head.appendChild(script);
}

document.addEventListener('DOMContentLoaded', () => {
    const urlParams: URLSearchParams = new URLSearchParams(location.search);
    const scriptForm : HTMLFormElement | undefined = document.getElementById('scriptForm') as HTMLFormElement;
    const scriptFormSelect : HTMLSelectElement | undefined = document.getElementById('scriptFormSelect') as HTMLSelectElement;

    if (scriptFormSelect) {
        // Set scene name
        if (urlParams.has('v')) {
            scriptFormSelect.value = urlParams.get('v')!;
        } else {
            scriptForm.submit();
        }
        // Reload if scene changes
        scriptForm.addEventListener('change', () => {
            console.log(scriptFormSelect!.value);
            urlParams.set('v', scriptFormSelect!.value);
            location.search = urlParams.toString();
        });
    }

    const sceneName: string = urlParams.get('v') ?? 'example1';
    loadScript(`./build/loader/examples/${sceneName}.js`, 'module');
});