//
//  StampSelectViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


// MARK: StampSelectViewDelegate
extension NamingViewController: StampSelectViewDelegate {
    
    // スタンプViewの閉じるボタンが押された時
    func stampSelectCloseTapped() {
        closeStampSelectView(isAnimation: true)
    }
    
    func stampSelectImageTapped(imageName: String) {
        // スタンプをタップしたとき呼ばれる
        
        // とりあえず画面の中心に配置
        let screen = UIScreen.main.bounds.size
        let origin = CGPoint(x: (screen.width / 2) - 50, y: (screen.height / 2) - 130)
        let size = CGSize(width: 100, height: 130)
        
        stampAddImageView(imageName: imageName, origin: origin, size: size)
    }
    
    // スタンプをimageViewに追加する
    func stampAddImageView(imageName: String, origin: CGPoint, size: CGSize) {
        if let stampView = UINib(nibName: StampView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StampView {
            
            stampView.delegate = self
            stampView.stamp.image = UIImage(named: imageName)
            // 永続化のためにプロパティで保持
            stampView.imageName = imageName
            stampView.beforeFrame = origin
            // 位置を大きさを設定
            stampView.frame.origin = origin
            stampView.frame.size = size
            // imageViewに追加
            self.imageView?.addSubview(stampView)
        }
    }
    
    // MARK: - スタンプ選択Viewを閉じる
    func closeStampSelectView(isAnimation: Bool) {
        // 色変更のViewがなかったら以下に進まない
        guard let stampSelectView = self.stampSelectView else {
            return
        }
        
        func delete() {
            // レイヤーから削除
            stampSelectView.removeFromSuperview()
            // ポインタを破棄
            self.stampSelectView = nil
        }
        
        if isAnimation {
            // アニメーションありでSettingViewを消す
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
                stampSelectView.frame.origin.y += stampSelectView.frame.size.height
            }, completion: { fin in
                delete()
            })
        } else {
            // アニメーション無しでSettingViewを消す
            delete()
        }
    }
    
}
