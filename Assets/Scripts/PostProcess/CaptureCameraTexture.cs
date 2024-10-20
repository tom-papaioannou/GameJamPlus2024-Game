using UnityEngine;

[ExecuteInEditMode]
public class CaptureCameraTexture : MonoBehaviour
{
    [SerializeField] private Material mat;
    [SerializeField] private RenderTexture m_Texture;
    [SerializeField] private Camera secondCamera;

    void OnEnable()
    {
        // Set the second camera's target texture when the script is enabled
        if (secondCamera != null)
        {
            secondCamera.targetTexture = m_Texture;
            mat.SetTexture("_MainTex", m_Texture);
            
        }
    }

    private void OnDisable()
    {
        // Reset the second camera's target texture when the script is disabled
        if (secondCamera != null)
        {
            secondCamera.targetTexture = null;
        }
    }

}
