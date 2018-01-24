//
//  StampViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


// MARK: StampViewDelegate
extension NamingViewController: StampViewDelegate {
    
    func stampTapped(view: StampView) {
        
        // 2回目にタップしたビューが同じビューではなく、前のタップしたラベルが選択状態のままの時
        if let editStamp = stampView {
            if editStamp != view && editStamp.isSubLayer(count: 3) {
                // スタンプの選択状態を解除
                stampSelectCancel()
            }
        }
        
        if view.isSubLayer(count: 3) {
            // タップしたら非選択になった
            
        } else {
            // タップしたら選択中になった
            // プロパティで保持
            selectView(view: view)
            // 色選択のViewが表示されていたら閉じる
            closeLabelSettingView(isAnimation: true)
        }
    }
    
    func stampCloseTapped(view: StampView) {
        view.removeFromSuperview()
    }
    
    // スタンプビューの選択を解除
    func stampSelectCancel() {
        stampView?.layer.sublayers?.last?.removeFromSuperlayer()
        stampView?.close.isHidden = true
        stampView = nil
    }
    
}
