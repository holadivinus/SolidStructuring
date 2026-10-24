Shader "Unlit/SolidStructuring/StructureZone"
{
    Properties
    {
        _Color("Color", Color) = (0, 0, 0, 0)
        _EdgeDragColor("EdgeDragColor", Color) = (0, 0, 0, 0)
        _CornerDragColor("CornerDragColor", Color) = (0, 0, 0, 0)
        _HoverDragColor("HoverDragColor", Color) = (0, 0, 0, 0)
        _EdgeSpan("EdgeSpan", Float) = 0
        _UVAdjust("UVAdjust", Vector) = (0, 0, 0, 0)
        _MouseUV("MouseUV", Vector) = (0, 0, 0, 0)
        [ToggleUI]_ShowAccessors("ShowAccessors", Integer) = 0
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        PackageRequirements 
        {
            "com.unity.render-pipelines.core"
        }

        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            "DisableBatching"="true"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.BaseColor = (_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5.xyz);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 4.5
        #pragma exclude_renderers gles gles3 glcore
        #pragma multi_compile_instancing
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    SubShader
    {
        PackageRequirements 
        {
            "com.unity.render-pipelines.core"
        }

        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Unlit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            "DisableBatching"="true"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                // LightMode: <None>
            }
        
        // Render State
        Cull Back
        Blend One Zero
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma shader_feature _ _SAMPLE_GI
        #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
        #pragma multi_compile_fragment _ DEBUG_DISPLAY
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_POSITION_WS
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define VARYINGS_NEED_VIEWDIRECTION_WS
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_UNLIT
        #define _FOG_FRAGMENT 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 positionWS;
             float3 normalWS;
             float4 texCoord0;
             float3 viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float3 interp1 : INTERP1;
             float4 interp2 : INTERP2;
             float3 interp3 : INTERP3;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.texCoord0;
            output.interp3.xyz =  input.viewDirectionWS;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.positionWS = input.interp0.xyz;
            output.normalWS = input.interp1.xyz;
            output.texCoord0 = input.interp2.xyzw;
            output.viewDirectionWS = input.interp3.xyz;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.BaseColor = (_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5.xyz);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormalsOnly"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define ATTRIBUTES_NEED_TEXCOORD1
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TANGENT_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
             float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 tangentWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
             float4 interp2 : INTERP2;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.tangentWS;
            output.interp2.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.tangentWS = input.interp1.xyzw;
            output.texCoord0 = input.interp2.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        ColorMask 0
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_SHADOWCASTER
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "SceneSelectionPass"
            Tags
            {
                "LightMode" = "SceneSelectionPass"
            }
        
        // Render State
        Cull Off
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENESELECTIONPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "ScenePickingPass"
            Tags
            {
                "LightMode" = "Picking"
            }
        
        // Render State
        Cull Back
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHONLY
        #define SCENEPICKINGPASS 1
        #define ALPHA_CLIP_THRESHOLD 1
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float4 interp0 : INTERP0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.texCoord0 = input.interp0.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormalsOnly"
            }
        
        // Render State
        Cull Back
        ZTest LEqual
        ZWrite On
        
        // Debug
        // <None>
        
        // --------------------------------------------------
        // Pass
        
        HLSLPROGRAM
        
        // Pragmas
        #pragma target 2.0
        #pragma only_renderers gles gles3 glcore d3d11
        #pragma multi_compile_instancing
        #pragma multi_compile_fog
        #pragma instancing_options renderinglayer
        #pragma vertex vert
        #pragma fragment frag
        
        // DotsInstancingOptions: <None>
        // HybridV1InjectedBuiltinProperties: <None>
        
        // Keywords
        // PassKeywords: <None>
        // GraphKeywords: <None>
        
        // Defines
        
        #define ATTRIBUTES_NEED_NORMAL
        #define ATTRIBUTES_NEED_TANGENT
        #define ATTRIBUTES_NEED_TEXCOORD0
        #define VARYINGS_NEED_NORMAL_WS
        #define VARYINGS_NEED_TEXCOORD0
        #define FEATURES_GRAPH_VERTEX
        /* WARNING: $splice Could not find named fragment 'PassInstancing' */
        #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        #define _ALPHATEST_ON 1
        /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
        // custom interpolator pre-include
        /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
        // Includes
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
        // --------------------------------------------------
        // Structs and Packing
        
        // custom interpolators pre packing
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
        struct Attributes
        {
             float3 positionOS : POSITION;
             float3 normalOS : NORMAL;
             float4 tangentOS : TANGENT;
             float4 uv0 : TEXCOORD0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
             float4 positionCS : SV_POSITION;
             float3 normalWS;
             float4 texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        struct SurfaceDescriptionInputs
        {
             float4 uv0;
        };
        struct VertexDescriptionInputs
        {
             float3 ObjectSpaceNormal;
             float3 ObjectSpaceTangent;
             float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
             float4 positionCS : SV_POSITION;
             float3 interp0 : INTERP0;
             float4 interp1 : INTERP1;
            #if UNITY_ANY_INSTANCING_ENABLED
             uint instanceID : CUSTOM_INSTANCE_ID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
             uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
             uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
             FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
            #endif
        };
        
        PackedVaryings PackVaryings (Varyings input)
        {
            PackedVaryings output;
            ZERO_INITIALIZE(PackedVaryings, output);
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.normalWS;
            output.interp1.xyzw =  input.texCoord0;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        Varyings UnpackVaryings (PackedVaryings input)
        {
            Varyings output;
            output.positionCS = input.positionCS;
            output.normalWS = input.interp0.xyz;
            output.texCoord0 = input.interp1.xyzw;
            #if UNITY_ANY_INSTANCING_ENABLED
            output.instanceID = input.instanceID;
            #endif
            #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
            output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
            #endif
            #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
            output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
            #endif
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            output.cullFace = input.cullFace;
            #endif
            return output;
        }
        
        
        // --------------------------------------------------
        // Graph
        
        // Graph Properties
        CBUFFER_START(UnityPerMaterial)
        float4 _Color;
        float4 _EdgeDragColor;
        float4 _CornerDragColor;
        float4 _HoverDragColor;
        float _EdgeSpan;
        float4 _UVAdjust;
        float4 _MouseUV;
        float _ShowAccessors;
        CBUFFER_END
        
        // Object and Global properties
        
        // Graph Includes
        // GraphIncludes: <None>
        
        // -- Property used by ScenePickingPass
        #ifdef SCENEPICKINGPASS
        float4 _SelectionID;
        #endif
        
        // -- Properties used by SceneSelectionPass
        #ifdef SCENESELECTIONPASS
        int _ObjectId;
        int _PassValue;
        #endif
        
        // Graph Functions
        
        void Unity_Multiply_float3_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }
        
        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }
        
        void Unity_Distance_float3(float3 A, float3 B, out float Out)
        {
            Out = distance(A, B);
        }
        
        void StructureZoneFunc_float(float4 inUV, float3 camDist, out float shouldClip, out float4 ColorOut){
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
        
        void Unity_Branch_float(float Predicate, float True, float False, out float Out)
        {
            Out = Predicate ? True : False;
        }
        
        // Custom interpolators pre vertex
        /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };
        
        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            float3 _Multiply_e20266fac04f479897c437deabd2d878_Out_2;
            Unity_Multiply_float3_float3(IN.ObjectSpaceNormal, float3(0.0001, 0.0001, 0.0001), _Multiply_e20266fac04f479897c437deabd2d878_Out_2);
            float3 _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_e20266fac04f479897c437deabd2d878_Out_2, _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2);
            description.Position = _Add_6e394cc61c5d452e914e5f7bf20d2b57_Out_2;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }
        
        // Custom interpolators, pre surface
        #ifdef FEATURES_GRAPH_VERTEX
        Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
        {
        return output;
        }
        #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
        #endif
        
        // Graph Pixel
        struct SurfaceDescription
        {
            float Alpha;
            float AlphaClipThreshold;
        };
        
        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0 = IN.uv0;
            float _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2;
            Unity_Distance_float3(SHADERGRAPH_OBJECT_POSITION, _WorldSpaceCameraPos, _Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2);
            float _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4;
            float4 _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5;
            StructureZoneFunc_float(_UV_01a5f5dfadbe4fcf9816035dfcd27c4e_Out_0, (_Distance_ecc6a6f7a00b4009be0d2dc32c29efb0_Out_2.xxx), _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, _StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_ColorOut_5);
            float _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            Unity_Branch_float(_StructureZoneFuncCustomFunction_1866ce38f2414db895c7b1ea783f7c12_shouldClip_4, 0, 1, _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3);
            surface.Alpha = _Branch_18581b45c5d148d2b43c3e29f8b78787_Out_3;
            surface.AlphaClipThreshold = 0.5;
            return surface;
        }
        
        // --------------------------------------------------
        // Build Graph Inputs
        #ifdef HAVE_VFX_MODIFICATION
        #define VFX_SRP_ATTRIBUTES Attributes
        #define VFX_SRP_VARYINGS Varyings
        #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
        #endif
        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
            output.ObjectSpaceNormal =                          input.normalOS;
            output.ObjectSpaceTangent =                         input.tangentOS.xyz;
            output.ObjectSpacePosition =                        input.positionOS;
        
            return output;
        }
        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
        #ifdef HAVE_VFX_MODIFICATION
            // FragInputs from VFX come from two places: Interpolator or CBuffer.
            /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
        
        #endif
        
            
        
        
        
        
        
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
        }
        
        // --------------------------------------------------
        // Main
        
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
        
        // --------------------------------------------------
        // Visual Effect Vertex Invocations
        #ifdef HAVE_VFX_MODIFICATION
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
        #endif
        
        ENDHLSL
        }
    }
    //CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    //CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Unlit/SolidStructuring/FallBack/StructureZone"
}