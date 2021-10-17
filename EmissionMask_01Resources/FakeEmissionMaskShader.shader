Shader "FeGameArt/FakeEmission/FakeEmissionMaskShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _EmissionMask("EmissionMask", 2D) = "white" {}
        _EmissionMaxIntensity("Emission max intensity", 
            Range(0, 1)) = 1
    }
        SubShader
    {
        Tags { "Queue" = "Transparent" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

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

            sampler2D   _MainTex,
                        _EmissionMask;

            float4 _MainTex_ST;

            float _EmissionMaxIntensity;

            float4 _EmissionColor;

            fixed4 applyEmissionMask(float4 color, float2 uv)
            {
                fixed4 emissionMask = 
                    tex2D(_EmissionMask, uv).a;

                float normalizedTime = (sin(_Time.y * 2) 
                    * 0.5 + 0.5);

                float emissionWithOffset = 
                    (normalizedTime + 0.8);

                float emissionIntensity = 
                    _EmissionMaxIntensity * emissionWithOffset;

                emissionMask.a *= emissionIntensity;

                emissionMask *= _EmissionColor;

                fixed4 finalColor = color;
                finalColor.rgb = lerp(color,
                                         emissionMask, 
                                         emissionMask.a).rgb;

                return finalColor;
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

                col = applyEmissionMask(col, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
