Shader "MMW/PolarBeatShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RingSpeed("Ring Scroll Speed", Range(-12.0, 12.0)) = 2.0
        _ChangingSpeed("Changing Speed", Range(-12.0, 12.0)) = 2.0
        _BeatLength("Beat Length", Range(0.0, 0.9)) = 0.3
        _VertexLength("Size Beat Length", Range(0.0, 1.0)) = 0.1
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
                half3 normal : NORMAL;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _MainTex_ST;
            half _RingSpeed;
            half _ChangingSpeed;
            half _BeatLength;
            half _VertexLength;
            half _ColorTimes;
            half _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                half timeVal = frac(_RingSpeed*_Time.y);
                half timeValCalced = -(timeVal-1)*(timeVal-1)+1;
                o.vertex = UnityObjectToClipPos(v.vertex *(1+_VertexLength*frac(timeValCalced)));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half val = distance(i.uv, half2(0.5, 0.5));
                half2 polarUV;
                half beatOneMinus = 1-_BeatLength;
                polarUV.x = frac(_ChangingSpeed * _Time.x);
                polarUV.y = frac(val*beatOneMinus*2)- (frac(_RingSpeed*_Time.y)-1)*_BeatLength; 

                half4 col = tex2D(_MainTex, polarUV);
                clip(col.a-_Threshold);
                col += col*_ColorTimes;

                return col;
            }
            ENDCG
        }
    }
}
