//
//  ItemViewDelegate.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/08/16.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import Social
import Cartography


// MARK: ItemViewDelegate
extension NamingViewController: ItemViewDelegate {
    
    func allDeleteTapped() {
        // このControllerに対応するRealmのエンティティを削除する
        present(AlertControllerManager.customActionAlert(title: nil, message: ConstText.allDelete,
                                                         defaultAction: { _ in
                                                            // subViewのラベルを全て削除
                                                            for subView in (self.imageView?.subviews)! {
                                                                subView.removeFromSuperview()
                                                            }
                                                            
                                                            if let title = self.navigationItem.title {
                                                                RealmStoreManager.deleteLabelEntity(key: title)
                                                                RealmStoreManager.deleteStampEntity(key: title)
                                                            }
        }), animated: true, completion: nil)
    }
    
    
    /// 色選択のViewを表示
    ///
    /// - Parameters:
    ///   - isFont: 今フォント色変更かどうかのフラグ
    ///   - isSelectItemView: ItemViewをタップして呼ばれたかのフラグ
    func showColorPicker(isFont: Bool, isSelectItemView: Bool) {
        
        // ラベルを編集集じゃなかったら以下に進まない
        guard let _ = self.editLabelView else {
            return
        }
        
        if let labelSettingView = UINib(nibName: LabelSettingView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? LabelSettingView {
            
            closeLabelSettingView(isAnimation: false)
            
            // プロパティで保持
            textSettingView = labelSettingView
            textSettingView?.delegate = self
            textSettingView?.isFontColorSelected = isFont
            if isFont {
                // フォント色変更時の初期設定
                textSettingView?.fill.drawLine(color: UIColor.white, lineWidth: 1.0)
                
                // 現状フォント色選択時にスライダーを活用しないので非表示にする
                textSettingView?.slider.isHidden = true
                textSettingView?.sliderLeftImage.isHidden = true
                textSettingView?.sliderRightImage.isHidden = true
            } else {
                // 枠色変更時の初期設定
                textSettingView?.stroke.drawLine(color: UIColor.white, lineWidth: 1.0)
            }
            textSettingView?.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height - 200)
            
            guard let settingView = textSettingView else {
                return
            }
            
            guard let image = imageView else {
                return
            }
            
            self.view.addSubview(settingView)
            
            // オートレイアウトの制約更新
            constrain(settingView, image) { view1, view2 in
                view1.height == 200.0
                view1.width == UIScreen.main.bounds.size.width
                view1.left == view2.left
                view1.right == view2.right
                view1.bottom == view2.bottom - 60
            }
            
            // アニメーションで下から出てくる設定
            if isSelectItemView {
                // ItemViewで選択されていたらアニメーションで表示
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
                    settingView.frame.origin.y -= settingView.frame.size.height
                }, completion: nil)
            }
            
        }
    }
    
    // 塗りつぶしボタンを押した時
    func fillTapped() {
        showColorPicker(isFont: true, isSelectItemView: true)
    }
    
    // 枠線ボタンを押した時
    func strokeTapped() {
        showColorPicker(isFont: false, isSelectItemView: true)
    }
    
    // スタンプボタンタップ
    func stampTapped() {
        
        if let stampSelectView = UINib(nibName: StampSelectView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StampSelectView {
            
            guard let image = imageView else {
                return
            }
            
            closeLabelSettingView(isAnimation: false)
            labelSelectCancel()
            
            closeStampSelectView(isAnimation: false)
            
            
            stampSelectView.delegate = self
            
            // 表示したstamp表示用のViewを保持
            self.stampSelectView = stampSelectView
            
            self.view.addSubview(stampSelectView)
            
            constrain(stampSelectView, image) { view1, view2 in
                view1.height == 200.0
                view1.width == UIScreen.main.bounds.size.width
                view1.left == view2.left
                view1.right == view2.right
                view1.bottom == view2.bottom - 60
            }
            
            // アニメーションで表示
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
                stampSelectView.frame.origin.y -= stampSelectView.frame.size.height
            }, completion: nil)
            
        }
    }
    
    func twitterTapped() {
        if let image = imageView?.castImage() {
            // ツイッター投稿画面を表示
            let twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            twitterPostView.add(image)
            twitterPostView.setInitialText("#Splatoon2 #スプラトゥーン2\n#\(navigationItem.title ?? "") #めがほん\n")
            present(twitterPostView, animated: true, completion: nil)
        }
    }
    
    func screenShotTapped() {
        guard let image = imageView?.castImage() else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImageResult), nil)
    }
    
    // MARK: - フォントボタンの打ち消し線処理
    
    // ItemsViewの塗りつぶし・枠線ボタンに打ち消し線を描く
    func drawCancelLineToFontConfig() {
        // ラベルを編集中じゃなかったら塗りつぶし・枠線ボタンに打ち消し線を描く
        if self.editLabelView == nil {
            topItemsView?.fillButton.drawCancelLine(color: UIColor.lightGray, lineWidth: 2.0)
            topItemsView?.strokeButton.drawCancelLine(color: UIColor.lightGray, lineWidth: 2.0)
        }
    }
    
    // ItemsViewの塗りつぶし・枠線ボタンに書いている打ち消し線を削除する
    func deleteCancelLineToFontConfig() {
        topItemsView?.fillButton.layer.sublayers?.last?.removeFromSuperlayer()
        topItemsView?.strokeButton.layer.sublayers?.last?.removeFromSuperlayer()
    }
    
    // MARK: - スクリーンショット押下時処理
    
    // 保存を試みた結果をダイアログで表示
    func saveImageResult(_ image: UIImage, didFinishSavingWithError error: Error!, contextInfo: UnsafeMutableRawPointer) {
        
        var title = ConstText.imageSaveSuccess
        var message = ConstText.imageSaveSuccessMessage
        
        if error != nil {
            title = ConstText.imageSaveFailure
            message = ConstText.imageSaveFailureMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: ConstText.ok, style: .default, handler: nil))
        
        // UIAlertController を表示
        present(alert, animated: true, completion: nil)
    }
    
}
