Shader "Water_Gerstner_ZWrite_On"
{
    Properties
    {
        Wave_A("Wave_A", Vector) = (1, 1, 25, 60)
        Wave_B("Wave_B", Vector) = (1, 1, 25, 60)
        Wave_C("Wave_C", Vector) = (0, 0, 0, 0)
        Wave_D("Wave_D", Vector) = (0, 0, 0, 0)
        TopColor("TopColor", Color) = (0.05807226, 0.5214607, 0.8207547, 0)
        BottomColor("BottomColor", Color) = (0.1249555, 0.1344851, 0.2264151, 0)
        ShallowColor("ShallowColor", Color) = (0, 0, 0, 0)
        DepthColorFade("DepthColorFade", Float) = 2
        DepthColorOffset("DepthColorOffset", Float) = 0
        DepthDistance("DepthDistance", Float) = 0
        [NoScaleOffset]NormalMap("NormalMap", 2D) = "white" {}
        NormalStrength("NormalStrength", Float) = 0
        NormalTiling_A("NormalTiling_A", Float) = 0
        NormalPanningDirection_A("NormalPanningDirection_A", Vector) = (0, 0, 0, 0)
        NormalTiling_B("NormalTiling_B", Float) = 0
        NormalPanningDirection_B("NormalPanningDirection_B", Vector) = (0, 0, 0, 0)
        NormalPanningSpeed("NormalPanningSpeed", Range(0, 1)) = 0
        RefractionStrength("RefractionStrength", Float) = 0
        RefractionSpeed("RefractionSpeed", Float) = 0
        RefractionScale("RefractionScale", Float) = 0
        FoamDistance("FoamDistance", Float) = 1
        FoamStrength("FoamStrength", Float) = 1
        FoamTiling("FoamTiling", Float) = 1
        Smoothness("Smoothness", Float) = 0
        _Specular("Specular", Range(0, 0.5)) = 0
        [NoScaleOffset]FoamTexture("FoamTexture", 2D) = "white" {}
        FoamTextureSpeed("FoamTextureSpeed", Vector) = (0, 0, 0, 0)
        FoamTextureColor("FoamTextureColor", Color) = (1, 1, 1, 0)
        FoamTextureTiling("FoamTextureTiling", Float) = 1
        FoamTextureHeight("FoamTextureHeight", Float) = 0
        FoamTextureBlendPower("FoamTextureBlendPower", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

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
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            UnityTexture2D _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_18e9eefd3d9c421280b4bd584405280f_Out_0 = NormalTiling_A;
            float _Split_5cc95bde39044565b5a685a605fee516_R_1 = IN.WorldSpacePosition[0];
            float _Split_5cc95bde39044565b5a685a605fee516_G_2 = IN.WorldSpacePosition[1];
            float _Split_5cc95bde39044565b5a685a605fee516_B_3 = IN.WorldSpacePosition[2];
            float _Split_5cc95bde39044565b5a685a605fee516_A_4 = 0;
            float2 _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0 = float2(_Split_5cc95bde39044565b5a685a605fee516_R_1, _Split_5cc95bde39044565b5a685a605fee516_B_3);
            float2 _Multiply_a63e69f715a34775aebd6798157667a3_Out_2;
            Unity_Multiply_float((_Property_18e9eefd3d9c421280b4bd584405280f_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_a63e69f715a34775aebd6798157667a3_Out_2);
            float2 _Property_4461e5f25c184aa8a257646757f31527_Out_0 = NormalPanningDirection_A;
            float2 _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2;
            Unity_Multiply_float(_Property_4461e5f25c184aa8a257646757f31527_Out_0, (IN.TimeParameters.x.xx), _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2);
            float _Property_ede1244c48ae40818cec7b612331a1b9_Out_0 = NormalPanningSpeed;
            float2 _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2;
            Unity_Multiply_float(_Multiply_805d13bb40e24f848b49c74330546cf6_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2);
            float2 _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3;
            Unity_TilingAndOffset_float(_Multiply_a63e69f715a34775aebd6798157667a3_Out_2, float2 (1, 1), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            float4 _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0);
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_R_4 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.r;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_G_5 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.g;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_B_6 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.b;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_A_7 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.a;
            float _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0 = NormalStrength;
            float3 _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2);
            float _Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0 = NormalTiling_B;
            float2 _Multiply_b434e9937279465790037bb190fe3142_Out_2;
            Unity_Multiply_float((_Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_b434e9937279465790037bb190fe3142_Out_2);
            float2 _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0 = NormalPanningDirection_B;
            float2 _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0, _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2);
            float2 _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2;
            Unity_Multiply_float(_Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2);
            float2 _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3;
            Unity_TilingAndOffset_float(_Multiply_b434e9937279465790037bb190fe3142_Out_2, float2 (1, 1), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            float4 _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0);
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_R_4 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.r;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_G_5 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.g;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_B_6 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.b;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_A_7 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.a;
            float3 _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2);
            float3 _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            Unity_NormalBlend_float(_NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2, _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2);
            UnityTexture2D _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_c3695b09892b4d8299253a554862ded9_Out_0 = FoamTiling;
            float2 _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0 = FoamTextureSpeed;
            float2 _Multiply_968f8d4b816a430780f901975da35618_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0, _Multiply_968f8d4b816a430780f901975da35618_Out_2);
            float2 _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_c3695b09892b4d8299253a554862ded9_Out_0.xx), _Multiply_968f8d4b816a430780f901975da35618_Out_2, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float4 _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.tex, _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.samplerstate, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.r;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_G_5 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.g;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_B_6 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.b;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_A_7 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.a;
            float _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1);
            float _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2;
            Unity_Multiply_float(_SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1, _ProjectionParams.z, _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2);
            float4 _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0 = IN.ScreenPosition;
            float _Split_1389f8a43b974782a108f657b1902b81_R_1 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[0];
            float _Split_1389f8a43b974782a108f657b1902b81_G_2 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[1];
            float _Split_1389f8a43b974782a108f657b1902b81_B_3 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[2];
            float _Split_1389f8a43b974782a108f657b1902b81_A_4 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[3];
            float _Property_254de66547b74938a946b95dac8892dd_Out_0 = FoamDistance;
            float _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2;
            Unity_Subtract_float(_Split_1389f8a43b974782a108f657b1902b81_A_4, _Property_254de66547b74938a946b95dac8892dd_Out_0, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2);
            float _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2;
            Unity_Subtract_float(_Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2, _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2);
            float _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1;
            Unity_OneMinus_float(_Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2, _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1);
            float _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0 = FoamStrength;
            float _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2;
            Unity_Multiply_float(_OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1, _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2);
            float _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2;
            Unity_Multiply_float(_SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2, _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2);
            float _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3;
            Unity_Clamp_float(_Multiply_563f15cb647247dab93b7257ef58b39b_Out_2, 0, 1, _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3);
            float _Property_7e72be1cd66a4e118999b5c145a964d2_Out_0 = _Specular;
            float _Property_8240827f9f544e7495b84af7e501bcee_Out_0 = Smoothness;
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.NormalTS = _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            surface.Emission = (_Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3.xxx);
            surface.Specular = (_Property_7e72be1cd66a4e118999b5c145a964d2_Out_0.xxx);
            surface.Smoothness = _Property_8240827f9f544e7495b84af7e501bcee_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma multi_compile _ DOTS_INSTANCING_ON
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
        #pragma multi_compile _ _GBUFFER_NORMALS_OCT
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_GBUFFER
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

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
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            UnityTexture2D _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_18e9eefd3d9c421280b4bd584405280f_Out_0 = NormalTiling_A;
            float _Split_5cc95bde39044565b5a685a605fee516_R_1 = IN.WorldSpacePosition[0];
            float _Split_5cc95bde39044565b5a685a605fee516_G_2 = IN.WorldSpacePosition[1];
            float _Split_5cc95bde39044565b5a685a605fee516_B_3 = IN.WorldSpacePosition[2];
            float _Split_5cc95bde39044565b5a685a605fee516_A_4 = 0;
            float2 _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0 = float2(_Split_5cc95bde39044565b5a685a605fee516_R_1, _Split_5cc95bde39044565b5a685a605fee516_B_3);
            float2 _Multiply_a63e69f715a34775aebd6798157667a3_Out_2;
            Unity_Multiply_float((_Property_18e9eefd3d9c421280b4bd584405280f_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_a63e69f715a34775aebd6798157667a3_Out_2);
            float2 _Property_4461e5f25c184aa8a257646757f31527_Out_0 = NormalPanningDirection_A;
            float2 _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2;
            Unity_Multiply_float(_Property_4461e5f25c184aa8a257646757f31527_Out_0, (IN.TimeParameters.x.xx), _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2);
            float _Property_ede1244c48ae40818cec7b612331a1b9_Out_0 = NormalPanningSpeed;
            float2 _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2;
            Unity_Multiply_float(_Multiply_805d13bb40e24f848b49c74330546cf6_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2);
            float2 _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3;
            Unity_TilingAndOffset_float(_Multiply_a63e69f715a34775aebd6798157667a3_Out_2, float2 (1, 1), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            float4 _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0);
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_R_4 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.r;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_G_5 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.g;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_B_6 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.b;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_A_7 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.a;
            float _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0 = NormalStrength;
            float3 _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2);
            float _Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0 = NormalTiling_B;
            float2 _Multiply_b434e9937279465790037bb190fe3142_Out_2;
            Unity_Multiply_float((_Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_b434e9937279465790037bb190fe3142_Out_2);
            float2 _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0 = NormalPanningDirection_B;
            float2 _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0, _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2);
            float2 _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2;
            Unity_Multiply_float(_Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2);
            float2 _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3;
            Unity_TilingAndOffset_float(_Multiply_b434e9937279465790037bb190fe3142_Out_2, float2 (1, 1), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            float4 _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0);
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_R_4 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.r;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_G_5 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.g;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_B_6 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.b;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_A_7 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.a;
            float3 _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2);
            float3 _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            Unity_NormalBlend_float(_NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2, _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2);
            UnityTexture2D _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_c3695b09892b4d8299253a554862ded9_Out_0 = FoamTiling;
            float2 _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0 = FoamTextureSpeed;
            float2 _Multiply_968f8d4b816a430780f901975da35618_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0, _Multiply_968f8d4b816a430780f901975da35618_Out_2);
            float2 _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_c3695b09892b4d8299253a554862ded9_Out_0.xx), _Multiply_968f8d4b816a430780f901975da35618_Out_2, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float4 _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.tex, _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.samplerstate, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.r;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_G_5 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.g;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_B_6 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.b;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_A_7 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.a;
            float _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1);
            float _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2;
            Unity_Multiply_float(_SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1, _ProjectionParams.z, _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2);
            float4 _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0 = IN.ScreenPosition;
            float _Split_1389f8a43b974782a108f657b1902b81_R_1 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[0];
            float _Split_1389f8a43b974782a108f657b1902b81_G_2 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[1];
            float _Split_1389f8a43b974782a108f657b1902b81_B_3 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[2];
            float _Split_1389f8a43b974782a108f657b1902b81_A_4 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[3];
            float _Property_254de66547b74938a946b95dac8892dd_Out_0 = FoamDistance;
            float _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2;
            Unity_Subtract_float(_Split_1389f8a43b974782a108f657b1902b81_A_4, _Property_254de66547b74938a946b95dac8892dd_Out_0, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2);
            float _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2;
            Unity_Subtract_float(_Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2, _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2);
            float _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1;
            Unity_OneMinus_float(_Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2, _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1);
            float _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0 = FoamStrength;
            float _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2;
            Unity_Multiply_float(_OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1, _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2);
            float _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2;
            Unity_Multiply_float(_SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2, _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2);
            float _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3;
            Unity_Clamp_float(_Multiply_563f15cb647247dab93b7257ef58b39b_Out_2, 0, 1, _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3);
            float _Property_7e72be1cd66a4e118999b5c145a964d2_Out_0 = _Specular;
            float _Property_8240827f9f544e7495b84af7e501bcee_Out_0 = Smoothness;
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.NormalTS = _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            surface.Emission = (_Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3.xxx);
            surface.Specular = (_Property_7e72be1cd66a4e118999b5c145a964d2_Out_0.xxx);
            surface.Smoothness = _Property_8240827f9f544e7495b84af7e501bcee_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

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
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
            output.positionCS = input.positionCS;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

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
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
            output.positionCS = input.positionCS;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
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
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
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
            output.tangentWS = input.interp2.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_18e9eefd3d9c421280b4bd584405280f_Out_0 = NormalTiling_A;
            float _Split_5cc95bde39044565b5a685a605fee516_R_1 = IN.WorldSpacePosition[0];
            float _Split_5cc95bde39044565b5a685a605fee516_G_2 = IN.WorldSpacePosition[1];
            float _Split_5cc95bde39044565b5a685a605fee516_B_3 = IN.WorldSpacePosition[2];
            float _Split_5cc95bde39044565b5a685a605fee516_A_4 = 0;
            float2 _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0 = float2(_Split_5cc95bde39044565b5a685a605fee516_R_1, _Split_5cc95bde39044565b5a685a605fee516_B_3);
            float2 _Multiply_a63e69f715a34775aebd6798157667a3_Out_2;
            Unity_Multiply_float((_Property_18e9eefd3d9c421280b4bd584405280f_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_a63e69f715a34775aebd6798157667a3_Out_2);
            float2 _Property_4461e5f25c184aa8a257646757f31527_Out_0 = NormalPanningDirection_A;
            float2 _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2;
            Unity_Multiply_float(_Property_4461e5f25c184aa8a257646757f31527_Out_0, (IN.TimeParameters.x.xx), _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2);
            float _Property_ede1244c48ae40818cec7b612331a1b9_Out_0 = NormalPanningSpeed;
            float2 _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2;
            Unity_Multiply_float(_Multiply_805d13bb40e24f848b49c74330546cf6_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2);
            float2 _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3;
            Unity_TilingAndOffset_float(_Multiply_a63e69f715a34775aebd6798157667a3_Out_2, float2 (1, 1), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            float4 _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0);
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_R_4 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.r;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_G_5 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.g;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_B_6 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.b;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_A_7 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.a;
            float _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0 = NormalStrength;
            float3 _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2);
            float _Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0 = NormalTiling_B;
            float2 _Multiply_b434e9937279465790037bb190fe3142_Out_2;
            Unity_Multiply_float((_Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_b434e9937279465790037bb190fe3142_Out_2);
            float2 _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0 = NormalPanningDirection_B;
            float2 _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0, _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2);
            float2 _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2;
            Unity_Multiply_float(_Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2);
            float2 _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3;
            Unity_TilingAndOffset_float(_Multiply_b434e9937279465790037bb190fe3142_Out_2, float2 (1, 1), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            float4 _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0);
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_R_4 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.r;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_G_5 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.g;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_B_6 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.b;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_A_7 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.a;
            float3 _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2);
            float3 _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            Unity_NormalBlend_float(_NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2, _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2);
            surface.NormalTS = _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
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
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            UnityTexture2D _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_c3695b09892b4d8299253a554862ded9_Out_0 = FoamTiling;
            float2 _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0 = FoamTextureSpeed;
            float2 _Multiply_968f8d4b816a430780f901975da35618_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0, _Multiply_968f8d4b816a430780f901975da35618_Out_2);
            float2 _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_c3695b09892b4d8299253a554862ded9_Out_0.xx), _Multiply_968f8d4b816a430780f901975da35618_Out_2, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float4 _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.tex, _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.samplerstate, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.r;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_G_5 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.g;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_B_6 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.b;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_A_7 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.a;
            float _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1);
            float _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2;
            Unity_Multiply_float(_SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1, _ProjectionParams.z, _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2);
            float4 _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0 = IN.ScreenPosition;
            float _Split_1389f8a43b974782a108f657b1902b81_R_1 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[0];
            float _Split_1389f8a43b974782a108f657b1902b81_G_2 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[1];
            float _Split_1389f8a43b974782a108f657b1902b81_B_3 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[2];
            float _Split_1389f8a43b974782a108f657b1902b81_A_4 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[3];
            float _Property_254de66547b74938a946b95dac8892dd_Out_0 = FoamDistance;
            float _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2;
            Unity_Subtract_float(_Split_1389f8a43b974782a108f657b1902b81_A_4, _Property_254de66547b74938a946b95dac8892dd_Out_0, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2);
            float _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2;
            Unity_Subtract_float(_Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2, _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2);
            float _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1;
            Unity_OneMinus_float(_Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2, _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1);
            float _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0 = FoamStrength;
            float _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2;
            Unity_Multiply_float(_OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1, _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2);
            float _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2;
            Unity_Multiply_float(_SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2, _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2);
            float _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3;
            Unity_Clamp_float(_Multiply_563f15cb647247dab93b7257ef58b39b_Out_2, 0, 1, _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3);
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.Emission = (_Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3.xxx);
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Transparent"
            "UniversalMaterialType" = "Lit"
            "Queue"="Transparent"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
        #pragma multi_compile _ LIGHTMAP_ON
        #pragma multi_compile _ DIRLIGHTMAP_COMBINED
        #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
        #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
        #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
        #pragma multi_compile _ _SHADOWS_SOFT
        #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
        #pragma multi_compile _ SHADOWS_SHADOWMASK
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

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
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
            float4 texCoord0;
            float3 viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            float2 lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 sh;
            #endif
            float4 fogFactorAndVertexLight;
            float4 shadowCoord;
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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 TangentSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
            float3 interp4 : TEXCOORD4;
            #if defined(LIGHTMAP_ON)
            float2 interp5 : TEXCOORD5;
            #endif
            #if !defined(LIGHTMAP_ON)
            float3 interp6 : TEXCOORD6;
            #endif
            float4 interp7 : TEXCOORD7;
            float4 interp8 : TEXCOORD8;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
            output.interp4.xyz =  input.viewDirectionWS;
            #if defined(LIGHTMAP_ON)
            output.interp5.xy =  input.lightmapUV;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.interp6.xyz =  input.sh;
            #endif
            output.interp7.xyzw =  input.fogFactorAndVertexLight;
            output.interp8.xyzw =  input.shadowCoord;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
            output.viewDirectionWS = input.interp4.xyz;
            #if defined(LIGHTMAP_ON)
            output.lightmapUV = input.interp5.xy;
            #endif
            #if !defined(LIGHTMAP_ON)
            output.sh = input.interp6.xyz;
            #endif
            output.fogFactorAndVertexLight = input.interp7.xyzw;
            output.shadowCoord = input.interp8.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float3 Specular;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            UnityTexture2D _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_18e9eefd3d9c421280b4bd584405280f_Out_0 = NormalTiling_A;
            float _Split_5cc95bde39044565b5a685a605fee516_R_1 = IN.WorldSpacePosition[0];
            float _Split_5cc95bde39044565b5a685a605fee516_G_2 = IN.WorldSpacePosition[1];
            float _Split_5cc95bde39044565b5a685a605fee516_B_3 = IN.WorldSpacePosition[2];
            float _Split_5cc95bde39044565b5a685a605fee516_A_4 = 0;
            float2 _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0 = float2(_Split_5cc95bde39044565b5a685a605fee516_R_1, _Split_5cc95bde39044565b5a685a605fee516_B_3);
            float2 _Multiply_a63e69f715a34775aebd6798157667a3_Out_2;
            Unity_Multiply_float((_Property_18e9eefd3d9c421280b4bd584405280f_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_a63e69f715a34775aebd6798157667a3_Out_2);
            float2 _Property_4461e5f25c184aa8a257646757f31527_Out_0 = NormalPanningDirection_A;
            float2 _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2;
            Unity_Multiply_float(_Property_4461e5f25c184aa8a257646757f31527_Out_0, (IN.TimeParameters.x.xx), _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2);
            float _Property_ede1244c48ae40818cec7b612331a1b9_Out_0 = NormalPanningSpeed;
            float2 _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2;
            Unity_Multiply_float(_Multiply_805d13bb40e24f848b49c74330546cf6_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2);
            float2 _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3;
            Unity_TilingAndOffset_float(_Multiply_a63e69f715a34775aebd6798157667a3_Out_2, float2 (1, 1), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            float4 _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0);
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_R_4 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.r;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_G_5 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.g;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_B_6 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.b;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_A_7 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.a;
            float _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0 = NormalStrength;
            float3 _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2);
            float _Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0 = NormalTiling_B;
            float2 _Multiply_b434e9937279465790037bb190fe3142_Out_2;
            Unity_Multiply_float((_Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_b434e9937279465790037bb190fe3142_Out_2);
            float2 _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0 = NormalPanningDirection_B;
            float2 _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0, _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2);
            float2 _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2;
            Unity_Multiply_float(_Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2);
            float2 _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3;
            Unity_TilingAndOffset_float(_Multiply_b434e9937279465790037bb190fe3142_Out_2, float2 (1, 1), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            float4 _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0);
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_R_4 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.r;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_G_5 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.g;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_B_6 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.b;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_A_7 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.a;
            float3 _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2);
            float3 _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            Unity_NormalBlend_float(_NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2, _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2);
            UnityTexture2D _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_c3695b09892b4d8299253a554862ded9_Out_0 = FoamTiling;
            float2 _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0 = FoamTextureSpeed;
            float2 _Multiply_968f8d4b816a430780f901975da35618_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0, _Multiply_968f8d4b816a430780f901975da35618_Out_2);
            float2 _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_c3695b09892b4d8299253a554862ded9_Out_0.xx), _Multiply_968f8d4b816a430780f901975da35618_Out_2, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float4 _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.tex, _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.samplerstate, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.r;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_G_5 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.g;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_B_6 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.b;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_A_7 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.a;
            float _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1);
            float _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2;
            Unity_Multiply_float(_SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1, _ProjectionParams.z, _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2);
            float4 _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0 = IN.ScreenPosition;
            float _Split_1389f8a43b974782a108f657b1902b81_R_1 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[0];
            float _Split_1389f8a43b974782a108f657b1902b81_G_2 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[1];
            float _Split_1389f8a43b974782a108f657b1902b81_B_3 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[2];
            float _Split_1389f8a43b974782a108f657b1902b81_A_4 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[3];
            float _Property_254de66547b74938a946b95dac8892dd_Out_0 = FoamDistance;
            float _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2;
            Unity_Subtract_float(_Split_1389f8a43b974782a108f657b1902b81_A_4, _Property_254de66547b74938a946b95dac8892dd_Out_0, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2);
            float _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2;
            Unity_Subtract_float(_Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2, _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2);
            float _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1;
            Unity_OneMinus_float(_Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2, _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1);
            float _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0 = FoamStrength;
            float _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2;
            Unity_Multiply_float(_OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1, _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2);
            float _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2;
            Unity_Multiply_float(_SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2, _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2);
            float _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3;
            Unity_Clamp_float(_Multiply_563f15cb647247dab93b7257ef58b39b_Out_2, 0, 1, _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3);
            float _Property_7e72be1cd66a4e118999b5c145a964d2_Out_0 = _Specular;
            float _Property_8240827f9f544e7495b84af7e501bcee_Out_0 = Smoothness;
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.NormalTS = _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            surface.Emission = (_Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3.xxx);
            surface.Specular = (_Property_7e72be1cd66a4e118999b5c145a964d2_Out_0.xxx);
            surface.Smoothness = _Property_8240827f9f544e7495b84af7e501bcee_Out_0;
            surface.Occlusion = 1;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale
            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

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
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #pragma multi_compile _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
            output.positionCS = input.positionCS;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

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
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
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
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
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
            output.positionCS = input.positionCS;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv1 : TEXCOORD1;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
            float3 normalWS;
            float4 tangentWS;
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
            float3 TangentSpaceNormal;
            float3 WorldSpacePosition;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
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
            output.tangentWS = input.interp2.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
        {
            Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 NormalTS;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_18e9eefd3d9c421280b4bd584405280f_Out_0 = NormalTiling_A;
            float _Split_5cc95bde39044565b5a685a605fee516_R_1 = IN.WorldSpacePosition[0];
            float _Split_5cc95bde39044565b5a685a605fee516_G_2 = IN.WorldSpacePosition[1];
            float _Split_5cc95bde39044565b5a685a605fee516_B_3 = IN.WorldSpacePosition[2];
            float _Split_5cc95bde39044565b5a685a605fee516_A_4 = 0;
            float2 _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0 = float2(_Split_5cc95bde39044565b5a685a605fee516_R_1, _Split_5cc95bde39044565b5a685a605fee516_B_3);
            float2 _Multiply_a63e69f715a34775aebd6798157667a3_Out_2;
            Unity_Multiply_float((_Property_18e9eefd3d9c421280b4bd584405280f_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_a63e69f715a34775aebd6798157667a3_Out_2);
            float2 _Property_4461e5f25c184aa8a257646757f31527_Out_0 = NormalPanningDirection_A;
            float2 _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2;
            Unity_Multiply_float(_Property_4461e5f25c184aa8a257646757f31527_Out_0, (IN.TimeParameters.x.xx), _Multiply_805d13bb40e24f848b49c74330546cf6_Out_2);
            float _Property_ede1244c48ae40818cec7b612331a1b9_Out_0 = NormalPanningSpeed;
            float2 _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2;
            Unity_Multiply_float(_Multiply_805d13bb40e24f848b49c74330546cf6_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2);
            float2 _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3;
            Unity_TilingAndOffset_float(_Multiply_a63e69f715a34775aebd6798157667a3_Out_2, float2 (1, 1), _Multiply_a4332c640fc7409bb1b8c455ba382928_Out_2, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            float4 _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_b85c798d467e4b39bff7fb49689cfc25_Out_3);
            _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0);
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_R_4 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.r;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_G_5 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.g;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_B_6 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.b;
            float _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_A_7 = _SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.a;
            float _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0 = NormalStrength;
            float3 _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_2257b24cb3034e3bb50047c9b2e0edf3_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2);
            float _Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0 = NormalTiling_B;
            float2 _Multiply_b434e9937279465790037bb190fe3142_Out_2;
            Unity_Multiply_float((_Property_fa2bc5ae536e43a2bc11689e16102bf1_Out_0.xx), _Vector2_85e0c4b4042d4efaba104797834dd3d4_Out_0, _Multiply_b434e9937279465790037bb190fe3142_Out_2);
            float2 _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0 = NormalPanningDirection_B;
            float2 _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_3cebc084c15e4f569c649f36fa77c5b3_Out_0, _Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2);
            float2 _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2;
            Unity_Multiply_float(_Multiply_6033eb10f8d94e2d94b8ccdbe7a707b8_Out_2, (_Property_ede1244c48ae40818cec7b612331a1b9_Out_0.xx), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2);
            float2 _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3;
            Unity_TilingAndOffset_float(_Multiply_b434e9937279465790037bb190fe3142_Out_2, float2 (1, 1), _Multiply_8e36b156541e432fae9f02ff30c28dc8_Out_2, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            float4 _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0 = SAMPLE_TEXTURE2D(_Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.tex, _Property_8f4680b19f9e4c2d8796252be8436a55_Out_0.samplerstate, _TilingAndOffset_8f982c8959314938b3d30cffe1630db9_Out_3);
            _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0);
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_R_4 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.r;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_G_5 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.g;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_B_6 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.b;
            float _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_A_7 = _SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.a;
            float3 _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2;
            Unity_NormalStrength_float((_SampleTexture2D_bd5ea3a54d134a2e81cc8eecfe038b8b_RGBA_0.xyz), _Property_0d5747f633a94e4f90497e8eb35e3404_Out_0, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2);
            float3 _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            Unity_NormalBlend_float(_NormalStrength_ce421a18dece4fafbd6bf6bd68b6ea03_Out_2, _NormalStrength_2bacfe75aebd486095d8fb590a3e789b_Out_2, _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2);
            surface.NormalTS = _NormalBlend_d82f4385d78347f5a45afc17a12ddab5_Out_2;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition =          input.positionWS;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
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
        #pragma vertex vert
        #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_META
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS : NORMAL;
            float4 tangentOS : TANGENT;
            float4 uv0 : TEXCOORD0;
            float4 uv1 : TEXCOORD1;
            float4 uv2 : TEXCOORD2;
            #if UNITY_ANY_INSTANCING_ENABLED
            uint instanceID : INSTANCEID_SEMANTIC;
            #endif
        };
        struct Varyings
        {
            float4 positionCS : SV_POSITION;
            float3 positionWS;
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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

        void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
        {
            Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float3 Emission;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            UnityTexture2D _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_c3695b09892b4d8299253a554862ded9_Out_0 = FoamTiling;
            float2 _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0 = FoamTextureSpeed;
            float2 _Multiply_968f8d4b816a430780f901975da35618_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_4f2cfbb2bfbf44e6b7413fd1ba17da8a_Out_0, _Multiply_968f8d4b816a430780f901975da35618_Out_2);
            float2 _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_c3695b09892b4d8299253a554862ded9_Out_0.xx), _Multiply_968f8d4b816a430780f901975da35618_Out_2, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float4 _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0 = SAMPLE_TEXTURE2D(_Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.tex, _Property_f198ca03f4bf403faf01fe3363d5df06_Out_0.samplerstate, _TilingAndOffset_b2317e61c6184515974529c4d1c4777e_Out_3);
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.r;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_G_5 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.g;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_B_6 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.b;
            float _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_A_7 = _SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_RGBA_0.a;
            float _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1;
            Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1);
            float _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2;
            Unity_Multiply_float(_SceneDepth_e5d46fa9bd0c47a9a123ea6ef7516a00_Out_1, _ProjectionParams.z, _Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2);
            float4 _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0 = IN.ScreenPosition;
            float _Split_1389f8a43b974782a108f657b1902b81_R_1 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[0];
            float _Split_1389f8a43b974782a108f657b1902b81_G_2 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[1];
            float _Split_1389f8a43b974782a108f657b1902b81_B_3 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[2];
            float _Split_1389f8a43b974782a108f657b1902b81_A_4 = _ScreenPosition_f75dcd31d58f4108a441113ef209bfde_Out_0[3];
            float _Property_254de66547b74938a946b95dac8892dd_Out_0 = FoamDistance;
            float _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2;
            Unity_Subtract_float(_Split_1389f8a43b974782a108f657b1902b81_A_4, _Property_254de66547b74938a946b95dac8892dd_Out_0, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2);
            float _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2;
            Unity_Subtract_float(_Multiply_35f87b1289614c3c8ba09b6e85160a1a_Out_2, _Subtract_76506f6b6c54416b9139931da3bdfc16_Out_2, _Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2);
            float _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1;
            Unity_OneMinus_float(_Subtract_6b5d7d69c9f141ac87acff5c23a16aef_Out_2, _OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1);
            float _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0 = FoamStrength;
            float _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2;
            Unity_Multiply_float(_OneMinus_5359bdfdd70246d79f3a08c7315cfcd0_Out_1, _Property_f2a453db9e844e3f8bc9e4eee16aa656_Out_0, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2);
            float _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2;
            Unity_Multiply_float(_SampleTexture2D_591108e0675b424d992eb67dd5d8a6bd_R_4, _Multiply_988d5f1383ef43459cbb4fe3f9cc1c3d_Out_2, _Multiply_563f15cb647247dab93b7257ef58b39b_Out_2);
            float _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3;
            Unity_Clamp_float(_Multiply_563f15cb647247dab93b7257ef58b39b_Out_2, 0, 1, _Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3);
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.Emission = (_Clamp_f3da814e5f6b4926a40a0789ab66bf9c_Out_3.xxx);
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

            ENDHLSL
        }
        Pass
        {
            // Name: <None>
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // Render State
            Cull Off
        Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
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
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _SPECULAR_SETUP
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_2D
        #define REQUIRE_DEPTH_TEXTURE
        #define REQUIRE_OPAQUE_TEXTURE
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
        #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

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
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
            float3 WorldSpacePosition;
            float4 ScreenPosition;
            float4 uv0;
            float3 TimeParameters;
        };
        struct VertexDescriptionInputs
        {
            float3 ObjectSpaceNormal;
            float3 WorldSpaceNormal;
            float3 ObjectSpaceTangent;
            float3 WorldSpaceTangent;
            float3 ObjectSpaceBiTangent;
            float3 WorldSpaceBiTangent;
            float3 ObjectSpacePosition;
        };
        struct PackedVaryings
        {
            float4 positionCS : SV_POSITION;
            float3 interp0 : TEXCOORD0;
            float3 interp1 : TEXCOORD1;
            float4 interp2 : TEXCOORD2;
            float4 interp3 : TEXCOORD3;
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
            output.positionCS = input.positionCS;
            output.interp0.xyz =  input.positionWS;
            output.interp1.xyz =  input.normalWS;
            output.interp2.xyzw =  input.tangentWS;
            output.interp3.xyzw =  input.texCoord0;
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
            output.tangentWS = input.interp2.xyzw;
            output.texCoord0 = input.interp3.xyzw;
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
        float4 Wave_A;
        float4 Wave_B;
        float4 Wave_C;
        float4 Wave_D;
        float4 TopColor;
        float4 BottomColor;
        float4 ShallowColor;
        float DepthColorFade;
        float DepthColorOffset;
        float DepthDistance;
        float4 NormalMap_TexelSize;
        float NormalStrength;
        float NormalTiling_A;
        float2 NormalPanningDirection_A;
        float NormalTiling_B;
        float2 NormalPanningDirection_B;
        float NormalPanningSpeed;
        float RefractionStrength;
        float RefractionSpeed;
        float RefractionScale;
        float FoamDistance;
        float FoamStrength;
        float FoamTiling;
        float Smoothness;
        float _Specular;
        float4 FoamTexture_TexelSize;
        float2 FoamTextureSpeed;
        float4 FoamTextureColor;
        float FoamTextureTiling;
        float FoamTextureHeight;
        float FoamTextureBlendPower;
        CBUFFER_END

        // Object and Global properties
        SAMPLER(SamplerState_Linear_Repeat);
        TEXTURE2D(NormalMap);
        SAMPLER(samplerNormalMap);
        TEXTURE2D(FoamTexture);
        SAMPLER(samplerFoamTexture);

            // Graph Functions
            
        // 5f29a1470af875800e3353eb43022519
        #include "Assets/Shader/Wave_Gerstner.hlsl"

        void Unity_Add_float3(float3 A, float3 B, out float3 Out)
        {
            Out = A + B;
        }

        void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
        {
            Out = cross(A, B);
        }

        void Unity_Normalize_float3(float3 In, out float3 Out)
        {
            Out = normalize(In);
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        struct Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c
        {
            half4 uv0;
            float3 TimeParameters;
        };

        void SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(float Speed, float2 Scale, Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c IN, out float2 Out_Vector4_1)
        {
            float2 _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0 = Scale;
            float _Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0 = Speed;
            float _Multiply_090d001668e2428e9945567a05835df5_Out_2;
            Unity_Multiply_float(_Property_8a78b482fb1f4f7f8b6b325cb5b25d5d_Out_0, IN.TimeParameters.x, _Multiply_090d001668e2428e9945567a05835df5_Out_2);
            float2 _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, _Property_ccf55df9f21e4b9a96f9cdb1fbcb6e41_Out_0, (_Multiply_090d001668e2428e9945567a05835df5_Out_2.xx), _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3);
            Out_Vector4_1 = _TilingAndOffset_46805d8b34fd4532b450bec2ba933ecd_Out_3;
        }

        void Unity_Negate_float(float In, out float Out)
        {
            Out = -1 * In;
        }

        void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
        {
            Out = SafeNormalize(float3(A.rg + B.rg, A.b * B.b));
        }

        void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
        {
            Out = A * B;
        }

        void Unity_SceneColor_float(float4 UV, out float3 Out)
        {
            Out = SHADERGRAPH_SAMPLE_SCENE_COLOR(UV.xy);
        }

        void Unity_Add_float(float A, float B, out float Out)
        {
            Out = A + B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Clamp_float(float In, float Min, float Max, out float Out)
        {
            Out = clamp(In, Min, Max);
        }

        void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
        {
            Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
        }

        void Unity_Subtract_float(float A, float B, out float Out)
        {
            Out = A - B;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        struct Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d
        {
            float4 ScreenPosition;
        };

        void SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(float Distance, Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d IN, out float Out_Vector4_1)
        {
            float _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1;
            Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1);
            float4 _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0 = IN.ScreenPosition;
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_R_1 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[0];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_G_2 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[1];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_B_3 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[2];
            float _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4 = _ScreenPosition_5f5f14a5ca154aa8b32dc8c54e2225d7_Out_0[3];
            float _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2;
            Unity_Subtract_float(_SceneDepth_6ca8daf579cd496e900133f9c1dced58_Out_1, _Split_032c3c82b5c74e078c46a4f68ce39c40_A_4, _Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2);
            float _Property_769b3f71c83240d88e57d26154a9e182_Out_0 = Distance;
            float _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2;
            Unity_Divide_float(_Subtract_d82bd3d8be744dabb335af06a3832f5a_Out_2, _Property_769b3f71c83240d88e57d26154a9e182_Out_0, _Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2);
            float _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
            Unity_Saturate_float(_Divide_d7bfe92a6d184a58b7620ad2bf53798c_Out_2, _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1);
            Out_Vector4_1 = _Saturate_0ad98f7a548f497a8c1263bebbe968fa_Out_1;
        }

        void Unity_Lerp_float3(float3 A, float3 B, float3 T, out float3 Out)
        {
            Out = lerp(A, B, T);
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Preview_float3(float3 In, out float3 Out)
        {
            Out = In;
        }

        void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Power_float(float A, float B, out float Out)
        {
            Out = pow(A, B);
        }

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Saturate_float3(float3 In, out float3 Out)
        {
            Out = saturate(In);
        }

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
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6, _Add_5f2e59b8def443d595aca165f68ec0a7_Out_2);
            float3 _Add_542613de38ce4efb91148ec126a20da7_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6, _Add_542613de38ce4efb91148ec126a20da7_Out_2);
            float3 _Add_b5505d118a234dcf974b377084cb1a56_Out_2;
            Unity_Add_float3(_Add_5f2e59b8def443d595aca165f68ec0a7_Out_2, _Add_542613de38ce4efb91148ec126a20da7_Out_2, _Add_b5505d118a234dcf974b377084cb1a56_Out_2);
            float3 _Add_56fc3e813720411d911beee907468731_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _Add_56fc3e813720411d911beee907468731_Out_2);
            float3 _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2);
            float3 _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2;
            Unity_Add_float3(_Add_56fc3e813720411d911beee907468731_Out_2, _Add_48420701a0264b9fb20a6bbd131d1b06_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2);
            float3 _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2;
            Unity_CrossProduct_float(_Add_b5505d118a234dcf974b377084cb1a56_Out_2, _Add_57ee5136fe4346afb6e4f1366123b01b_Out_2, _CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2);
            float3 _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            Unity_Normalize_float3(_CrossProduct_ce21797e95fe4cba9ec6ee30eba6f3d3_Out_2, _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1);
            description.Position = _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1;
            description.Normal = _Normalize_0e575bd700de4ef197f7f62cf9f94f99_Out_1;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

            // Graph Pixel
            struct SurfaceDescription
        {
            float3 BaseColor;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            UnityTexture2D _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0 = UnityBuildTexture2DStructNoScale(NormalMap);
            float _Property_6e4723be6f2447218170293956f7c5c2_Out_0 = RefractionSpeed;
            float _Property_e7ebba41293847a796c485c2fc20d797_Out_0 = RefractionScale;
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_ccb1b3e17d05487285608645167559fc;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.uv0 = IN.uv0;
            _TextureMovement_ccb1b3e17d05487285608645167559fc.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_ccb1b3e17d05487285608645167559fc, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            float4 _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_ccb1b3e17d05487285608645167559fc_OutVector4_1);
            _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0);
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_R_4 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.r;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_G_5 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.g;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_B_6 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.b;
            float _SampleTexture2D_f730489e38d2443aae5ae872058ef350_A_7 = _SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.a;
            float _Negate_050754ec00b741f1a374b86fe2251403_Out_1;
            Unity_Negate_float(_Property_6e4723be6f2447218170293956f7c5c2_Out_0, _Negate_050754ec00b741f1a374b86fe2251403_Out_1);
            Bindings_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.uv0 = IN.uv0;
            _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e.TimeParameters = IN.TimeParameters;
            float2 _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1;
            SG_TextureMovement_9610fdb99b16f7e4081b6f2b7a6bf59c(_Negate_050754ec00b741f1a374b86fe2251403_Out_1, (_Property_e7ebba41293847a796c485c2fc20d797_Out_0.xx), _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            float4 _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0 = SAMPLE_TEXTURE2D(_Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.tex, _Property_b6ecbce13e5f45ee83bda2b285706875_Out_0.samplerstate, _TextureMovement_4ef434b0bdea41dd962ecab6df3f689e_OutVector4_1);
            _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.rgb = UnpackNormal(_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0);
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_R_4 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.r;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_G_5 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.g;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_B_6 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.b;
            float _SampleTexture2D_b93aeb280684472992c84bdbab656d41_A_7 = _SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.a;
            float3 _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2;
            Unity_NormalBlend_float((_SampleTexture2D_f730489e38d2443aae5ae872058ef350_RGBA_0.xyz), (_SampleTexture2D_b93aeb280684472992c84bdbab656d41_RGBA_0.xyz), _NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2);
            float _Property_9a762a55da8d4116b73388e0eb051a36_Out_0 = RefractionStrength;
            float _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2;
            Unity_Multiply_float(_Property_9a762a55da8d4116b73388e0eb051a36_Out_0, 0.2, _Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2);
            float3 _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2;
            Unity_Multiply_float(_NormalBlend_8d6c29f87ffa4666bad4350f83978db4_Out_2, (_Multiply_553bf27c3a7f4a69b505202b77bc56ec_Out_2.xxx), _Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2);
            float4 _ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float3 _Add_20834d4ba3b54a168292652980a8d686_Out_2;
            Unity_Add_float3(_Multiply_3c5447dd3b42499dbb7d1409d8dc1409_Out_2, (_ScreenPosition_84fc52bdf50e4f648d03ea1fc0947c5a_Out_0.xyz), _Add_20834d4ba3b54a168292652980a8d686_Out_2);
            float3 _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1;
            Unity_SceneColor_float((float4(_Add_20834d4ba3b54a168292652980a8d686_Out_2, 1.0)), _SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1);
            float4 _Property_f8ebab114787412e8b27347759a1a4d1_Out_0 = ShallowColor;
            float4 _Property_4961ad10d9424ebc8e637ece79c4c507_Out_0 = BottomColor;
            float4 _Property_e5cf458544834565bf98d6edf12dfac1_Out_0 = TopColor;
            float _Property_d196c10aa96c408e965181a9ccfb6cba_Out_0 = DepthColorOffset;
            float _Split_d715a2afa06d4ebc973240024b3b7074_R_1 = IN.ObjectSpacePosition[0];
            float _Split_d715a2afa06d4ebc973240024b3b7074_G_2 = IN.ObjectSpacePosition[1];
            float _Split_d715a2afa06d4ebc973240024b3b7074_B_3 = IN.ObjectSpacePosition[2];
            float _Split_d715a2afa06d4ebc973240024b3b7074_A_4 = 0;
            float _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2;
            Unity_Add_float(_Property_d196c10aa96c408e965181a9ccfb6cba_Out_0, _Split_d715a2afa06d4ebc973240024b3b7074_G_2, _Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2);
            float _Property_1f694e06986946928e77df779d625109_Out_0 = DepthColorFade;
            float _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2;
            Unity_Divide_float(_Add_228d7a1d300944ab8a11501e2cddf3fa_Out_2, _Property_1f694e06986946928e77df779d625109_Out_0, _Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2);
            float _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3;
            Unity_Clamp_float(_Divide_15697bcfcf1d43bb81d96a01bf303ff5_Out_2, 0, 1, _Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3);
            float4 _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3;
            Unity_Lerp_float4(_Property_4961ad10d9424ebc8e637ece79c4c507_Out_0, _Property_e5cf458544834565bf98d6edf12dfac1_Out_0, (_Clamp_951a8dc6a8c844aaaff2dfba2ede4b9d_Out_3.xxxx), _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3);
            float _Property_b176c803a5234a7f95d54b336af8bbd6_Out_0 = DepthDistance;
            Bindings_DepthFadeBasic_8db2196e82620c4439d23257fb09794d _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce;
            _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce.ScreenPosition = IN.ScreenPosition;
            float _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1;
            SG_DepthFadeBasic_8db2196e82620c4439d23257fb09794d(_Property_b176c803a5234a7f95d54b336af8bbd6_Out_0, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce, _DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1);
            float4 _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3;
            Unity_Lerp_float4(_Property_f8ebab114787412e8b27347759a1a4d1_Out_0, _Lerp_2a959c85bdc8452e959e2fe3a02454a7_Out_3, (_DepthFadeBasic_c2cfe6fbb9494950946b15a3d4e0b7ce_OutVector4_1.xxxx), _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3);
            float _Split_5419640f04404df48e4635d7eba4c29d_R_1 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[0];
            float _Split_5419640f04404df48e4635d7eba4c29d_G_2 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[1];
            float _Split_5419640f04404df48e4635d7eba4c29d_B_3 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[2];
            float _Split_5419640f04404df48e4635d7eba4c29d_A_4 = _Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3[3];
            float3 _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3;
            Unity_Lerp_float3(_SceneColor_58aa6d47e20a48e6b41bbb2681369bbd_Out_1, (_Lerp_0a3aaee0ea684e5298a33d2cc6cfb6d2_Out_3.xyz), (_Split_5419640f04404df48e4635d7eba4c29d_A_4.xxx), _Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3);
            UnityTexture2D _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0 = UnityBuildTexture2DStructNoScale(FoamTexture);
            float _Property_5785627fae604d21909124fc527ef629_Out_0 = FoamTextureTiling;
            float2 _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0 = FoamTextureSpeed;
            float2 _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2;
            Unity_Multiply_float((IN.TimeParameters.x.xx), _Property_54dca3e7b4cb4982bd1efee964f85edf_Out_0, _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2);
            float2 _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3;
            Unity_TilingAndOffset_float(IN.uv0.xy, (_Property_5785627fae604d21909124fc527ef629_Out_0.xx), _Multiply_50a72c56b90a4908bd0836b9b7cde0b2_Out_2, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float4 _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0 = SAMPLE_TEXTURE2D(_Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.tex, _Property_31ddf82e8ac545faad136d7f791b9e2d_Out_0.samplerstate, _TilingAndOffset_ebe2ce6608184922ad0081ff7001b5d2_Out_3);
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.r;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_G_5 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.g;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_B_6 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.b;
            float _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_A_7 = _SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_RGBA_0.a;
            float3 _Transform_5a94276883694c4381365c05e7274271_Out_1 = GetAbsolutePositionWS(TransformObjectToWorld(IN.ObjectSpacePosition.xyz));
            float4 _Property_425843bc872941149062893820db8c53_Out_0 = Wave_A;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5;
            float3 _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6;
            Wave_float(_Property_425843bc872941149062893820db8c53_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutTangent_5, _WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_OutBinormal_6);
            float4 _Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0 = Wave_B;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5;
            float3 _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6;
            Wave_float(_Property_8b6d9274a9ba4798a8cc796feb751f45_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutTangent_5, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_OutBinormal_6);
            float3 _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2;
            Unity_Add_float3(_WaveCustomFunction_dc2a08d986cb4cc7a197316eef13c39a_Out_1, _WaveCustomFunction_5dfb105a75f540cfa0ad78914181283d_Out_1, _Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2);
            float4 _Property_3893506383fc4a3aac6268e42855fb24_Out_0 = Wave_C;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5;
            float3 _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6;
            Wave_float(_Property_3893506383fc4a3aac6268e42855fb24_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutTangent_5, _WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_OutBinormal_6);
            float4 _Property_632b75ae21614814aee942dcf9adf161_Out_0 = Wave_D;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5;
            float3 _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6;
            Wave_float(_Property_632b75ae21614814aee942dcf9adf161_Out_0, _Transform_5a94276883694c4381365c05e7274271_Out_1, float3 (1, 0, 0), float3 (0, 0, 1), _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutTangent_5, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_OutBinormal_6);
            float3 _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2;
            Unity_Add_float3(_WaveCustomFunction_ba7ce0cfdd3d436db8215392ae1fbd0a_Out_1, _WaveCustomFunction_7b68abc3219546feb39d4c5c7ca490a0_Out_1, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2);
            float3 _Add_3a19c74b46f143fd8b3774987a7426df_Out_2;
            Unity_Add_float3(_Add_fc4c1a5bc72e4903a39f70d4f9fab178_Out_2, _Add_3d6cc2fb58044c238be85db4b7bcc81c_Out_2, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2);
            float3 _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2;
            Unity_Add_float3(_Transform_5a94276883694c4381365c05e7274271_Out_1, _Add_3a19c74b46f143fd8b3774987a7426df_Out_2, _Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2);
            float3 _Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1 = TransformWorldToObject(GetCameraRelativePositionWS(_Add_e5da5ad67d1d46f98e5c5518eda4779d_Out_2.xyz));
            float3 _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1;
            Unity_Preview_float3(_Transform_d4abf0d93be64a1fbd6019c83f7d95e5_Out_1, _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1);
            float _Split_8feb91dae334466c9c0efa0f366c3df3_R_1 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[0];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_G_2 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[1];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_B_3 = _Preview_c3e9f588c8104ecba0204430eec74a44_Out_1[2];
            float _Split_8feb91dae334466c9c0efa0f366c3df3_A_4 = 0;
            float _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0 = FoamTextureHeight;
            float _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3;
            Unity_Clamp_float(_Split_8feb91dae334466c9c0efa0f366c3df3_G_2, 0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0, _Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3);
            float2 _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0 = float2(0, _Property_31ef318d5adf4ee49faeda63dc10cf63_Out_0);
            float _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3;
            Unity_Remap_float(_Clamp_70373a0ec81c4df29f49ed918fa9932f_Out_3, _Vector2_409803760d38484bbd57a2eb79edb19c_Out_0, float2 (0, 1), _Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3);
            float _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0 = FoamTextureBlendPower;
            float _Power_92a297ff07d64df2896895c742dbcc43_Out_2;
            Unity_Power_float(_Remap_6531450635b844e5ae9fa6e7f3b55ad0_Out_3, _Property_8a852aa239eb4cd1b90bd7c86edd8a4c_Out_0, _Power_92a297ff07d64df2896895c742dbcc43_Out_2);
            float _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2;
            Unity_Power_float(_SampleTexture2D_5f4bfe9088294628b1a2ed1e0d4b24f0_R_4, _Power_92a297ff07d64df2896895c742dbcc43_Out_2, _Power_21577b3eeed7407e85123e5d2c75b02d_Out_2);
            float4 _Property_903516878f9a47f7a7e7140c249ed569_Out_0 = FoamTextureColor;
            float4 _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2;
            Unity_Multiply_float((_Power_21577b3eeed7407e85123e5d2c75b02d_Out_2.xxxx), _Property_903516878f9a47f7a7e7140c249ed569_Out_0, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2);
            float4 _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3;
            Unity_Lerp_float4(_Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, _Multiply_73127dacc7474de99f25915a37acd6e7_Out_2, (_Power_92a297ff07d64df2896895c742dbcc43_Out_2.xxxx), _Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3);
            float3 _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2;
            Unity_Add_float3(_Lerp_be1612de4956498fb24fd8b3b3714d74_Out_3, (_Lerp_5d86ed30ffbf4804a9d64bbd6193d625_Out_3.xyz), _Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2);
            float3 _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            Unity_Saturate_float3(_Add_a744a047805f44ecaa77d6a4fe51b36f_Out_2, _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1);
            surface.BaseColor = _Saturate_df6f3d6ecf77452a889210ac57313866_Out_1;
            surface.Alpha = 1;
            return surface;
        }

            // --------------------------------------------------
            // Build Graph Inputs

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal =           input.normalOS;
            output.WorldSpaceNormal =            TransformObjectToWorldNormal(input.normalOS);
            output.ObjectSpaceTangent =          input.tangentOS.xyz;
            output.WorldSpaceTangent =           TransformObjectToWorldDir(input.tangentOS.xyz);
            output.ObjectSpaceBiTangent =        normalize(cross(input.normalOS, input.tangentOS) * (input.tangentOS.w > 0.0f ? 1.0f : -1.0f) * GetOddNegativeScale());
            output.WorldSpaceBiTangent =         TransformObjectToWorldDir(output.ObjectSpaceBiTangent);
            output.ObjectSpacePosition =         input.positionOS;

            return output;
        }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);

            // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
            float3 unnormalizedNormalWS = input.normalWS;
            const float renormFactor = 1.0 / length(unnormalizedNormalWS);

            // use bitangent on the fly like in hdrp
            // IMPORTANT! If we ever support Flip on double sided materials ensure bitangent and tangent are NOT flipped.
            float crossSign = (input.tangentWS.w > 0.0 ? 1.0 : -1.0) * GetOddNegativeScale();
            float3 bitang = crossSign * cross(input.normalWS.xyz, input.tangentWS.xyz);

            output.WorldSpaceNormal =            renormFactor*input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
            output.ObjectSpaceNormal =           normalize(mul(output.WorldSpaceNormal, (float3x3) UNITY_MATRIX_M));           // transposed multiplication by inverse matrix to handle normal scale

            // to preserve mikktspace compliance we use same scale renormFactor as was used on the normal.
            // This is explained in section 2.2 in "surface gradient based bump mapping framework"
            output.WorldSpaceTangent =           renormFactor*input.tangentWS.xyz;
            output.WorldSpaceBiTangent =         renormFactor*bitang;

            output.ObjectSpaceTangent =          TransformWorldToObjectDir(output.WorldSpaceTangent);
            output.ObjectSpaceBiTangent =        TransformWorldToObjectDir(output.WorldSpaceBiTangent);
            output.WorldSpacePosition =          input.positionWS;
            output.ObjectSpacePosition =         TransformWorldToObject(input.positionWS);
            output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 =                         input.texCoord0;
            output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
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

            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

            ENDHLSL
        }
    }
    CustomEditorForRenderPipeline "ShaderGraph.PBRMasterGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    FallBack "Hidden/Shader Graph/FallbackError"
}