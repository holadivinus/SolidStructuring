#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

public enum MouseSection
{
    Left, Right, Top, Bottom, TopLeft, BottomLeft, TopRight, BottomRight, Center
}
public enum QuadBlockType
{
    Solid, StructureZone
}

[ExecuteAlways]
public class QuadBlock : MonoBehaviour
{
    public QuadBlockType QuadBlockType = QuadBlockType.Solid;
    public MeshRenderer[] Quads;
    public QuadBlockFace[] QuadFaces;
    public GameObject[] QuadGobjs;
    public Material HoveredMat;
    public Material DeselectedMat;
    public Material NormalDeselectedMat;
    public Material NoCollideDeselectedMat;
    public Material ClipMat;
    public Material DraggerMat;
    public BoxCollider SelectionCollider;
    public string UniqueID;

    public void EnforceDeselectedMat()
    {
        foreach (var mat in Quads)
        {
            if (mat.sharedMaterial != ClipMat)
            mat.sharedMaterial = DeselectedMat;
        }
    }
    public void SetCollision(bool state)
    {
        UnityEngine.Object[] changed = new UnityEngine.Object[7];
        changed[0] = this;
        changed[1] = QuadFaces[0];
        changed[2] = QuadFaces[1];
        changed[3] = QuadFaces[2];
        changed[4] = QuadFaces[3];
        changed[5] = QuadFaces[4];
        changed[6] = QuadFaces[5];
        Undo.RecordObjects(changed, "Change QuadBlock Collision");

        NoCollision = state;
        DeselectedMat = NoCollision ? NoCollideDeselectedMat : NormalDeselectedMat;
        EnforceDeselectedMat();
        Undo.FlushUndoRecordObjects();
        foreach (var c in changed)
        {
            PrefabUtility.RecordPrefabInstancePropertyModifications(c);
            EditorUtility.SetDirty(c);
        }
        FindContainingStructure()?.UpdateMesh();
    }

    public MeshRenderer ActiveQuad 
    {
        get => _aq;
        set 
        {
            if (_aq == value) return;
            if (_aq != null) _aq.sharedMaterial = QuadFaces[Array.IndexOf(Quads, _aq)].materialChoice == null ? DeselectedMat : ClipMat;
            _aq = value;
            if (_aq != null) _aq.sharedMaterial = HoveredMat;
        }
    }
    private MeshRenderer _aq;
    public QuadBlockFace ActiveQuadFace => QuadFaces[Array.IndexOf(Quads, ActiveQuad)];


    public float EdgeSpan = 0.1f;
    [NonSerialized] public Vector2 MouseLocalPos;
    [NonSerialized] public Vector2 MousePos;
    [NonSerialized] public MouseSection MouseSection;

    public void HoverByNormal(Vector3 n)
    {
        n = transform.InverseTransformDirection(n);
        MeshRenderer o = null;
        if (n.x < -.1f) o = Quads[0];
        if (n.x > .1f) o = Quads[1];
        if (n.y < -.1f) o = Quads[2];
        if (n.y > .1f) o = Quads[3];
        if (n.z < -.1f) o = Quads[4];
        if (n.z > .1f) o = Quads[5];
        ActiveQuad = o;
    }

    public void UpdateMousePos(Vector3 worldMos)
    {
        MousePos = worldMos;
        Vector3 mouseInQuad = ActiveQuad.transform.InverseTransformPoint(worldMos);

        float uvX = Vector3.Distance(ActiveQuad.transform.TransformPoint(new Vector3(-.5f, mouseInQuad.y, 0)), worldMos);
        float uvY = Vector3.Distance(ActiveQuad.transform.TransformPoint(new Vector3(mouseInQuad.x, -.5f, 0)), worldMos);
        ActiveQuad.sharedMaterial?.SetVector("_MouseUV", new Vector4(uvX, uvY));
        MouseLocalPos = new Vector2(uvX, uvY);

        // determine mouse evil or not
        float ediCamDist;
        if (SolidStructuringPlugin.CurEditorCamera != null)
            ediCamDist = Vector3.Distance(ActiveQuad.transform.position, SolidStructuringPlugin.CurEditorCamera.transform.position);
        else ediCamDist = 10;
        float scaledEdgeSpan = EdgeSpan + ediCamDist/115f;
        ActiveQuad.sharedMaterial?.SetFloat("_EdgeSpan", scaledEdgeSpan);


        float boxSpan = scaledEdgeSpan * 2.5f;
        float quadSizeX = Vector3.Distance(ActiveQuad.transform.TransformPoint(new Vector3(-.5f, -.5f, 0)), ActiveQuad.transform.TransformPoint(new Vector3(.5f, -.5f, 0)));
        float quadSizeY = Vector3.Distance(ActiveQuad.transform.TransformPoint(new Vector3(-.5f, -.5f, 0)), ActiveQuad.transform.TransformPoint(new Vector3(-.5f, .5f, 0)));
        MouseSection sec;
        if (MouseLocalPos.x < boxSpan && MouseLocalPos.y < boxSpan)
            sec = MouseSection.BottomLeft;
        else if (MouseLocalPos.x < boxSpan && MouseLocalPos.y > quadSizeY - boxSpan)
            sec = MouseSection.TopLeft;
        else if (MouseLocalPos.x > quadSizeX - boxSpan && MouseLocalPos.y > quadSizeY - boxSpan)
            sec = MouseSection.TopRight;
        else if (MouseLocalPos.x > quadSizeX - boxSpan && MouseLocalPos.y < boxSpan)
            sec = MouseSection.BottomRight;
        else if (MouseLocalPos.x < scaledEdgeSpan)
            sec = MouseSection.Left;
        else if (MouseLocalPos.y < scaledEdgeSpan)
            sec = MouseSection.Bottom;
        else if (MouseLocalPos.x > quadSizeX - scaledEdgeSpan)
            sec = MouseSection.Right;
        else if (MouseLocalPos.y > quadSizeY - scaledEdgeSpan)
            sec = MouseSection.Top;
        else
            sec = MouseSection.Center;

        MouseSection = sec;
    }

    [Header("QuadBlock Config")]
    public Vector3 LastPosition;
    public Vector3 Scale;
    public bool NoCollision;

    [ContextMenu("Enforce Scale")]
    public void EnforceScale()
    {
        transform.localScale = Scale;

        var xUV1 = new MaterialPropertyBlock();
        xUV1.SetVector("_UVAdjust", new Vector4(Scale.z, Scale.y));
        Quads[0].SetPropertyBlock(xUV1);
        Quads[1].SetPropertyBlock(xUV1);

        var yUV1 = new MaterialPropertyBlock();
        yUV1.SetVector("_UVAdjust", new Vector4(Scale.z, Scale.x));
        Quads[2].SetPropertyBlock(yUV1);
        Quads[3].SetPropertyBlock(yUV1);

        var zUV = new MaterialPropertyBlock();
        zUV.SetVector("_UVAdjust", new Vector4(Scale.x, Scale.y));
        Quads[4].SetPropertyBlock(zUV);
        Quads[5].SetPropertyBlock(zUV);

        FindContainingStructure()?.UpdateMesh();
    }

    private void OnEnable()
    {
        hideFlags = HideFlags.DontSaveInBuild;
        SelectionCollider.hideFlags = HideFlags.DontSaveInBuild | HideFlags.HideInInspector;

        Scale = transform.localScale; // For some reason, QuadBlock.Scale won't serialize, despite using EditorUtility.SetDirty + PrefabUtility.RecordPrefabInstanceModifications + SerializedObject changes

        SolidStructuringPlugin.ShiftState += ShiftChange;
        EnforceScale();

        if (string.IsNullOrWhiteSpace(UniqueID))
        {
            UniqueID = GUID.Generate().ToString();
            PrefabUtility.RecordPrefabInstancePropertyModifications(this);
            EditorUtility.SetDirty(this);
        }

        SolidStructuringPlugin.EditorUpdate += EditorUpdate;
    }
    private void EditorUpdate()
    {
        if (BuildPipeline.isBuildingPlayer) return;


        if (QuadBlockType == QuadBlockType.StructureZone)
        {
            if (SolidStructuringPlugin.CurEditorCamera != null)
            {
                Vector3 camPos = SolidStructuringPlugin.CurEditorCamera.transform.position;
                camPos = transform.InverseTransformPoint(camPos);
                if (camPos.x > 0 && camPos.y > 0 && camPos.z > 0 && camPos.x < 1 && camPos.y < 1 && camPos.z < 1)
                {
                    // cam inside structure
                    SceneVisibilityManager.instance.DisablePicking(gameObject, true);
                    foreach (var q in Quads)
                        SceneVisibilityManager.instance.DisablePicking(q.gameObject, true);
                } else
                {
                    SceneVisibilityManager.instance.EnablePicking(gameObject, true);
                    foreach (var q in Quads)
                        SceneVisibilityManager.instance.EnablePicking(q.gameObject, true);
                }
            }
        }
    }
    private void ShiftChange(bool state)
    {
        if (QuadBlockType == QuadBlockType.Solid)
            SelectionCollider.enabled = state;
        if (QuadBlockType == QuadBlockType.StructureZone)
            SelectionCollider.enabled = Selection.activeGameObject == gameObject;
    }
    private void OnDisable() 
    {
        SolidStructuringPlugin.ShiftState -= ShiftChange;

        FindContainingStructure()?.UpdateMesh();
        SolidStructuringPlugin.EditorUpdate -= EditorUpdate;
    }

    private const bool FACES_DEBUG = false;

    [NonSerialized] Vector3 LastPoseSnap;
    [NonSerialized] Vector3 LastScaleSnap;
    [NonSerialized] Quaternion LastRot;
    private void Update()
    {
        if (BuildPipeline.isBuildingPlayer) return;

        if (!FACES_DEBUG)
        {
            if (Array.IndexOf(QuadGobjs, Selection.activeGameObject) != -1)
                Selection.activeGameObject = gameObject;

            foreach (var q in QuadGobjs)
            {

                q.hideFlags = (Selection.activeGameObject == gameObject && DragAndDrop.objectReferences.Length == 0) ? HideFlags.HideInHierarchy : HideFlags.None;
                q.hideFlags |= HideFlags.DontSaveInBuild;
            }
        }

        if (QuadBlockType == QuadBlockType.Solid)   
        {
            Vector3 locPos = transform.localPosition;
            transform.localPosition = SolidStructuringPlugin.SnapToGrid(transform.localPosition, ContainingStructureGrid, gameObject);
            if (transform.localScale != Scale)
            {
                Scale = SolidStructuringPlugin.SnapToGrid(transform.localScale, ContainingStructureGrid, gameObject);
                EnforceScale();
            }
            else if (transform.localPosition != LastPoseSnap || transform.localScale != LastScaleSnap || transform.localRotation != LastRot)
                FindContainingStructure()?.UpdateMesh();

            LastPoseSnap = transform.localPosition;
            LastScaleSnap = transform.localScale;
            LastRot = transform.localRotation;
        }
    }

    private QuadBlock _lastContainer;
    public QuadBlock FindContainingStructure()
    {
        bool shouldReparent = QuadBlockType == QuadBlockType.Solid && !BuildPipeline.isBuildingPlayer;

        foreach (var q in FindObjectsOfType<QuadBlock>())
            if (q.QuadBlockType == QuadBlockType.StructureZone)
                if (q.ContainsQuadBlock(this, shouldReparent))
                    return _lastContainer = q;


        _lastContainer?.UpdateMesh();

        //not contained
        if (shouldReparent && gameObject != null && gameObject.activeInHierarchy && _lastContainer != null && _lastContainer.QuadBlockHolder != null)
        {
            _lastContainer = null;
            transform.SetParent(null, true);
        }
        return null;
    }
    public Vector3 ContainingStructureGrid => FindContainingStructure()?.StructureGridSnappingV3 ?? Vector3.zero;
    public bool ContainsQuadBlock(QuadBlock block, bool reParentIfInside = false)
    {
        Vector3[] worldCorners = new Vector3[]
        {
            block.transform.TransformPoint(Vector3.zero),
            block.transform.TransformPoint(Vector3.one),
            block.transform.TransformPoint(Vector3.right),
            block.transform.TransformPoint(Vector3.forward),
            block.transform.TransformPoint(Vector3.up),
            block.transform.TransformPoint(Vector3.one / 2f),
        };
        foreach (var wC in worldCorners)
        {
            Vector3 lC = transform.InverseTransformPoint(wC);
            if (lC.x > 0 && lC.y > 0 && lC.z > 0 && lC.x < 1 && lC.y < 1 && lC.z < 1)
            {
                if (reParentIfInside && block.transform.parent != QuadBlockHolder && QuadBlockHolder != null)
                    block.transform.SetParent(QuadBlockHolder, true);

                return true;
            }
        }
        return false;
    }
    public void UpdateMesh()
    {
        if (this == null || BuildPipeline.isBuildingPlayer) return;

        Vector3[] oldVerts = null;
        if (StructureMeshFilter.sharedMesh == null)
        {
            StructureMeshFilter.sharedMesh = new Mesh();
        } else
        {
            oldVerts = StructureMeshFilter.sharedMesh.vertices;
        }


        Mesh m = StructureMeshFilter.sharedMesh;
        m.Clear();

        QuadBlock[] blocks;
        if (QuadBlockHolder == null)
        {
            var b = new List<QuadBlock>();
            foreach (var q in FindObjectsOfType<QuadBlock>())
            {
                if (q == null || q.QuadBlockType == QuadBlockType.StructureZone || !ContainsQuadBlock(q))
                    continue;
                b.Add(q);
            }
            blocks = b.ToArray();
        }
        else blocks = QuadBlockHolder.GetComponentsInChildren<QuadBlock>();

            List<Vector3> poses = new List<Vector3>();
        List<Vector2> uvs = new List<Vector2>();
        Dictionary<Material, List<int>> subMeshes = new Dictionary<Material, List<int>>();
        Dictionary<Material, MaterialToUVSpec> StructureUVOverrides = UVSettings.ToDictionary(m => m.material);

        // Gather Verts & Quads
        Vector3 ToLocal(Component t, Vector3 otherLocal) => transform.InverseTransformPoint(t.transform.TransformPoint(otherLocal));
        foreach (var q in blocks)
        {
            Dictionary<QuadBlockFace, MaterialToUVSpec> QuadUVOverrides = q.UVSettings?.Where(m => m.Face != null).ToDictionary(m => m.Face);
            foreach (var face in q.QuadFaces)
            {
                if (face.materialChoice != null)
                {
                    poses.Add(ToLocal(face, face.QuadBottomLeft));
                    poses.Add(ToLocal(face, face.QuadBottomRight));
                    poses.Add(ToLocal(face, face.QuadTopRight));
                    poses.Add(ToLocal(face, face.QuadTopLeft));

                    if (!subMeshes.ContainsKey(face.materialChoice))
                        subMeshes[face.materialChoice] = new List<int>();

                    subMeshes[face.materialChoice].Add(poses.Count - 1);
                    subMeshes[face.materialChoice].Add(poses.Count - 2);
                    subMeshes[face.materialChoice].Add(poses.Count - 3);

                    subMeshes[face.materialChoice].Add(poses.Count - 4);
                    subMeshes[face.materialChoice].Add(poses.Count - 1);
                    subMeshes[face.materialChoice].Add(poses.Count - 3);

                    void SetupUVs(MaterialToUVSpec @override)
                    {
                        if (@override != null)
                        {
                            Vector2 RotateV2(Vector2 i, float a)
                            { 
                                a = Mathf.Deg2Rad * a * -1;
                                return new Vector2((i.x * Mathf.Cos(a)) - (i.y * Mathf.Sin(a)), (i.x * Mathf.Sin(a)) + (i.y * Mathf.Cos(a)));
                            }

                            if (@override.uvSpecification.TextureMode == UVType.Stretched)
                            {
                                Vector2 GetStretchedUV(Vector2 c) => (RotateV2(c - @override.uvSpecification.Offset, @override.uvSpecification.Rotation) ) * @override.uvSpecification.Scale;
                                uvs.Add(GetStretchedUV(new Vector2(0, 0)));
                                uvs.Add(GetStretchedUV(new Vector2(1, 0)));
                                uvs.Add(GetStretchedUV(new Vector2(1, 1)));
                                uvs.Add(GetStretchedUV(new Vector2(0, 1)));
                                return;
                            }
                            if (@override.uvSpecification.TextureMode == UVType.RepeatAcrossWorld)
                            {
                                Vector3 card = (-face.transform.forward).RoundToNearestCardinal();
                                if (card.x != 0.0)
                                {
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomLeft).z * card.x, face.transform.TransformPoint(face.QuadBottomLeft).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomRight).z * card.x, face.transform.TransformPoint(face.QuadBottomRight).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopRight).z * card.x, face.transform.TransformPoint(face.QuadTopRight).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopLeft).z * card.x, face.transform.TransformPoint(face.QuadTopLeft).y));
                                }
                                else
                                if (card.y != 0.0)
                                {
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomLeft).z * card.y, face.transform.TransformPoint(face.QuadBottomLeft).x * -card.y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomRight).z * card.y, face.transform.TransformPoint(face.QuadBottomRight).x * -card.y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopRight).z * card.y, face.transform.TransformPoint(face.QuadTopRight).x * -card.y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopLeft).z * card.y, face.transform.TransformPoint(face.QuadTopLeft).x * -card.y));
                                }
                                else
                                if (card.z != 0.0)
                                {
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomLeft).x * -card.z, face.transform.TransformPoint(face.QuadBottomLeft).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadBottomRight).x * -card.z, face.transform.TransformPoint(face.QuadBottomRight).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopRight).x * -card.z, face.transform.TransformPoint(face.QuadTopRight).y));
                                    uvs.Add(new Vector2(face.transform.TransformPoint(face.QuadTopLeft).x * -card.z, face.transform.TransformPoint(face.QuadTopLeft).y));
                                }
                                Vector2 offset = -@override.uvSpecification.Offset;
                                uvs[uvs.Count - 4] += offset;
                                uvs[uvs.Count - 4] = RotateV2(uvs[uvs.Count - 4], @override.uvSpecification.Rotation);
                                uvs[uvs.Count - 4] *= @override.uvSpecification.Scale;
                                uvs[uvs.Count - 3] += offset;
                                uvs[uvs.Count - 3] = RotateV2(uvs[uvs.Count - 3], @override.uvSpecification.Rotation);
                                uvs[uvs.Count - 3] *= @override.uvSpecification.Scale;
                                uvs[uvs.Count - 2] += offset;
                                uvs[uvs.Count - 2] = RotateV2(uvs[uvs.Count - 2], @override.uvSpecification.Rotation);
                                uvs[uvs.Count - 2] *= @override.uvSpecification.Scale;
                                uvs[uvs.Count - 1] += offset;
                                uvs[uvs.Count - 1] = RotateV2(uvs[uvs.Count - 1], @override.uvSpecification.Rotation);
                                uvs[uvs.Count - 1] *= @override.uvSpecification.Scale;
                                return;
                            }
                            throw new NotImplementedException("uvs not handled for " + @override.uvSpecification.TextureMode);
                        }
                        else
                        {
                            uvs.Add(new Vector2(0, 0));
                            uvs.Add(new Vector2(1, 0));
                            uvs.Add(new Vector2(1, 1));
                            uvs.Add(new Vector2(0, 1));
                            return;
                        }
                    }
                    if (QuadUVOverrides != null && QuadUVOverrides.TryGetValue(face, out MaterialToUVSpec specA))
                        SetupUVs(specA);
                    else if (StructureUVOverrides != null && StructureUVOverrides.TryGetValue(face.materialChoice, out MaterialToUVSpec specB))
                        SetupUVs(specB);
                    else SetupUVs(null);
                }
            }
        }


        // Optimize by merging super-close verts
        /* Damnit, didn't realize merged verts = shared normals
        int big = 0;
        while (true)
        {
            int keepVert = -1;
            int redundantVert = -1;
            bool foundRedundancy = false;
            for (int i = 0; i < poses.Count-1; i++)
            {
                keepVert = i;
                for (int l = (i+1); l < poses.Count; l++)
                {
                    redundantVert = l;
                    if (Vector3.Distance(poses[keepVert], poses[redundantVert]) < .0001f)
                    {
                        foundRedundancy = true;
                        break;
                    }
                }
                if (foundRedundancy)
                    break;
            }
            if (!foundRedundancy) break;
            big++;
            if (big > 100000) throw new Exception("too much loop");

            // retarget all refs to redundantVert with keepVert
            foreach (var quads in subMeshes.Values)
                for (int i = 0; i < quads.Count; i++)
                    if (quads[i] == redundantVert)
                        quads[i] = keepVert;

            // Remove redundantVert
            poses.RemoveAt(redundantVert);

            // update refs to higher verts
            foreach (var quads in subMeshes.Values)
                for (int i = 0; i < quads.Count; i++)
                    if (quads[i] > redundantVert)
                        quads[i]--;
        }*/

        // Update mesh
        m.SetVertices(poses);
        m.subMeshCount = subMeshes.Count;
        int j = 0;
        foreach (var quads in subMeshes.Values)
        {
            m.SetIndices(quads, MeshTopology.Triangles, j);
            j++;
        }
        m.SetUVs(0, uvs);

        m.RecalculateNormals();
        m.RecalculateTangents();
        m.RecalculateBounds();

        if (poses.Count != 0)
            Unwrapping.GenerateSecondaryUVSet(m);

        StructureRenderer.sharedMaterials = subMeshes.Keys.ToArray();

        if (oldVerts != null && !oldVerts.SequenceEqual(m.vertices))
        {
            StructureRenderer.lightmapIndex = -1;
            PrefabUtility.RecordPrefabInstancePropertyModifications(StructureRenderer);
            EditorUtility.SetDirty(StructureRenderer);
        }

        // Colliders!!!
        if (BoxColliderHolder != null)
        {
            // Erase Cols
            List<GameObject> oldCols = new();
            for (int i = 0; i < BoxColliderHolder.childCount; i++)
            {
                if (BoxColliderHolder.GetChild(i) != null && BoxColliderHolder.GetChild(i).gameObject.name.EndsWith($"[{UniqueID}]"))
                    oldCols.Add(BoxColliderHolder.GetChild(i).gameObject);
            }
            foreach (var col in oldCols)
                DestroyImmediate(col);
            if (CollidersMode == StructureCollidersMode.Boxes && BoxColliderHolder != null)
            {
                int i = 1;
                foreach (var q in blocks)
                {
                    if (q.NoCollision)
                        continue;

                    var newCol = new GameObject($"Collider #{i++} [{UniqueID}]", typeof(BoxCollider));
                    newCol.transform.SetParent(BoxColliderHolder);
                    newCol.transform.position = q.transform.position;
                    newCol.transform.rotation = q.transform.rotation;
                    float scaleX = Vector3.Dot(q.transform.right, q.transform.TransformPoint(Vector3.right) - q.transform.position);
                    float scaleY = Vector3.Dot(q.transform.up, q.transform.TransformPoint(Vector3.up) - q.transform.position);
                    float scaleZ = Vector3.Dot(q.transform.forward, q.transform.TransformPoint(Vector3.forward) - q.transform.position);
                    newCol.transform.localScale = new Vector3(scaleX, scaleY, scaleZ);

                    BoxCollider c = newCol.GetComponent<BoxCollider>();
                    c.center = Vector3.one / 2f;

                    List<Material> mats = q.QuadFaces.Select(f => f.materialChoice).Where(m => m != null).ToList();
                    if (mats.Count == 0)
                        BonusMatWallSetup(null, c, null);
                    else
                    {
                        UVSpecification spec = null;
                        Material mot = null;
                        foreach (Material mat in mats)
                        {
                            mot = mat;
                            foreach (var vs in q.UVSettings) // get first quad-override uv spec 
                                if (vs.Face.materialChoice == mat)
                                {
                                    spec = vs.uvSpecification;
                                    break;
                                }
                            if (spec == null)
                                foreach (var vs in UVSettings) // get material based definition 
                                    if (vs.material == mat)
                                    {
                                        spec = vs.uvSpecification;
                                        break;
                                    }   

                            if (spec != null)
                                break;
                        }
                        BonusMatWallSetup(spec, c, mot);
                    }
                }
            }
            if (CollidersMode == StructureCollidersMode.MaterialUniqueBoxes && BoxColliderHolder != null)
            {
                foreach (var q in blocks)
                {
                    if (q.NoCollision)
                        continue;

                    var mats = q.QuadFaces.Select(f => f.materialChoice).Where(m => m != null).Distinct().ToArray();

                    if (mats.Length < 2) // super simple block
                    {
                        // Root Collider, usually acts as invisible walls
                        GameObject invisColGobj = new GameObject($"Invisible Wall [{UniqueID}]", typeof(BoxCollider));
                        invisColGobj.transform.SetParent(BoxColliderHolder);
                        invisColGobj.transform.position = q.transform.position;
                        invisColGobj.transform.rotation = q.transform.rotation;
                        float scaleX = Vector3.Dot(q.transform.right, q.transform.TransformPoint(Vector3.right) - q.transform.position);
                        float scaleY = Vector3.Dot(q.transform.up, q.transform.TransformPoint(Vector3.up) - q.transform.position);
                        float scaleZ = Vector3.Dot(q.transform.forward, q.transform.TransformPoint(Vector3.forward) - q.transform.position);
                        invisColGobj.transform.localScale = new Vector3(scaleX, scaleY, scaleZ);
                        BoxCollider invisCol = invisColGobj.GetComponent<BoxCollider>();
                        invisCol.center = Vector3.one / 2f;


                        if (mats.Length == 1)
                        {
                            // maybe do mat process thing for apps that take that
                            invisColGobj.name = $"{mats[0].name} [{UniqueID}]";
                            UVSpecification quadUVOverrides = q.UVSettings?.FirstOrDefault(uvs => uvs.material == mats[0])?.uvSpecification ?? UVSettings?.FirstOrDefault(uvs => uvs.material == mats[0])?.uvSpecification;
                            BonusMatWallSetup(quadUVOverrides, invisCol, mats[0]);
                        }
                        continue;
                    }

                    // setup cols per face
                    float[] scalz = new float[6];
                    for (int i = 0; i < q.QuadFaces.Length; i++)
                    {
                        QuadBlockFace f = q.QuadFaces[i];
                        if (f.materialChoice == null) continue;

                        Transform matColT = new GameObject($"{f.materialChoice.name} SubFace", typeof(BoxCollider)).transform;
                        BoxCollider matCol = matColT.GetComponent<BoxCollider>();
                        matCol.center = Vector3.one / 2f;
                        matCol.size = Vector3.one;

                        matColT.transform.SetParent(f.transform);
                        matColT.localPosition = new Vector3(-.5f, -.5f, 0);
                        matColT.localRotation = Quaternion.identity;
                        matColT.localScale = new Vector3(1, 1, MaterialColliderPercent);

                        float lengthWorld = Vector3.Distance(f.transform.TransformPoint(Vector3.zero), f.transform.TransformPoint(new Vector3(0, 0, 1)));
                        matColT.name += " - " + lengthWorld;
                        if (lengthWorld > MaterialColliderOverlapMax)
                        {
                            float newZ = f.transform.InverseTransformPoint(matColT.position + (matColT.forward * MaterialColliderOverlapMax)).z;
                            matColT.localScale = new Vector3(1, 1, newZ);
                        }
                        scalz[i] = matColT.localScale.z;

                        matColT.SetParent(BoxColliderHolder, true);
                        matColT.gameObject.name += $" [{UniqueID}]";

                        UVSpecification quadUVOverrides = q.UVSettings.FirstOrDefault(uvs => uvs.material == f.materialChoice)?.uvSpecification ?? UVSettings.FirstOrDefault(uvs => uvs.material == f.materialChoice)?.uvSpecification;
                        BonusMatWallSetup(quadUVOverrides, matCol, f.materialChoice);
                    }
                    // center collider
                    {
                        GameObject invisColGobj = new GameObject($"Invisible Wall [{UniqueID}]", typeof(BoxCollider));
                        invisColGobj.transform.SetParent(BoxColliderHolder);
                        invisColGobj.transform.position = q.transform.position;
                        invisColGobj.transform.rotation = q.transform.rotation;
                        float scaleX = Vector3.Dot(q.transform.right, q.transform.TransformPoint(Vector3.right) - q.transform.position);
                        float scaleY = Vector3.Dot(q.transform.up, q.transform.TransformPoint(Vector3.up) - q.transform.position);
                        float scaleZ = Vector3.Dot(q.transform.forward, q.transform.TransformPoint(Vector3.forward) - q.transform.position);
                        invisColGobj.transform.localScale = new Vector3(scaleX, scaleY, scaleZ);
                        BoxCollider invisCol = invisColGobj.GetComponent<BoxCollider>();
                        invisCol.center = Vector3.one / 2f;

                        // Scale inwards to avoid collision with mat cols
                        Vector3 scale = Vector3.one;
                        if (q.QuadFaces[0].materialChoice != null || q.QuadFaces[1].materialChoice != null)
                        {
                            float p = Mathf.Max(scalz[0], scalz[1]);
                            scale.x = Mathf.Clamp01(1 - (p * 2));
                        }
                        if (q.QuadFaces[2].materialChoice != null || q.QuadFaces[3].materialChoice != null)
                        {
                            float p = Mathf.Max(scalz[2], scalz[3]);
                            scale.y = Mathf.Clamp01(1 - (p * 2));
                        }
                        if (q.QuadFaces[4].materialChoice != null || q.QuadFaces[5].materialChoice != null)
                        {
                            float p = Mathf.Max(scalz[4], scalz[5]);
                            scale.z = Mathf.Clamp01(1 - (p * 2));
                        }
                        invisCol.size = scale;

                        if (scale.x == 0 || scale.y == 0 || scale.z == 0)
                            DestroyImmediate(invisColGobj);
                    }
                }
            }
        }

        // Light Probes!!!!
        if (AutoGenLightProbeGroup != null)
        {
            List<Vector3> probeOut = new();
            // Light Probe at Each corner & center of a face, if the face has a mat & the point isn't contained by any blocks
            foreach (var b in blocks)
            {
                foreach (var f in b.QuadFaces)
                {
                    if (f.materialChoice == null) continue;
                    Vector3 center = (f.QuadBottomLeft + f.QuadBottomRight + f.QuadTopLeft + f.QuadTopRight) / 4f;
                    foreach (var pose in new Vector3[] { f.QuadBottomLeft, f.QuadBottomRight, f.QuadTopLeft, f.QuadTopRight })
                    {
                        Vector3 worldPose = f.transform.TransformPoint(pose) + (f.transform.forward * -.5f);
                        worldPose = f.transform.InverseTransformPoint(worldPose);
                        worldPose -= center;
                        worldPose *= .9f;
                        worldPose += center;
                        worldPose = f.transform.TransformPoint(worldPose);

                        if (blocks.Any(blok => blok.ContainsPoint(worldPose)))
                            continue;
                        probeOut.Add(AutoGenLightProbeGroup.transform.InverseTransformPoint(worldPose));
                    }
                }
            }
            foreach (var l in UnityEngine.Object.FindObjectsOfType<Light>())
                if (l != null && l.lightmapBakeType == LightmapBakeType.Baked && ContainsPoint(l.transform.position))
                    probeOut.Add(AutoGenLightProbeGroup.transform.InverseTransformPoint(l.transform.position));

            List<Vector3> finProbes = new();
            // merge
            foreach (var a in probeOut)
            {
                if (!finProbes.Any(b => Vector3.Distance(a,b) < LightProbeCombineDist))
                    finProbes.Add(a);
            }

            

            AutoGenLightProbeGroup.probePositions = finProbes.ToArray();
        }
    }
    private void BonusMatWallSetup(UVSpecification uvs, BoxCollider wall, Material mat)
    {
#if MARROW_SDK
        MarrowSDKSupport.SetupMaterialWall(uvs, wall);
#endif
    }
    public bool ContainsPoint(Vector3 point)
    {
        Vector3 loc = transform.InverseTransformPoint(point);
        return (loc.x > 0 && loc.y > 0 && loc.z > 0 && loc.x < 1 && loc.y < 1 && loc.z < 1);
    }


    [Header("Structure Config")]
    public MeshRenderer StructureRenderer;
    public MeshFilter StructureMeshFilter;
    public StructureCollidersMode CollidersMode = StructureCollidersMode.Boxes;
    public Transform BoxColliderHolder;
    public Transform QuadBlockHolder;
    public LightProbeGroup AutoGenLightProbeGroup;
    public float FORCEDStructureGridSnapping = .5f;
    public Vector3 StructureGridSnappingV3 => FORCEDStructureGridSnapping * Vector3.one;
    public List<MaterialToUVSpec> UVSettings;

    [SerializeField] float MaterialColliderPercent = .1f;
    [SerializeField] float MaterialColliderOverlapMax = .2f;
    [SerializeField] float LightProbeCombineDist = 3f;
}
public enum StructureCollidersMode
{
    None, Boxes, MaterialUniqueBoxes
}
#endif