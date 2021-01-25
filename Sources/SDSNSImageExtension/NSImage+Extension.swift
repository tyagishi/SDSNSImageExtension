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
    
    public func unscaledBitmapImageRep(_ targetSize:CGSize, drawHandler: @escaping () -> () ) -> NSBitmapImageRep {
        guard let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(targetSize.width), pixelsHigh: Int(targetSize.height),
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
            preconditionFailure()
        }
        bitmapRep.size = targetSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        drawHandler()
        NSGraphicsContext.restoreGraphicsState()
        return bitmapRep;
    }
}
