//
//  NSImage+Extension.swift
//
//  Created by : Tomoaki Yagishita on 2021/01/25
//  © 2021  SmallDeskSoftware
//

import Foundation
import AppKit

extension NSImage {
    public func copyWithUnscaledRepResolution() -> NSImage {
        let newImage = NSImage(size: self.getSizeFromRepresentations())
        let bitmapRep = self.unscaledBitmapImageRep()
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
    
    public func unscaledBitmapImageRep() -> NSBitmapImageRep {
        let imagePixelSize = self.getSizeFromRepresentations()
        guard let bitmapRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imagePixelSize.width), pixelsHigh: Int(imagePixelSize.height),
                                         bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                         colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0) else {
            preconditionFailure()
        }
        bitmapRep.size = imagePixelSize
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
        self.draw(at: .zero, from: .zero, operation: .copy, fraction: 1.0)
        NSGraphicsContext.restoreGraphicsState()
        return bitmapRep;
    }
}
