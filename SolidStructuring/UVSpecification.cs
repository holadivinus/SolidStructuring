#if UNITY_EDITOR
using System;
using UnityEngine;

[Serializable]
public class UVSpecification
{
    public UVType TextureMode;
    public Vector2 Offset;
    public Vector2 Scale = Vector2.one;
    public float Rotation;
}

[Serializable]
public class MaterialToUVSpec
{
    public Material material;
    public QuadBlockFace Face;
    public UVSpecification uvSpecification;
}

public enum UVType
{
    Stretched, RepeatAcrossWorld
}
#endif
