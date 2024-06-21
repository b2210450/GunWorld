Shader "MMW/SlantingShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SquareSpeed("Square Scroll Speed", Range(-200.0, 200.0)) = 12.0
        _ChangingSpeed("Changing Speed", Range(-12.0, 12.0)) = 2.0
        _ColorTimes("Color Times", Range(0.0, 10.0)) = 1.0
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Cull [_CullMode]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                half4 vertex : POSITION;
                half2 uv : TEXCOORD0;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _MainTex_ST;
            half _SquareSpeed;
            half _ChangingSpeed;
            half _ColorTimes;
            half _Threshold;
            half _UseSine;


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 val = half2(0.5, 0.5)-i.uv;
                half2 polarUV;
                polarUV.x = frac(_ChangingSpeed * _Time.x);
                polarUV.y = frac(abs(val.x+val.y)-_SquareSpeed * _Time.y); 

                half4 col = tex2D(_MainTex, polarUV);
                clip(col.a-_Threshold);
                col += col*_ColorTimes;

                return col;
            }
            ENDCG
        }
    }
}
