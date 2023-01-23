Shader "TK/Custom/Glitch"
{
    Properties
    {
        _MainTex("MainTex", 2D) = "white" { }
    }

     HLSLINCLUDE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

    TEXTURE2D(_MainTex); 
    SAMPLER(sampler_MainTex);

    struct AttributesDefault
    {
        float4 positionOS: POSITION;
        float2 uv: TEXCOORD0;
    };


    struct VaryingsDefault
    {
        float4 positionCS: SV_POSITION;
        float2 uv: TEXCOORD0;
    };


    VaryingsDefault VertDefault(AttributesDefault input)
    {
        VaryingsDefault output;
        output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
        output.uv = input.uv;

        return output;
    }

    uniform half3 _DataParams;
    uniform half4 _LayerParams;
    uniform half3 _IntensityDataParams;

    #define _TimeX _DataParams.x
    #define _Offset _DataParams.y
    #define _Fade _DataParams.z

    #define _Layer1 _LayerParams.w
    #define _Layer1_2 _LayerParams.x
    #define _Layer2 _LayerParams.y
    #define _Layer2_2 _LayerParams.z

    #define _Indensity _IntensityDataParams.x
    #define _Layer1Indensity _IntensityDataParams.y
    #define _Layer2Indensity _IntensityDataParams.z


    float randomNoise(float2 seed)
    {
        return frac(sin(dot(seed * floor(_TimeX * 30.0), float2(127.1, 311.7))) * 43758.5453123);
    }

    float randomNoise(float seed)
    {
        return randomNoise(float2(seed, 1.0));
    }

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float2 uv = i.uv.xy;

        float2 layer1 = floor(uv * float2(_Layer1, _Layer1_2));
        float2 layer2 = floor(uv * float2(_Layer2, _Layer2_2));


        float lineNoise1 = pow(randomNoise(layer1), _Layer1Indensity);
        float lineNoise2 = pow(randomNoise(layer2), _Layer2Indensity);
        float noise = pow(randomNoise(5.1379), 7.1) * _Indensity;
        float lineNoise = lineNoise1 * lineNoise2 * _Offset - noise;

        float4 colorR = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
        float4 colorG = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv + 
            float2(lineNoise * 0.05 * randomNoise(7.0), 0));
        float4 colorB = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv - 
            float2(lineNoise * 0.05 * randomNoise(23.0), 0));

        float4 result = float4(float3(colorR.x, colorG.y, colorB.z), colorR.a + colorG.a + colorB.a);
        result = lerp(colorR, result, _Fade);

        return result;
    }


        float4 Frag_Debug(VaryingsDefault i) : SV_Target
    {
        float2 uv = i.uv.xy;

        float2 layer1 = floor(uv * float2(_Layer1, _Layer1_2));
        float2 layer2 = floor(uv * float2(_Layer2, _Layer2_2));

        float lineNoise1 = pow(randomNoise(layer1), _Layer1Indensity);
        float lineNoise2 = pow(randomNoise(layer2), _Layer2Indensity);
        float noise = pow(randomNoise(5.1379), 7.1) * _Indensity;
        float lineNoise = lineNoise1 * lineNoise2 * _Offset - noise;

        return float4(lineNoise, lineNoise, lineNoise, 1);
    }

    ENDHLSL

    SubShader
    {
        Tags{ "RenderPipeline" = "UniversalPipeline" "RenderType" = "Opaque" }

        Cull Off
        ZWrite Off
        ZTest Always


        Pass
        {
            HLSLPROGRAM

            #pragma vertex VertDefault
            #pragma fragment Frag

            ENDHLSL

        }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex VertDefault
            #pragma fragment Frag_Debug

            ENDHLSL

        }
    }
}
