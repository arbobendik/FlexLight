"use strict";

import { Vector, cross, dot, matrix_vector_mul, normalize, transpose, vector_add, vector_difference, vector_length, vector_scale } from "../lib/math";
import { Instance } from "./instance";
import { PointLight } from "./point-light";
import { TRIANGLE_SIZE } from "./prototype";

// Node of the light BVH as flex-cuda-pt's LightNode, kind 0 inner, 1 triangle leaf, 2 sphere leaf, a leaf naming its
// instance and triangle or its light and the trail slot it is found by
export interface LightNode {
    low: Vector<3>; high: Vector<3>; w: Vector<3>; phi: number; cosThetaO: number; child: number;
    kind: number; id: number; triangle: number; slot: number;
}

const LIGHT_BUCKETS = 12;
const EMPTY: LightNode = { low: new Vector(0, 0, 0), high: new Vector(0, 0, 0), w: new Vector(0, 0, 0), phi: 0, cosThetaO: 0, child: 0, kind: 0, id: 0, triangle: 0, slot: 0 };

const lower = (a: Vector<3>, b: Vector<3>): Vector<3> => new Vector(Math.min(a.x, b.x), Math.min(a.y, b.y), Math.min(a.z, b.z));
const upper = (a: Vector<3>, b: Vector<3>): Vector<3> => new Vector(Math.max(a.x, b.x), Math.max(a.y, b.y), Math.max(a.z, b.z));
const centroid = (node: LightNode, dimension: number): number => (node.low[dimension]! + node.high[dimension]!) * 0.5;

// Union of light bounds and of their normal cones, either for the other of no power (pbrt-v4's Union)
const merge = (a: LightNode, b: LightNode): LightNode => {
    if (a.phi === 0) return b;
    if (b.phi === 0) return a;
    const node: LightNode = { ...EMPTY, low: lower(a.low, b.low), high: upper(a.high, b.high), w: a.w, phi: a.phi + b.phi, cosThetaO: a.cosThetaO };
    const thetaA = Math.acos(a.cosThetaO), thetaB = Math.acos(b.cosThetaO);
    const thetaD = Math.acos(Math.min(Math.max(dot(a.w, b.w), -1), 1));
    if (Math.min(thetaD + thetaB, Math.PI) <= thetaA) return node;
    if (Math.min(thetaD + thetaA, Math.PI) <= thetaB) return { ...node, w: b.w, cosThetaO: b.cosThetaO };
    // Spread over the entire sphere, else a's axis turned about the normal of both axes
    const thetaO = (thetaA + thetaD + thetaB) / 2;
    const wr = cross(a.w, b.w);
    if (thetaO >= Math.PI || dot(wr, wr) === 0) return { ...node, cosThetaO: -1 };
    const w = vector_add(vector_scale(a.w, Math.cos(thetaO - thetaA)), vector_scale(cross(normalize(wr), a.w), Math.sin(thetaO - thetaA)));
    return { ...node, w, cosThetaO: Math.cos(thetaO) };
};

// Surface area orientation heuristic of light bounds b in node bounds split along dimension, diffuse emitters spreading
// a quarter turn (pbrt-v4's EvaluateCost)
const cost = (b: LightNode, bounds: LightNode, dimension: number): number => {
    const thetaO = Math.acos(b.cosThetaO), thetaW = Math.min(thetaO + Math.PI / 2, Math.PI);
    const sinThetaO = Math.sqrt(Math.max(1 - b.cosThetaO * b.cosThetaO, 0));
    const mOmega = 2 * Math.PI * (1 - b.cosThetaO) + Math.PI / 2 * (2 * thetaW * sinThetaO
        - Math.cos(thetaO - 2 * thetaW) - 2 * thetaO * sinThetaO + b.cosThetaO);
    const d = vector_difference(bounds.high, bounds.low), e = vector_difference(b.high, b.low);
    return b.phi * mOmega * Math.max(d.x, d.y, d.z) / d[dimension]! * 2 * (e.x * e.y + e.y * e.z + e.z * e.x);
};

// Light BVH over lights[start, end) appended to nodes, split between the buckets of their centroids per dimension of
// least cost, else in the middle (pbrt-v4's buildBVH). Returns the bounds of its root.
const buildLights = (nodes: Array<LightNode>, lights: Array<LightNode>, start: number, end: number): LightNode => {
    if (end - start === 1) return nodes.push(lights[start]!), lights[start]!;
    let bounds: LightNode = EMPTY;
    const low = [Infinity, Infinity, Infinity], high = [-Infinity, -Infinity, -Infinity];
    for (let i = start; i < end; i++) {
        bounds = merge(bounds, lights[i]!);
        for (let dimension = 0; dimension < 3; dimension++) {
            low[dimension] = Math.min(low[dimension]!, centroid(lights[i]!, dimension));
            high[dimension] = Math.max(high[dimension]!, centroid(lights[i]!, dimension));
        }
    }
    const bucket = (light: LightNode, dimension: number): number => Math.min(Math.trunc(LIGHT_BUCKETS
        * (centroid(light, dimension) - low[dimension]!) / (high[dimension]! - low[dimension]!)), LIGHT_BUCKETS - 1);
    let least = Infinity, along = -1, split = 0;
    for (let dimension = 0; dimension < 3; dimension++) if (high[dimension]! > low[dimension]!) {
        const buckets: Array<LightNode> = new Array(LIGHT_BUCKETS).fill(EMPTY);
        for (let i = start; i < end; i++) buckets[bucket(lights[i]!, dimension)] = merge(buckets[bucket(lights[i]!, dimension)]!, lights[i]!);
        for (let s = 1; s < LIGHT_BUCKETS - 1; s++) {
            let below: LightNode = EMPTY, above: LightNode = EMPTY;
            for (let j = 0; j <= s; j++) below = merge(below, buckets[j]!);
            for (let j = s + 1; j < LIGHT_BUCKETS; j++) above = merge(above, buckets[j]!);
            const total = cost(below, bounds, dimension) + cost(above, bounds, dimension);
            if (total > 0 && total < least) least = total, along = dimension, split = s;
        }
    }
    // Partition lights[start, end) in place by their bucket along the split
    let middle = start;
    if (along >= 0) for (let i = start; i < end; i++) if (bucket(lights[i]!, along) <= split) {
        [lights[middle], lights[i]] = [lights[i]!, lights[middle]!];
        middle++;
    }
    if (middle === start || middle === end) middle = Math.floor((start + end) / 2);
    const index = nodes.length;
    nodes.push(EMPTY);
    const first = buildLights(nodes, lights, start, middle);
    const second = nodes.length;
    const node: LightNode = { ...merge(first, buildLights(nodes, lights, middle, end)), child: second, kind: 0, id: 0, triangle: 0, slot: 0 };
    return nodes[index] = node;
};

// Light BVH over the emitting triangles of the instances in world space and the point lights as spheres, packed as
// texels: a header (node count, first trail, triangle trails, 0), four per node and a trail per triangle and light
export const packLightTree = (instances: Set<Instance>, pointLights: Set<PointLight>, triangleTrails: number): Uint32Array<ArrayBuffer> => {
    const lights: Array<LightNode> = [];
    let instanceID = 0, firstTriangle = 0;
    for (const instance of instances) {
        const emitted = instance.material.emissive.x + instance.material.emissive.y + instance.material.emissive.z;
        // As the shaders transform, which take the rows of the matrix for the columns of theirs
        const triangles = instance.prototype.triangles, rotation = transpose(instance.transform.matrix), position = instance.transform.position;
        const vertex = (offset: number): Vector<3> => vector_add(matrix_vector_mul(rotation,
            new Vector<3>(triangles[offset]!, triangles[offset + 1]!, triangles[offset + 2]!)), position);
        for (let t = 0; emitted > 0 && t < triangles.length / TRIANGLE_SIZE; t++) {
            const a = vertex(t * TRIANGLE_SIZE), b = vertex(t * TRIANGLE_SIZE + 3), c = vertex(t * TRIANGLE_SIZE + 6);
            const n = cross(vector_difference(b, a), vector_difference(c, a));
            if (vector_length(n) > 0) lights.push({ low: lower(lower(a, b), c), high: upper(upper(a, b), c), w: normalize(n),
                phi: Math.PI * emitted * vector_length(n) / 2, cosThetaO: 1, child: 0, kind: 1, id: instanceID, triangle: t, slot: firstTriangle + t });
        }
        firstTriangle += triangles.length / TRIANGLE_SIZE;
        instanceID++;
    }
    let pointLightID = 0;
    for (const pointLight of pointLights) {
        const phi = 4 * Math.PI * pointLight.intensity * (pointLight.color.x + pointLight.color.y + pointLight.color.z);
        const radius = new Vector<3>(pointLight.variance, pointLight.variance, pointLight.variance);
        if (phi > 0) lights.push({ low: vector_difference(pointLight.position, radius), high: vector_add(pointLight.position, radius),
            w: new Vector(0, 0, 1), phi, cosThetaO: -1, child: 0, kind: 2, id: pointLightID, triangle: 0, slot: triangleTrails + pointLightID });
        pointLightID++;
    }
    // Else a leaf of no power, the placeholder light 0 of the scene
    if (lights.length === 0) lights.push({ ...EMPTY, kind: 2, slot: triangleTrails });
    const nodes: Array<LightNode> = [];
    buildLights(nodes, lights, 0, lights.length);
    // Header, nodes, then trails of no leaf (0, 0, 0xFFFFFFFF, 0) to the leaves' (pbrt-v4's bit trails)
    const trailBase = 1 + 4 * nodes.length;
    const texels = new Uint32Array(4 * (trailBase + triangleTrails + pointLights.size));
    const floats = new Float32Array(texels.buffer);
    texels.set([nodes.length, trailBase, triangleTrails, 0]);
    for (let j = trailBase; j < texels.length / 4; j++) texels[4 * j + 2] = 0xFFFFFFFF;
    const trails: Array<bigint> = new Array(nodes.length).fill(0n), depth: Array<number> = new Array(nodes.length).fill(0);
    nodes.forEach((node, n) => {
        floats.set([...node.low, node.phi, ...node.high, node.cosThetaO, ...node.w], 4 + 16 * n);
        texels.set([node.child, node.kind, node.id, node.triangle], 15 + 16 * n);
        if (node.kind !== 0) return texels.set([Number(trails[n]! & 0xFFFFFFFFn), Number(trails[n]! >> 32n), n], 4 * (trailBase + node.slot));
        if (depth[n]! >= 64) throw new Error("Light tree deeper than its 64 bit trails");
        trails[n + 1] = trails[n]!, trails[node.child] = trails[n]! | 1n << BigInt(depth[n]!);
        depth[n + 1] = depth[node.child] = depth[n]! + 1;
    });
    return texels;
};
