Shader "FeGameArt/UVSinAnimation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _WaveSpeed("Wave speed", Range(0, 10)) = 0
        _WaveAmplitude("Wave amplitude", Range(0, 1)) = 0
        _WaveFrequency("Wave frequency", Range(0, 5)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Cull off

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
                //The color information is passed by vertex in the particle system.
                //We need to get this color and pass to the frag shader if we want to use 
                //this shader with Particle system
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveSpeed;
            float _WaveAmplitude;
            float _WaveFrequency;


            float2 calculateSinUV(float2 uv)
            {
                float speed = _WaveSpeed * _Time.y;

                uv.x += sin(speed + uv.y * _WaveFrequency) * _WaveAmplitude;

                return uv;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = calculateSinUV(i.uv);
                float4 col = tex2D(_MainTex, uv);

                col *= i.color;

                return col;
            }
            ENDCG
        }
    }
}
