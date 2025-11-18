#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
    float2 textureCoordinate [[attribute(1)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 textureCoordinate;
};

// FIX: Change the argument to use [[stage_in]]
// This tells the GPU: "Please assemble this vertex using the VertexDescriptor rules."
vertex VertexOut vertexShader(VertexIn in [[stage_in]]) {
    VertexOut out;
    
    out.position = in.position;
    out.textureCoordinate = in.textureCoordinate;
    
    return out;
}

fragment float4 grayscaleFragmentShader(VertexOut input [[stage_in]],
                                        texture2d<float> cameraTexture [[texture(0)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    
    // Sample the color
    float4 color = cameraTexture.sample(textureSampler, input.textureCoordinate);
    
    // Grayscale calculation
    float3 grayscaleWeights = float3(0.299, 0.587, 0.114);
    float grayValue = dot(color.rgb, grayscaleWeights);
    
    return float4(grayValue, grayValue, grayValue, 1.0);
}
