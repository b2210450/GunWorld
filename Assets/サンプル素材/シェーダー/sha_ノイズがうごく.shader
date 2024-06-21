Shader "MMW/NoiseShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0.3, 0.8, 1)
        _Speed("Speed", Range(0.0, 20.0)) = 5.0
        [KeywordEnum(Vertical, Horizontal)]_LineType("Line Type", Float) = 0
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
            #pragma multi_compile _LINETYPE_VERTICAL _LINETYPE_HORIZONTAL

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
            half _Speed;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                #ifdef _LINETYPE_VERTICAL
                    i.uv.y = _Time.x*_Speed;
                #else
                    i.uv.x = _Time.x*_Speed;
                #endif

                fixed4 col;
                fixed4 noiseVal = tex2D(_MainTex, i.uv);
                clip(noiseVal.a-0.5);
                col = _Color*noiseVal;
                return col;
            }
            ENDCG
        }
    }
}
