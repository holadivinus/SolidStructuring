Shader "Unlit/SolidStructuring/FallBack/StructureZone"
{
    Properties
    {
        _Color ("Grid Color", Color) = (1,0.7,0.7,1)
        _EdgeDragColor ("Edge Drag Color", Color) = (1,0.7,0.7,1)
        _CornerDragColor ("Corner Drag Color", Color) = (1,0.7,0.7,1)
        _HoverDragColor ("Hover Color", Color) = (1,0.7,0.7,1)
        _UVAdjust ("UV", Vector) = (1,1,0.0,0.0)
        [Toggle] _ShowAccessors ("Show Accessors", Integer) = 0
        _HoverEdge ("Hover Edge", Integer) = 0
        _EdgeSpan ("Edge Span", Float) = .1
        _MouseUV ("Mouse UV", Vector) = (1,1,0.0,0.0)
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
                float3 worldPos : TEXCOORD1;
            };


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, float4(0,0,0, 1.0)).xyz;
                return o;
            }

            fixed4 _Color;
            fixed4 _HoverDragColor;
            UNITY_INSTANCING_BUFFER_START(Props)
                UNITY_DEFINE_INSTANCED_PROP(float4, _UVAdjust)
                UNITY_DEFINE_INSTANCED_PROP(int, _HoverEdge)
            UNITY_INSTANCING_BUFFER_END(Props)

            fixed4 _EdgeDragColor;
            fixed4 _CornerDragColor;
            bool _ShowAccessors;
            float _EdgeSpan;
            fixed4 _MouseUV;

            #define PI 3.14159265359
            
            fixed4 frag (v2f i) : SV_Target
            {
                // soooo this is the worst shader code ever,
                // but it works for now

                float4 _uvA = UNITY_ACCESS_INSTANCED_PROP(Props, _UVAdjust);
                float2 uv = i.uv.xy * _uvA;

                float camDist = distance(i.worldPos, _WorldSpaceCameraPos);
                float span = camDist/100;
                bool show = fmod(uv.y, span)-(span/2) > 0.0;
                bool show2 = fmod(uv.x, span)-(span/2) > 0.0;

                fixed4 col;

                // red edges
                float span2 = .01f;
                bool edgeHide = uv.x > span2 && uv.x < _uvA.x - span2;
                bool edgeHide2 = uv.y > span2 && uv.y < _uvA.y - span2;
                bool notRedEdge = edgeHide && edgeHide2;
                col = _Color;
                bool isColChange = false;

                bool isHoverEdge = false;
                if (_ShowAccessors) 
                {
                    // blue select-drag edge things

                    // box corners
                    fixed4 mv = _MouseUV;
                    float cubeSpan = _EdgeSpan * 2.5f;
                    bool cornerBottomLeft = uv.x < cubeSpan && uv.y < cubeSpan;                 bool mosBottomLeft = mv.x < cubeSpan && mv.y < cubeSpan;
                    bool cornerBottomRight = uv.x > _uvA.x - cubeSpan && uv.y < cubeSpan;       bool mosBottomRight = mv.x > _uvA.x - cubeSpan && mv.y < cubeSpan;
                    bool cornerTopLeft = uv.x < cubeSpan && uv.y > _uvA.y - cubeSpan;           bool mosTopLeft = mv.x < cubeSpan && mv.y > _uvA.y - cubeSpan;
                    bool cornerTopRight = uv.x > _uvA.x - cubeSpan && uv.y > _uvA.y - cubeSpan; bool mosTopRight = mv.x > _uvA.x - cubeSpan && mv.y > _uvA.y - cubeSpan;

                    // edges
                    float span3 = _EdgeSpan;
                    bool edgeLeft = uv.x < span3;           bool mosLeft = mv.x < span3 && !mosBottomLeft && !mosTopLeft;
                    bool edgeRight = uv.x > _uvA.x - span3; bool mosRight = mv.x > _uvA.x - span3 && !mosBottomRight && !mosTopRight;
                    bool edgeDown = uv.y < span3;           bool mosDown = mv.y < span3 && !mosBottomLeft && !mosBottomRight;
                    bool edgeUp = uv.y > _uvA.y - span3;    bool mosUp = mv.y > _uvA.y - span3 && !mosTopLeft && !mosTopRight;


                    if (edgeLeft | edgeRight | edgeDown | edgeUp)
                    {
                        col = _EdgeDragColor;
                        isColChange = true;
                    }
                    if (cornerBottomLeft | cornerBottomRight | cornerTopLeft | cornerTopRight)
                    {
                        col = _CornerDragColor;
                        isColChange = true;
                    }


                    isHoverEdge = (edgeLeft && mosLeft && !cornerTopLeft && !cornerBottomLeft) 
                                | (edgeRight && mosRight && !cornerTopRight && !cornerBottomRight) 
                                | (edgeDown && mosDown && !cornerBottomLeft && !cornerBottomRight) 
                                | (edgeUp && mosUp && !cornerTopLeft && !cornerTopRight)
                                | (cornerBottomLeft && mosBottomLeft)
                                | (cornerBottomRight && mosBottomRight)
                                | (cornerTopLeft && mosTopLeft)
                                | (cornerTopRight && mosTopRight);
                    if (isHoverEdge) 
                    {
                        col = _HoverDragColor;
                        isColChange = true;
                    }
                }

                if (!isColChange && notRedEdge) clip(-1.0);

                if ((show || show2) && notRedEdge && !isHoverEdge)
                    clip(-1.0);

                return col;
            }
            ENDCG
        }
    }
}
