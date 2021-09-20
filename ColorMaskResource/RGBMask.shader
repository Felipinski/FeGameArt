Shader "FeGameArt/RGBMask"
{
    Properties
    {
        [HideInInspector]
        _MainTex("Texture", 2D) = "white" {}

        [NoScaleOffset]
        _RGBMask("RGBMask", 2D) = "white" {}
        //[PerRendererData]
        //[HideInInspector]
        _RChannel("R Channel", Color) = (1, 0, 0, 1)
        //[PerRendererData]
        //[HideInInspector]
        _GChannel("G Channel", Color) = (0, 1, 0, 1)
        //[PerRendererData]
        //[HideInInspector]
        _BChannel("B Channel", Color) = (0, 0, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _RGBMask;
            float4 _RChannel;
            float4 _GChannel;
            float4 _BChannel;

            float4 applyRGBMaskColors(float4 col, float2 uv)
            {
                float4 rgbMaskMap = tex2D(_RGBMask, uv);

                float4 rChannel = rgbMaskMap.r * _RChannel;
                float4 gChannel = rgbMaskMap.g * _GChannel;
                float4 bChannel = rgbMaskMap.b * _BChannel;

                float4 finalCol = rChannel + gChannel + bChannel;

                float isMasked = rgbMaskMap.r + rgbMaskMap.g + rgbMaskMap.b;

                finalCol = lerp(col, finalCol, isMasked);

                return finalCol;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                col = applyRGBMaskColors(col, i.uv);

                clip(col.a - 0.5);

                return col;
            }
            ENDCG
        }
    }
}
