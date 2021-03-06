//
//  UIViewExtension.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/31.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

enum DashedLineType {
    case All,Top,Down,Right,Left
}

extension UIView {
    
    // ViewをUIImageに変換して返却
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
    
    // 枠線を描くメソッド
    func drawLine(color: UIColor, lineWidth: CGFloat) {
        let lineLayer = CAShapeLayer()
        lineLayer.frame = self.bounds
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.fillColor = nil
        lineLayer.path = UIBezierPath(rect: lineLayer.frame).cgPath
        
        self.layer.addSublayer(lineLayer)
    }
    
    // 斜めの打ち消し線を描くメソッド
    func drawCancelLine(color: UIColor, lineWidth: CGFloat) {
        let lineLayer = CAShapeLayer()
        let path: CGMutablePath = CGMutablePath()
        
        lineLayer.frame = self.bounds
        lineLayer.strokeColor = color.cgColor
        lineLayer.lineWidth = lineWidth
        lineLayer.fillColor = nil
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint.init(x: self.frame.size.width, y: self.frame.size.height))
        lineLayer.path = path
        
        self.layer.addSublayer(lineLayer)
    }
    
    // 破線を描くメソッド
    func drawDashedLine(color: UIColor, lineWidth: CGFloat, lineSize: NSNumber, spaceSize: NSNumber, type: DashedLineType) {
        let dashedLineLayer: CAShapeLayer = CAShapeLayer()
        dashedLineLayer.frame = self.bounds
        dashedLineLayer.strokeColor = color.cgColor
        dashedLineLayer.lineWidth = lineWidth
        dashedLineLayer.lineDashPattern = [lineSize, spaceSize]
        let path: CGMutablePath = CGMutablePath()
        
        switch type {
            
        case .All:
            dashedLineLayer.fillColor = nil
            dashedLineLayer.path = UIBezierPath(rect: dashedLineLayer.frame).cgPath
        case .Top:
            path.move(to: CGPoint(x: 0.0, y: 0.0))
            path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
            dashedLineLayer.path = path
        case .Down:
            path.move(to: CGPoint(x: 0.0, y: self.frame.size.height))
            path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
            dashedLineLayer.path = path
        case .Right:
            path.move(to: CGPoint(x: self.frame.size.width, y: 0.0))
            path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height))
            dashedLineLayer.path = path
        case .Left:
            path.move(to: CGPoint(x: 0.0, y: 0.0))
            path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height))
            dashedLineLayer.path = path
        }
        self.layer.addSublayer(dashedLineLayer)
    }
    
    // サブレイヤーが指定した数以上存在するかを返す
    func isSubLayer(count: Int) -> Bool {
        
        guard let sublayers = self.layer.sublayers else {
            // サブレイヤーがnilだったらfalseを返す
            return false
        }
        
        // サブレイヤーの有無を返却
        return sublayers.count >= count
    }
    
    /**
     addSubviewする際に貼り付け元のViewの中央を指定すると、
     貼り付けるViewの左上が中央になるので、
     貼り付けるViewのサイズに合わせた中央値を返すメソッドを実装
     **/
    func centerPoint(size: CGSize) -> CGPoint {
        return CGPoint(x: (self.frame.size.width / 2) - (size.width / 2),
                       y: (self.frame.size.height / 2) - (size.height / 2))
    }
    
}
