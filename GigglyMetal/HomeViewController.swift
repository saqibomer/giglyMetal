//
//  HomeViewController.swift
//  GigglyMetal
//
//  Created by Saqib Omer on 11/12/15.
//  Copyright © 2015 KaboomLab. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class HomeViewController: UIViewController {
    
    //Properties
    var metalDevice : MTLDevice? // Declare Metal Device
    var metalLayer: CAMetalLayer? // Declare a metal layer. Metal Layer is subclass of CALayer and its part of QuartzCore
    var vertexBuffer: MTLBuffer? // Vertex Buffer
    var pipelineState: MTLRenderPipelineState? //Complied render pipeline
    var commandQueue: MTLCommandQueue? // A list of commands to GPU
    

    override func viewDidLoad() {
        super.viewDidLoad()

        metalDevice =  MTLCreateSystemDefaultDevice() // Initialize Metal Device
        
        metalLayer = CAMetalLayer() // Initialize Metal Layer
        metalLayer?.device = metalDevice // Add Metal Device to Metal Layer
        metalLayer?.pixelFormat = .BGRA8Unorm //Set Pixel Format
        metalLayer?.framebufferOnly = true // Set Framebuffer
        metalLayer?.frame = view.layer.frame // Set frame of Metal Layer to current frame
        
        
        var timer: CADisplayLink? //For Redraw
        
        
        
        if let mLayer = metalLayer {
            view.layer.addSublayer(mLayer)// Add Metal Layer
        }
        
        let vertexData:[Float] = [ // vertexData for traiangle. Verteces are points defined in coordinate system
            0.0, 1.0, 0.0,
            -1.0, -1.0, 0.0,
            1.0, -1.0, 0.0]
        let dataSize = vertexData.count * sizeofValue(vertexData[0]) // size of the vertex data in bytes
        
        if let device = metalDevice {
            
//            if var buffer : MTLBuffer = vertexBuffer {
                vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: MTLResourceOptions.OptionCPUCacheModeDefault)
            
        }
        
        let defaultLibrary = metalDevice?.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary?.newFunctionWithName("basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
//        var pipelineError : NSError?
        do {
            pipelineState = try metalDevice!.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch {
            print("error with device.newRenderPipelineStateWithDescriptor")
        }
        
        commandQueue = metalDevice?.newCommandQueue()
        timer = CADisplayLink(target: self, selector: Selector("gameloop")) // Calls a loop each time screen refreshes
        timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func render() { // Rendeer function for rendering textures and configuration of rendering process
        let drawable = metalLayer!.nextDrawable()
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture;
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear;
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        let commandBuffer = commandQueue!.commandBuffer()
        
        let renderEncoderOpt = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        if let renderEncoder : MTLRenderCommandEncoder = renderEncoderOpt {
            renderEncoder.setRenderPipelineState(pipelineState!)
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
            renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
            renderEncoder.endEncoding()
        }
        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
    }
    
    func gameloop() {
        autoreleasepool {
            self.render()
        }
    }

}
