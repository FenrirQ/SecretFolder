//
//  UIImageExtension.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/30/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit

extension UIImage {
    func thumbImage(with size: Int) -> UIImage {            /* get thumb image of a image */
        let imageData = UIImageJPEGRepresentation(self, 1)!
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: size] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnail = UIImage(cgImage: imageReference)
        return thumbnail
    }
    
    func isEqual(to img: UIImage) -> Bool {         /* prepare 2 images */
        guard let data1 = UIImagePNGRepresentation(self) else { return false }
        guard let data2 = UIImagePNGRepresentation(img) else { return false }
        return data1 == data2
    }
    
    func rotatedByDegrees(deg degrees: CGFloat) -> UIImage {
        /* Calculate the size of the rotated view's containing box for our drawing space */
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        /* Create the bitmap context */
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        /* Move the origin to the middle of the image so we will rotate and scale around the center. */
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        /* Rotate the image context */
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        /* Now, draw the rotated/scaled image into the context */
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
