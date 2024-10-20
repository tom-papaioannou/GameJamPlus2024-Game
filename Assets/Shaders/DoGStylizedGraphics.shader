Shader "VFX/DoGStylizedGraphics"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_DitherTex("Dither Texture ", 2D) = "white" {}
		_GradientMap("Color Palette", 2D) = "white" {}
		_NoiseMap("Noise Texture", 2D) = "white" {}
		_HatchingTex("Hatching Texture", 2D) = "white" {}
       
		[Space(20)]
        [Toggle(BANDING)]
        _Banding("Color banding", float) = 0
        _Bands("Number of bands", float) = 3
		_PaletteSize("Palette Size", float) = 32.0
		_MatchingThreshold("Matching Threshold", float) = 0.1
		_DiscardThreshold("Discard Threshold", float) = 0.1
		_ToneDownThreshold("Tone Down Threshold", float) = 0.8
		_ToneDownStrength("Tone Down Strength", float) = 0.1
		_BrightnessAdjustment("Brightness Adjustment", Range(0,10)) = 0.8
	   
		[Space(20)]
		[Toggle(BAYER_DITHERING)]
		_BayerDithering("Color dithering", float) = 0
		_DitherStrength("Dither Strength", Range(0, 10)) = 0.1	
		_NoiseScale("Noise Scale", float) = 10
		_PaletteBlacksDitheringThreshold("Palette Black Threshold", float) = 0.3
		
		[Space(20)]
		[Toggle(COMIC_STYLE)]
		_ComicStyle("Comic Style", float) = 0
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
        _OutlineThickness ("Outline Thickness", float) = 0.1
		_OutlineSoftness ("Edge Softness", float) = 0.1
		 _BilateralRadius ("Bilateral Radius", float) = 1.0
        _BilateralSigma ("Bilateral Sigma", float) = 1.0
        _BilateralSigma2 ("Bilateral Sigma 2", float) = 1.0
		
		[Space(20)]
		[Toggle(PAINTERLY_FILTERING)]
		_PainterlyFiltering("Painterly Filtering", float) = 0
		_PainterlyBrushSize("Brush Size", Range(0, 10)) = 0.1
		_PainterlyEdgeThreshold("Painterly Threshold", float) = 0.1
		_PainterlyColorVariation("Color Variation", float) = 1
		
		
		[Space(20)]
		[Toggle(CARTOON_EFFECT)]
		_CartoonEffect("Cartoon Effect", float) = 0
		_HatchingScale("Hatching Scale", float) = 0.1
		_HatchingIntensity("Hatching Intensity", float) = 0.1
		_HatchingThreshold("Hatching Threshold", float) = 0.1
		_HatchingExtension("Hatching Extension", float) = 0.1
		_HatchingThickness("Hatching Thickness", float) = 0.1
		_HatchingToneDownThreshold("Hatching Tone Down Threshold", float) = 0.9
		_SobelKernelSize("Sobel Kernel Size", float) = 0.1
		
		
    }
    SubShader
    {
	
		
        Pass
        {
            CGPROGRAM
			#pragma vertex vert
            #pragma fragment frag
			#pragma shader_feature BANDING
			#pragma shader_feature BAYER_DITHERING
			#pragma shader_feature COMIC_STYLE
			#pragma shader_feature PAINTERLY_FILTERING
			#pragma shader_feature CARTOON_EFFECT
			
            #include "UnityCG.cginc"

            sampler2D _MainTex;
			sampler2D _DitherTex;
			sampler2D _GradientMap;
			sampler2D _HatchingTex;
			sampler2D _NoiseMap;
			
			float _Bands;
			float _PaletteSize;
			float _MatchingThreshold;
			float _DiscardThreshold;
			float _ToneDownThreshold;
			float _ToneDownStrength;
			float _BrightnessAdjustment;
			
			float _DitherStrength;
			float _NoiseScale;
			float _PaletteBlacksDitheringThreshold;
			
            float _BilateralRadius;
            float _BilateralSigma;
            float _BilateralSigma2;
			
			float _OutlineThickness;
			float _OutlineSoftness;
            fixed4 _OutlineColor;
			
			float _PainterlyBrushSize;
			float _PainterlyEdgeThreshold;
			float _PainterlyColorVariation;
			
			float4 _HatchingTexture_ST;
			float _HatchingScale;
			float _HatchingIntensity;
			float _HatchingThreshold;
			float _HatchingExtension;
			float _HatchingThickness;
			float _HatchingToneDownThreshold;
			float _SobelKernelSize;
			
            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				
                return o;
            }
			
			float3 mapToPalette(float3 color)
			{
				// Calculate the luminance of the input color
				float luminance = dot(color, float3(0.299, 0.587, 0.114));
				
				// Use the luminance to sample from the gradient map
				return tex2D(_GradientMap, float2(luminance, 0.5)).rgb;
			}
						
			float3 rgb2hsv(float3 c) {
			
				float4 K = float4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
				float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
				float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

				float d = q.x - min(q.w, q.y);
				float e = 1.0e-10;
				return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}

			float3 hsv2rgb(float3 c) {
			
				float4 K = float4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
				float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
				return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
			}
			
			float4 Grayscale(float4 color)
			{
				float gray = (color.r + color.g + color.b) / 3.0;
				return float4(gray, gray, gray, color.a);
			}
			
			float2 SobelFilter2(sampler2D tex, float2 uv, float2 texelSize)
			{
				float3x3 sobelX = float3x3(
					-1, 0, 1,
					-2, 0, 2,
					-1, 0, 1
				);
				
				float3x3 sobelY = float3x3(
					-1, -2, -1,
					0, 0, 0,
					1, 2, 1
				);

				float2 gradient = float2(0, 0);
				float kernelSize = _SobelKernelSize;

				for (int i = -1; i <= 1; i++)
				{
					for (int j = -1; j <= 1; j++)
					{
						float2 offset = float2(i, j) * texelSize * kernelSize;
						float3 color = tex2D(tex, uv + offset).rgb;
						float luminance = dot(color, float3(0.299, 0.587, 0.114));
						
						gradient.x += luminance * sobelX[i+1][j+1];
						gradient.y += luminance * sobelY[i+1][j+1];
					}
				}

				return gradient;
			}
			
			float2 SobelFilter(sampler2D tex, float2 uv, float2 texelSize)
			{
				float2 sobelX = float2(0, 0);
				float2 sobelY = float2(0, 0);
				float kernelSize = _SobelKernelSize;

				for (int i = -1; i <= 1; i++)
				{
					for (int j = -1; j <= 1; j++)
					{
						float2 offset = float2(i, j) * texelSize * kernelSize;
						float3 color = tex2D(tex, uv + offset).rgb;
						float luminance = dot(color, float3(0.299, 0.587, 0.114));

						sobelX += luminance * float2(i, 0);
						sobelY += luminance * float2(0, j);
					}
				}

				return float2(sobelX.x + sobelX.y, sobelY.x + sobelY.y);
			}
			
			float4 DynamicInkColor(float4 originalColor, float4 paletteColor, float threshold, float2 uv) {
				float3 originalHSV = rgb2hsv(originalColor.rgb);
				float3 paletteHSV = rgb2hsv(paletteColor.rgb);
				
				// Calculate the distance from the center of the texture
				float2 center = float2(0.5, 0.5);
				float distance = length(uv - center) * _NoiseScale;
				
				// Use the distance to influence the pattern
				float noise = tex2D(_DitherTex, uv).r;
				float alpha = tex2D(_DitherTex, uv).a;
				
				// Combine the original color with the texture based on the distance
				float3 inkColorRGB = lerp(originalColor.rgb, paletteColor.rgb, (noise+_DitherStrength) / (distance + threshold));
				
				float lerpedAlpha = lerp(originalColor.a, alpha, 0.1);
				float4 inkCol = float4(inkColorRGB, lerpedAlpha);
				
				//inkCol = Grayscale(inkCol);
				inkCol *= lerpedAlpha;
				
				return inkCol;
			}
			
			float CalculatePaletteIndex(float4 screenColor, int n)
			{
				// Convert the screen color to HSV
				float3 screenHSV = rgb2hsv(screenColor.rgb);
				float screenLuminance = dot(screenColor.rgb, float3(0.299, 0.587, 0.114));

				float minDistance = 1e6;
				int index = -1;

				[loop]
				for (int i = 0; i < n; ++i)
				{
					// Sample the palette color
					//float4 paletteColor = tex2D(_GradientMap, float2(i / 31.0, 0));
					float4 paletteColor = tex2D(_GradientMap, float2(i / (_PaletteSize-1), 0));
					// Convert the palette color to HSV
					float3 paletteHSV = rgb2hsv(paletteColor.rgb);
					float paletteLuminance = dot(paletteColor.rgb, float3(0.299, 0.587, 0.114));

					// Calculate the distance between the screen color and the palette color
					//float distance = length(screenHSV - paletteHSV);
					float distance = abs(screenLuminance-paletteLuminance);
					
					// If this is the closest color so far, save its index
					if (distance < minDistance)
					{
						minDistance = distance;
						index = i;
					}
				}
				
				if (minDistance > _MatchingThreshold)
				{
					index = -1;  // No match within the threshold
				}

				// Return the index of the closest color in the palette
				return index;
			}
			
			float gaussianPoly(float x)
			{
				return 1.0 - x * x * (0.5 - 0.15 * x * x);
			}
			
			// Color quantization function
			float3 quantizeColor(float3 color, float levels)
			{
				//return floor(color * levels + 0.5) / levels;
				return floor(color*levels)/(levels-1);
			}
			
			
			float4 SimplePainterlyEffect(sampler2D inputTexture, float2 uv, float2 texelSize)
			{
				
				float4 centerColor = tex2D(inputTexture, uv);
				
				// Calculate simple edge detection using neighboring pixels
				float2 offsets[4] = {
					float2(-1, 0), float2(1, 0),
					float2(0, -1), float2(0, 1)
				};
				
				float edgeStrength = 0;
				for (int i = 0; i < 4; i++)
				{
					float4 neighborColor = tex2D(inputTexture, uv + offsets[i] * texelSize * _PainterlyBrushSize);
					edgeStrength += distance(neighborColor, centerColor);
				}
				edgeStrength /= 4.0;
				
				// Apply brush stroke effect if not on an edge
				if (edgeStrength < _PainterlyEdgeThreshold)
				{
					// Create a brushstroke effect by averaging colors in a small area
					float4 brushColor = 0;
					int samples = 5;
					for (int x = -samples / 2; x <= samples / 2; x++)
					{
						for (int y = -samples / 2; y <= samples / 2; y++)
						{
							float2 offset = float2(x, y) * texelSize * _PainterlyBrushSize;
							brushColor += tex2D(inputTexture, uv + offset);
						}
					}
					brushColor /= (samples * samples);
					
					// Add slight color variation
					float3 randomColor = float3(
						frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453),
						frac(sin(dot(uv, float2(4.1414, 2.5723))) * 43758.5453),
						frac(sin(dot(uv, float2(23.4572, 97.2817))) * 43758.5453)
					);
					
					float4 noiseColor = tex2D(_NoiseMap,float2(edgeStrength, edgeStrength));
					float3 noiseHSV = rgb2hsv(noiseColor.rgb);
					float3 brushHSV = rgb2hsv(brushColor.rgb);
					float randomHSV = rgb2hsv(randomColor);
					brushHSV.b += lerp(abs(noiseHSV.b)*_PainterlyColorVariation, noiseHSV.b,edgeStrength);
					//brushColor.rgb += (randomColor - 0.5) * _PainterlyColorVariation;
					brushColor.rgb = hsv2rgb(brushHSV);
					return brushColor;
				}
				else
				{
					// On edges, return the original color to preserve details
					return centerColor;
				}
			}
			
			float4 BilateralFilter1D(sampler2D tex, float2 uv, int radius, float sigma, float2 texelSize)
			{
				float4 result = float4(0.0, 0.0, 0.0, 0.0);
				float totalWeight = 0.0;
				float4 centerColor = tex2D(tex, uv);
				float sigmaSpatial = sigma * sigma;
				float invTwoSigmaSpatial = 0.5 / sigmaSpatial;
				float invSigmaColor = 0.5 / sigma;

				// Horizontal pass
				for (int x = -radius; x <= radius; x++)
				{
					float2 offset = float2(x, 0) * texelSize;
					float4 sampleColor = tex2D(tex, uv + offset);
					float spatialDist2 = float(x*x);
					float spatialWeight = exp(-spatialDist2 * invTwoSigmaSpatial);
					float3 colorDiff = centerColor.rgb - sampleColor.rgb;
					float colorWeight = exp(-dot(colorDiff, colorDiff) * invSigmaColor);
					float weight = spatialWeight * colorWeight;
					result += sampleColor * weight;
					totalWeight += weight;
				}

				// Normalize intermediate result
				float4 intermediateResult = result / totalWeight;

				// Reset accumulators
				result = float4(0.0, 0.0, 0.0, 0.0);
				totalWeight = 0.0;

				// Vertical pass
				for (int y = -radius; y <= radius; y++)
				{
					float2 offset = float2(0, y) * texelSize;
					float4 sampleColor = tex2D(tex, uv + offset);
					float spatialDist2 = float(y*y);
					float spatialWeight = exp(-spatialDist2 * invTwoSigmaSpatial);
					float3 colorDiff = intermediateResult.rgb - sampleColor.rgb;
					float colorWeight = exp(-dot(colorDiff, colorDiff) * invSigmaColor);
					float weight = spatialWeight * colorWeight;
					result += sampleColor * weight;
					totalWeight += weight;
				}

				// Final normalization
				return result / totalWeight;
			}
			
			
			float4 BilateralFilter(sampler2D tex, float2 uv, int radius, float sigma, float2 texelSize) {
				float4 result = float4(0.0, 0.0, 0.0, 0.0);
				float totalWeight = 0.0;
				float4 centerColor = tex2D(tex, uv);
				
				float sigmaSpatial = sigma * sigma;
				float invTwoSigmaSpatial = 0.5 / sigmaSpatial;
				float invSigmaColor = 0.5 / sigma;
				
				for (int x = -radius; x <= radius; x++) {
					float2 offsetX = float2(x, 0) * texelSize;
					for (int y = -radius; y <= radius; y++) {
						float2 offset = offsetX + float2(0, y) * texelSize;
						float4 sampleColor = tex2D(tex, uv + offset);
						
						float spatialDist2 = float(x*x + y*y);
						float spatialWeight = exp(-spatialDist2 * invTwoSigmaSpatial);
						
						float3 colorDiff = centerColor.rgb - sampleColor.rgb;
						float colorWeight = exp(-dot(colorDiff, colorDiff) * invSigmaColor);
						
						float weight = spatialWeight * colorWeight;
						result += sampleColor * weight;
						totalWeight += weight;
					}
				}
				return result / totalWeight;
			}
				
            fixed4 frag(v2f i) : SV_Target
            {
			
				
                fixed4 col = tex2D(_MainTex, i.uv);
				float2 texelSize = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
				
				float3 screenHSV = rgb2hsv(col.rgb);
				float3 screenCol = col;
				
				float paletteIndex = CalculatePaletteIndex(col, _Bands);
				float normalizedIndex = paletteIndex / (_PaletteSize-1);
				float4 paletteColor = tex2D(_GradientMap, float2(normalizedIndex, 0));
				if(paletteIndex<0)paletteColor = col;
				
				fixed4 ditherCol = tex2D(_DitherTex, i.uv);
				
				float edge = 0;
				float edgeFactor = 0;
				
				#ifdef COMIC_STYLE
					
					float2 size = _OutlineThickness / _ScreenParams.xy;
					fixed4 outlineColor = _OutlineColor;
					
					float2 uv = float2(i.uv.x, i.uv.y);
					
					float4 leftPixel = tex2D(_MainTex, float2(i.uv.x - size.x, i.uv.y));
					float4 rightPixel = tex2D(_MainTex, float2(i.uv.x + size.x, i.uv.y));
					float4 upPixel = tex2D(_MainTex, float2(i.uv.x, i.uv.y - size.y));
					float4 downPixel = tex2D(_MainTex, float2(i.uv.x, i.uv.y + size.y));
					edge = length(clamp(col.rgb - leftPixel.rgb, -0.1, 0.1)) +length(clamp(col.rgb - rightPixel.rgb, -0.1, 0.1)) +length(clamp(col.rgb - upPixel.rgb, -0.1, 0.1)) +length(clamp(col.rgb - downPixel.rgb, -0.1, 0.1));
		
					// Apply bilateral filter for smoothing
					fixed4 filtered1 = BilateralFilter1D(_MainTex, i.uv, _BilateralRadius, _BilateralSigma, texelSize);
					fixed4 filtered2 = BilateralFilter1D(_MainTex, i.uv, _BilateralRadius, _BilateralSigma2, texelSize);
				
					float4 edges = abs(filtered1-filtered2);
					//float4 edges = (1-_OutlineThickness)*filtered1-_OutlineThickness*filtered2;
					
					// Apply threshold
					edge += length(edges.rgb)*0.5;
					edgeFactor = smoothstep(_OutlineThickness, _OutlineThickness + _OutlineSoftness, edge);
					edgeFactor *= smoothstep(_OutlineThickness - 0.01, _OutlineThickness + 0.01, edge);
					// Blend the edge color based on the threshold
					
					if(edge>=_OutlineThickness){
						col = lerp(col, _OutlineColor, edgeFactor);
						//col = float4(1,1,1,1);
					}
					//else col = float4(0,0,0,1);
					
				#endif
				
				#ifdef BANDING

					if (edge < _OutlineThickness) {
						float3 bandingHSVCol = rgb2hsv(col.rgb);
						float3 paletteHSVCol = rgb2hsv(paletteColor.rgb);
						bandingHSVCol.g = paletteHSVCol.g;
						
						if (screenHSV.b > _DiscardThreshold) {
							bandingHSVCol.b = clamp(paletteHSVCol.b, 0, 0.35);
						}
						
						col.rgb += hsv2rgb(bandingHSVCol);
						
						if(screenHSV.b > _ToneDownThreshold){
							float3 toneDownHSV = rgb2hsv(col.rgb);
							toneDownHSV.b -= _ToneDownStrength;
							col.rgb = hsv2rgb(toneDownHSV);
						}
						
						// Use _BandingStrength to interpolate between original and banded color
						
						float3 hsvCol = rgb2hsv(col.rgb);
						hsvCol.b *= _BrightnessAdjustment;
						col.rgb = hsv2rgb(hsvCol);
						
					}

				#endif
				
				float3 beforeCol = rgb2hsv(col.rgb);
				#ifdef PAINTERLY_FILTERING
					
					if(edge<_OutlineThickness){
					
						
						float4 painterlyCol = SimplePainterlyEffect(_MainTex, i.uv, texelSize);
						painterlyCol = saturate(painterlyCol);
						col.rgb = lerp(col.rgb, painterlyCol.rgb, 0.5);
						
					}
					 
					
				#endif
				
				#ifdef CARTOON_EFFECT
				
					float2 gradient = SobelFilter2(_MainTex, i.uv, texelSize);
					float edgeStrength = length(gradient);
					float2 edgeDirection = normalize(gradient + float2(0.00001, 0.00001));

					// Calculate the direction perpendicular to the edge
					float2 perpDirection = float2(-edgeDirection.y, edgeDirection.x);

					// Calculate UV offset for hatching, extending outward
					float2 hatchOffset = perpDirection * _HatchingExtension * texelSize;

					// Sample hatching texture
					float2 hatchUV = (i.uv * _HatchingScale + hatchOffset);
					float4 hatch = tex2D(_HatchingTex, hatchUV);

					// Calculate hatching factor based on edge strength
					float hatchFactor = smoothstep(_HatchingThreshold, _HatchingThreshold + _HatchingExtension, edgeStrength);
					hatchFactor *= _HatchingIntensity;

					if(edge<= _OutlineThickness){
						// Apply hatching
						if(rgb2hsv(col.rgb).b<_HatchingToneDownThreshold)col.rgb = lerp(col.rgb, col.rgb * hatch.rgb, hatchFactor);

						// Apply outline (if needed)
						if(edgeStrength > _HatchingThreshold) {
							col = lerp(col, _OutlineColor, smoothstep(_HatchingThreshold, _HatchingThreshold + _OutlineSoftness, edgeStrength));
						}
					}
					
				#endif
				
				// Bayer matrix dithering
				#ifdef BAYER_DITHERING
				
                // Apply dithering
                
					if(edge<_OutlineThickness)
					{
						float3 _paletteHSVCol = rgb2hsv(paletteColor.rgb);
						
						if(_paletteHSVCol.b<_PaletteBlacksDitheringThreshold)col = DynamicInkColor(col, paletteColor, _PaletteBlacksDitheringThreshold, i.uv);
						
					}
				#endif
				
                return col;
            }
            ENDCG
        }
    }
}
