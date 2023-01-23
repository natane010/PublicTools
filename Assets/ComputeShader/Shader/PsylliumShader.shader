Shader "TK/Custom/PsylliumShader"
{
    Properties
    {
        _MainTex("Base", 2D) = "white" {}
        _Intensity("Intensity", Range(1, 10)) = 1
    }

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct PsylliumData
            {
                // ç¿ïW
                float3 Position;
                // âÒì]
                float2x2 Rotation;
                // êF
                float4 PsylliumColor;
            };

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            StructuredBuffer<PsylliumData> _PsylliumDataBuffer;
            float3 _PsylliumMeshScale;
            float3 _Color;
            CBUFFER_START(UnityPerMaterial)
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            float _Intensity;
            CBUFFER_END

            float random(float2 st, int seed)
            {
                return frac(sin(dot(st.xy, float2(12.9898, 78.233)) + seed) * 43758.5453123);
            }

            v2f vert(appdata_t v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                v.vertex.y += ((_MainTex_TexelSize.w / 100) / 2);
                float2x2 rotationMatrix = _PsylliumDataBuffer[instanceID].Rotation;
                v.vertex.yz = mul(rotationMatrix, v.vertex.yz);
                v.vertex.y -= ((_MainTex_TexelSize.w / 100) / 2);

                float4x4 matrix_ = (float4x4)0;
                matrix_._11_22_33_44 = float4(_PsylliumMeshScale.xyz, 1.0);
                matrix_._14_24_34 += _PsylliumDataBuffer[instanceID].Position;
                v.vertex = mul(matrix_, v.vertex);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = _PsylliumDataBuffer[instanceID].PsylliumColor;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                col.rgb =  i.color.rgb * _Intensity * _Color;
                clip(col.a - 0.1);
                col.rgb *= 6;
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
