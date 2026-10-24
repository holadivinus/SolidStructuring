#if UNITY_EDITOR
using System.Linq;
using UnityEditor;
using UnityEngine;

[ExecuteAlways]
public class UVEditSettings : MonoBehaviour
{
    public bool Reset; // this should reaaaally just be a button
    public bool UniqueUVs;
    public UVType Mode;

    private void OnEnable()
    {
        if (GetComponent<MeshRenderer>())
        GetComponent<MeshRenderer>().hideFlags = HideFlags.HideInInspector;
        if (GetComponent<MeshFilter>())
        GetComponent<MeshFilter>().hideFlags = HideFlags.HideInInspector;
    }

    private bool _lastUniqueUVsState;
    private bool _init;
    public bool QuadFaceUpdate(QuadBlockFace face, MaterialToUVSpec uvSettings)
    {
        if (BuildPipeline.isBuildingPlayer) return false;

        if (!_init)
        {
            _lastUniqueUVsState = UniqueUVs;
            _init = true;
        }
        if (!_lastUniqueUVsState && UniqueUVs) // Unique UV's Enabled
        {
            _lastUniqueUVsState = true;


            if (!face.QuadBlock.UVSettings.Any(uvs => uvs.Face == face))
            {

                MaterialToUVSpec newSpec = new MaterialToUVSpec()
                {
                    Face = face,
                    uvSpecification = new UVSpecification()
                };
                face.QuadBlock.UVSettings.Add(newSpec);

                if (uvSettings != null)
                {
                    newSpec.uvSpecification.Offset = newSpec.uvSpecification.TextureMode == UVType.Stretched ? uvSettings.uvSpecification.Offset : uvSettings.uvSpecification.Offset * face.QuadBlock.transform.localScale.magnitude;
                    newSpec.uvSpecification.Scale = uvSettings.uvSpecification.Scale;
                    newSpec.uvSpecification.TextureMode = uvSettings.uvSpecification.TextureMode;
                    newSpec.uvSpecification.Rotation = uvSettings.uvSpecification.Rotation;
                }
                uvSettings = newSpec;
            }
            return true;
        }
        if (_lastUniqueUVsState && !UniqueUVs)
        {
            _lastUniqueUVsState = false;
            face.QuadBlock.UVSettings.Remove(uvSettings);
            return true;
        }

        uvSettings.uvSpecification.TextureMode = Mode;

        if (Reset)
        {
            uvSettings.uvSpecification.Offset = Vector2.zero;
            uvSettings.uvSpecification.Scale = Vector2.one;
            uvSettings.uvSpecification.Rotation = 0;
            uvSettings.uvSpecification.TextureMode = UVType.Stretched;

            Mode = UVType.Stretched;
            
            Reset = false;
            return true;
        }
        return false;
    }
}
#endif