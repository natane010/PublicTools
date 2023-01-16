using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace TK.MetaBall
{
    [System.Serializable]
    public struct MetaData
    {
        public Color ballColor;
        public float radius;

    }
    [ExecuteAlways]
    public class MetaController : MonoBehaviour
    {
        const int MaxCount = 256;
        readonly Vector4[] m_circles = new Vector4[MaxCount];
        [SerializeField] Metaball[] m_metaball;
        Vector4[] m_colors = new Vector4[MaxCount];
        Metaball[] m_metaColors = new Metaball[MaxCount];

        [SerializeField] float radiusper = 1;

        [SerializeField] Material m_material;
        private void Start()
        {

            SetColor();
        }
        private void Update()
        {
#if UNITY_EDITOR
            SetColor();
#endif

            for (int i = 0; i < m_metaball.Length; i++)
            {
                Metaball meta = m_metaball[i];
                Transform tf = meta.transform;
                Debug.Log(tf.position);
                Vector3 center = tf.position;
                float radius = (tf.lossyScale.x + meta.metaData.radius) / radiusper;
                m_circles[i] = new Vector4(center.x, center.y, center.z, radius);
            }
            m_material.SetVectorArray("_Circles", m_circles);
        }
        void SetColor()
        {
            for (int i = 0; i < m_metaball.Length; i++)
            {
                m_metaColors[i] = m_metaball[i].GetComponent<Metaball>();
            }

            Debug.Log("set:" + m_metaball.Length);
            m_material.SetInt("_CircleCount", m_metaball.Length);
            for (var i = 0; i < m_metaball.Length; i++)
            {

                Debug.LogError(m_metaColors[i].metaData.ballColor);
                Vector4 color = (Vector4)m_metaColors[i].metaData.ballColor;
                m_colors[i] = color;
            }
            Debug.Log("SetColor");
            m_material.SetVectorArray("_Colors", m_colors);
        }
    }
}
