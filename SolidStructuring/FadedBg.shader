Shader "Unlit/FadedBg"
{
    Properties
    {
        _Color ("Color", Color) = (1,0.7,0.7,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                float3 displacedVertex = v.vertex.xyz + v.normal * -.001;
                o.vertex = UnityObjectToClipPos(float4(displacedVertex, 1.0));
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                if (((i.uv.x) * 1000) % 1.25 < 1)
                    clip(-1.0);
                if (((i.uv.y) * 1000) % 1.25 < 1)
                    clip(-1.0);
                return _Color;
            }
            ENDCG
        }
    }
}
