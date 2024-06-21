Shader "MMW/UVScrollCutOffShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _XSpeed("Scroll Speed(X)", Range(-200.0, 200.0)) = 12.0
        _YSpeed("Scroll Speed(Y)", Range(-200.0, 200.0)) = 6.0
        _ColorTimes("Color Times", Range(0.0, 10.0)) = 1.0
        _Threshold("Threshold", Range(0.0, 1.0)) = 0.5
        [Enum(UnityEngine.Rendering.CullMode)]_CullMode("Cull Mode", Float) = 0
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
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            half _XSpeed;
            half _YSpeed;
            half _ColorTimes;
            half _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                i.uv.x += _XSpeed * _Time;
                i.uv.y += _YSpeed * _Time;

                half4 col = tex2D(_MainTex, i.uv)*_Color;
                clip(col.a-0.5);

                col += col*_ColorTimes;

                return col;
            }
            ENDCG
        }
    }
}
