Shader "MMW/NoisePolarShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0.3, 0.8, 1)
        _RepeatNum("Repeat Num", Range(1, 10)) = 2.0
        _ChangingSpeed("Changing Speed", Range(-200.0, 200.0)) = 12.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull Off

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
            half4 _Color;
            half _RepeatNum;
            half _ChangingSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                const half PI = 3.1415;

                float2 uvVal = float2(i.uv.x-0.5, i.uv.y-0.5);
                float radian = atan2(uvVal.x, uvVal.y);
                half2 polarUV;
                polarUV.x = frac(_Time.x*_ChangingSpeed);
                polarUV.y = (1-radian/PI)/2*_RepeatNum;

                fixed4 col;
                fixed4 noiseVal = tex2D(_MainTex, polarUV);
                clip(noiseVal.a-0.5);
                col = noiseVal*_Color;
                return col;
            }
            ENDCG
        }
    }
}
