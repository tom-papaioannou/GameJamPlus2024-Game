Shader "VFX/VFXMasterShaderTransparentEmissive"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientMap("Gradient map", 2D) = "white" {} 
        [HDR]_Color("Color", Color) = (1,1,1,1)
 
        //Secondary texture
        [Space(20)]
        [Toggle(SECONDARY_TEX)]
        _SecondTex("Second texture", float) = 0
        _SecondaryTex("Secondary texture", 2D) = "white" {}
        _SecondaryPanningSpeed("Secondary panning speed", Vector) = (0,0,0,0)
         
        _PanningSpeed("Panning speed (XY main texture - ZW displacement texture)", Vector) = (0,0,0,0)
		_ScrollingSpeed("Scrolling Speed", Vector) = (0,0,0,0)
        _Contrast("Contrast", float) = 1
        _Power("Power", float) = 1
		
		_Emissive("Emissive", Range(1,5)) = 1.0
		_Glow ("Glow", Range(0.1, 10)) = 1
 
        //Clipping
        [Space(20)]
        _Cutoff("Cutoff", Range(0, 1)) = 0
        _CutoffSoftness("Cutoff softness", Range(0, 1)) = 0
        [HDR]_BurnCol("Burn color", Color) = (1,1,1,1)
        _BurnSize("Burn size", float) = 0
 
        //Softness
        [Space(20)]
        [Toggle(SOFT_BLEND)]
        _SoftBlend("Soft blending", float) = 0
        _IntersectionThresholdMax("Intersection Threshold Max", float) = 1
         
        //Vertex offset
        [Space(20)]
        [Toggle(VERTEX_OFFSET)]
        _VertexOffset("Vertex offset", float) = 0
        _VertexOffsetAmount("Vertex offset amount", float) = 0
 
        //Displacement
        [Space(20)]
        _DisplacementAmount("Displacement", float) = 0
        _DisplacementGuide("DisplacementGuide", 2D) = "white" {}
         
        //Culling
        [Space(20)]
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Cull Mode", Int) = 2
 
        //Banding
        [Space(20)]
        [Toggle(BANDING)]
        _Banding("Color banding", float) = 0
        _Bands("Number of bands", float) = 3
 
        //Polar coordinates
        [Space(20)]
        [Toggle(POLAR)]
        _PolarCoords("Polar coordinates", float) = 0
 
        //Circle mask
        [Space(20)]
        [Toggle(CIRCLE_MASK)]
        _CircleMask("Circle mask", float) = 0
        _OuterRadius("Outer radius", Range(0,1)) = 0.5
        _InnerRadius("Inner radius", Range(-1,1)) = 0
        _Smoothness("Smoothness", Range(0,1)) = 0.2
 
        //Rect mask
        [Space(20)]
        [Toggle(RECT_MASK)]
        _RectMask("Rectangle mask", float) = 0
        _RectWidth("Rectangle width", float) = 0
        _RectHeight("Rectangle height", float) = 0
        _RectMaskCutoff("Rectangle mask cutoff", Range(0,1)) = 0
        _RectSmoothness("Rectangle mask smoothness", Range(0,1)) = 0 

		//Tilemap mask
		[Space(20)]
		[Toggle(TILEMAP_MASK)]
		_TilemapMask("Tilemap mask", float) = 0
		_TilemapMaskCenter ("Tilemap Mask Center", Vector) = (0, 0, 0, 0)
        _TilemapMaskRadius ("Tilemap Mask Radius", Float) = 1.0
		
		//Outlining
        [Space(20)]
		[Toggle(OUTLINE)]
		_Outline("Outline", float) = 0
		_OutlineThickness("Outline Thickness", float) = 0.1
		_OutlineThreshold("Outline Threshold", float) = 0.1
		[HDR]_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		
		//Pixelization
		[Space(20)]
		[Toggle(PIXELIZATION)]
		_Pixelization("Pixelization", float) = 0
		_PixelSize("Pixel Size", float) = 16
		
		//AlphaOutsideControl
		[Space(20)]
		[Toggle(ALPHAOUTSIDECONTROL)]
		_AlphaOutsideControl("Alpha Outside Control", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        //Offset -1, -1
        Cull [_Culling]
        LOD 100
 
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature SECONDARY_TEX
            #pragma shader_feature VERTEX_OFFSET
            #pragma shader_feature SOFT_BLEND
            #pragma shader_feature BANDING
            #pragma shader_feature POLAR
            #pragma shader_feature CIRCLE_MASK
            #pragma shader_feature RECT_MASK
			#pragma shader_feature TILEMAP_MASK
			#pragma shader_feature OUTLINE
			#pragma shader_feature PIXELIZATION
			#pragma shader_feature ALPHAOUTSIDECONTROL
            // make fog work
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
                float3 normal : NORMAL;
            };
 
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float2 displUV : TEXCOORD2;
                float2 secondaryUV : TEXCOORD3;
                float4 scrPos : TEXCOORD4;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
				float4 worldPos : TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            sampler2D _GradientMap;
            float _Contrast;
            float _Power;
			float _Emissive;
			float _Glow;
 
            fixed4 _Color;
 
            float _Bands;
 
            float4 _PanningSpeed;
            float4 _SecondaryPanningSpeed;
			float4 _ScrollingSpeed;
             
            float _Cutoff;
            float _CutoffSoftness;
            fixed4 _BurnCol;
            float _BurnSize;
 
            sampler2D _CameraDepthTexture;
            float _IntersectionThresholdMax;
 
            float _VertexOffsetAmount;
 
            sampler2D _DisplacementGuide;
            float4 _DisplacementGuide_ST;
            float _DisplacementAmount;
 
            float _Smoothness;
            float _OuterRadius;
            float _InnerRadius;
 
            float _RectSmoothness;
            float _RectHeight;
            float _RectWidth;
            float _RectMaskCutoff;
			
			float4 _TilemapMaskCenter;
            float _TilemapMaskRadius;
			
			float _OutlineThickness;
			float _OutlineThreshold;
			fixed4 _OutlineColor;
			
			float _PixelSize;
			
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.secondaryUV = TRANSFORM_TEX(v.uv, _SecondaryTex);
 
                #ifdef VERTEX_OFFSET
                float vertOffset = tex2Dlod(_MainTex, float4(o.uv + _Time.y * _PanningSpeed.xy, 1, 1)).x;
                #ifdef SECONDARY_TEX
                float secondTex = tex2Dlod(_SecondaryTex, float4(o.secondaryUV + _Time.y * _SecondaryPanningSpeed.xy, 1, 1)).x;
                vertOffset = vertOffset * secondTex * 2;
                #endif
                vertOffset = ((vertOffset * 2) - 1) * _VertexOffsetAmount;
                v.vertex.xyz += vertOffset * v.normal;
                #endif
 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.displUV = TRANSFORM_TEX(v.uv, _DisplacementGuide);
                o.scrPos = ComputeScreenPos(o.vertex);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o,o.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
			
            fixed4 frag (v2f i) : SV_Target
            {
 
				float2 panningOffset = frac(_ScrollingSpeed.xy * _Time.y);
                // sample the texture
                float2 uv = i.uv+panningOffset;
				
                float2 displUV = i.displUV;
                float2 secondaryUV = i.secondaryUV;
 
				#ifdef PIXELIZATION
					uv = round(uv* _PixelSize)/_PixelSize;
					displUV = round(displUV*_PixelSize)/_PixelSize;
					secondaryUV = round(secondaryUV*_PixelSize)/_PixelSize;
				#endif
 
                //Polar coords
                #ifdef POLAR
                float2 mappedUV = (uv * 2) - 1;
                uv = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.displUV * 2) - 1;
                displUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.secondaryUV * 2) - 1;
                secondaryUV = float2(atan2(mappedUV.y, mappedUV.x) / UNITY_PI / 2.0 + 0.5, length(mappedUV));
                #endif
 
                //UV Panning
                uv += _Time.y * _PanningSpeed.xy;
                displUV += _Time.y * _PanningSpeed.zw;
                secondaryUV += _Time.y * _SecondaryPanningSpeed.xy;
 
                //Displacement
                float2 displ = tex2D(_DisplacementGuide, displUV).xy;
                displ = ((displ * 2) - 1) * _DisplacementAmount;
 
                float col = pow(saturate(lerp(0.5, tex2D(_MainTex, uv + displ).x, _Contrast)), _Power);
                #ifdef SECONDARY_TEX
                col = col * pow(saturate(lerp(0.5, tex2D(_SecondaryTex, secondaryUV + displ).x, _Contrast)), _Power) * 2;
                #endif
 
                //Masking
                #ifdef CIRCLE_MASK
                float circle = distance(i.uv, float2(0.5, 0.5));
                col *= 1 - smoothstep(_OuterRadius, _OuterRadius + _Smoothness, circle);
                col *= smoothstep(_InnerRadius, _InnerRadius + _Smoothness, circle);
                #endif
 
                #ifdef RECT_MASK
                float2 uvMapped = (i.uv * 2) - 1;
                float rect = max(abs(uvMapped.x / _RectWidth), abs(uvMapped.y / _RectHeight));
                col *= 1 - smoothstep(_RectMaskCutoff, _RectMaskCutoff + _RectSmoothness, rect);
                #endif
             
				
 
                float orCol = col;
 
                //Banding
                #ifdef BANDING
                col = round(col * _Bands) / _Bands;
                #endif
 
                //Transparency
                float cutoff = saturate(_Cutoff + (1 - i.color.a));
                float alpha = smoothstep(cutoff, cutoff + _CutoffSoftness, orCol);
 
                //Coloring
                fixed4 rampCol = tex2D(_GradientMap, float2(col, 0)) + _BurnCol * smoothstep(orCol - cutoff, orCol - cutoff + _CutoffSoftness, _BurnSize) * smoothstep(0.001, 0.5, cutoff);
                //fixed4 finalCol = fixed4(rampCol.rgb * _Color.rgb * rampCol.a, 1);
				fixed4 finalCol = fixed4(tex2D(_GradientMap, float2(col, 0)) * _Color.rgb, 1);
                // apply fog
				
				//finalCol.a = alpha * tex2D(_MainTex, uv + displ).a * _Color.a;
		
				#ifdef ALPHAOUTSIDECONTROL
					// Alpha is controlled externally
					UNITY_APPLY_FOG(i.fogCoord, finalCol);
					float _externalAlpha = tex2D(_MainTex, uv+displ).a*(i.color.a);
					finalCol.a = i.color.a;
					
				#else
					finalCol = fixed4(rampCol.rgb * _Color.rgb * rampCol.a, 1);
					UNITY_APPLY_FOG(i.fogCoord, finalCol);
					finalCol.a = alpha * tex2D(_MainTex, uv + displ).a * _Color.a;
					
				#endif
		
				//Outlining
				#ifdef OUTLINE
					
					// Check if we're near the edge of the UV space
					float2 uvDistance = min(i.uv, 1 - i.uv);
					float edgeDistance1 = min(uvDistance.x, uvDistance.y);
					float edgeDistance2 = min(1-uvDistance.x,1-uvDistance.y);
					float edgeDistance = min(edgeDistance1, edgeDistance2);
					if (edgeDistance <= _OutlineThickness)
					{
						float outlineStrength = 1 - (edgeDistance / _OutlineThickness);
						outlineStrength = smoothstep(_OutlineThreshold, finalCol.a, outlineStrength);
						float4 outlineRes = lerp(finalCol, _OutlineColor, outlineStrength*finalCol.a);
						finalCol.rgb = outlineRes.rgb;
					}
				#endif
 
                //Soft Blending
                #ifdef SOFT_BLEND
                float depth = LinearEyeDepth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)));
                float diff = saturate(_IntersectionThresholdMax * (depth - i.scrPos.w));
                finalCol.a *= diff;
                #endif
				
				//Apply Emmision
				finalCol.rgb *= _Emissive;
				
				// Apply Glow
				finalCol.rgb = pow(finalCol.rgb, 1.0 / _Glow);
				
				#ifdef TILEMAP_MASK
					float2 maskCenter = _TilemapMaskCenter.xy;
					float2 pos = i.worldPos.xy;
					float2 diff = pos-maskCenter;
					float distance = length(diff);

					// Apply the mask based on the distance
					if (distance > _TilemapMaskRadius)
					{
						finalCol.a = 0; // Outside the circle, make it transparent
					}
				#endif
				
                return finalCol;
            }
            ENDCG
        }
    }
}