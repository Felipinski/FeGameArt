Shader "FeGameArt/ToonShadeWithTexture"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _GrayscaleTex("Gray Scale Texture", 2D) = "white" {}
    }
    SubShader
    {
         Tags {"Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GrayscaleTex;

            float4 _Color;

            float4 applyToonShade(float4 col, float3 worldNormal)
            {
                float NdotL = dot(_WorldSpaceLightPos0.xyz,
                    worldNormal);

                float remappedDot = ((NdotL * 0.5) + 0.5);

                float2 grayScaleUV = float2(remappedDot, 0);

                float grayScaleInfluence = tex2D(_GrayscaleTex,
                    grayScaleUV).r;

                col *= grayScaleInfluence;

                return col;
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

                col.rgb = applyToonShade(col, i.worldNormal);

                clip(col.a - 0.5);

                return col * _Color;
            }
            ENDCG
        }
    }
}
