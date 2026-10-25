#if UNITY_EDITOR
using System;
using UnityEngine;

#if MARROW_SDK
using SLZ.Marrow.Warehouse;
#endif

[Serializable]
public class UVSpecification
{
    public UVType TextureMode;
    public Vector2 Offset;
    public Vector2 Scale = Vector2.one;
    public float Rotation;

#if MARROW_SDK
    [SerializeField]
    public DataCardReference<SurfaceDataCard> BonelabSurfaceType = new() { Barcode = new Barcode("SLZ.Backlot.SurfaceDataCard.Default") };
#endif
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
