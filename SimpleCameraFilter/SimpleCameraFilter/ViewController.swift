//
//  ViewController.swift
//  SimpleCameraFilter
//
//  Refactored by Your Coding Partner
//

import UIKit
import MetalKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: - Metal Resources
    var mtkView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var textureCache: CVMetalTextureCache?
    
    // MARK: - Synchronization
    // We use a semaphore or a lock to prevent reading/writing the texture at the same time
    let frameLock = NSLock()
    var currentTexture: MTLTexture?
    
    // MARK: - Camera Resources
    let captureSession = AVCaptureSession()
    
    // Vertex Data: X, Y, Z, W, U, V
    // Fixed Z to 0.0 ensures it's within clip space (0 to 1)
    let vertexData: [Float] = [
        -1.0, -1.0, 0.0,  1.0,  0.0,  1.0, // Bottom Left
         1.0, -1.0, 0.0,  1.0,  1.0,  1.0, // Bottom Right
        -1.0,  1.0, 0.0,  1.0,  0.0,  0.0, // Top Left
         1.0,  1.0, 0.0,  1.0,  1.0,  0.0  // Top Right
    ]
    var vertexBuffer: MTLBuffer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Setup Metal First
        setupMetal()
        
        // 2. Setup Camera
        setupCamera()
    }
    
    func setupMetal() {
        // Guard against Simulator
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device (or Simulator).")
            return
        }
        
        device = defaultDevice
        mtkView = MTKView(frame: view.bounds, device: device)
        mtkView.delegate = self
        mtkView.framebufferOnly = false
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Handle rotation
        view.addSubview(mtkView)
        
        commandQueue = device.makeCommandQueue()
        
        // Create Texture Cache
        var cache: CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &cache)
        textureCache = cache
        
        // Create Vertex Buffer
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        buildPipelineState()
    }
    
    func buildPipelineState() {
        guard let library = device.makeDefaultLibrary() else { return }
        let vertexFunction = library.makeFunction(name: "vertexShader")
        let fragmentFunction = library.makeFunction(name: "grayscaleFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        
        let vertexDescriptor = MTLVertexDescriptor()
        
        // Attribute 0: Position (Float4)
        vertexDescriptor.attributes[0].format = .float4
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        // Attribute 1: Texture Coord (Float2)
        vertexDescriptor.attributes[1].format = .float2
        vertexDescriptor.attributes[1].offset = MemoryLayout<Float>.size * 4
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        // Stride = 6 floats * 4 bytes = 24 bytes
        vertexDescriptor.layouts[0].stride = MemoryLayout<Float>.size * 6
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Failed to create pipeline state: \(error)")
        }
    }
    
    func setupCamera() {
        captureSession.sessionPreset = .medium
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        let output = AVCaptureVideoDataOutput()
        // Metal requires BGRA
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            
            // FIX: Correct the orientation so the image isn't rotated
            if let connection = output.connection(with: .video) {
                connection.videoOrientation = .portrait
                // Mirror if front camera
                if camera.position == .front {
                    connection.isVideoMirrored = true
                }
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
}

// MARK: - MTKViewDelegate (Render Loop)
extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let descriptor = view.currentRenderPassDescriptor else { return }
        
        // Thread Safe: Read the texture
        var inputTexture: MTLTexture?
        frameLock.lock()
        inputTexture = currentTexture
        frameLock.unlock()
        
        // If we haven't received a frame yet, clear screen to black and return
        guard let texture = inputTexture else {
            return
        }
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setFragmentTexture(texture, index: 0)
        
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

// MARK: - Camera Delegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer),
              let cache = textureCache else { return }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        var textureRef: CVMetalTexture?
        let result = CVMetalTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            cache,
            pixelBuffer,
            nil,
            .bgra8Unorm,
            width,
            height,
            0,
            &textureRef
        )
        
        if result == kCVReturnSuccess, let textureRef = textureRef {
            // Thread Safe: Write the texture
            frameLock.lock()
            self.currentTexture = CVMetalTextureGetTexture(textureRef)
            frameLock.unlock()
        }
    }
}
