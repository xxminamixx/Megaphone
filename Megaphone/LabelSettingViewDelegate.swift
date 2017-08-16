//
//  LabelSettingViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


// MARK: LabelSettingViewDelegate
extension NamingViewController: LabelSettingViewDelegate {
    
    func closeTapped() {
        closeLabelSettingView(isAnimation: true)
    }
    
    func modeChange(isFont: Bool) {
        showColorPicker(isFont: isFont, isSelectItemView: false)
    }
    
    func movedSlider(sender: UISlider, isFont: Bool, color: UIColor) {
        if isFont{
            // フォント選択時にスライダーを動かした時の処理
        } else {
            // 枠線選択時にスライダーを動かした時の処理
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withStrokeWidth(-1.0 * (Double(sender.value * 10))).withStrokeColor(color)
        }
    }
    
    func colorViewTapped(isFont: Bool, color: UIColor, strokeWidth: Float) {
        if isFont {
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withTextColor(color)
        } else {
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withStrokeColor(color).withStrokeWidth(-1.0 * Double(strokeWidth * 10))
        }
    }
    
    
    //　MARK: - ラベル設定を閉じる
    func closeLabelSettingView(isAnimation: Bool) {
        // 色変更のViewがなかったら以下に進まない
        guard let settingView = textSettingView else {
            return
        }
        
        func delete() {
            // レイヤーから削除
            settingView.removeFromSuperview()
            // ポインタを破棄
            self.textSettingView = nil
        }
        
        if isAnimation {
            // アニメーションありでSettingViewを消す
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
                settingView.frame.origin.y += settingView.frame.size.height
            }, completion: { fin in
                delete()
            })
        } else {
            // アニメーション無しでSettingViewを消す
            delete()
        }
    }
    
}
