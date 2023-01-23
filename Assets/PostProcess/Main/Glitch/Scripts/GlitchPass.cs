using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace TK.Rendering.PostProcess
{

    public class GlitchPass : PostProcessBasePass<Glitch>
    {
        private static readonly int TempBlurBuffer1 = 
            UnityEngine.Shader.PropertyToID("_TempBlurBuffer1");

        
        static readonly int _DataParams = Shader.PropertyToID("_DataParams");
        static readonly int _LayerParams = Shader.PropertyToID("_LayerParams");
        static readonly int _IntensityData = Shader.PropertyToID("_IntensityDataParams");

        private float TimeX = 1.0f;

        public GlitchPass(RenderPassEvent renderPassEvent, Shader shader) : base(renderPassEvent, shader)
        {
        }

        protected override string RenderTag => "Glitch";

        protected override void BeforeRender(CommandBuffer commandBuffer, ref RenderingData renderingData)
        {
            TimeX += Time.deltaTime;
            if (TimeX > 100)
            {
                TimeX = 0;
            }

            Material.SetVector(_DataParams, new Vector3(TimeX * Component._Speed.value, 
                Component._Amount.value, Component._Fade.value));
            Material.SetVector(_LayerParams, 
                new Vector4(Component._Layer1.value, Component._Layer1_2.value,
                Component._Layer2.value, Component._Layer2_2.value));
            Material.SetVector(_IntensityData, 
                new Vector3(Component.RGBSplit.value, Component._Indensity1.value,
                Component._Indensity2.value));

        }

        protected override void Render(CommandBuffer commandBuffer, 
            ref RenderingData renderingData, RenderTargetIdentifier source,
            RenderTargetIdentifier dest)
        {

            if (Component._isDebug.value)
            {
                commandBuffer.Blit(source, dest, Material, 1);
            }
            else
            {
                commandBuffer.Blit(source, dest, Material, 0);
            }
            commandBuffer.ReleaseTemporaryRT(TempBlurBuffer1);
        }

        protected override bool IsActive()
        {
            return Component.IsActive();
        }
    }
}