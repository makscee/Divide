Shader "base"{
    Properties{
        _MainTex ("Texture", 2D) = "white" { }
        _VDiv("VDiv", Range(0.0, 30.0)) = 20.0
        _TopBalanceStart("TopBalanceStart", Range(0.0, 10.0)) = 5.0
        _SFDiv("S First Div", Range(0, 10)) = 5
        _SSDiv("S Second Div", Range(0.0, 1.0)) = 0.5
        _VRev("VRev", Range(0, 1)) = 0
        _DistMul("DistMul", Range(0.0, 100.0)) = 1.0
        
    }
	SubShader{
		Tags{
				"RenderType"="Opaque" 
				"Queue"="Geometry"
			}
		Pass{
			

			CGPROGRAM
            #pragma target 5.0
			#include "UnityCG.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
			};
			
			uniform float4 _LinesData[1023];
			uniform int _Length = 0;
			
			sampler2D _MainTex;
            fixed4 _Color;
            fixed _S, _V;
            fixed _VDiv, _SSDiv, _TopBalanceStart, _DistMul;
            int _VRev, _SFDiv;

			v2f vert(appdata v){
				v2f o;
				o.position = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
				return o;
			}
			
			fixed3 HSVtoRGB(int H, float S, float V) {
			    V = max(0.0, min(V, 1.0));
			    S = max(0.0, min(S, 1.0));
                float C = S * V;
                float X = C * (1 - abs(fmod(H / 60.0, 2) - 1));
                float m = V - C;
                float Rs, Gs, Bs;
            
                if(H >= 0 && H < 60) {
                    Rs = C;
                    Gs = X;
                    Bs = 0;	
                }
                else if(H >= 60 && H < 120) {	
                    Rs = X;
                    Gs = C;
                    Bs = 0;	
                }
                else if(H >= 120 && H < 180) {
                    Rs = 0;
                    Gs = C;
                    Bs = X;	
                }
                else if(H >= 180 && H < 240) {
                    Rs = 0;
                    Gs = X;
                    Bs = C;	
                }
                else if(H >= 240 && H < 300) {
                    Rs = X;
                    Gs = 0;
                    Bs = C;	
                }
                else {
                    Rs = C;
                    Gs = 0;
                    Bs = X;	
                }
                fixed3 output;
                output[0] = (Rs + m);
                output[1] = (Gs + m);
                output[2] = (Bs + m);
                return output;
            }
            
            float rand(float2 co){
               return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
            }

			fixed4 frag(v2f i) : SV_TARGET{
			    fixed2 c = fixed2(i.uv.x, i.uv.y);
			    int curInd = 0;
			    int curTop = 0;
			    fixed cMax = 1, cMin = 0;
			    int depth = 0, topBalance = _TopBalanceStart;
			    fixed dist = 1;
			    for (int j = 0; j < _Length; j++)
                {
                    float k = _LinesData[j][0];
                    float b = _LinesData[j][1];
                    float parent = _LinesData[j][2];
                    float top = _LinesData[j][3];
                    dist = min(dist, abs(c.y - k * c.x - b) / sqrt(k * k + 1));
                    if (parent == curInd && top == curTop) {
                        depth++;
                        curInd = j;
                        if (c.y - c.x * k - b > 0) { 
                            curTop = 1;
                            cMin = (cMax + cMin) / 2;
                            topBalance++;
                        }
                        else {
                            curTop = 0;
                            cMax = (cMax + cMin) / 2;
                            topBalance--;
                        }
                    } else if (j == 0) {
                        if (c.y - c.x * k - b > 0) { 
                            curTop = 1;
                        }
                        else {
                            curTop = 0;
                        }
                    }
                }
                fixed v;
                if (_VRev) v = 1 - dist * _DistMul;
                else v = dist * _DistMul;
                fixed s = _SSDiv;
                fixed cMid = (cMax + cMin) / 2;
                fixed res;
                if (curTop == 1) res = (cMid + cMax) / 2;
                else res = (cMid + cMin) / 2;
                //res = rand(float2(res, 1.0));
                fixed3 rgb = HSVtoRGB(round(res * 360), s, v);
                
                return fixed4(rgb[0], rgb[1], rgb[2], 1);
			}

			ENDCG
		}
	}
}