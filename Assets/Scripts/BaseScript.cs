using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = System.Random;

public class BaseScript : MonoBehaviour
{
    public static BaseScript Instance;
    
    private Lines Lines;
    private static Material _mat;

    private void Awake()
    {
        _mat = GetComponent<SpriteRenderer>().material;
        Lines = new Lines(_mat);
        Instance = this;
    }

    private void Start()
    {
        RandomLines();
    }

    private void RandomLines()
    {
        Lines.Clear();
        for (var i = 0; i < Lines.MaxSize / 10; i++)
        {
            Lines.AddLine(new Vector2(UnityEngine.Random.value - 0.5f, UnityEngine.Random.value - 0.5f), 
                new Vector2(UnityEngine.Random.value - 0.5f, UnityEngine.Random.value - 0.5f));
        }
        Lines.UpdateShader();
    }

    private Vector2 pos1, pos2;

    private Vector2 _dragStart, _offsetStart;
    private bool _dragging;
    private void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            var pos = GetRealMousePos();
            if (pos != Vector2.zero)
            {
                pos1 = pos;
            }
        } else if (Input.GetMouseButtonUp(0))
        {
            var pos = GetRealMousePos();
            if (pos != Vector2.zero)
            {
                pos2 = pos;
                AddLine();
            }
        } else  if (Input.GetMouseButtonDown(2))
        {
            var pos = GetMousePos(true);
            Utils.Animate(Vector3.zero, pos, 0.3f, (v) => Lines.AddOffset(v));
            
            Utils.Animate(Lines.Zoom, Lines.Zoom * 0.5f, 0.3f, (v) => Lines.SetZoom(v), true);
        }
        
        if (Input.GetMouseButtonDown(1))
        {
            var pos = GetMousePos(true) * Lines.Zoom;
            _dragStart = pos;
            _offsetStart = Lines.Offset;
            _dragging = true;
        } else if (Input.GetMouseButtonUp(1))
        {
            _dragging = false;
        }

        if (_dragging)
        {
            var pos = GetMousePos(true) * Lines.Zoom;
            Lines.SetOffset(_offsetStart + _dragStart - pos);
        }
        
        
        if (Input.GetKeyDown(KeyCode.T))
        {
            Lines.ClearOffset();
            Lines.ClearZoom();
        }
        if (Input.GetKeyDown(KeyCode.R))
        {
            RandomLines();
        }
        if (Input.GetKeyDown(KeyCode.C))
        {
            Lines.Clear();
            Lines.UpdateShader();
        }
        if (Input.GetKey(KeyCode.A))
        {
            Lines.AddLine(new Vector2(UnityEngine.Random.value, UnityEngine.Random.value), new Vector2(UnityEngine.Random.value, UnityEngine.Random.value));
            Lines.UpdateShader();
        }
    }

    private void AddLine()
    {
        Lines.AddLine(pos1, pos2);
        Lines.UpdateShader();
    }

    private Vector2 GetMousePos(bool midCenter = false)
    {
        var pos = Input.mousePosition;
        pos = Camera.main.ScreenToWorldPoint(pos);
        if (pos.x < 0.5f && pos.x > -0.5f && pos.y < 0.5f && pos.y > -0.5f)
        {
            if (!midCenter) pos += new Vector3(0.5f, 0.5f);
            return pos;
        }
        return Vector2.zero;
    }

    private Vector2 GetRealMousePos()
    {
        return GetMousePos(true) * Lines.Zoom + Lines.Offset;
        
    }


}
