using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[ExecuteInEditMode]
public class PixelEffect : MonoBehaviour
{
    public Material effect;
    //Source, render de la camara y destination la imagen final
    private void OnRendererImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination,effect );
    }
   
   

    // Update is called once per frame
    void Update()
    {
        
    }
}
