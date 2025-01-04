"use strict";

import { ValidInputType, ConfigElement } from "./element.js";

// Types for ConfigForm
export type ValueType = boolean | number | string;
export type KeyAssignable<O extends Object, K extends keyof O, V extends ValueType> = O[K] extends V ? K : never;

export class ConfigForm<O extends Object> {
    private _form: HTMLElement;
    private _config: O;
    private _hook: (name: string, value: ValueType) => void;

    constructor(form: HTMLElement, config: O, hook: (name: string, value: ValueType) => void = () => {}) {
        this._form = form;
        this._config = config;
        this._hook = hook;
    }

    addCheckbox<K extends keyof O>(name: string, key: KeyAssignable<O, K, boolean>, val: ValidInputType<"checkbox", O, K> | undefined = undefined) {
        const checkbox = document.createElement("config-element") as ConfigElement<"checkbox", O, K>;
        checkbox.object = this._config;
        checkbox.key = key;
        checkbox.name = name;
        checkbox.type = "checkbox";
        checkbox.hook = this._hook;
        // Set value if provided
        if (val) checkbox.value = val;
        this._form.appendChild(checkbox);
    }

    addSlider<K extends keyof O>(name: string, key: KeyAssignable<O, K, number>, min: number, max: number, step: number, val: ValidInputType<"range", O, K> | undefined = undefined) {
        const slider = document.createElement("config-element") as ConfigElement<"range", O, K>;
        slider.object = this._config;
        slider.key = key;
        slider.name = name;
        slider.type = "range";
        slider.min = min.toString();
        slider.max = max.toString();
        slider.step = step.toString();
        slider.hook = this._hook;
        // Set value if provided
        if (val) slider.value = val;
        this._form.appendChild(slider);
    }

    addSelect<K extends keyof O>(name: string, key: KeyAssignable<O, K, string>, options: string[], val: ValidInputType<"select", O, K> | undefined = undefined) {
        const select = document.createElement("config-element") as ConfigElement<"select", O, K>;
        select.object = this._config;
        select.key = key;
        select.name = name;
        select.type = "select";
        select.options = options;
        select.hook = this._hook;
        // Set value if provided
        if (val) select.value = val;
        this._form.appendChild(select);
    }
}
