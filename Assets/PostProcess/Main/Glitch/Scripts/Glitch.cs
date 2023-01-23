using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

namespace TK.Rendering.PostProcess
{
    [VolumeComponentMenu("TK/CustomGlitch")]
    public class Glitch : VolumeComponent
    {

        public ClampedFloatParameter _Fade = new ClampedFloatParameter(0f, 0f, 1f);
        public ClampedFloatParameter _Speed = new ClampedFloatParameter(0.5f, 0f, 1f);
        public FloatParameter _Amount = new ClampedFloatParameter(1f, 0f, 10f);
        public FloatParameter _Layer1 = new ClampedFloatParameter(9f, 0f, 50f);
        public FloatParameter _Layer1_2 = new ClampedFloatParameter(9f, 0f, 50f);
        public FloatParameter _Layer2 = new ClampedFloatParameter(5f, 0f, 50f);
        public FloatParameter _Layer2_2 = new ClampedFloatParameter(5f, 0f, 50f);
        public FloatParameter _Indensity1 = new ClampedFloatParameter(8f, 0f, 50f);
        public FloatParameter _Indensity2 = new ClampedFloatParameter(4f, 0f, 50f);
        public FloatParameter RGBSplit = new ClampedFloatParameter(0.5f, 0f, 50f);

        public BoolParameter _isDebug = new BoolParameter(false);

        public bool IsActive() => _Fade.value > 0;
    }
}
