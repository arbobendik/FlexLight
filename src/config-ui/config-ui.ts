"use strict";

import { FlexLight } from "flexlight";
import { ValueType, ConfigForm } from "./form.js";
import { RendererType } from "flexlight/common/renderer.js";
import { ApiType } from "flexlight/common/renderer.js";
import { StringAntialiasingType } from "flexlight/common/config.js";
// Types for ConfigUI
interface Property<T extends ValueType> {
    name: string;
    defaultValue: T;
}

const getStartValueCheckbox = (property: Property<boolean>): boolean => {
    const value = localStorage.getItem(property.name);
    if (!value) return property.defaultValue;
    else if (value === "true") return true;
    else if (value === "false") return false;
    else throw new Error(`Unsupported value: ${value}`);
};

const isNumber = (n: string): boolean => String(Number.parseFloat(n)) === n; 
const getStartValueSlider = (property: Property<number>): number => {
    const value = localStorage.getItem(property.name);
    if (!value) return property.defaultValue;
    else if (isNumber(value)) return Number(value);
    else throw new Error(`Unsupported value: ${value}`);
};

const getStartValueSelect = <T extends ValueType>(property: Property<T>): T => {
    const value = localStorage.getItem(property.name);
    if (!value) return property.defaultValue;
    else return value as T;
};

const addScreenshotButton = (parent: HTMLElement, engine: FlexLight) => {
    const button = document.createElement("button");
    button.id = "screenshot";
    button.textContent = "Screenshot";
    button.type = "button";
    button.onclick = () => saveCanvas(engine.canvas);
    parent.appendChild(button);
};

const saveCanvas = (canvas: HTMLCanvasElement) => {
    canvas.toBlob((blob) => {
        console.log(blob);
        if (!blob) return;
        const url = URL.createObjectURL(blob);

        var link = document.createElement("a");
        link.style.display = "none";
        document.body.appendChild(link);
        link.href = url;
        link.download = "screenshot.png";
        link.click();
        URL.revokeObjectURL(url);
    });
};

const addSection = (parent: HTMLElement, title: string): HTMLElement => {
    const section = document.createElement("section");
    const heading = document.createElement("h2");
    heading.textContent = title;
    section.appendChild(heading);
    parent.appendChild(section);
    return section;
};

export function createConfigUI(engine: FlexLight): HTMLFormElement {
    const form = document.createElement("form");

    const localStorageHook = (name: string, value: ValueType) => {
        localStorage.setItem(name, value.toString());
    };
    // Add FlexLight settings to parameter form
    const engineSection = addSection(form, "Engine");
    const flexLightForm = new ConfigForm(engineSection, engine, localStorageHook);
    flexLightForm.addSelect("Backend", "api", ["webgl2", "webgpu"] as const, getStartValueSelect({ name: "Backend", defaultValue: "webgpu" as ApiType }));
    flexLightForm.addSelect("Renderer", "rendererType", ["rasterizer", "pathtracer"] as const, getStartValueSelect({ name: "Renderer", defaultValue: "pathtracer" as RendererType }));
    // Add Camera settings to parameter form
    const cameraForm = new ConfigForm(engineSection, engine.camera, localStorageHook);
    cameraForm.addSlider("Field of view", "fov", 20, 120, 1, getStartValueSlider({ name: "Field of view", defaultValue: engine.camera.fov }));

    // Add Config settings to parameter form
    const configForm = new ConfigForm(addSection(form, "Rendering"), engine.config, localStorageHook);
    configForm.addSelect("Antialiasing", "antialiasingAsString", ["undefined", "fxaa", "taa"] as const, getStartValueSelect({ name: "Antialiasing", defaultValue: "undefined" as StringAntialiasingType }));
    configForm.addCheckbox("Temporal averaging", "temporal", getStartValueCheckbox({ name: "Temporal averaging", defaultValue: true }));
    configForm.addCheckbox("Tonemapping", "tonemapping", getStartValueCheckbox({ name: "Tonemapping", defaultValue: true }));
    configForm.addSlider("Render resolution", "renderResolution", 0.1, 2, 0.1, getStartValueSlider({ name: "Render resolution", defaultValue: 1 }));
    configForm.addSlider("Samples per pixel", "samplesPerPixel", 1, 32, 1, getStartValueSlider({ name: "Samples per pixel", defaultValue: 1 }));
    configForm.addSlider("Max GI bounces", "maxBounces", 1, 16, 1, getStartValueSlider({ name: "Max GI bounces", defaultValue: 7 }));
    configForm.addSlider("Reprojections", "maxReprojections", 4, 256, 1, getStartValueSlider({ name: "Max frame reprojections", defaultValue: 32 }));
    // ReSTIR is only implemented by the WebGPU backend
    const restirSection = addSection(form, "ReSTIR");
    const restirForm = new ConfigForm(restirSection, engine.config, localStorageHook);
    restirForm.addCheckbox("ReSTIR PT", "restir", getStartValueCheckbox({ name: "ReSTIR PT", defaultValue: false }));
    restirForm.addCheckbox("Biased decorrelation", "restirDecorrelation", getStartValueCheckbox({ name: "Biased decorrelation", defaultValue: false }));
    restirForm.addSlider("Spatial neighbours", "restirNeighbours", 1, 3, 1, getStartValueSlider({ name: "Spatial neighbours", defaultValue: 3 }));
    const updateRestirVisibility = () => restirSection.hidden = engine.api !== "webgpu";
    engineSection.addEventListener("change", updateRestirVisibility);
    updateRestirVisibility();

    addScreenshotButton(form, engine);
    return form;
};