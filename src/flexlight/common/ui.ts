'use strict';

import { Scene } from "./scene/scene.js";
import { Camera } from "./scene/camera.js";
import { Transform } from "./scene/transform.js";
import { Ray, Vector, ray_bounding, POW32M1, normalize, Matrix, moore_penrose, vector_scale, matrix_vector_mul, vector_add, vector_length, ray_triangle, matrix_mul, transpose, moellerTrumbore } from "./lib/math.js";
import { BVHNode } from "./scene/bvh.js";
import { BVHLeaf } from "./scene/bvh.js";
import { IndexedInstance } from "./scene/instance-bvh.js";
import { TypedArrayView } from "./buffer/typed-array-view.js";
import { Instance } from "./scene/instance.js";
import { Prototype } from "./scene/prototype.js";

interface Hit {
    distance: number;
    instance_index: number;
    triangle_index: number;
}

interface TransformStruct {
    rotation: Matrix<3, 3>;
    shift: Vector<3>;
}


const UINT_MAX = POW32M1;
const TRIANGLE_SIZE = 6;

const INSTANCE_UINT_SIZE = 9;
const TRANSFORM_SIZE = 12;

const BVH_INSTANCE_SIZE = 3;
const INSTANCE_BOUNDING_VERTICES_SIZE = 12;

const BVH_TRIANGLE_SIZE = 1;
const BVH_TRIANGLE_SIZE_FACTOR = 4;
const TRIANGLE_BOUNDING_VERTICES_SIZE = 5;
const TRIANGLE_BOUNDING_VERTICES_SIZE_FACTOR = 4;

export class UI {
    selected: Instance | null = null;
    scene: Scene;
    camera: Camera;

    constructor (scene: Scene, camera: Camera) {
        this.scene = scene;
        this.camera = camera;

        this.runSelector();
    }
    
    // Test for closest ray triangle intersection
    private traverseTriangleBVH(instance: IndexedInstance, ray: Ray, max_len: number): Hit {
        // Maximal distance a triangle can be away from the ray origin
        let instance_uint_offset = instance.id * INSTANCE_UINT_SIZE;

        const transform: Transform = instance.instance.transform;
        const inverse_rotation: Matrix<3, 3> = moore_penrose(transpose(transform.matrix));
        const inverse_shift: Vector<3> = vector_scale(transform.position, - 1);

        const inverse_dir: Vector<3> = matrix_vector_mul(inverse_rotation, ray.unit_direction);
        const t_ray = {
            origin: matrix_vector_mul(inverse_rotation, vector_add(ray.origin, inverse_shift)),
            unit_direction: normalize(inverse_dir)
        };

        const len_factor: number = vector_length(inverse_dir);

        const triangle_bvh: Uint32Array<ArrayBuffer> = Prototype.BVHManager.bufferView;
        const triangle_bounding_vertices: Float16Array = Prototype.boundingVertexManager.bufferView;
        const instance_uint: Uint32Array<ArrayBuffer> = this.scene.instanceUintManager.bufferView;

        const triangle_instance_offset: number = instance_uint[instance_uint_offset]!;
        const instance_bvh_offset: number = instance_uint[instance_uint_offset + 1]!;
        const instance_vertex_offset: number = instance_uint[instance_uint_offset + 2]!;
        // Hit object
        // First element of vector is current closest intersection point
        var hit: Hit = { distance: max_len, instance_index: UINT_MAX, triangle_index: UINT_MAX };
        // Stack for BVH traversal
        var stack = new Array<number>(32).fill(0);
        var stack_index: number = 1;
        
        while (stack_index > 0 && stack_index < 32) {
            stack_index -= 1;
            var node_index: number = stack[stack_index]!;

            let bvh_offset: number = (instance_bvh_offset + node_index * BVH_TRIANGLE_SIZE) * BVH_TRIANGLE_SIZE_FACTOR;
            let vertex_offset: number = (instance_vertex_offset + node_index * TRIANGLE_BOUNDING_VERTICES_SIZE) * TRIANGLE_BOUNDING_VERTICES_SIZE_FACTOR;

            let indicator_and_children: Vector<3> = new Vector(triangle_bvh[bvh_offset]!, triangle_bvh[bvh_offset + 1]!, triangle_bvh[bvh_offset + 2]!);

            const bv0 = new Vector<4>(triangle_bounding_vertices[vertex_offset]!, triangle_bounding_vertices[vertex_offset + 1]!, triangle_bounding_vertices[vertex_offset + 2]!, triangle_bounding_vertices[vertex_offset + 3]!);
            const bv1 = new Vector<4>(triangle_bounding_vertices[vertex_offset + 4]!, triangle_bounding_vertices[vertex_offset + 5]!, triangle_bounding_vertices[vertex_offset + 6]!, triangle_bounding_vertices[vertex_offset + 7]!);
            const bv2 = new Vector<4>(triangle_bounding_vertices[vertex_offset + 8]!, triangle_bounding_vertices[vertex_offset + 9]!, triangle_bounding_vertices[vertex_offset + 10]!, triangle_bounding_vertices[vertex_offset + 11]!);
            const bv3 = new Vector<4>(triangle_bounding_vertices[vertex_offset + 12]!, triangle_bounding_vertices[vertex_offset + 13]!, triangle_bounding_vertices[vertex_offset + 14]!, triangle_bounding_vertices[vertex_offset + 15]!);
            const bv4 = new Vector<4>(triangle_bounding_vertices[vertex_offset + 16]!, triangle_bounding_vertices[vertex_offset + 17]!, triangle_bounding_vertices[vertex_offset + 18]!, triangle_bounding_vertices[vertex_offset + 19]!);
            
            
            if (indicator_and_children.x == 0) {
                const t0 = new Matrix<3, 3>(
                    new Vector<3>(bv0.x, bv0.y, bv0.z),
                    new Vector<3>(bv0.w, bv1.x, bv1.y),
                    new Vector<3>(bv1.z, bv1.w, bv2.x)
                );
                // Run Moeller-Trumbore algorithm for both triangles
                // Test if ray even intersects
                let hit0_distance = moellerTrumbore(t0[0]!, t0[1]!, t0[2]!, t_ray, hit.distance * len_factor);
                if (hit0_distance != Infinity) {
                    // Calculate intersection point
                    hit.distance = hit0_distance / len_factor;
                    hit.instance_index = instance.id;
                    hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.y;
                }

                if (indicator_and_children.z != UINT_MAX) {
                    const t1 = new Matrix<3, 3>(
                        new Vector<3>(bv2.y, bv2.z, bv2.w),
                        new Vector<3>(bv3.x, bv3.y, bv3.z),
                        new Vector<3>(bv3.w, bv4.x, bv4.y)
                    );
                    // Test if ray even intersects
                    let hit1_distance = moellerTrumbore(t1[0]!, t1[1]!, t1[2]!, t_ray, hit.distance * len_factor);
                    if (hit1_distance != Infinity) {
                        // Calculate intersection point
                        hit.distance = hit1_distance / len_factor;
                        hit.instance_index = instance.id;
                        hit.triangle_index = triangle_instance_offset / TRIANGLE_SIZE + indicator_and_children.z;
                    }
                }
                
            } else {
                let dist0: number = ray_bounding(t_ray, { min: new Vector<3>(bv0.x, bv0.y, bv0.z), max: new Vector<3>(bv0.w, bv1.x, bv1.y) }, hit.distance * len_factor);
                var dist1: number = Infinity;
                if (indicator_and_children.z != UINT_MAX) {
                    dist1 = ray_bounding(t_ray, { min: new Vector<3>(bv1.z, bv1.w, bv2.x), max: new Vector<3>(bv2.y, bv2.z, bv2.w) }, hit.distance * len_factor);
                }

                let near_child = dist0 < dist1 ? indicator_and_children.y : indicator_and_children.z;
                let far_child = dist0 < dist1 ? indicator_and_children.z : indicator_and_children.y;

                // If node is an AABB, push children to stack, furthest first
                if (Math.max(dist0, dist1) != Infinity) {
                    stack[stack_index] = far_child;
                    // distance_stack[stack_index] = max(dist0, dist1);
                    stack_index += 1;
                }
                if (Math.min(dist0, dist1) != Infinity) {
                    stack[stack_index] = near_child;
                    // distance_stack[stack_index] = min(dist0, dist1);
                    stack_index += 1;
                }
            }
        }
        // Return hit object
        return hit;
    }

    private traverseInstanceBVH = (ray: Ray): Hit => {
        // Hit object
        // Maximal distance a triangle can be away from the ray origin is POW32 at initialisation
        let hit: Hit = { distance: Infinity, instance_index: -1, triangle_index: -1 };
        // Stack for BVH traversal
        let stack: Array<BVHNode<IndexedInstance> | BVHLeaf<IndexedInstance>> = [];
        const root: BVHNode<IndexedInstance> | BVHLeaf<IndexedInstance> = this.scene.instanceBVH.root;
        stack[0] = root;
        let stack_index: number = 1;

        while (stack_index > 0 && stack_index < 16) {
            stack_index -= 1;
            const node: BVHNode<IndexedInstance> | BVHLeaf<IndexedInstance> = stack[stack_index]!;

            const min0: Vector<3> = node.children[0]?.bounding.min ?? new Vector(0, 0, 0);
            const max0: Vector<3> = node.children[0]?.bounding.max ?? new Vector(0, 0, 0);
            const min1: Vector<3> = node.children[1]?.bounding.min ?? new Vector(0, 0, 0);
            const max1: Vector<3> = node.children[1]?.bounding.max ?? new Vector(0, 0, 0);

            const dist0 = ray_bounding(ray, { min: min0, max: max0 }, hit.distance);
            
            let dist1: number = Infinity;
            if (node.children[1]) {
                dist1 = ray_bounding(ray, { min: min1, max: max1 }, hit.distance);
            }

            const dist_near = Math.min(dist0, dist1);
            const dist_far = Math.max(dist0, dist1);

            // console.log(dist_near, dist_far);
            // console.log(node);
            

            if (node instanceof BVHLeaf) {
                const leaf = node as BVHLeaf<IndexedInstance>;
                const near_child = dist0 < dist1 ? leaf.children[0]! : leaf.children[1]!;
                const far_child = dist0 < dist1 ? leaf.children[1]! : leaf.children[0]!;
                // If node is a triangle, test for intersection, closest first
                if (dist_near != Infinity) {
                    let new_hit: Hit = this.traverseTriangleBVH(near_child, ray, hit.distance);
                    // new_hit.distance = dist_near;
                    if (new_hit.distance < hit.distance) {
                        hit = new_hit;
                    }
                    // let new_hit: Hit = { distance: dist_near, instance_index: near_child.id, triangle_index: 0 };
                    // return new_hit;
                }
                if (dist_far != Infinity && dist_far < hit.distance) {
                    // let new_hit: Hit = { distance: dist_far, instance_index: far_child.id, triangle_index: 0 };
                    // return new_hit;
                    let new_hit: Hit = this.traverseTriangleBVH(far_child, ray, hit.distance);
                    // new_hit.distance = dist_far;
                    if (new_hit.distance < hit.distance) {
                        hit = new_hit;
                    }
                }
            } else if (node instanceof BVHNode) {
                const non_leaf_node = node as BVHNode<IndexedInstance>;
                const near_child = dist0 < dist1 ? non_leaf_node.children[0]! : non_leaf_node.children[1]!;
                const far_child = dist0 < dist1 ? non_leaf_node.children[1]! : non_leaf_node.children[0]!;
                // If node is an AABB, push children to stack, furthest first
                if (dist_far != Infinity) {
                    stack[stack_index] = far_child;
                    // distance_stack[stack_index] = dist_far;
                    stack_index += 1;
                }
                if (dist_near != Infinity) {
                    stack[stack_index] = near_child;
                    // distance_stack[stack_index] = dist_near;
                    stack_index += 1;
                }
            }
        }
        // Return hit object
        return hit;
    }
    

    private runSelector = () => {
        setInterval(() => {
            const direction = new Vector<3>(
                - Math.sin(this.camera.direction.x) * Math.cos(this.camera.direction.y),
                - Math.sin(this.camera.direction.y),
                Math.cos(this.camera.direction.x) * Math.cos(this.camera.direction.y)
            );

            let hit = this.traverseInstanceBVH({ origin: this.camera.position, unit_direction: normalize(direction) });
            // If pointer is currently pointing at object
            if (hit.distance !== Infinity) {
                // hit.object.selected = true;
                // console.log(hit.instance_index);
                let indexedInstance = this.scene.instanceBVH.getInstanceById(hit.instance_index);
                if (indexedInstance) {
                    this.selected = indexedInstance.instance;
                } else {
                    this.selected = null;
                }
            } else {
                this.selected = null;
            }
        }, 10);
    }

    /*
    getObjectInCenter = (part, o, dir) => {
        if (Array.isArray(part) || part.indexable) {
            if (part.length === 0) return;
            // Get object with least distance
            let least = this.getObjectInCenter(part[0], o, dir);
            // Iterate over all sub elements
            for (let i = 1; i < part.length; i++) {
                let t = this.getObjectInCenter(part[i], o, dir);
                if (least.distance > t.distance) least = t;
            }
            return least;
        } else {      
            if (part.length === 2) {
                let n = part.normal;
                let t0 = [part.vertices.slice(0, 3), part.vertices.slice(3, 6), part.vertices.slice(6, 9)];
                let t1 = [part.vertices.slice(9, 12), part.vertices.slice(12, 15), part.vertices.slice(15, 18)];
                return {
                    distance: Math.min(Math.rayTriangle (o, dir, t0[0], t0[1], t0[2], n), Math.rayTriangle (o, dir, t1[0], t1[1], t1[2], n)),
                    object: part
                };
            } else if (part.length === 1) {
                let n = part.normal;
                let t = [part.vertices.slice(0, 3), part.vertices.slice(3, 6), part.vertices.slice(6, 9)];
                return {
                    distance: Math.rayTriangle (o, dir, t[0], t[1], t[2], n),
                    object: part
                };
            }
        }
    }
    */
}