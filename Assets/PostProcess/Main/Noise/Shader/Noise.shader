Shader "TK/Custom/Noise"
{
    HLSLINCLUDE
    # include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    # include "Assets/PostProcess/Main/IncludeBase/BaseCalcColor.hlsl"
    # include "Assets/PostProcess/Main/IncludeBase/NoiseBase.hlsl"

    uniform TEXTURE2D_X(_MainTex);
    SAMPLER(sampler_MainTex);

    float4 _MainTex_ST;

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float2 uv           : TEXCOORD0;
        float2 noiseUv1     : TEXCOORD1;
        float2 noiseUv2     : TEXCOORD2;
    };

    struct Varyings
    {
        float2 uv           : TEXCOORD0;
        float4 positionHCS  : SV_POSITION;
    };

    Varyings Vert(Attributes IN)
    {
        Varyings OUT;
        OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
        OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex) + _Time.y;
        return OUT;
    }

    half4 Frag(Varyings input) : SV_Target
    {
        half4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv);
        return color;
    }

    ENDHLSL

    SubShader
    {
        Tags
        { 
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline" 
        }
        ZTest Always 
        ZWrite Off 
        Cull Off

        // 0 
        Pass
        {
            Name "Post"

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            ENDHLSL
        }
    }
}
