"use strict";

export function loadScript(url: string, type: string | undefined = undefined) {
    const script = document.createElement("script");
    script.src = url;
    if (type) script.type = type;
    document.head.appendChild(script);
}