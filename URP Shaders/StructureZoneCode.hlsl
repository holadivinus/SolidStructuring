// soooo this is the worst shader code ever,
// but it works for now

void StructureZoneFunc_float(float4 inUV, float camDist, out bool shouldClip, out float4 ColorOut) 
{
    float4 _uvA = _UVAdjust;
    float2 uv = inUV * _uvA;

    float span = camDist / 80;
    bool show = fmod(uv.y, span)-(span/2) > 0.0;
    bool show2 = fmod(uv.x, span)-(span/2) > 0.0;

    float4 col = _Color;

    // red edges
    float span2 = .01f;
    bool edgeHide = uv.x > span2 && uv.x < _uvA.x - span2;
    bool edgeHide2 = uv.y > span2 && uv.y < _uvA.y - span2;
    bool notRedEdge = edgeHide && edgeHide2;

    bool isColChange = false;
    bool isHoverEdge = false;
    if (_ShowAccessors) 
    {
        // box corners
        float4 mv = _MouseUV;
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

    shouldClip = ((!isColChange && notRedEdge) || (show || show2) && notRedEdge && !isHoverEdge);

    ColorOut = float4(col.x, col.y, col.z, col.w);
}