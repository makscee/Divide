//UNITY_SHADER_NO_UPGRADE
#ifndef MYHLSLINCLUDE_INCLUDED
#define MYHLSLINCLUDE_INCLUDED

uniform float4 _LinesData[100];
uniform int _Length = -1;

struct float2v
{
    float x, y;
};

float3 HSVtoRGB(int H, float S, float V) {
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
    float3 output;
    output[0] = (Rs + m);
    output[1] = (Gs + m);
    output[2] = (Bs + m);
    return output;
}

void MyFunction_float(float2 UV, float2 offset, float zoom, out float4 Out)
{
    if (_Length == -1) {
        float4 lines[3] = 
        {
            float4(2, 0, -1.0, -1.0),
            float4(-1, 0, 0.0, 1.0),
            float4(0.8, 0.5, 1.0, 1.0)
        };
        for (int i = 0; i < 3; i++) 
        {
            _LinesData[i] = lines[i];
        }
        _Length = 3;
    }
    float2v c;
    c.x = UV.x * zoom + offset.x;
    c.y = UV.y * zoom + offset.y;
    int curInd = 0;
    int curTop = 0;
    float cMax = 1, cMin = 0;
    float dist = 1;
    for (int j = 0; j < _Length; j++)
    {
        float k = _LinesData[j][0];
        float b = _LinesData[j][1];
        float parent = _LinesData[j][2];
        float top = _LinesData[j][3];
        dist = min(dist, abs(c.y - k * c.x - b) / sqrt(k * k + 1));
        if (parent == curInd && top == curTop) { 
            curInd = j;
            if (c.y - c.x * k - b > 0) { 
                curTop = 1;
                cMin = (cMax + cMin) / 2;
            }
            else {
                curTop = 0;
                cMax = (cMax + cMin) / 2;
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
    float v = 1;
    float s = 1;
    float cMid = (cMax + cMin) / 2;
    float res;
    if (curTop == 1) res = (cMid + cMax) / 2;
    else res = (cMid + cMin) / 2;
    //res = rand(float2(res, 1.0));
    float3 rgb = HSVtoRGB(round(res * 360), s, v);
    
    Out = float4(rgb[0], rgb[1], rgb[2], 1);
}

#endif