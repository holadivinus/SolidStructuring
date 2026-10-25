#if UNITY_EDITOR
#if MARROW_SDK
using SLZ.Marrow;
using UnityEngine;

public static class MarrowSDKSupport
{
    public static void SetupMaterialWall(UVSpecification uvs, BoxCollider wall)
    {
        var impactProps = wall.gameObject.AddComponent<ImpactProperties>();
        impactProps.decalType = ImpactProperties.DecalType.Collider;

        void SetBarCode(string b) => impactProps.SurfaceDataCard = new SLZ.Marrow.Warehouse.DataCardReference<SLZ.Marrow.Warehouse.SurfaceDataCard>(new SLZ.Marrow.Warehouse.Barcode(b));

        if (uvs == null)
        {
            SetBarCode("SLZ.Backlot.SurfaceDataCard.Default");
            return;
        }
        SetBarCode(uvs.BonelabSurfaceType.Barcode.ID);

        if (impactProps.SurfaceDataCard.TryGetDataCard(out var dataCard))
        {
            wall.sharedMaterial = dataCard.PhysicsMaterialStatic.EditorAsset;
        }
    }
}
#endif
#endif