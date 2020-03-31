using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class Lines
{
    private class Line
    {
        public Line(float k, float b)
        {
            this.k = k;
            this.b = b;
            Top = null;
            Bottom = null;
        }
        public float k, b;
        public Line Top, Bottom;
    }

    private Material _mat;
    public Lines(Material mat)
    {
        _mat = mat;
    }

    private int _linesCount = 0;
    public const int MaxSize = 100;
    private Line Root;

    private void LineRecursiveAdd(Line cur, Vector2 pos, float k, float b)
    {
        if (TopOrBottom(cur, pos))
        {
            if (cur.Top != null)
            {
                LineRecursiveAdd(cur.Top, pos, k, b);
            }
            else
            {
                cur.Top = new Line(k, b);
            }
        }
        else
        {
            if (cur.Bottom != null)
            {
                LineRecursiveAdd(cur.Bottom, pos, k, b);
            }
            else
            {
                cur.Bottom = new Line(k, b);
            }
        }
    }

    public void AddLine(Vector2 pos1, Vector2 pos2)
    {
        if (_linesCount >= MaxSize) return;
        var k = (pos1.y - pos2.y) / (pos1.x - pos2.x);
        var b = pos1.y - k * pos1.x;
        if (Root != null)
        {
            LineRecursiveAdd(Root, pos1, k, b);
        }
        else
        {
            Root = new Line(k, b);
        }

        _linesCount++;
    }

    private bool TopOrBottom(Line l, Vector2 pos)
    {
        return pos.y - pos.x * l.k - l.b > 0;
    }

    private void ConstructShaderArray(List<Vector4> array, Line cur, int parent, int top)
    {
        if (cur == null) return;
        array.Add(new Vector4(cur.k, cur.b, parent, top));
        var ind = array.Count - 1;
        ConstructShaderArray(array, cur.Top, ind, 1);
        ConstructShaderArray(array, cur.Bottom, ind, 0);
    }

    private Vector4[] GetShaderArray()
    {
        if (Root == null) return null;
        var data = new List<Vector4>();
        ConstructShaderArray(data, Root, -1, -1);
        data.AddRange(new Vector4[MaxSize - data.Count]);
        return data.ToArray();
    }

    public void UpdateShader()
    {
        var data = GetShaderArray();
        if (false)
        {
            foreach (var v in data)
            {
                if (v[0] != 0)
                {
                    Debug.Log($"{v}");
                }
                else break;
            }
        }
        if (data != null)
        {
            _mat.SetVectorArray("_LinesData", data);
        }

        _mat.SetInt("_Length", _linesCount);
    }

    public float Zoom = 1f;
    public Vector2 Offset = Vector2.zero;

    public void AddOffset(Vector2 position)
    {
        Offset = position * Zoom + Offset;
        _mat.SetVector("_offset", Offset);
    }

    public void SetOffset(Vector2 position)
    {
        Offset = position;
        _mat.SetVector("_offset", Offset);
    }

    public void ClearOffset()
    {
        Offset = Vector2.zero;
        _mat.SetVector("_offset", Offset);
    }

    public void AddZoom(float zoom)
    {
        SetZoom(Zoom * zoom);
    }

    public void SetZoom(float zoom)
    {
        Zoom = zoom;
        _mat.SetFloat("_zoom", Zoom);
        Debug.Log(Zoom);
    }

    public void ClearZoom()
    {
        Zoom = 1f;
        _mat.SetFloat("_zoom", Zoom);
    }

    private void RecursiveClear(Line cur)
    {
        if (cur == null) return;
        RecursiveClear(cur.Top);
        RecursiveClear(cur.Bottom);
        cur.Top = null;
        cur.Bottom = null;
    }

    public void Clear()
    {
        RecursiveClear(Root);
        Root = null;
        _linesCount = 0;
    }
}