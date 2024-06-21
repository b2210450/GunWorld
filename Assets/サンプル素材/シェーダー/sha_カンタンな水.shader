Shader "MMW/EasyWaterShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (0, 0.3, 0.8, 1)
        _WaveScale("Wave Scale", Range(0.0, 3.0)) = 0.3
        _Speed("Speed", Range(0.0, 20.0)) = 5.0
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags {"Queue" = "Transparent"
        "RenderType" = "Transparent" }
        LOD 100
        //Cull Off

        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                half2 noise : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;

            half _Speed;
            half _WaveScale;
      

            float2 noiseFunc(float2 uvPos)
            {
                float2 result = float2(dot(uvPos, float2(127.1, 311.7)),dot(uvPos, float2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(result) * 43758.5453123);
            }   

            float cellularnoise(float2 st,float n) {
                st *= n;

                float2 ist = floor(st);
                float2 fst = frac(st);

                float distance = 5;

                for (int y = -1; y <= 1; y++)
                for (int x = -1; x <= 1; x++){
                    float2 neighbor = float2(x, y);
                    float2 p = 0.5 + 0.5 * sin(_Time.y + 6.2831 * noiseFunc(ist + neighbor));

                    float2 diff = neighbor + p - fst;
                    distance = min(distance, length(diff));
                }

                float color = distance * 0.5;

                return color;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                

                o.noise.x = cellularnoise(v.texcoord, 40);
                v.vertex.y += o.noise.x*_WaveScale;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= _Color;
                col.xyz = saturate(col.xyz+(i.noise.x*i.noise.x*i.noise.x*0.5+step(0.6,i.noise.x)*0.6)*_SpecColor);
                col.a += i.noise.x;
                //col.xyz = i.noise.x*i.noise.x;

                return col;
            }
            ENDCG
        }
    }
}
