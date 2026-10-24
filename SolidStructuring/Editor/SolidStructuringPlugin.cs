#if UNITY_EDITOR
using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;

[InitializeOnLoad]
public static class SolidStructuringPlugin
{
    static SolidStructuringPlugin()
    {
        EditorApplication.update += Update;
        SceneView.duringSceneGui += SceneViewUpdate;


        System.Reflection.FieldInfo info = typeof(EditorApplication).GetField("globalEventHandler", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic);
        EditorApplication.CallbackFunction value = (EditorApplication.CallbackFunction)info.GetValue(null);
        value += EditorEvent;
        info.SetValue(null, value);
    }

    public static Action DragDropped = delegate { };
    public static Action EditorUpdate = delegate { };

    public static Vector3 SnapToGrid(Vector3 posOrScale, Vector3 grid, GameObject target)
    {
        if (grid == Vector3.zero || (target != null && (Selection.objects.Length > 1 || Array.IndexOf(Selection.objects, target) == -1))) return posOrScale;
        float x = Mathf.Round(posOrScale.x / grid.x) * grid.x;
        float y = Mathf.Round(posOrScale.y / grid.y) * grid.y;
        float z = Mathf.Round(posOrScale.z / grid.z) * grid.z;
        return new Vector3(x, y, z);
    }

    public static Camera CurEditorCamera;
    static VisualElement CurSceneViewRoot 
    {
        get => _csvr;
        set
        {
            if (value == _csvr) return;

            if (_csvr != null)
            {
                _csvr.UnregisterCallback<MouseMoveEvent>(MouseMoved);
                _csvr.UnregisterCallback<MouseDownEvent>(MouseClick);
                _csvr.UnregisterCallback<MouseUpEvent>(MouseUnClick);
            }

            _csvr = value;

            if (value != null)
            {
                _csvr.RegisterCallback<MouseMoveEvent>(MouseMoved);
                _csvr.RegisterCallback<MouseDownEvent>(MouseClick);
                _csvr.RegisterCallback<MouseUpEvent>(MouseUnClick);
                _csvr.RegisterCallback<MouseUpEvent>(MouseUnClick);
            }
        }
    }
    static VisualElement _csvr;
    static void MouseMoved(MouseMoveEvent mosMov) => MouseXY = mosMov.localMousePosition;
    static void MouseClick(MouseDownEvent mosDwn)
    {
        if (mosDwn.button == 0) M1Down = true;
        if (mosDwn.button == 1) M2Down = true;
        if (mosDwn.button == 0 && CurHover != null && !ActivelyDragging)
        {
            ActivelyDragging = true;
            DragPointStart = Mouse3DHitPosition;
            DragPlaneDir = Mouse3DHitNormal;
            DragQuadStartPos = CurHover.transform.localPosition;
            DragQuadStartSize = CurHover.transform.localScale;
            DragType = CurHover.MouseSection;
        }
        if (mosDwn.button == 1 && CurHover != null && !ActivelyDragging)
        {
            CurHover.ActiveQuadFace.MeshRenderer.sharedMaterial = CurHover.ActiveQuadFace.materialChoice;
            Undo.RecordObjects(new UnityEngine.Object[] { CurHover.ActiveQuadFace.MeshRenderer }, "Clear QuadBlock Material");
            CurHover.ActiveQuadFace.MeshRenderer.sharedMaterial = null;
            EditorUtility.SetDirty(CurHover.ActiveQuadFace.MeshRenderer);
            Undo.FlushUndoRecordObjects();
        }
    }
    public static bool M1Down;
    public static bool M2Down;
    static void MouseUnClick(MouseUpEvent mosUp)
    {
        if (mosUp.button == 0) M1Down = false;
        if (mosUp.button == 1) M2Down = false;
        if (mosUp.button == 0 && ActivelyDragging)
        {
            ActivelyDragging = false;

            Vector3 finScale = CurHover.Scale;
            Vector3 finPos = CurHover.transform.localPosition;

            CurHover.transform.localPosition = DragQuadStartPos;
            CurHover.Scale = CurHover.transform.localScale = DragQuadStartSize;
            Undo.RecordObjects(new UnityEngine.Object[] { CurHover, CurHover.transform }, "Modify QuadBlock");
            CurHover.transform.localPosition = finPos;
            CurHover.transform.localScale = CurHover.transform.localScale = finScale;
            EditorUtility.SetDirty(CurHover);
            EditorUtility.SetDirty(CurHover.transform);
            PrefabUtility.RecordPrefabInstancePropertyModifications(CurHover);
            PrefabUtility.RecordPrefabInstancePropertyModifications(CurHover.transform);
            Undo.FlushUndoRecordObjects();
        }
    }
    static void EditorEvent()
    {
        if (Event.current.type == EventType.KeyDown)
        {
            if (Event.current.keyCode == KeyCode.LeftShift && !M2Down)
            {
                LeftShiftPressed = true;
                ShiftState.Invoke(true);
            }
            if (LeftShiftPressed && Event.current.keyCode == KeyCode.R)
                PendingRScan = true;
            if (LeftShiftPressed && Event.current.keyCode == KeyCode.C)
                PendingCScan = true;
        }

        void ShiftKeyUp()
        {
            LeftShiftPressed = false;
            ShiftState.Invoke(false);
        }
        if (M2Down && LeftShiftPressed)
            ShiftKeyUp();
        if (Event.current.type == EventType.KeyUp)
        {
            if (Event.current.keyCode == KeyCode.LeftShift)
                ShiftKeyUp();
            if (Event.current.control && (Event.current.keyCode == KeyCode.Z || Event.current.keyCode == KeyCode.Y))
            {
                // Undo/Redo happened!
                foreach (var q in UnityEngine.Object.FindObjectsOfType<QuadBlock>())
                {
                    if (q.QuadBlockType == QuadBlockType.StructureZone && q != null)
                    {
                        q.UpdateMesh();
                    }
                }
            }
        }
    }

    public static Action<bool> ShiftState = delegate { };
    public static bool LeftShiftPressed;
    static bool PendingRScan;
    static bool PendingCScan;
    static Vector2 MouseXY;
    static Vector3 Mouse3DHitPosition;
    static Vector3 Mouse3DHitNormal;
    static Ray MouseRay;

    static void SceneViewUpdate(SceneView sv)
    {
        MouseRay = HandleUtility.GUIPointToWorldRay(MouseXY);
        if (ActivelyDragging || CurHover != null)
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
    }

    static bool IsDragNDropping;
    static void Update()
    {
        try
        {
            EditorUpdate.Invoke();
        }
        catch (Exception ex) 
        {
            Debug.LogException(ex); 
        }

        QuadBlock newHover = null;
        if (ActivelyDragging)
        {
            newHover = CurHover;

            Vector3 difference = DragPointStart - MouseRay.origin;
            float product_1 = Vector3.Dot(difference, DragPlaneDir);
            float product_2 = Vector3.Dot(MouseRay.direction, DragPlaneDir);
            float distance_from_origin_to_plane = product_1 / product_2;
            Vector3 intersection = MouseRay.origin + MouseRay.direction * distance_from_origin_to_plane;

            Vector3 worldDiff = intersection - DragPointStart;
            Vector3 gridSpec = CurHover.FindContainingStructure()?.StructureGridSnappingV3 ?? Vector3.zero;

            void ApplyStretch(float diffA, StretchDir dirA, float diffB, StretchDir dirB)
            {
                float x = DragQuadStartSize.x;
                float y = DragQuadStartSize.y;
                float z = DragQuadStartSize.z;

                float pX = 0;
                float pY = 0;
                float pZ = 0;

                void FigureScale(StretchDir dir, float diff)
                {
                    switch (dir)
                    {
                        case StretchDir.X:
                            x += diff;
                            if (x < 0)
                            {
                                x = -x;
                                pX += diff + DragQuadStartSize.x;
                            }
                            break;
                        case StretchDir.Y:
                            y += diff;
                            if (y < 0)
                            {
                                y = -y;
                                pY += diff + DragQuadStartSize.y;
                            }
                            break;
                        case StretchDir.Z:
                            z += diff;
                            if (z < 0)
                            {
                                z = -z;
                                pZ += diff + DragQuadStartSize.z;
                            }
                            break;
                        case StretchDir.eX:
                            pX -= diff;
                            x += diff;
                            if (x < 0)
                            {
                                x = -x;
                                pX += diff + DragQuadStartSize.x;
                            }
                            break;
                        case StretchDir.eY:
                            pY -= diff;
                            y += diff;
                            if (y < 0)
                            {
                                y = -y;
                                pY += diff + DragQuadStartSize.y;
                            }
                            break;
                        case StretchDir.eZ:
                            pZ -= diff;
                            z += diff;
                            if (z < 0)
                            {
                                z = -z;
                                pZ += diff + DragQuadStartSize.z;
                            }
                            break;
                        default:
                            break;
                    }
                }
                FigureScale(dirA, diffA);
                FigureScale(dirB, diffB);



                CurHover.transform.localScale = Vector3.one;
                CurHover.transform.localPosition = SnapToGrid(DragQuadStartPos + CurHover.transform.TransformDirection(new Vector3(pX,pY, pZ)), gridSpec, null);

                CurHover.Scale = SnapToGrid(new Vector3(x, y, z), gridSpec, null);
                CurHover.EnforceScale();
            }

            switch (DragType)
            {
                case MouseSection.Center:
                    CurHover.transform.localPosition = DragQuadStartPos + worldDiff;
                    break;
                default:
                    Vector3 localDragDir = CurHover.ActiveQuadFace.FromMousePose(DragType, out StretchDir primaryStretch, out Vector3 bonusLocalDragDir, out StretchDir secondaryStretch);

                    Vector3 cs = CurHover.transform.localScale;
                    CurHover.transform.localScale = Vector3.one;
                    Vector3 localDiff = CurHover.transform.InverseTransformPoint(intersection) - CurHover.transform.InverseTransformPoint(DragPointStart);
                    CurHover.transform.localScale = cs;

                    float changeAlongAxis = Vector3.Dot(localDiff, localDragDir);
                    float changeAlongAxis2 = Vector3.Dot(localDiff, bonusLocalDragDir);

                    ApplyStretch(changeAlongAxis, primaryStretch, changeAlongAxis2, secondaryStretch);
                    break;
            }

            CurHover.transform.localPosition = SnapToGrid(CurHover.transform.localPosition, gridSpec, null);

            if (CurHover.QuadBlockType == QuadBlockType.StructureZone)
                CurHover.UpdateMesh();
        }
        else if (EditorWindow.mouseOverWindow is SceneView sv)
        {
            CurEditorCamera = sv.camera;
            CurSceneViewRoot = sv.rootVisualElement.Q("unity-scene-view-camera-rect");

            if (LeftShiftPressed)
            {
                RaycastHit[] hits = Physics.RaycastAll(MouseRay);
                RaycastHit? hit = null;
                float nearest = float.MaxValue;
                foreach (var h in hits)
                    if (h.collider.GetComponent<QuadBlock>() != null && Vector3.Distance(h.point, MouseRay.origin) < nearest)
                    {
                        hit = h;
                        nearest = Vector3.Distance(h.point, MouseRay.origin);
                    }   
                if (hit != null)
                {
                    RaycastHit hitInfo = hit.Value;
                    Mouse3DHitPosition = hitInfo.point;
                    Mouse3DHitNormal = hitInfo.normal;
                    newHover = hitInfo.collider.GetComponent<QuadBlock>();
                    if (newHover != null)
                    {
                        newHover.HoverByNormal(hitInfo.normal);
                        newHover.UpdateMousePos(hitInfo.point);
                    }

                    if (PendingRScan)
                    {
                        PendingRScan = false;
                        if (newHover.QuadBlockType == QuadBlockType.Solid && newHover.ActiveQuadFace.materialChoice != null)
                        {
                            Selection.activeGameObject = newHover.gameObject;

                            if (!newHover.ActiveQuadFace.IsFaceBeingModified)
                            {
                                newHover.ActiveQuadFace.IsFaceBeingModified = true;
                                newHover.ActiveQuadFace.IsUVBeingModified = false;
                            }
                            else
                            {
                                // Pressed R twice, do UV editting
                                newHover.ActiveQuadFace.IsFaceBeingModified = false;
                                newHover.ActiveQuadFace.IsUVBeingModified = true;
                            }
                        }
                    }
                    if (PendingCScan)
                    {
                        PendingCScan = false;
                        if (newHover.QuadBlockType == QuadBlockType.Solid)
                        {
                            newHover.SetCollision(!newHover.NoCollision);

                        }
                    }
                }
            }
        }
        else
        {
            CurSceneViewRoot = null;
        }
        CurHover = newHover;

        if (DragAndDrop.objectReferences.Length == 0 && IsDragNDropping)
        {
            // dropped
            DragDropped.Invoke();
        }
        IsDragNDropping = DragAndDrop.objectReferences.Length > 0;
    }

    static bool ActivelyDragging;
    static Vector3 DragPointStart;
    static Vector3 DragPlaneDir;
    static Vector3 DragQuadStartPos;    
    static Vector3 DragQuadStartSize;
    static MouseSection DragType;

    static QuadBlock CurHover 
    {
        get => _ch;
        set 
        {
            if (_ch == value) return;
            if (_ch != null) _ch.HoverByNormal(Vector2.zero);
            _ch = value;
        }
    }
    private static QuadBlock _ch;


    private static string _prp;
    public static string PackageRootPath
    {
        get
        {
            if (_prp != null)
                return _prp;

            var tQ = new GameObject("lol", typeof(UVEditSettings)).GetComponent<UVEditSettings>();
            string qBPath = AssetDatabase.GetAssetPath(MonoScript.FromMonoBehaviour(tQ));
            UnityEngine.Object.DestroyImmediate(tQ.gameObject);
            _prp = qBPath.Replace("UVEditSettings.cs", "");
            return _prp;
        }
    }

    [MenuItem("GameObject/3D Object/QuadBlock", false, 10)]
    private static void SpawnQuadBlock(MenuCommand menuCommand)
    {
        GameObject prefabAsset = AssetDatabase.LoadAssetAtPath<GameObject>(PackageRootPath + "QuadBlock.prefab");

        GameObject instance = UnityEngine.Object.Instantiate(prefabAsset);
        if (Selection.activeTransform != null)
            instance.transform.SetParent(Selection.activeTransform, false);
        instance.name = "QuadBlock";
        instance.transform.rotation = Quaternion.identity;
        instance.transform.position = SolidStructuringPlugin.CurEditorCamera.transform.position + SolidStructuringPlugin.CurEditorCamera.transform.forward * 4f;

        Undo.RegisterCreatedObjectUndo(instance, "Create " + instance.name);
        Selection.activeObject = instance;
    }
    [MenuItem("GameObject/3D Object/StructureBox", false, 10)]
    private static void SpawnStructureBox(MenuCommand menuCommand)
    {
        GameObject prefabAsset = AssetDatabase.LoadAssetAtPath<GameObject>(PackageRootPath + "StructureBox.prefab");

        GameObject instance = UnityEngine.Object.Instantiate(prefabAsset);
        if (Selection.activeTransform != null)
            instance.transform.SetParent(Selection.activeTransform, false);
        instance.name = "StructureBox";
        instance.transform.rotation = Quaternion.identity;
        instance.transform.position = SolidStructuringPlugin.CurEditorCamera.transform.position + SolidStructuringPlugin.CurEditorCamera.transform.forward * 4f;

        Undo.RegisterCreatedObjectUndo(instance, "Create " + instance.name);
        Selection.activeObject = instance;
    }
}
#endif