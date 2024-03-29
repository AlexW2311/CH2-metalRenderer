//
//  Renderer.swift
//  ch3renderPipeline
//
//  Created by Alexander Williams on 3/11/24.
//

import MetalKit

class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQ: MTLCommandQueue!
    static var library: MTLLibrary!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    

    
    init(metalView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
                    fatalError("Broke!")
                }
        Renderer.device = device
        Renderer.commandQ = commandQueue
        metalView.device = device
        
        
        // create the mesh (box mesh)
        let allocator = MTKMeshBufferAllocator(device: device)
        let size: Float = 0.8
        let mdlMesh = MDLMesh(
          boxWithExtent: [size, size, size],
          segments: [1, 1, 1],
          inwardNormals: false,
          geometryType: .triangles,
          allocator: allocator)
        do {
          mesh = try MTKMesh(mesh: mdlMesh, device: device)
        } catch let error {
          print(error.localizedDescription)
        }
        
        
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        
        
        // create the shader function library
        let library = device.makeDefaultLibrary()
        Renderer.library = library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction =
          library?.makeFunction(name: "fragment_main")
        
        
        // create the pipeline state object
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat =
          metalView.colorPixelFormat
        pipelineDescriptor.vertexDescriptor =
          MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        do {
          pipelineState =
            try device.makeRenderPipelineState(
              descriptor: pipelineDescriptor)
        } catch let error {
          fatalError(error.localizedDescription)
        }
        
        
        super.init()
        
        metalView.clearColor = MTLClearColor(red: 1.0, 
                                             green: 1.0,
                                             blue: 0.8,
                                             alpha: 1.0)
        metalView.delegate = self
    }
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        //
    }
    func draw(in view: MTKView) {
        guard
          let commandBuffer = Renderer.commandQ.makeCommandBuffer(),
          let descriptor = view.currentRenderPassDescriptor,
          let renderEncoder =
            commandBuffer.makeRenderCommandEncoder(
              descriptor: descriptor) else {
        return
        }
        
        //encoding n drawing
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount, indexType: submesh.indexType, indexBuffer: submesh.indexBuffer.buffer, indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
    }
}


