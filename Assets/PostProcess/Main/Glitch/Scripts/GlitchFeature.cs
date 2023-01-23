using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

namespace TK.Rendering.PostProcess
{
    public class GlitchFeature : ScriptableRendererFeature
    {
        [System.Serializable]
        public class Settings
        {
            public RenderPassEvent renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            public Shader shader;
        }

        public Settings settings = new Settings();

        private GlitchPass _pass;

        public override void Create()
        {
            this.name = "Glitch";
            settings.shader = Shader.Find("TK/Custom/Glitch");
            _pass = new GlitchPass(settings.renderPassEvent, settings.shader);
        }

        public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
        {
            _pass.Setup(renderer.cameraColorTarget);
            renderer.EnqueuePass(_pass);
        }
    }
}
