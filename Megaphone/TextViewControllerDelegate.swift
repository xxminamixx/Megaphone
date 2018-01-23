//
//  TextViewControllerDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


// MARK: TextViewControllerDelegate
extension NamingViewController: TextViewControllerDelegate {
    
    func getTextView(text: String?, completion: () -> Void) {
        
        if editLabelView != nil {
            // ラベルの編集が行われている場合
            
            // 編集が終わった後は選択状態ではないため、スクロールビューのスクロールができるようにする
            imageScrollView.isScrollEnabled = true
            
            // 編集中のラベルの座標
            let x = editLabelView?.beforFrame.x
            let y = editLabelView?.beforFrame.y
            
            // 新しいラベルビューを追加
            
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                let data = NSKeyedArchiver.archivedData(withRootObject: editLabelView?.namingLabel.attributedText ?? "")
                addLabelToImageView(label: label, x: x!, y: y!, text: text, fontSize: (self.editLabelView?.fontSize)!, attribute: data)
            }
            // 編集中のラベルを削除
            editLabelView?.removeFromSuperview()
            // 何度もこのif文に入らないように破棄
            editLabelView = nil
        } else {
            // NamingLabelViewを生成する
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                /* TODO:
                 ここのラベル新規作成を既存メソッドを使って共通化したいが、
                 ラベルにテキストをはめてからじゃないとラベルを初期表示する中心位置が計算できないため保留
                 */
                
                // サイズ計算用のダミーのラベル
                let settingLabel = text?.withTextColor(UIColor.white).withFont(UIFont(name: ConstText.helveticaNeue, size: 18)!).withStrokeColor(UIColor.white)
                label.namingLabel.attributedText = settingLabel
                
                label.namingLabel.sizeToFit()
                
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeImageView.bounds.height
                let origin = CGPoint(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2))
                
                // ラベルの初期位置を設定
                label.frame = CGRect(x: origin.x, y: origin.y, width: labelWidth, height: viewHeight)
                
                // 永続化用にプロパティにセット
                label.fontSize = 18
                label.beforFrame = CGPoint(x: origin.x, y: origin.y)
                label.delegate = self
                
                // 新規作成時は選択状態にする
                label.closeImageView.isHidden = false
                label.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
                self.editLabelView = label
                
                // 選択状態のためスクロールができないようにする
                imageScrollView.isScrollEnabled = false
                
                imageView?.addSubview(label)
                
            }
        }
        // テキストビューコントローラーを消す
        completion()
    }
    
}
