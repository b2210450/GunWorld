Shader "MMW/PolarMaskShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _SubTex ("Sub Texture", 2D) = "white" {}
        _RingSpeed("Ring Scroll Speed", Range(-200.0, 200.0)) = 12.0
        _ChangingSpeed("Changing Speed", Range(-200.0, 200.0)) = 12.0
        _ColorTimes("Color Times", Range(0.0, 10.0)) = 1.0
        _Color ("Color", Color) = (1, 1, 1, 1)
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
                half2 uv2 : TEXCOORD1;
                half2 uv3 : TEXCOORD2;
            };

            struct v2f
            {
                half2 uv : TEXCOORD0;
                half2 uv2 : TEXCOORD1;
                half2 uv3 : TEXCOORD2;
                half4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            half4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            sampler2D _SubTex;
            float4 _SubTex_ST;
            half _RingSpeed;
            half _ChangingSpeed;
            half _ColorTimes;
            half4 _Color;   
            half _Threshold;

            const half PI = 3.14159265;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.uv2, _MaskTex);
                o.uv3 = TRANSFORM_TEX(v.uv3, _SubTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half val = distance(i.uv2, half2(0.5, 0.5));
                half2 polarUV;
                polarUV.x = frac(_ChangingSpeed * _Time.x);
                polarUV.y = frac(val-_RingSpeed * _Time.y); 

                half4 maskCol = tex2D(_MaskTex, polarUV);

                half4 col = tex2D(_MainTex, i.uv);
                half4 colSub = tex2D(_SubTex, i.uv3);

                col = lerp(colSub,col,maskCol.r);

                clip(col.a-0.5);

                col *= _Color;
                col += col*_ColorTimes;

                return col;
            }
            ENDCG
        }
    }
}
