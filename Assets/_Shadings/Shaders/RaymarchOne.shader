﻿Shader "Raymarching/RaymarchOne"
{
    Properties
    {
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define MAX_STEPS 100
            #define MAX_DIST 100
            #define SURF_DIST 1e-3

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // World space
                o.ro = _WorldSpaceCameraPos;
                o.hitPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float GetDist(float3 p) {
                float4 s = float4(0, 1, 2, 0.5);

                float sphereDist = length(p-s.xyz)-s.w;
                float planeDist = p.y;
                float d = min(sphereDist, planeDist);
                return d;
            }

            float RayMarch(float3 ro, float3 rd) {
                float dO = 0;
                for (int i = 0; i<MAX_STEPS; i++) {
                    float3 p = ro + rd*dO;
                    float dS = GetDist(p);
                    dO += dS;
                    if(dO>MAX_DIST || dS<SURF_DIST) break;
                }
                return dO;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv-.5;
                float3 ro = i.ro;
                float3 rd = normalize(i.hitPos - ro);
                float d = RayMarch(ro, rd);
                d /= 6.;
                float3 col = d;
                return float4(col.x, col.y, col.z, 1);
            }
            ENDCG
        }
    }
}