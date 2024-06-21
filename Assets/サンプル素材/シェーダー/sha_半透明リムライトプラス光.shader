Shader "Custom/TransparentRimLightPlus"
{
    Properties
    {
        _RimLightColor ("RimLightColor", Color) = (1,1,1,1)
        _SubLightColor ("SubLightColor", Color) = (1,1,1,1)
        _Alpha("Alpha", float) = 0.5
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
                float3 worldPos: TEXCOORD0;
                float3 view : TEXCOORD1;
                float3 normal : TEXCOORD2;
            };

            half _Alpha;
            fixed4 _RimLightColor;
            fixed4 _SubLightColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.view = normalize(UnityWorldSpaceViewDir(o.worldPos));
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 halfDir = normalize(lightDir + i.view);

                half spec = saturate(pow( max(dot(i.normal, halfDir),0), 24)*4);

                fixed4 col;
                half dotVal = 1-abs(dot(i.view, i.normal));
                col.a = saturate(dotVal * _Alpha)+spec;
                col.rgb = saturate(_RimLightColor.rgb+half3(spec,spec,spec)*_SubLightColor);
                
                return col;
            }
            ENDCG
        }
    }
}