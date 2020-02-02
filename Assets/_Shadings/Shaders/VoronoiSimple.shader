Shader "Custom/VoronoiSimple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range (1, 100)) = 10
        _Count("Point Count", Range (10, 50)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Speed;
            int _Count;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 N22(float2 p) {
                float3 a = frac(p.xyx*float3(123.34, 234.34, 345.65));
                a += dot(a, a+34.45);
                return frac(float2(a.x*a.y, a.y*a.z));
            }

            float4 frag (v2f i) : SV_Target
            {
                // float2 uv = i.uv;
                float2 uv = i.uv*2 - 1;
                // return float4(uv, 0, 0);
                float t = _Time*_Speed;
                float m = 0;

                float minDist = 100.;
                for(float i=0; i<_Count; i++) {
                    float2 n = N22(i);
                    float2 p = sin(n*t);

                    float d = length(uv-p);
                    m += smoothstep(.05, .03, d);

                    if(d<minDist) {
                        minDist = d;
                    }
                }
                float3 col = minDist;
                float4 fragCol = float4(col, 1);
                return fragCol;
            }
            ENDCG
        }
    }
}
