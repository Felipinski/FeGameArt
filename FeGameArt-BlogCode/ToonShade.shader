Shader "FeGameArt/Tutorial/HLSL/ToonShade"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _GrayScaleTex("Gray Scale Texture", 2D) = "white" {}
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GrayScaleTex;

            float4 toonShade(float4 color, float3 normal)
            {
                fixed3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                fixed NdotL = dot(normal, lightDirection);
                NdotL = (NdotL * 0.5) + 0.5;

                fixed toonColor = tex2D(_GrayScaleTex, float2(NdotL, 0));

                color *= toonColor;

                return color;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.worldNormal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                i.worldNormal = normalize(i.worldNormal);

                col = toonShade(col, i.worldNormal);

                return col;
            }
            ENDCG
        }
    }
}
