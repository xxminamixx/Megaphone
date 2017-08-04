//
//  NamingLabelView.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/28.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GestureRecognizerClosures

protocol NamingLabelViewDelegate {
    func namingLabelTapped(view: NamingLabelView)
}

class NamingLabelView: UIView {
    
    static let nibName = "NamingLabelView"
    
    @IBOutlet weak var closeImageView: UIImageView!
    @IBOutlet weak var namingLabel: UILabel!
    
    var delegate: NamingLabelViewDelegate!
    
    // このViewの１フレーム前の移動量
    var beforFrame: CGPoint!
    // このViewの１フレーム前のスケール
    var befroScale: CGFloat = 1.0
    // ラベルのフォントサイズ
    var fontSize: CGFloat = 18.0
    
    override func awakeFromNib() {
        
        backgroundColor = UIColor.clear        
        namingLabel.textColor = UIColor.white
        self.closeImageView.isHidden = true
        
        // 閉じるボタンが押された時の処理
        closeImageView.onTap { _ in
            if self.isSubLayer(count: 3) {
                self.removeFromSuperview()
            }
        }
        
        // Viewをタップしたときの処理
        self.onTap {_ in
            self.delegate.namingLabelTapped(view: self)
            // 閉じるボタン・ラベル・選択状態を表す破線で3つのサブレイヤだから3を渡す
            if self.isSubLayer(count: 3) {
                // 選択状態のとき
                
                // 一番最後のレイヤーを削除
                self.layer.sublayers?.last?.removeFromSuperlayer()
                // TODO: 閉じるボタンの非活性
                self.closeImageView.isHidden = true
            } else {
                // 非選択のとき
                
                // 破線のレイヤを追加して選択状態とする
                self.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
                // TODO: 閉じるボタンの活性化
                self.closeImageView.isHidden = false
            }
        }
        
        // ドラックした時の処理
        self.onPan { pan in
            let location: CGPoint = pan.translation(in: self)
            let x = location.x + self.beforFrame.x
            let y = location.y + self.beforFrame.y
            self.beforFrame = CGPoint(x: x, y: y)
            pan.setTranslation(CGPoint.zero, in: self)
            self.frame.origin = self.beforFrame
            // オートレイアウトの制約を超えてLabelが大きくなる問題を修正
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.namingLabel.sizeToFit()
        }
        
        super.awakeFromNib()
    }
    
}
