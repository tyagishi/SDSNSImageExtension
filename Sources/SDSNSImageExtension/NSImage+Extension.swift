//
//  NSImage+Extension.swift
//
//  Created by : Tomoaki Yagishita on 2021/01/25
//  © 2021  SmallDeskSoftware
//

import Foundation
import AppKit

extension NSImage {
    // pos is location in new Image
    public func unscaledCropWithString(_ cropRect: CGRect, _ attrStr: NSAttributedString, _ pos: NSPoint) -> NSImage {
        let newImage = NSImage(size:cropRect.size)
        let bitmapRep = newImage.unscaledBitmapImageRep(cropRect.size) {
            self.draw(at: .zero, from: cropRect, operation: .copy, fraction: 1.0)
            attrStr.draw(at: pos)
        }
        newImage.addRepresentation(bitmapRep)
        return newImage
    }

    public func unscaledCopy() -> NSImage {
        let newImage = NSImage(size: self.getSizeFromRepresentations())
        let bitmapRep = newImage.unscaledBitmapImageRep(self.getSizeFromRepresentations()) {
            self.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
        }
        newImage.addRepresentation(bitmapRep)
        return newImage
    }
    
    // rect should align with getSizeFromRepresentations
    public func unscaledCrop(_ rect: CGRect) -> NSImage {
        let newImage = NSImage(size:rect.size)
        let bitmapRep = newImage.unscaledBitmapImageRep(rect.size) {
            self.draw(at: .zero, from: rect, operation: .copy, fraction: 1.0)
        }
        newImage.addRepresentation(bitmapRep)
        return newImage
    }
    
    public func getSizeFromRepresentations() -> CGSize {
        var width: Int = 0
        var height: Int = 0
        for repre in self.representations {
            if repre.pixelsWide > width { width = repre.pixelsWide }
            if repre.pixelsHigh > height { height = repre.pixelsHigh }
        }
        return CGSize(width: width, height: height)
    }
    
    public func unscaledBitmapImageRep(_ targetSize:CGSize, drawHandler: (() -> ())? ) -> NSBitmapImageRep {
        guard let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(targetSize.width), pixelsHigh: Int(targetSize.height),
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
            preconditionFailure()
        }
        bitmapRep.size = targetSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        drawHandler?()
        NSGraphicsContext.restoreGraphicsState()
        return bitmapRep;
    }
}

extension NSImage {
    public func jpegDataWithMetadata(_ image: NSImage, _ imageURL: URL) -> Data?{
        // copy source property
        guard let cgImageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else { print("failed to create")
            return nil
        }
        // let props = CGImageSourceCopyProperties(cgImageSource, nil) // NG: failed to get
        let sourceProps = CGImageSourceCopyPropertiesAtIndex(cgImageSource, 0, nil)

        let destData = NSMutableData()
        let cgImageDestination = CGImageDestinationCreateWithData(destData as CFMutableData, kUTTypeJPEG, 1, nil)!

        // test dic
        var testDic = Dictionary<String,Any>()
        testDic[kCGImagePropertyExifAuxSerialNumber as String] = NSNumber(2828)
//        CGImageDestinationSetProperties(cgImageDestination, testDic as CFDictionary)

        var rect = CGRect(x: 50, y: 50, width: 200, height: 200)
        let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        let writeCGImage = cgImage.cropping(to: rect)!
        //var dic = sourceProps as? Dictionary<String,Any>
        var dic = sourceProps as? Dictionary<String,Any>
        if dic != nil {
            // always NSImage has .up
            dic![kCGImagePropertyOrientation as String] = CGImagePropertyOrientation.up
            
            if var exif = dic![kCGImagePropertyExifDictionary as String] as? Dictionary<String,Any> {
                
                exif[kCGImagePropertyExifUserComment as String] = "Hello from ExifClip"
                //exif[kCGImagePropertyExifPixelXDimension as String] = NSNumber(333)
                print("exit exists!")
//                //print(dic![kCGImagePropertyExifPixelXDimension as String] as? NSNumber )
//                //dic![kCGImagePropertyExifAuxSerialNumber as String] = NSNumber(2929)
//                //dic![kCGImagePropertyExifPixelXDimension as String] = NSNumber(300)
                // need to copy-back to original dictionary
                dic![kCGImagePropertyExifDictionary as String] = exif
            }
//            dic[kCGImagePropertyOrientation as String] = CGImagePropertyOrientation.up
        }
        //let check = dic[kCGImagePropertyOrientation]
        CGImageDestinationAddImage(cgImageDestination, writeCGImage, dic! as CFDictionary)
        //CGImageDestinationSetProperties(cgImageDestination, dic! as CFDictionary)
        
        //print(sourceProps)
        CGImageDestinationFinalize(cgImageDestination)
        
        return destData as Data
    }
}
