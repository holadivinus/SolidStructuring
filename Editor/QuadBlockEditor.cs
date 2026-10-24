using System;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

[CustomEditor(typeof(QuadBlock))]
public class QuadBlockEditor : Editor
{
    [SerializeField] VisualTreeAsset _treeAsset;
    public override VisualElement CreateInspectorGUI()
    {
        VisualElement root = new VisualElement();
        QuadBlock q = (QuadBlock)target;

        var ui = _treeAsset.Instantiate();
        root.Add(ui);

        MatColSettings = ui.Q("MatColSettings");
        ColliderDropdown = ui.Q<EnumField>("MatColChoice");

        ColliderDropdown.RegisterValueChangedCallback(e =>
        {
            HandleMatColSettings(e.newValue);
        });
        HandleMatColSettings(q.CollidersMode);

        ui.Q("StructureBoxUI").style.display = q.QuadBlockType == QuadBlockType.StructureZone ? DisplayStyle.Flex : DisplayStyle.None;
        ui.Q("QuadBlockUI").style.display = q.QuadBlockType == QuadBlockType.Solid ? DisplayStyle.Flex : DisplayStyle.None;

        ui.Q<Button>("ColToggle").clicked += () => q.SetCollision(!q.NoCollision);
        return root;
    }

    EnumField ColliderDropdown;
    VisualElement MatColSettings;
    private void HandleMatColSettings(System.Enum val)
    {
        MatColSettings.style.display = val.Equals(StructureCollidersMode.MaterialUniqueBoxes) ? DisplayStyle.Flex : DisplayStyle.None;
    }
}
