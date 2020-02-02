Shader "Custom/VoronoiSimple"
{
    Properties
    {
        _Speed ("Speed", Range (1, 100)) = 10
        _Density("Point Density", Range (1., 20.)) = 5.
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

            float _Speed;
            int _Density;

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
                float2 uv = i.uv*2 - 1;

                float t = _Time*_Speed;
                float m = 0;

                float minDist = 100.;
                
                uv *= _Density;
                float2 gv = frac(uv)-.5;
                float2 id = floor(uv);
                
                for(float y=-1; y<=1; y++) {
                    for(float x=-1; x<=1; x++) {
                        float2 offs = float2(x, y);
                        float2 n = N22(id+offs);
                        float2 p = offs+sin(n*t)*.5;
                        float d = length(gv-p);
                        if(d<minDist) {
                            minDist = d;
                        }
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
