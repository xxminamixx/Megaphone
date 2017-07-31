//
//  UIViewExtension.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/31.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


extension UIView {
    
    func castImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        self.layer.render(in: context)
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        return image
    }
    
}
