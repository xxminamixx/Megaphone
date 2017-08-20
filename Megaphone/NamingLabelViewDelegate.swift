//
//  NamingLabelViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit


// MARK: NamingLabelViewDelegate
extension NamingViewController: NamingLabelViewDelegate {
    
    func closeButtonTapped(view: NamingLabelView) {
        // ラベルを削除
        view.removeFromSuperview()
        // 色変更のViewが表示されていたら削除
        closeLabelSettingView(isAnimation: true)
    }
    
    func namingLabelTapped(view: NamingLabelView) {
        
        // 2回目にタップしたビューが同じビューではなく、前のタップしたラベルが選択状態のままの時
        if let editingLabel = self.editLabelView {
            if editingLabel != view && editingLabel.isSubLayer(count: 3) {
                // ラベルの選択状態を解除
                labelSelectCancel()
            }
        }
        
        // 編集用のラベルを保持
        self.editLabelView = view
        
        if view.isSubLayer(count: 3) {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
                let navigation = TextViewNavigationController()
                navigation.addChildViewController(viewController)
                
                viewController.navigationItem.title = ConstText.editLabel
                viewController.delegate = self
                viewController.text = view.namingLabel.text
                
                present(navigation, animated: true, completion: nil)
            }
        } else {
            // 選択状態にした時
            // ItemViewのフォントアイコンに使えないことを表す斜線を入れる
            deleteCancelLineToFontConfig()
            // スタンプの選択を解除
            stampSelectCancel()
            closeStampSelectView(isAnimation: true)
            // スクロールビューのスクロールをできないようにする
            self.imageScrollView.isScrollEnabled = false
        }
    }
    
    // ラベルの選択を解除
    func labelSelectCancel() {
        guard let editLebel = editLabelView else {
            return
        }
        editLebel.layer.sublayers?.last?.removeFromSuperlayer()
        editLebel.closeImageView.isHidden = true
        editLabelView = nil
    }
    
}
