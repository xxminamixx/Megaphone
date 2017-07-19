//
//  UIImageExtension.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/19.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

class UIImageExtension: NSObject {

}

extension UIImage {
    /**
     * 画像リサイズ
     */
//    - (UIImage *)resizeImage:(UIImage *)sourceImage toSize:(CGFloat)newSize
//    {
//    UIImage *destinationImage = [[UIImage alloc] init];
//    CGFloat currentWidth = sourceImage.size.width;
//    CGFloat currentHeight = sourceImage.size.height;
//    CGFloat newWidth, newHeight;
//    
//    if (newSize == 0) {
//    newWidth = newHeight = 0;
//    
//    } else if (currentHeight < currentWidth) {
//    newHeight = floorf(currentHeight * newSize / currentWidth);
//    newWidth = newSize;
//    
//    } else if (currentWidth <= currentHeight) {
//    newWidth = floorf(currentWidth * newSize / currentHeight);
//    newHeight = newSize;
//    
//    }
//    
//    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
//    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
//    destinationImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return destinationImage;
//    }
    
    func resize() {
        
    }
}
