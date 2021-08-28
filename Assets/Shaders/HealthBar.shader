Shader"Unlit/HealthBar"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Health ("Health", Range(0, 1)) = 1
    }
    SubShader // Subshader tags go below
    {
        Tags {
                 "RenderType" = "Transparent"
                 "Queue" = "Transparent"
                 }
        LOD 100

        Pass // Pass tags go below
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #define TAU 6.28318530718 // preprocessor constant

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f // data passed from vertex to fragment shader
            {
                float4 vertex : SV_POSITION; // clip space position
                float2 uv : TEXCOORD0; // texcoords don't have to specifically refer to UV channels
            };

            sampler2D _MainTex;
            float _Health;

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }
            
            // Vertex shader - loops over each vertex - optimization tip: do as much as possible in vertex shader unless you have many models in the far distance to render
            v2f vert (MeshData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex); // convert local space to clip space
                o.uv = v.uv;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float healthBarMask = _Health > i.uv.x; // bools can be cast to floats
                // clip(healthBarMask - 0.5); // remove backgound in opaque shader
                
                // Clamp color changes between left and round bound
                float leftBound = 0.2;
                float rightBound = 0.8;
                float colorT = saturate(InverseLerp(leftBound, rightBound, _Health));
                float4 healthBarColor = lerp(float4(1, 0, 0, 1), float4(0, 1, 0, 1), colorT);
                
                // % after which healthbar opacity start to fade out
                float fadeOutBegin = 0.6;
                if (i.uv.x > fadeOutBegin)
                {
                    float transparencyT = saturate(InverseLerp(fadeOutBegin, 1, i.uv.x));
                    healthBarMask *= lerp(1, 0.5, transparencyT);
                    healthBarColor = lerp(healthBarColor, float4(.8,1,.8,1), InverseLerp(fadeOutBegin, 1, i.uv.x));
                }
                return healthBarColor * float4(1, 1, 1, healthBarMask);
            }
            ENDCG
        }
    }
}
