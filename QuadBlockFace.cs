#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class QuadBlockFace : MonoBehaviour
{
    public QuadBlock QuadBlock;
    public MeshRenderer MeshRenderer;
    public Material materialChoice 
    {
        get => m;
        set
        {
            m = value;
        }
    }
    [SerializeField] private Material m;

    public StretchDir Left;
    public StretchDir Right => (StretchDir)(((byte)Left + 3) % 6);
    public StretchDir Up;
    public StretchDir Down => (StretchDir)(((byte)Up + 3) % 6);

    public Vector2 QuadTopLeft = new Vector2(-.5f, .5f);
    public Vector2 QuadBottomRight = new Vector2(.5f, -.5f);
    public Vector2 QuadBottomLeft = new Vector2(-.5f, -.5f);
    public Vector2 QuadTopRight = new Vector2(.5f, .5f);

    public Vector3 FromMousePose(MouseSection ms, out StretchDir primaryStretch, out Vector3 extraDir, out StretchDir secondaryStretch)
    {
        extraDir = Vector3.zero;
        secondaryStretch = StretchDir.X;
        switch (ms)
        {
            case MouseSection.Left:
                primaryStretch = Left;
                return Left.ToDir();
            case MouseSection.Right:
                primaryStretch = Right;
                return Right.ToDir();
            case MouseSection.Top:
                primaryStretch = Up;
                return Up.ToDir();
            case MouseSection.Bottom:
                primaryStretch = Down;
                return Down.ToDir();
            case MouseSection.TopLeft:
                extraDir = Up.ToDir();
                secondaryStretch = Up;
                primaryStretch = Left;
                return Left.ToDir();
            case MouseSection.BottomLeft:
                extraDir = Down.ToDir();
                secondaryStretch = Down;
                primaryStretch = Left;
                return Left.ToDir();
            case MouseSection.TopRight:
                extraDir = Up.ToDir();
                secondaryStretch = Up;
                primaryStretch = Right;
                return Right.ToDir();
            case MouseSection.BottomRight:
                extraDir = Down.ToDir();
                secondaryStretch = Down;
                primaryStretch = Right;
                return Right.ToDir();
            case MouseSection.Center:
                primaryStretch = StretchDir.X;
                return Vector3.zero;
        }
        throw new NotImplementedException(ms + " not supported");
    }

    private void Update()
    {
        if (QuadBlock.QuadBlockType == QuadBlockType.StructureZone && MeshRenderer.sharedMaterial != QuadBlock.DeselectedMat && MeshRenderer.sharedMaterial != QuadBlock.HoveredMat)
        {
            MeshRenderer.sharedMaterial = QuadBlock.DeselectedMat;
        }
        CheckMat();
    }

    private Material lastMat;
    void CheckMat()
    {
        if (BuildPipeline.isBuildingPlayer) return;

        Material[] ignoredMats = new Material[] { QuadBlock.HoveredMat, QuadBlock.NoCollideDeselectedMat, QuadBlock.NormalDeselectedMat, QuadBlock.ClipMat };
        if (DragAndDrop.objectReferences.Length == 0 && Array.IndexOf(ignoredMats, MeshRenderer.sharedMaterial) == -1 && MeshRenderer.sharedMaterial != materialChoice)
        {
            Material newMat = MeshRenderer.sharedMaterial;
            if (Undo.GetCurrentGroupName() == "Assign Material")
            {
                Undo.RevertAllDownToGroup(Undo.GetCurrentGroup() - 1);

                //MeshRenderer.sharedMaterial = lastMat;
                Undo.RegisterFullObjectHierarchyUndo(this.gameObject, "Assign Quad Material");
                materialChoice = newMat;
                MeshRenderer.sharedMaterial = materialChoice;
                EditorUtility.SetDirty(MeshRenderer);
                EditorUtility.SetDirty(this);
                PrefabUtility.RecordPrefabInstancePropertyModifications(MeshRenderer);
                PrefabUtility.RecordPrefabInstancePropertyModifications(this);
                Undo.FlushUndoRecordObjects();
            }
            else
            {
                // mat change!
                materialChoice = MeshRenderer.sharedMaterial;
                MeshRenderer.sharedMaterial = materialChoice == null ? QuadBlock.HoveredMat : QuadBlock.ClipMat;
                EditorUtility.SetDirty(MeshRenderer);
                EditorUtility.SetDirty(this);
                PrefabUtility.RecordPrefabInstancePropertyModifications(MeshRenderer);
                PrefabUtility.RecordPrefabInstancePropertyModifications(this);
            }
            QuadBlock.FindContainingStructure()?.UpdateMesh();

        }
        else
        {
            if (lastMat != QuadBlock.ClipMat && MeshRenderer.sharedMaterial == QuadBlock.ClipMat)
                QuadBlock.FindContainingStructure()?.UpdateMesh();
        }
        lastMat = MeshRenderer.sharedMaterial;

        if (!SolidStructuringPlugin.LeftShiftPressed)
        {
            if (MeshRenderer.sharedMaterial == QuadBlock.HoveredMat)
                MeshRenderer.sharedMaterial = QuadBlock.DeselectedMat;
        }
    }

    private void OnEnable()
    {
        SolidStructuringPlugin.DragDropped += CheckMat;
        SolidStructuringPlugin.EditorUpdate += EditorUpdate;

        if (materialChoice == null)
        {
            MeshRenderer.sharedMaterial = QuadBlock.DeselectedMat;
        }

        gameObject.hideFlags = HideFlags.DontSaveInBuild;
        foreach (var c in gameObject.GetComponents<Component>())
        {
            c.hideFlags = HideFlags.DontSaveInBuild;
        }
        gameObject.isStatic = false;

        if (Application.isPlaying)
            MeshRenderer.enabled = false;
    }
    private void OnDisable()
    {
        SolidStructuringPlugin.DragDropped -= CheckMat;
        SolidStructuringPlugin.EditorUpdate -= EditorUpdate;

        if (okaySelections != null)
            for (int i = 1; i < okaySelections.Length; i++)
            {
                GameObject s = okaySelections[i];
                if (s != null)
                    DestroyImmediate(s);
            }
    }


    private bool _lastFaceState;
    private bool _lastUVState;
    [NonSerialized] public bool IsFaceBeingModified;
    [NonSerialized] public bool IsUVBeingModified;
    private Transform TopLeftDragger;
    private Transform BottomLeftDragger;
    private Transform TopRightDragger;
    private Transform BottomRightDragger;
    private Transform UVDragger;
    private UnityEngine.Object specHolder;
    private MaterialToUVSpec targSpecification;
    private UVEditSettings EditSettings;
    private GameObject[] okaySelections;

    private Vector2[] oldPoses;
    private Vector3[] snappables;
    private (Vector3, Vector3)[] lineSnappables;
    private void EditorUpdate()
    {
        if (SolidStructuringPlugin.CurEditorCamera == null || BuildPipeline.isBuildingPlayer) return;

        float camDist = Vector3.Distance(SolidStructuringPlugin.CurEditorCamera.transform.position, transform.position);
        MeshRenderer.enabled = (!Application.isPlaying || EditorWindow.focusedWindow is SceneView) && (QuadBlock.QuadBlockType == QuadBlockType.StructureZone || camDist < 50 || IsFaceBeingModified || Selection.activeGameObject == gameObject);

        // Handle "IsFaceBeingModified"
        {
            if (IsFaceBeingModified && !_lastFaceState) // started modify, setup Draggers
            {
                {
                    var dragger = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    dragger.hideFlags = HideFlags.HideInInspector | HideFlags.DontSave;
                    dragger.GetComponent<MeshRenderer>().sharedMaterial = QuadBlock.DraggerMat;
                    DestroyImmediate(dragger.GetComponent<SphereCollider>());
                    dragger.transform.position = transform.TransformPoint(QuadTopLeft);
                    TopLeftDragger = dragger.transform;
                    dragger.name = "Temp_DragPoint";
                }
                {
                    var dragger = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    dragger.hideFlags = HideFlags.HideInInspector | HideFlags.DontSave;
                    dragger.GetComponent<MeshRenderer>().sharedMaterial = QuadBlock.DraggerMat;
                    DestroyImmediate(dragger.GetComponent<SphereCollider>());
                    dragger.transform.position = transform.TransformPoint(QuadTopRight);
                    TopRightDragger = dragger.transform;
                    dragger.name = "Temp_DragPoint";
                }
                {
                    var dragger = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    dragger.hideFlags = HideFlags.HideInInspector | HideFlags.DontSave;
                    dragger.GetComponent<MeshRenderer>().sharedMaterial = QuadBlock.DraggerMat;
                    DestroyImmediate(dragger.GetComponent<SphereCollider>());
                    dragger.transform.position = transform.TransformPoint(QuadBottomLeft);
                    BottomLeftDragger = dragger.transform;
                    dragger.name = "Temp_DragPoint";
                }
                {
                    var dragger = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    dragger.hideFlags = HideFlags.HideInInspector | HideFlags.DontSave;
                    dragger.GetComponent<MeshRenderer>().sharedMaterial = QuadBlock.DraggerMat;
                    DestroyImmediate(dragger.GetComponent<SphereCollider>());
                    dragger.transform.position = transform.TransformPoint(QuadBottomRight);
                    BottomRightDragger = dragger.transform;
                    dragger.name = "Temp_DragPoint";
                }
                okaySelections = new GameObject[] { QuadBlock.gameObject, TopLeftDragger.gameObject, TopRightDragger.gameObject, BottomLeftDragger.gameObject, BottomRightDragger.gameObject };
                oldPoses = new Vector2[] { QuadTopLeft, QuadTopRight, QuadBottomLeft, QuadBottomRight };

                List<Vector3> snaps = new List<Vector3>()
            {
                transform.TransformPoint(new Vector3(.5f, .5f)),
                transform.TransformPoint(new Vector3(-.5f, -.5f)),
                transform.TransformPoint(new Vector3(-.5f, .5f)),
                transform.TransformPoint(new Vector3(.5f, -.5f)),
            };
                List<(Vector3, Vector3)> lineSnaps = new List<(Vector3, Vector3)>()
            {
                (snaps[0], snaps[1]),
                (snaps[1], snaps[2]),
                (snaps[2], snaps[3]),
                (snaps[3], snaps[0]),
            };
                foreach (var qb in FindObjectsOfType<QuadBlock>())
                {
                    if (qb == null || qb == QuadBlock || qb.QuadBlockType == QuadBlockType.StructureZone)
                        continue;
                    foreach (var qf in qb.QuadFaces)
                    {
                        snaps.Add(qf.transform.TransformPoint(qf.QuadTopLeft));
                        snaps.Add(qf.transform.TransformPoint(qf.QuadTopRight));
                        snaps.Add(qf.transform.TransformPoint(qf.QuadBottomLeft));
                        snaps.Add(qf.transform.TransformPoint(qf.QuadBottomRight));

                        lineSnaps.Add((snaps[snaps.Count - 4], snaps[snaps.Count - 3]));
                        lineSnaps.Add((snaps[snaps.Count - 3], snaps[snaps.Count - 2]));
                        lineSnaps.Add((snaps[snaps.Count - 2], snaps[snaps.Count - 1]));
                        lineSnaps.Add((snaps[snaps.Count - 1], snaps[snaps.Count - 4]));
                    }
                }
                snappables = snaps.Distinct().ToArray();
                lineSnappables = lineSnaps.Distinct().ToArray();
            }
            if (TopLeftDragger == null) IsFaceBeingModified = false;
            if (IsFaceBeingModified) // modify per-frame
            {
                if (Array.IndexOf(okaySelections, Selection.activeGameObject) != -1)
                {
                    for (int i = 1; i < okaySelections.Length; i++)
                    {
                        var dragGobj = okaySelections[i];
                        dragGobj.transform.localScale = Vector3.one * Vector3.Distance(dragGobj.transform.position, SolidStructuringPlugin.CurEditorCamera.transform.position) * .05f;

                        Vector3 nearestPointOnLine(Vector3 point, Vector3 start, Vector3 end)
                        {
                            Vector3 lineVector = end - start;
                            float sqrLen = lineVector.sqrMagnitude;
                            Vector3 startToPoint = point - start;
                            float t = Vector3.Dot(startToPoint, lineVector) / sqrLen;
                            t = Mathf.Clamp01(t);
                            return start + t * lineVector;
                        }

                        float snapDist = .05f;
                        // possibly snap point to corner or other quads points
                        bool didSnap = false;
                        foreach (var snapPt in snappables)
                        {
                            // to point
                            if (Vector3.Distance(dragGobj.transform.position, snapPt) < snapDist)
                            {
                                dragGobj.transform.position = snapPt;
                                didSnap = true;
                                break;
                            }
                        }
                        if (!didSnap)
                            foreach (var line in lineSnappables)
                            {
                                Vector3 onLine = nearestPointOnLine(dragGobj.transform.position, line.Item1, line.Item2);
                                if (Vector3.Distance(dragGobj.transform.position, onLine) < snapDist)
                                {
                                    dragGobj.transform.position = onLine;
                                    break;
                                }
                            }

                        // Limit Pose to the Quad
                        Vector3 newPos = transform.InverseTransformPoint(dragGobj.transform.position);
                        newPos.z = 0;
                        newPos.x = Mathf.Clamp(newPos.x, -.5f, .5f);
                        newPos.y = Mathf.Clamp(newPos.y, -.5f, .5f);
                        dragGobj.transform.position = transform.TransformPoint(newPos);
                    }

                    QuadTopLeft = transform.InverseTransformPoint(TopLeftDragger.transform.position);
                    QuadBottomLeft = transform.InverseTransformPoint(BottomLeftDragger.transform.position);
                    QuadBottomRight = transform.InverseTransformPoint(BottomRightDragger.transform.position);
                    QuadTopRight = transform.InverseTransformPoint(TopRightDragger.transform.position);

                    QuadBlock.FindContainingStructure()?.UpdateMesh();
                }
                else
                {
                    IsFaceBeingModified = false;
                }
            }
            if (!IsFaceBeingModified && _lastFaceState) // ending modify, cleanup
            {
                _lastFaceState = false;
                if (TopLeftDragger != null) DestroyImmediate(TopLeftDragger.gameObject);
                if (BottomLeftDragger != null) DestroyImmediate(BottomLeftDragger.gameObject);
                if (TopRightDragger != null) DestroyImmediate(TopRightDragger.gameObject);
                if (BottomRightDragger != null) DestroyImmediate(BottomRightDragger.gameObject);

                // Setup undo & saving
                Vector2 newTopLeft = QuadTopLeft;
                Vector2 newTopRight = QuadTopRight;
                Vector2 newBottomLeft = QuadBottomLeft;
                Vector2 newBottomRight = QuadBottomRight;

                QuadTopLeft = oldPoses[0];
                QuadTopRight = oldPoses[1];
                QuadBottomLeft = oldPoses[2];
                QuadBottomRight = oldPoses[3];

                Undo.RecordObject(this, "Change of Quad Points");
                QuadTopLeft = newTopLeft;
                QuadTopRight = newTopRight;
                QuadBottomLeft = newBottomLeft;
                QuadBottomRight = newBottomRight;
                Undo.FlushUndoRecordObjects();

                PrefabUtility.RecordPrefabInstancePropertyModifications(this);
                EditorUtility.SetDirty(this);
            }

            _lastFaceState = IsFaceBeingModified;
        }

        // Handle "IsUVBeingModified"
        if (!_lastUVState && IsUVBeingModified)
        {
            if (materialChoice == null)
                IsUVBeingModified = false;
            else
            {
                targSpecification = QuadBlock.UVSettings?.FirstOrDefault(uvs => uvs.Face == this);
                specHolder = QuadBlock;

                if (targSpecification == null)
                {
                    targSpecification = QuadBlock.FindContainingStructure()?.UVSettings?.FirstOrDefault(uvs => uvs.material == materialChoice);
                    specHolder = QuadBlock.FindContainingStructure();
                }
                if (targSpecification == null)
                {
                    var containing = QuadBlock.FindContainingStructure();
                    if (containing != null)
                    {
                        targSpecification = new MaterialToUVSpec() { material = materialChoice, uvSpecification = new UVSpecification() };
                        containing.UVSettings.Add(targSpecification);
                    } else IsUVBeingModified = false;
                }

                if (IsUVBeingModified)
                {
                    var dragger = GameObject.CreatePrimitive(PrimitiveType.Cube);
                    dragger.hideFlags = HideFlags.DontSave;

                    DestroyImmediate(dragger.GetComponent<BoxCollider>());
                    dragger.GetComponent<MeshRenderer>().sharedMaterial = QuadBlock.DraggerMat;

                    Vector2 correctedOffset = targSpecification.uvSpecification.TextureMode == UVType.RepeatAcrossWorld ? (targSpecification.uvSpecification.Offset / QuadBlock.transform.localScale.magnitude) : targSpecification.uvSpecification.Offset;
                    Vector3 dragStartPos = transform.TransformPoint(new Vector2(-.5f, -.5f) + correctedOffset);
                    dragger.transform.position = dragStartPos;
                    dragger.transform.SetParent(transform);
                    dragger.transform.localEulerAngles = new Vector3(0, 0, targSpecification.uvSpecification.Rotation);
                    dragger.transform.SetParent(null);
                    dragger.transform.position = dragStartPos;
                    dragger.transform.localScale = new Vector3(1f / targSpecification.uvSpecification.Scale.x, 1f / targSpecification.uvSpecification.Scale.y, 1);

                    UVDragger = dragger.transform;
                    UVDragger.name = "Temp_DragPoint";
                    Selection.activeObject = UVDragger.gameObject;

                    oldPoses = new Vector2[] { targSpecification.uvSpecification.Offset, targSpecification.uvSpecification.Scale, new Vector2(targSpecification.uvSpecification.Rotation, 0) };

                    EditSettings = UVDragger.gameObject.AddComponent<UVEditSettings>();
                    EditSettings.Mode = targSpecification.uvSpecification.TextureMode;
                    EditSettings.UniqueUVs = specHolder == QuadBlock;
#if MARROW_SDK
                    EditSettings.BonelabSurfaceType.Barcode = targSpecification.uvSpecification.BonelabSurfaceType.Barcode;
#endif
                }
            }
        }
        if (IsUVBeingModified)
        {
            if (UVDragger == null) IsUVBeingModified = false;
            else if (Selection.activeObject != UVDragger.gameObject) IsUVBeingModified = false;

            if (IsUVBeingModified)
            {
                Vector3 pos = transform.InverseTransformPoint(UVDragger.position);
                pos.z = 0;
                UVDragger.position = transform.TransformPoint(pos);

                Vector2 offset = pos + new Vector3(.5f, .5f);

                if (targSpecification.uvSpecification.TextureMode == UVType.RepeatAcrossWorld)
                    offset *= QuadBlock.transform.localScale.magnitude;

                targSpecification.uvSpecification.Offset = offset;

                targSpecification.uvSpecification.Scale = new Vector2(1f / UVDragger.localScale.x, 1f / UVDragger.localScale.y);

                Vector3 prePos = UVDragger.position;
                Vector3 preSiz = UVDragger.localScale;
                Quaternion preRot = UVDragger.rotation;
                UVDragger.SetParent(transform);
                float gotRot = UVDragger.localEulerAngles.z;
                UVDragger.SetParent(null);
                UVDragger.rotation = preRot;
                UVDragger.position = prePos;
                UVDragger.localScale = preSiz;
                targSpecification.uvSpecification.Rotation = gotRot;


                bool wasReset = EditSettings.QuadFaceUpdate(this, targSpecification);
                if (wasReset) IsUVBeingModified = false;

                QuadBlock.FindContainingStructure()?.UpdateMesh();
            }
        }
        if (_lastUVState && !IsUVBeingModified)
        {
            _lastUVState = false;
            if (UVDragger != null)
                DestroyImmediate(UVDragger.gameObject);

            Vector2 newOffset = targSpecification.uvSpecification.Offset;
            Vector2 newScale = targSpecification.uvSpecification.Scale;
            float newRot = targSpecification.uvSpecification.Rotation;
            targSpecification.uvSpecification.Offset = oldPoses[0];
            targSpecification.uvSpecification.Scale = oldPoses[1];
            targSpecification.uvSpecification.Rotation = oldPoses[2].x;
            Undo.RecordObject(specHolder, "Change of Quad UVs");
            targSpecification.uvSpecification.Offset = newOffset;
            targSpecification.uvSpecification.Scale = newScale;
            targSpecification.uvSpecification.Rotation = newRot;
            Undo.FlushUndoRecordObjects();

            PrefabUtility.RecordPrefabInstancePropertyModifications(specHolder);
            EditorUtility.SetDirty(specHolder);
        }
        _lastUVState = IsUVBeingModified;
    }

}

public enum StretchDir : byte
{
    X,Y,Z,eX,eY,eZ
}

public static class QuadExtensions
{
    private static readonly Vector3[] dirs = new Vector3[] { Vector3.right, Vector3.up, Vector3.forward, Vector3.left, Vector3.down, Vector3.back };
    public static Vector3 ToDir(this StretchDir sd) => dirs[(byte)sd];

    public static Vector3 RoundToNearestCardinal(this Vector3 vector)
    {
        float absX = Mathf.Abs(vector.x);
        float absY = Mathf.Abs(vector.y);
        float absZ = Mathf.Abs(vector.z);

        Vector3 result = Vector3.zero;

        if (absX > absY && absX > absZ)
        {
            result.x = vector.x > 0 ? 1f : -1f;
        }
        else if (absY > absX && absY > absZ)
        {
            result.y = vector.y > 0 ? 1f : -1f;
        }
        else
        {
            result.z = vector.z > 0 ? 1f : -1f;
        }

        return result;
    }
}
#endif