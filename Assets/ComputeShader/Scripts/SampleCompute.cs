using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

namespace TK.GPU
{
    public class SampleCompute : MonoBehaviour
    {
        #region  Function

        const int ThreadBlockSize = 256;

        public struct Matrix2x2
        {
            public float m00;
            public float m11;
            public float m01;
            public float m10;
            public static Matrix2x2 identity
            {
                get
                {
                    var m = new Matrix2x2();
                    m.m00 = m.m11 = 1f;
                    m.m01 = m.m10 = 0f;
                    return m;
                }
            }
        }

        struct PsylliumData
        {
            /// <summary>
            /// 座標
            /// </summary>
            public Vector3 Position;
            /// <summary>
            /// 回転
            /// </summary>
            public Matrix2x2 Rotation;
            /// <summary>
            /// 色
            /// </summary>
            public Color PsylliumColor;
        }


        [Range(256, 32768), SerializeField]
        int _MaxObjectNum = 14384;

        [SerializeField] ComputeShader _ComputeShader;

        [SerializeField] Mesh _Mesh;

        [SerializeField] Material _Material;

        [SerializeField] Vector3 _MeshScale = new Vector3(1f, 1f, 1f);

        [SerializeField] float _AnimationSpeed = 1f;

        [SerializeField] Vector3 _BoundCenter = Vector3.zero;

        [SerializeField] Vector3 _BoundSize = new Vector3(32f, 32f, 32f);

        [SerializeField] Color _Color = new Color(1.0f, 0.1f, 0.01f);

        ComputeBuffer _MeshDataBuffer;

        ComputeBuffer _AnimationStartPositionBuffer;

        uint[] _GPUInstancingArgs = new uint[5] { 0, 0, 0, 0, 0 };

        ComputeBuffer _GPUInstancingArgsBuffer;

        int kernelId;

        void Start()
        {
            if (_Mesh == null)
            {
                CreateMesh();
            }
            else
            {
                _Material.SetColor("_Color", _Color);
            }
            // バッファ生成
            this._MeshDataBuffer = new ComputeBuffer(this._MaxObjectNum, Marshal.SizeOf(typeof(PsylliumData)));
            this._AnimationStartPositionBuffer = new ComputeBuffer(this._MaxObjectNum, Marshal.SizeOf(typeof(float)));
            this._GPUInstancingArgsBuffer = new ComputeBuffer(1, this._GPUInstancingArgs.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
            PsylliumData[] rotationMatrixArr = new PsylliumData[this._MaxObjectNum];
            float[] timeArr = new float[this._MaxObjectNum];
            for (int i = 0; i < this._MaxObjectNum; ++i)
            {
                // バッファに初期値を代入
                var halfX = this._BoundSize.x / 2;
                var halfY = this._BoundSize.y / 2;
                var halfZ = this._BoundSize.z / 2;
                rotationMatrixArr[i].Position = new Vector3(
                    Random.Range(-halfX, halfX),
                    Random.Range(-halfY, halfY),
                    Random.Range(-halfZ, halfZ));
                rotationMatrixArr[i].Rotation = Matrix2x2.identity;
                // 角度でランダムに開始
                timeArr[i] = Random.Range(0f, 360f * Mathf.Deg2Rad);
                rotationMatrixArr[i].PsylliumColor = new Vector4(Random.Range(0f, 1f * Mathf.Deg2Rad), 
                    Random.Range(0f, 1f * Mathf.Deg2Rad), Random.Range(0f, 1f * Mathf.Deg2Rad), 1);

            }
            this._MeshDataBuffer.SetData(rotationMatrixArr);
            this._AnimationStartPositionBuffer.SetData(timeArr);
            rotationMatrixArr = null;
            timeArr = null;
            kernelId = this._ComputeShader.FindKernel("MainCS");
        }

        void Update()
        {
            // ComputeShader
            this._ComputeShader.SetFloat("_Time", Time.time);
            this._ComputeShader.SetFloat("_AnimationSpeed", this._AnimationSpeed);
            this._ComputeShader.SetBuffer(kernelId, "_PsylliumDataBuffer", this._MeshDataBuffer);
            this._ComputeShader.SetBuffer(kernelId, "_AnimationStartPositionBuffer", this._AnimationStartPositionBuffer);
            this._ComputeShader.Dispatch(kernelId, (Mathf.CeilToInt(this._MaxObjectNum / ThreadBlockSize) + 1), 1, 1);

            // GPU Instaicing
            this._GPUInstancingArgs[0] = (this._Mesh != null) ? this._Mesh.GetIndexCount(0) : 0;
            this._GPUInstancingArgs[1] = (uint)this._MaxObjectNum;
            this._GPUInstancingArgsBuffer.SetData(this._GPUInstancingArgs);
            this._Material.SetBuffer("_PsylliumDataBuffer", this._MeshDataBuffer);
            this._Material.SetVector("_PsylliumMeshScale", this._MeshScale);
            Graphics.DrawMeshInstancedIndirect(this._Mesh, 0, this._Material, new Bounds(this._BoundCenter, this._BoundSize), this._GPUInstancingArgsBuffer);
        }
        

        void OnDestroy()
        {
            if (this._MeshDataBuffer != null)
            {
                this._MeshDataBuffer.Release();
                this._MeshDataBuffer = null;
            }
            if (this._AnimationStartPositionBuffer != null)
            {
                this._AnimationStartPositionBuffer.Release();
                this._AnimationStartPositionBuffer = null;
            }
            if (this._GPUInstancingArgsBuffer != null)
            {
                this._GPUInstancingArgsBuffer.Release();
                this._GPUInstancingArgsBuffer = null;
            }
        }

        void CreateMesh()
        {
            float height = 0.4f;
            float width = 0.2f;
            float radius = width;
            _Mesh = new Mesh();
            _Mesh.vertices = new Vector3[] 
            {
                new Vector3 (-width, -height, 0),  // 0
                new Vector3 (-width, -height, 0),  // 1
                new Vector3 (width , -height, 0),  // 2
                new Vector3 (width , -height, 0),  // 3

                new Vector3 (-width,  height, 0),  // 4
                new Vector3 ( width,  height, 0),  // 5

                new Vector3 (-width,  height, 0),  // 6 
                new Vector3 (width ,  height, 0),  // 7
            };

            _Mesh.uv = new Vector2[] 
            {
                new Vector2 (0, 0),
                new Vector2 (0, 0.5f),
                new Vector2 (1, 0),
                new Vector2 (1, 0.5f),
                new Vector2 (0, 0.5f),
                new Vector2 (1, 0.5f),
                new Vector2 (0, 1),
                new Vector2 (1, 1),
            };

            _Mesh.uv2 = new Vector2[] 
            {
                new Vector2 (-radius, 0),
                new Vector2 (0, 0),
                new Vector2 (-radius, 0),
                new Vector2 (0, 0),
                new Vector2 (0, 0),
                new Vector2 (0, 0),
                new Vector2 (radius, 0),
                new Vector2 (radius, 0),
            };

            _Mesh.triangles = new int[] 
            {
                0, 1, 2,
                1, 3, 2,
                1, 4, 3,
                4, 5, 3,
                4, 6, 5,
                6, 7, 5,
            };

            _Material.SetColor("_Color", _Color);
        }

        #endregion
    }
}
