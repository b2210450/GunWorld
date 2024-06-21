Shader "Custom/TransparentRimLight"
{
    Properties
    {
        _RimLightColor ("RimLightColor", Color) = (1,1,1,1)
        _Alpha("Alpha", float) = 0.5
        _LightTimes("LightTimes", float) = 2
        _LightStyle("LightStyle", Range(0.01, 5.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Pass
        {
            ZWrite ON
            ColorMask 0
        }

        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        ZWrite OFF
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
        		float3 normal : NORMAL;
            };

            struct v2f
            {
		        float4 vertex : SV_POSITION;
                float3 view : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            half _Alpha;
            fixed4 _RimLightColor;
            half _LightStyle;
            half _LightTimes;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view = normalize(UnityWorldSpaceViewDir(worldPos));

                o.normal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                half dotVal = 1-abs(dot(i.view, i.normal));
                col.a = saturate(dotVal * _Alpha);
                col.rgb = _RimLightColor.rgb * pow(dotVal, 1/_LightStyle) * _LightTimes;
                
                return col;
            }
            ENDCG
        }
    }
}