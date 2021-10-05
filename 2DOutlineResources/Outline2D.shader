Shader "FeGameArt/Outline2D"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _OutlineColorPalette("Outline Color Pallete", 2D) = "white" {}
        _OutlineColorSpeed("Outline Color Speed", Range(0.1, 1)) = 0.1
        _OutlineSize("Outline size", Range(0, 0.1)) = 0
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

            sampler2D _OutlineColorPalette;
            float _OutlineSize;
            float _OutlineColorSpeed;

            float4 getOutlineColor()
            {
                float4 palleteTex = tex2D(_OutlineColorPalette,
                    float2(frac(_Time.y * _OutlineColorSpeed), 0));

                return palleteTex;
            }

            float4 applyOutline(float4 col, float2 uv)
            {
                float2 rightUV = uv + float2(_OutlineSize, 0);
                float2 leftUV = uv + float2(-_OutlineSize, 0);
                float2 topUV = uv + float2(0, _OutlineSize);
                float2 bottomUV = uv + float2(0, -_OutlineSize);

                float4 rightOutline = tex2D(_MainTex, rightUV).a;
                float4 leftOutline = tex2D(_MainTex, leftUV).a;
                float4 topOutline = tex2D(_MainTex, topUV).a;
                float4 bottomOutline = tex2D(_MainTex, bottomUV).a;

                float4 outline = saturate(rightOutline +
                    leftOutline +
                    topOutline +
                    bottomOutline);

                outline.a -= col.a;

                outline *= getOutlineColor();

                float4 finalCol = lerp(outline, col, col.a);

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

                col = applyOutline(col, i.uv);

                clip(col.a - 0.9);

                return col;
            }
            ENDCG
        }
    }
}
