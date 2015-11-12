//
//  Shader.metal
//  GigglyMetal
//
//  Created by Saqib Omer on 11/12/15.
//  Copyright © 2015 KaboomLab. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//Vertex Shader
vertex float4 basic_vertex(    // basic_vertex is name of shader. Every vertex shader must begin with keywork vertex
                           const device packed_float3* vertex_array [[ buffer(0) ]], // Packed vector of 3 floats, position of each vetex
                           unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0); //return position of vertex in vertex array
}

//Fragment Shader
fragment half4 basic_fragment () {
    return half4(1.0);
}