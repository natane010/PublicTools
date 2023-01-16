Shader "TK/Custom/MetaShader"
{
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent" 
        }

        Pass
        {
            ZWrite On 
            Blend SrcAlpha OneMinusSrcAlpha 

            CGPROGRAM

            #define MAX_SPHERE_COUNT 256
            float4 _Circles[MAX_SPHERE_COUNT];
            fixed3 _Colors[MAX_SPHERE_COUNT];
            int _CircleCount;

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "MetaFunc.cginc"

            struct input
            {
                float4 vertex : POSITION; 
            };

            struct v2f
            {
                float4 pos : POSITION1; 
                float4 vertex : SV_POSITION; 
            };

            struct output
            {
                float4 col: SV_Target; 
                float depth : SV_Depth; 
            };

            v2f vert(const input v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.pos = mul(unity_ObjectToWorld, v.vertex); 
                return o;
            }
            

            output frag(const v2f i)
            {
                output o;

                float3 pos = i.pos.xyz; 
                const float3 rayDir = normalize(pos.xyz - _WorldSpaceCameraPos); 
                const half3 halfDir = normalize(_WorldSpaceLightPos0.xyz - rayDir); 

                //åvéZâÒêîÇÕéãñÏäpìxÇ…ÇÊÇ¡ÇƒïœÇ¶ÇƒÇ≠ÇæÇ≥Ç¢ÅB
                for (int i = 0; i < 90; i++)
                {
                    //ç≈íZãóó£
                    float dist = getDistance(pos);

                    if (dist < 0.01)
                    {
                        fixed3 norm = getNormal(pos); 
                        fixed3 baseColor = getColor(pos);

                        const float rimPower = 0.5;
                        const float rimRate = pow(1 - abs(dot(norm, rayDir)), rimPower);
                        const fixed3 rimColor = fixed3(0.5, 0.5, 0.5);

                        float highlight = dot(norm, halfDir) > 0.99 ? 1 : 0;
                        fixed3 color = clamp(lerp(baseColor, rimColor, rimRate) + highlight, 0, 1);
                        float alpha = clamp(lerp(0.2, 4, rimRate) + highlight, 0, 1); 

                        o.col = fixed4(baseColor, alpha); 
                        o.depth = getDepth(pos);
                        return o;
                    }

                    pos += dist * rayDir;
                }

                o.col = 0;
                o.depth = 0;
                return o;
            }
            ENDCG
        }
    }
}
