using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


[SerializeField]
[PostProcess(typeof(OutlineEffectRenderer), PostProcessEvent.AfterStack, "Custom/OutlineEffect")]
public class OutlineEffect : PostProcessEffectSettings
{
    [Range(1f, 5f), Tooltip("Outline thickness")]
    public IntParameter thickness = new IntParameter { value = 2 };

    [Range(0f, 5f), Tooltip("Outline edge start")]
    public FloatParameter edge = new FloatParameter { value = 0.1f };

    //Suavidad para los objetos cercanos
    [Range(0f, 1f), Tooltip("Outline smoothness transition on close objects")]
    public FloatParameter transitionSmoothess = new FloatParameter { value = 0.2f };

    //Color
    [Tooltip("Outline color")]
    public ColorParameter color = new ColorParameter { value = Color.black };

}

public sealed class OutlineEffectRenderer : PostProcessEffectRenderer<OutlineEffect>
{
    public override void Render(PostProcessRenderContext context)
    {
        //Encontrar shader y variables a editar
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Custom/OutlineEffect"));
        sheet.properties.SetFloat("_Thickness", settings.thickness);
        sheet.properties.SetFloat("_TransitionSmoothness", settings.transitionSmoothess);
        sheet.properties.SetColor("_Color", settings.color);
        sheet.properties.SetFloat("_Edge", settings.edge);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}
