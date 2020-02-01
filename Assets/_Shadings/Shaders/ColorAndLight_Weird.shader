Shader "Custom/ColorAndLight_Weird"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientColor ("AmbientColor", Color) = (.1,.1,.1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Speed", Range (1, 100)) = 10
        _Amplitude ("Amplitude", Range (0.01, 2)) = 1
        _Offset("Offset", Range(-2, 2)) = 0
        _UVSpeed ("UV Speed", Range(-10, 10)) = 1
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
            sampler2D _MainTex;
            float _Speed;
            float _Amplitude;
            float _Offset;
            float _UVSpeed;

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
                float t = _Time;
                float2 uv = i.uv0;
                float3 n = i.normal;
                
                // Lighting
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float lightFalloff = max(dot(lightDir, n), 0);
                float3 directDiffuseLight = lightColor * lightFalloff;
                float3 ambientLight = _AmbientColor;
                float3 diffuseLight = ambientLight + directDiffuseLight;

                // Texture
                float2 animUV = float2(uv.x + sin(t*_UVSpeed), uv.y + cos(t*_UVSpeed));
                fixed4 tex = tex2D(_MainTex, animUV);
                
                // Blend color
                float4 color = float4(lerp(_Color.rgb, tex.rgb, (sin(t*_Speed)) * _Amplitude) + _Offset, 0);

                float4 col = float4(diffuseLight * color, 0);
                return col;
            }
            ENDCG
        }
    }
}
 