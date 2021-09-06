using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class OilPaintingEffect_RF : ScriptableRendererFeature
{
    [SerializeField] Material blitMaterial = null;
    
    class BlitPass : ScriptableRenderPass
    {
        Material blitMaterial;
        RenderTargetIdentifier source;
        RenderTargetIdentifier destination;
        int temporaryRTId = Shader.PropertyToID("_TempRT");

        public BlitPass(Material blitMaterial)
        {
            this.blitMaterial = blitMaterial;
        }

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
            var renderer = renderingData.cameraData.renderer;
            source = renderer.cameraColorTarget;
            cmd.GetTemporaryRT(temporaryRTId, renderingData.cameraData.cameraTargetDescriptor);
            destination = new RenderTargetIdentifier(temporaryRTId);
            // destination = renderer.cameraColorTarget;
        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get();
            Blit(cmd, source, destination, blitMaterial);
            Blit(cmd, destination, source);

            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    BlitPass m_ScriptablePass;

    /// <inheritdoc/>
    public override void Create()
    {
        m_ScriptablePass = new BlitPass(blitMaterial);

        // Configures where the render pass should be injected.
        m_ScriptablePass.renderPassEvent = RenderPassEvent.AfterRenderingOpaques;
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}


