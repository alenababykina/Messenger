//
//  UIImage+Extensions.swift
//  Messenger
//
//  Created by Alena on 5/18/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import UIKit

extension UIImage {

    func avatarAdjustedImageData() -> UIImage! {
        let maxSize: CGFloat = 50
        var height = self.size.height;
        var width = self.size.width;
        
        let ratio = CGFloat.maximum(height, width) / maxSize
        if ratio > 1 {
            height = (height / ratio).rounded()
            width = (width / ratio).rounded()
            
            let rect = CGRect(origin:CGPoint(x: 0, y: 0),
                                 size: CGSize(width: width, height: height))
            UIGraphicsBeginImageContext(rect.size);
            self.draw(in: rect)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            let imageData = UIImageJPEGRepresentation(img!, 1.0)
            UIGraphicsEndImageContext()
            
            return UIImage(data: imageData!)!
            
        } else {
            return self
        }
    }
}
