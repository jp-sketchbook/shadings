Shader "Custom/ColorAndLight"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientColor ("AmbientColor", Color) = (.1,.1,.1,1)
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
                float2 uv0 : TEXCOORD0;
            };

            float4 _Color;
            float4 _AmbientColor;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv0 = v.uv0;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv0;
                float3 n = i.normal; // -1<->1
                // float3 n = i.normal * .5 + .5; // 0<->1
                
                // Lighting
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFalloff = max(dot(lightDir, n), 0);
                float3 directDiffuseLight = lightColor * lightFalloff;
                float3 ambientLight = _AmbientColor;
                float3 diffuseLight = ambientLight + directDiffuseLight;

                float4 col = float4(diffuseLight * _Color.rgb, 0);
                return col;
            }
            ENDCG
        }
    }
}
 