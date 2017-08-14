//
//  SelectableView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/14.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit

protocol SelectableViewDelegate {
    func selectableViewTapped(view: SelectableView)
    func selectableCloseTapped(view: SelectableView)
}

class SelectableView: UIView {
    
    static let nibName = "SelectableView"
    
    @IBOutlet weak var close: UIImageView!
    // 継承先のViewが表示内容を変えれる
    @IBOutlet weak var contentView: UIView!
    
    var delegate: SelectableViewDelegate!
    // 利用する場合はこのプロパティに値をセットしないとクラッシュする
    var beforeFrame: CGPoint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 背景を透明に設定
        self.backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        
        self.onTap { _ in
            self.delegate.selectableViewTapped(view: self)
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
            self.delegate.selectableCloseTapped(view: self)
        }
    }

}
