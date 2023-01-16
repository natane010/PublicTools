// 球の距離関数
float4 sphereDistanceFunction(float4 sphere, float3 pos)
{
    return length(sphere.xyz - pos) - sphere.w;
}

// 深度計算
inline float getDepth(float3 pos)
{
    const float4 vpPos = mul(UNITY_MATRIX_VP, float4(pos, 1.0));

    float z = vpPos.z / vpPos.w;
#if defined(SHADER_API_GLCORE) || \
                    defined(SHADER_API_OPENGL) || \
                    defined(SHADER_API_GLES) || \
                    defined(SHADER_API_GLES3)
    return z * 0.5 + 0.5;
#else
    return z;
#endif
}
//Smooth
float smoothMin(float x1, float x2, float k)
{
    return -log(exp(-k * x1) + exp(-k * x2)) / k;
}
//距離取得
float getDistance(float3 pos)
{
    float dist = 100000;
    for (int i = 0; i < _CircleCount; i++)
    {
        dist = smoothMin(dist, sphereDistanceFunction(_Circles[i], pos), 3);
    }
    return dist;
}
//色取得
fixed3 getColor(const float3 pos)
{
    fixed3 color = fixed3(0, 0, 0);
    float weight = 0.01;
    for (int i = 0; i < _CircleCount; i++)
    {
        const float distinctness = 0.7;
        const float4 sphere = _Circles[i];
        const float x = clamp((length(sphere.xyz - pos) - sphere.w) * distinctness, 0, 1);
        const float t = 1.0 - x * x * (3.0 - 2.0 * x);
        color += t * _Colors[i];
        weight += t;
    }
    color /= weight;
    return float4(color, 1);
}

// 法線の算出
float3 getNormal(const float3 pos)
{
    float d = 0.0001;
    return normalize(float3(
        getDistance(pos + float3(d, 0.0, 0.0)) - getDistance(pos + float3(-d, 0.0, 0.0)),
        getDistance(pos + float3(0.0, d, 0.0)) - getDistance(pos + float3(0.0, -d, 0.0)),
        getDistance(pos + float3(0.0, 0.0, d)) - getDistance(pos + float3(0.0, 0.0, -d))
        ));
}