//
//  THBMainVC.swift
//  THBExampleDemo
//
//  Created by tanghongbo on 2022/12/14.
//

import UIKit
import MetalKit

struct ZoomBlurUniform2 {
    var size: Float
    var center: float2
}


class THBMainVC: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        view.backgroundColor = .red
        self.view.addSubview(view)
        
        var a = MemoryLayout<ZoomBlurUniform2>.stride
        self.render()
    }
    
    
    
    func render() {
        let textureLoader = MTKTextureLoader(device: sharedMetalRenderingDevice.device)
        guard let path = Bundle.main.path(forResource: "comics_22.png", ofType: nil) else { return  }
        let image = UIImage(contentsOfFile: path)
        // 可以通过这里指定纹理的坐标是左下为原点，否则一般是左上为原点
//        let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
//          [.origin: MTKTextureLoader.Origin.bottomLeft]
        let texture = try! textureLoader.newTexture(cgImage:image!.cgImage!, options: [MTKTextureLoader.Option.SRGB : false])
        
//        let texDescriptor = MTLTextureDescriptor()
//        texDescriptor.textureType = MTLTextureType.type2D
//        texDescriptor.width = 1000
//        texDescriptor.height = 1000
//        texDescriptor.sampleCount = 1
//        texDescriptor.pixelFormat = .bgra8Unorm
//        texDescriptor.storageMode = .shared
//        texDescriptor.usage = .renderTarget.union(.shaderWrite)
//
//        let dsttexture = sharedMetalRenderingDevice.device.makeTexture(descriptor: texDescriptor)
        
        let pixel = PixelbufferUtil.pixelBuffer(width: 1000, height: 1000)!
        let dsttexture = Texture.makeTexture(pixelBuffer: pixel)?.texture
        
        
        let pixel2 = PixelbufferUtil.pixelBuffer(width: 1000, height: 1000)!
        let dsttexture2 = Texture.makeTexture(pixelBuffer: pixel2)?.texture
        
        let pixel3 = PixelbufferUtil.pixelBuffer(image: image!)!
        let dsttexture3 = Texture.makeTexture(pixelBuffer: pixel3)?.texture
        
        let commandbuffer = sharedMetalRenderingDevice.commandQueue.makeCommandBuffer()!
        
        let pipeline = GrayComputePipeline.init()
        pipeline.input = dsttexture3
        pipeline.output = dsttexture
        pipeline.render(with: commandbuffer)
        
//        let pass = PassthroughRenderPipeline()
//        pass.input = texture
//        pass.output = dsttexture
//        pass.render(commandBuffer: commandbuffer)
        
        
        let pass2 = PassthroughRenderPipeline()
        pass2.input = texture
        pass2.output = dsttexture2
        pass2.render(commandBuffer: commandbuffer)
        
        
        commandbuffer.commit()
        
        let image1 = PixelbufferUtil.image(from: dsttexture!)
        let image2 = PixelbufferUtil.image(from: dsttexture2!)
        let image3 = PixelbufferUtil.image(from: dsttexture3!)
        let a = 0;
    }

    
    
//    - (CVPixelBufferRef)getPixelBufferFromBGRAMTLTexture:(id<MTLTexture>)texture {
//        CVPixelBufferRef pxbuffer = NULL;
//        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
//                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
//                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
//                                 nil];
//
//        size_t imageByteCount = texture.width * texture.height * 4;
//        void *imageBytes = malloc(imageByteCount);
//        NSUInteger bytesPerRow = texture.width * 4;
//
//        MTLRegion region = MTLRegionMake2D(0, 0, texture.width, texture.height);
//        [texture getBytes:imageBytes bytesPerRow:bytesPerRow fromRegion:region mipmapLevel:0];
//
//        CVPixelBufferCreateWithBytes(kCFAllocatorDefault,texture.width,texture.height,kCVPixelFormatType_32BGRA,imageBytes,bytesPerRow,NULL,NULL,(__bridge CFDictionaryRef)options,&pxbuffer);
//
//    //    free(imageBytes); CVPixelBufferCreateWithBytes 不会拷贝 因此这里不能直接释放
//
//        return pxbuffer;
//    }

    

}
