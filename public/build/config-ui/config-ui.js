// src/config-ui/form.ts
var ConfigForm = class {
  _form;
  _config;
  _hook;
  constructor(form, config, hook = () => {
  }) {
    this._form = form;
    this._config = config;
    this._hook = hook;
  }
  addCheckbox(name, key, val = void 0) {
    const checkbox = document.createElement("config-element");
    checkbox.object = this._config;
    checkbox.key = key;
    checkbox.name = name;
    checkbox.type = "checkbox";
    checkbox.hook = this._hook;
    if (val) checkbox.value = val;
    this._form.appendChild(checkbox);
  }
  addSlider(name, key, min, max, step, val = void 0) {
    const slider = document.createElement("config-element");
    slider.object = this._config;
    slider.key = key;
    slider.name = name;
    slider.type = "range";
    slider.min = min.toString();
    slider.max = max.toString();
    slider.step = step.toString();
    slider.hook = this._hook;
    if (val) slider.value = val;
    this._form.appendChild(slider);
  }
  addSelect(name, key, options, val = void 0) {
    const select = document.createElement("config-element");
    select.object = this._config;
    select.key = key;
    select.name = name;
    select.type = "select";
    select.options = options;
    select.hook = this._hook;
    if (val) select.value = val;
    this._form.appendChild(select);
  }
};

// src/config-ui/config-ui.ts
var getStartValueCheckbox = (property) => {
  const value = localStorage.getItem(property.name);
  if (!value) return property.defaultValue;
  else if (value === "true") return true;
  else if (value === "false") return false;
  else throw new Error(`Unsupported value: ${value}`);
};
var isNumber = (n) => String(Number.parseFloat(n)) === n;
var getStartValueSlider = (property) => {
  const value = localStorage.getItem(property.name);
  if (!value) return property.defaultValue;
  else if (isNumber(value)) return Number(value);
  else throw new Error(`Unsupported value: ${value}`);
};
var getStartValueSelect = (property) => {
  const value = localStorage.getItem(property.name);
  if (!value) return property.defaultValue;
  else return value;
};
function createConfigUI(engine) {
  const form = document.createElement("form");
  const localStorageHook = (name, value) => {
    localStorage.setItem(name, value.toString());
  };
  const flexLightForm = new ConfigForm(form, engine, localStorageHook);
  flexLightForm.addSelect("Backend", "api", ["webgl2", "webgpu"], getStartValueSelect({ name: "Backend", defaultValue: "webgl2" }));
  flexLightForm.addSelect("Renderer", "renderer", ["rasterizer", "pathtracer"], getStartValueSelect({ name: "Renderer", defaultValue: "rasterizer" }));
  const configForm = new ConfigForm(form, engine.config, localStorageHook);
  configForm.addSelect("Antialiasing", "antialiasing", ["none", "fxaa", "taa"], getStartValueSelect({ name: "Antialiasing", defaultValue: "fxaa" }));
  configForm.addCheckbox("Temporal averaging", "temporal", true);
  configForm.addCheckbox("HDR", "hdr", getStartValueCheckbox({ name: "HDR", defaultValue: true }));
  configForm.addSlider("Render quality", "renderQuality", 0.1, 2, 0.1, getStartValueSlider({ name: "Render quality", defaultValue: 1 }));
  configForm.addSlider("Samples per ray", "samplesPerRay", 1, 32, 1, getStartValueSlider({ name: "samplesPerRay", defaultValue: 1 }));
  configForm.addSlider("Max reflections", "maxReflections", 1, 16, 1, getStartValueSlider({ name: "Max reflections", defaultValue: 5 }));
  configForm.addSlider("Min importancy", "minImportancy", 0, 1, 0.01, getStartValueSlider({ name: "Min importancy", defaultValue: 0.3 }));
  return form;
}
export {
  createConfigUI
};
