"use strict";

// Types for ConfigElement
type InputType = "checkbox" | "range" | "select";
export type ValidValueType<IT extends InputType> = IT extends "checkbox" ? boolean : IT extends "range" ? number : IT extends "select" ? string : never;
export type ValidInputType<IT extends InputType, O extends Object, K extends keyof O> = O[K] extends ValidValueType<IT> ? O[K] : never;

const TypeScriptAssign = <O extends Object, K extends keyof O> (obj: O, key: K, val: O[K]) => obj[key] = val;

type IsRange<IT extends InputType, T> = IT extends "range" ? T : never;
type IsSelect<IT extends InputType, T> = IT extends "select" ? T : never;


export class ConfigElement<IT extends InputType, O extends Object, K extends keyof O> extends HTMLElement {
    private _name: string = "";
    private _object: O | undefined = undefined;
    private _key: K | undefined = undefined;
    private _value: ValidInputType<IT, O, K> | undefined = undefined;
    private _type: IT | undefined = undefined;
    private _options: IsSelect<IT, Array<string>> | undefined = undefined;

    private label: HTMLLabelElement;
    private input: HTMLInputElement | undefined = undefined;
    private select: HTMLSelectElement | undefined = undefined;

    private _hook: ((name: string, value: ValidInputType<IT, O, K>) => void) = () => {};
    

    constructor() {
      super();
      // Create outer label element
      this.label = document.createElement("label");
    }

    connectedCallback() {
        this.appendChild(this.label);
    }

    private createInput(): void {
        // If type is not set, don't create input
        if (!this._type) return;
        let input = document.createElement("input");
        input.type = this._type;
        // Add event listener
        input.addEventListener("change", (event: Event) => {
            if (!(event.target instanceof HTMLInputElement)) return;
            switch (input.type) {
                case "checkbox":
                    this._value = input.checked as ValidInputType<IT, O, K>;
                    this._hook(this.name ?? "", this._value);
                    break;
                case "range":
                    this._value = input.value as ValidInputType<IT, O, K>;
                    this._hook(this.name ?? "", this._value);
                    break;
            }
        });

        this.input = input;
        this.input.name = this._name;
        console.log(this._name, this._value);
        this.input.value = this._value?.toString() ?? "";
        this.label.appendChild(this.input);
    }

    private createSelect(): void {
        // If type is not set or options are not set, don't create select
        if (!this._type || !this._options) return;
        let select = document.createElement("select");
        // Create options
        for (let option of this._options) {
            let optionElement: HTMLOptionElement = document.createElement("option");
            optionElement.value = option;
            optionElement.textContent = option;
            select.appendChild(optionElement);
        }
        // Add event listener
        select.addEventListener("change", (event: Event) => {
            if (!(event.target instanceof HTMLSelectElement)) return;
            this._value = select.value as ValidInputType<IT, O, K>;
            this._hook(this.name ?? "", this._value);
        });

        this.select = select;
        this.select.name = this._name;
        this.select.value = this._value?.toString() ?? "";
        this.label.appendChild(this.select);
    }

    private attemptRender () {
        // If name is not set, don't render
        if (!this._type) return;
        // Clear label
        this.label.replaceChildren();
        // Write name to label
        this.label.textContent = this._name;
        this.label.htmlFor = this._name;
        // Test if type is valid
        switch (this._type) {
            case "checkbox":
                this.createInput();
                break;
            case "range":
                this.createInput();
                break;
            case "select":
                this.createSelect();
                break;
        }
    }

    set hook(hook: (name: string, value: ValidInputType<IT, O, K>) => void) { this._hook = hook; }
    get hook() { return this._hook; }

    set min(min: IsRange<IT, string>) { if (this.input) this.input.min = min; }
    get min() { return this.input?.min as IsRange<IT, string>; }

    set max(max: IsRange<IT, string>) { if (this.input) this.input.max = max; }
    get max() { return this.input?.max as IsRange<IT, string>; }

    set step(step: IsRange<IT, string>) { if (this.input) this.input.step = step; }
    get step() { return this.input?.step as IsRange<IT, string>; }

    set options(options: IsSelect<IT, Array<string>> | undefined) {
        this._options = options;
        this.attemptRender();
    }
    get options() { return this._options; }

    set object(object: O | undefined) { this._object = object; }
    get object() { return this._object; }

    set key(key: K | undefined) { this._key = key; }
    get key() { return this._key; }

    get value() { return this._value; }
    set value(value: ValidInputType<IT, O, K> | undefined) { 
        this._value = value;
        if (this.input) this.input.value = (value ?? "").toString();
        if (this.select) this.select.value = (value ?? "").toString();
        if (this._object && this._key && value) TypeScriptAssign(this._object, this._key, value);
        
        if (this.input) console.log(this._name, this.input.value, value);
        if (this.select) console.log(this._name, this.select.value, value);
    }

    get type() { return this._type; }
    set type(type: IT | undefined) { 
        this._type = type;
        this.attemptRender();
    }

    get name() { return this._name; }
    set name(name: string) {
        this._name = name;
        this.attemptRender();
    }
}

// Register custom element
customElements.define("config-element", ConfigElement);