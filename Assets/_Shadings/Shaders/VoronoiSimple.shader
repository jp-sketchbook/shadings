Shader "Custom/VoronoiSimple"
{
    Properties
    {
        _Speed ("Speed", Range (1, 100)) = 10
        _Density("Point Density", Range (1., 20.)) = 5.
        _Sharpen("Sharpen", Range(0, 1)) = 0
        _Brighten("Brighten", Range(0, .5)) = 0
        _LineColor("Line Color", Color) = (1,0,0,1)
        _CellColor("Cell Color", Color) = (0,0,1,1)
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
            float _Sharpen;
            float _Brighten;
            float4 _LineColor;
            float4 _CellColor;


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
                float2 cid = 0;
                
                for(float y=-1; y<=1; y++) {
                    for(float x=-1; x<=1; x++) {
                        float2 offs = float2(x, y);
                        float2 n = N22(id+offs);
                        float2 p = offs+sin(n*t)*.5;
                        p -= gv;
                        float ed = length(p);
                        float md = abs(p.x)+abs(p.y);
                        float d = lerp(ed, md, _Sharpen);
                        if(d<minDist) {
                            minDist = d;
                            cid = id+offs;
                        }
                    }
                }

                float3 col = minDist;
                float4 brightness = float4(col, 1);
                float4 darkness = float4(1-col.x, 1-col.y, 1-col.z, 1);

                float4 lightCol = _LineColor*brightness;
                float4 darkCol = _CellColor*darkness;
                float4 brightenCol = _Brighten;

                float4 fragCol = lerp(lightCol,darkCol,.5);
                fragCol += brightenCol;
                return fragCol;
            }
            ENDCG
        }
    }
}
