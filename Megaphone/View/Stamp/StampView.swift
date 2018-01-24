//
//  StampView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol StampViewDelegate {
    func stampTapped(view: StampView)
    func stampCloseTapped(view: StampView)
}

class StampView: UIView {
    
    static let nibName = "StampView"

    @IBOutlet weak var close: UIImageView!
    @IBOutlet weak var stamp: UIImageView!
    
    var beforeFrame: CGPoint!
    var befroScale: CGFloat = 1.0
    var imageName: String = ""
    var delegate: StampViewDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        stamp.contentMode = .scaleAspectFit
        close.isHidden = true
        
        self.onTap { _ in
            self.delegate.stampTapped(view: self)
            // 閉じるボタン・ラベル・選択状態を表す破線で3つのサブレイヤだから3を渡す
            if self.isSubLayer(count: 3) {
                // 選択状態のとき
                
                // 一番最後のレイヤーを削除
                self.layer.sublayers?.last?.removeFromSuperlayer()
                self.close.isHidden = true
            } else {
                // 非選択のとき
                
                // 破線のレイヤを追加して選択状態とする
                self.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
                self.close.isHidden = false
            }
        }
        
        self.onPan { pan in
            let location: CGPoint = pan.translation(in: self)
            let x = location.x + self.beforeFrame.x
            let y = location.y + self.beforeFrame.y
            self.beforeFrame = CGPoint(x: x, y: y)
            pan.setTranslation(CGPoint.zero, in: self)
            self.frame.origin = self.beforeFrame
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        
        close.onTap {_ in 
            self.delegate.stampCloseTapped(view: self)
        }
    }

}
