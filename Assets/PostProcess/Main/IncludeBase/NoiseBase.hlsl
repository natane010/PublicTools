float3 ReturnRed(float3 rgb)
{
	float3 reColor = float3(rgb.r,0,0);
	return reColor;
}

float3 ReturnBlue(float3 rgb)
{
	float3 reColor = float3(0,0,rgb.b);
	return reColor;
}

float3 ReturnGreen(float3 rgb)
{
	float3 reColor = float3(0,rgb.g,0);
	return reColor;
}

float GetRandomNumber(float2 texCoord, int Seed)
{
    return frac(sin(dot(texCoord.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}
float3 RandomCircleMap(float2 pivot, float seed)
{
	//x^2 + y^2 = l^2

}