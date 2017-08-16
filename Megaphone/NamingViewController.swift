
//  NamingViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import Social
import Cartography
import GestureRecognizerClosures
import SwiftyAttributes

class NamingViewController: UIViewController {
    
    static let identifier = "NamingViewController"
    var imageView: UIImageView?
    var actionTextView: UITextView?
    var scrollView: UIScrollView?
    // ラベルの表示テキスト位置保存用
    var pointX: CGFloat?
    var pointY: CGFloat?
    // 編集しているラベル保持用のプロパティ
    var editLabelView: NamingLabelView?
    // ラベル編集中のラベルを保持
    var textSettingView: LabelSettingView?
    // スタンプ表示用のViewを保持
    var stampView: StampView?
    // スタンプ選択用のViewを保持
    var stampSelectView: StampSelectView?
    // ItemsViewを保持
    var topItemsView: ItemView?
    // ピンチした中心座標を保持
    var pinchCenter = CGPoint.zero
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るボタンの文字を空にすることで矢印だけにする
        navigationController!.navigationBar.topItem!.title = ConstText.backNavigation
        
        /* View関連 */
        self.view.backgroundColor = UIColor.darkGray
        
        /* imageView関連 */
        imageView?.backgroundColor = UIColor.darkGray
        imageView?.isUserInteractionEnabled = true
        
        /* スクロールビュー関連 */
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 3.0
        imageScrollView.contentMode = .scaleAspectFit
        
        // スクロールビューにタップジェスチャを登録
        imageView?.onTap { tap in
            self.tapped(gesture: tap)
        }
        
        // スクロールビューにピンチジェスチャを登録
        imageView?.onPinch { pinch in
            
            guard let editingLabel = self.editLabelView else {
                // 編集中のラベル、スタンプがなかったらステージ画像をズーム
                guard let editStamp = self.stampView else {
                    self.imageScrollView.zoomScale = pinch.scale
                    return
                }
                
                // 倍率
                let changeAmountScele = pinch.scale / editStamp.befroScale
                // スタンプの親Viewの大きさをピンチで変化させる
                editStamp.frame.size = CGSize(width: editStamp.frame.width * changeAmountScele, height: editStamp.frame.height * changeAmountScele)
                // スタンプの親Viewの拡大・縮小に追随してスタンプ画像も変化させる
                editStamp.stamp.frame.size = CGSize(width: editStamp.stamp.frame.width * changeAmountScele, height: editStamp.stamp.frame.height * changeAmountScele)
                editStamp.befroScale = pinch.scale
                
                // 破線レイヤーの更新
                editStamp.layer.sublayers?.last?.removeFromSuperlayer()
                editStamp.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
                
                return
            }
            
            /* 以下ラベル選択中の処理 */
            
            // 倍率
            let changeAmountScele = pinch.scale / editingLabel.befroScale
            
            editingLabel.frame.size = CGSize(width: editingLabel.frame.width * changeAmountScele + 30, height: editingLabel.frame.width * changeAmountScele)
            editingLabel.namingLabel.frame.size = CGSize(width: editingLabel.namingLabel.frame.width * changeAmountScele + 30, height: editingLabel.namingLabel.frame.height * changeAmountScele)
            
            // ピンチしたときViewの大きさを変えてフォントサイズが変更されてもテキストが見切れないようにする            
            // フォントサイズ変更
            editingLabel.fontSize = editingLabel.fontSize * changeAmountScele
            editingLabel.namingLabel.font = UIFont(name: ConstText.helveticaNeue, size: editingLabel.fontSize)
            // スケール保持
            editingLabel.befroScale = pinch.scale
            
            editingLabel.setNeedsLayout()
            editingLabel.layoutIfNeeded()
            // ラベルの大きさを文字に合わせる
            editingLabel.namingLabel.sizeToFit()
            
            // Viewの大きさをラベルの大きさ変更に合わせて調整
            editingLabel.frame.size = CGSize(width: editingLabel.namingLabel.frame.width, height: editingLabel.namingLabel.frame.height + editingLabel.closeImageView.frame.height)
            
            // 破線レイヤーの更新
            editingLabel.layer.sublayers?.last?.removeFromSuperlayer()
            editingLabel.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
            
            if pinch.state == .ended {
                editingLabel.namingLabel.sizeToFit()
            }
            
        }
        
        // ラベルの配置
        loadLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let image = imageView else {
            return
        }
        // imageViewをscrollViewのsubViewとして追加
        imageScrollView.addSubview(image)
        
        // imageViewにアイテムViewを追加
        if let itemsView = UINib(nibName: ItemView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? ItemView {
            
            // プロパティでItemsViewを保持
            topItemsView = itemsView
            
            // ラベルを編集中じゃなかったら塗りつぶし・枠線ボタンに打ち消し線を描く
            drawCancelLineToFontConfig()
            
            itemsView.delegate = self
            // ItemViewをimageViewのsubViewとして追加
            self.view.addSubview(itemsView)
            
            // オートレイアウトの制約更新
            constrain(itemsView, image) { view1, view2 in
                view1.height == 60.0
                view1.width == UIScreen.main.bounds.width
                view1.left == view2.left
                view1.right == view2.right
            }

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 永続化処理
        saveLabels()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
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
    
    // MARK: 背景タップ時
    func tapped(gesture: UITapGestureRecognizer) {
        
        for i in 0..<gesture.numberOfTouches {
            let point = gesture.location(ofTouch: i, in: self.view)
            pointX = point.x
            pointY = point.y
        }
        
        // スタンプ選択画面と選択しているスタンプの両方が存在する時
        if stampSelectView != nil && stampView != nil {
            // 選択を解除しスタンプ選択画面を閉じる
            
            closeStampSelectView(isAnimation: true)
            // タップしたときstampViewがあるとき
            if let stamp = stampView {
                if stamp.isSubLayer(count: 3) {
                    // 選択状態を解除
                    stampSelectCancel()
                }
            }
            return
        } else if stampSelectView != nil {
            // スタンプ選択画面があるとき
            closeStampSelectView(isAnimation: true)
            return
        } else if stampView != nil {
            // 選択しているスタンプが存在するとき
            stampSelectCancel()
            return
        }
        
        // スクロールビューをタップしたときに選択状態のLabelがある場合
        if let editingLabel = self.editLabelView {
            if editingLabel.isSubLayer(count: 3) {
                // 選択状態を解除
                editingLabel.layer.sublayers?.last?.removeFromSuperlayer()
                // 閉じるボタンを非活性
                editingLabel.closeImageView.isHidden = true
                // 編集中のラベルのポインタを破棄
                self.editLabelView = nil
                
                // 色変更Viewを削除
                closeLabelSettingView(isAnimation: true)
                
                // ItemsViewの塗りつぶしボタン・枠線ボタンに打ち消し線を描く
                drawCancelLineToFontConfig()
                
                // スクロールビューのスクロールをできるようにする
                self.imageScrollView.isScrollEnabled = true
                
                // 選択を解除したらテキスト入力画面を出したくないのでreturn
                return
            }
        }
        
        // navigationBarの高さ + ステータスバーの高さ + ItemsViewの高さ(60.0)　より下をタップした時
        if pointY! > (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height + 60.0 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
                let navigation = TextViewNavigationController()
                navigation.addChildViewController(viewController)
                viewController.navigationItem.title = ConstText.newLabel
                viewController.delegate = self
                present(navigation, animated: true, completion: nil)
            }
        }

    }
    
    func onClickCloseButton() {
        if !(actionTextView?.hasText)! {
            // テキストが入力されていない
            actionTextView?.text = ConstText.notInputText
            actionTextView?.textColor = UIColor.lightGray
            actionTextView?.sizeToFit()
        }
        actionTextView?.resignFirstResponder()
    }
    
    // ImageViewにlabelを追加する
    func addLabelToImageView (label: NamingLabelView, x: CGFloat, y: CGFloat, text: String?, fontSize: CGFloat, attribute: Data) {
        label.namingLabel.text = text
        
        label.fontSize = fontSize
        label.namingLabel.font = UIFont(name: ConstText.helveticaNeue, size: fontSize)
        // NSDataから復元
        if let attributedText = NSKeyedUnarchiver.unarchiveObject(with: attribute) as? NSMutableAttributedString {
            attributedText.mutableString.setString(text!)
            label.namingLabel.attributedText = attributedText
        }
        label.namingLabel.sizeToFit()
        let labelWidth = label.namingLabel.bounds.width
        let viewHeight = label.namingLabel.bounds.height + label.closeImageView.bounds.height
        // ラベルの初期位置を設定
        label.frame = CGRect(x: x, y: y, width: labelWidth, height: viewHeight)
        // ラベルの初期位置を保持
        label.beforFrame = CGPoint(x: x , y: y)
        
        label.delegate = self
        imageView?.addSubview(label)
    }
    
    // MARK: ラベル永続化処理
    private func saveLabels() {
        // imageViewのsubviewであるNamingViewを全て取得したい
        guard let subviews = imageView?.subviews else {
            return
        }
        
        let labelEntity = LabelOfStageEntity()
        let stampEntityList = StampStoreEntityList()
        for subview in subviews {
            if subview is NamingLabelView {
                let entity = LabelEntity()
                // ラベルの原点格納
                entity.pointX = subview.frame.origin.x
                entity.pointY = subview.frame.origin.y
                
                // ラベルのフォントサイズ と　テキストを格納
                if let label = subview as? NamingLabelView {
                    entity.fontSize = label.fontSize
                    entity.text = label.namingLabel.text
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: label.namingLabel.attributedText ?? "")
                    
                    entity.attribute = data
                }
                labelEntity.labelList.append(entity)

            } else if subview is StampView {
                let entity = StampStoreEntity()
                // スタンプの原点格納
                entity.pointX = subview.frame.origin.x
                entity.pointY = subview.frame.origin.y
                
                if let stamp = subview as? StampView {
                    entity.width = stamp.frame.width
                    entity.height = stamp.frame.height
                    entity.name = stamp.imageName
                }
                stampEntityList.stampList.append(entity)
            }
        }
        
        // 画面タイトルをキーに設定
        labelEntity.key = navigationItem.title
        stampEntityList.key = navigationItem.title
        
        // タイトルがオプショナルなので安全な取り出し
        if let title = navigationItem.title {
            // もし同じ名前のLabelEntityが存在したら削除
            if RealmStoreManager.picLabelEntity(key: title) != nil {
                RealmStoreManager.deleteLabelEntity(key: title)
            }
            
            if RealmStoreManager.picStampEntity(key: title) != nil {
                RealmStoreManager.deleteStampEntity(key: title)
            }
        }
        
        // Entityを追加
        RealmStoreManager.addLabelEntity(object: labelEntity)
        RealmStoreManager.addStampEntity(object: stampEntityList)
    }
    
    // MARK: Realmに永続化されているラベル情報を読み込み配置する
    private func loadLabels() {
        if let title = navigationItem.title {
            
            if let missNameEntity = RealmStoreManager.picLabelEntity(key: "海女美術館") {
                RealmStoreManager.save {
                    missNameEntity.key = ConstText.ama
                }
            }
            
            // ラベルの配置
            if let entity = RealmStoreManager.picLabelEntity(key: title) {
                
                // このfor文で永続化永続化している複数のラベル座標からラベルを配置する
                for labelEntity in entity.labelList {
                    
                    if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                        if let attribute = labelEntity.attribute {
                             addLabelToImageView(label: label, x: labelEntity.pointX, y: labelEntity.pointY, text: labelEntity.text, fontSize: labelEntity.fontSize, attribute: attribute)
                        } else {
                             addLabelToImageView(label: label, x: labelEntity.pointX, y: labelEntity.pointY, text: labelEntity.text, fontSize: labelEntity.fontSize, attribute: Data())
                        }
                    }
                }
            }
            
            // スタンプの配置
            if let entity = RealmStoreManager.picStampEntity(key: title ) {
                
                for stampEntity in entity.stampList {
                    guard let name = stampEntity.name else {
                        return
                    }
                    // 位置と大きさを設定
                    let origin = CGPoint(x: stampEntity.pointX, y: stampEntity.pointY)
                    let size = CGSize(width: stampEntity.width, height: stampEntity.height)
                    
                    stampAddImageView(imageName: name, origin: origin, size: size)
                    
                }
                
            }
            
        }
    }
    
    // ラベルの色を設定するViewを閉じる
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
    
    // スタンプ選択Viewを閉じる
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
    
    // MARK: 選択中のラベルを管理
    func selectView(view: UIView) {
        if view is NamingLabelView {
            // ラベルのポインタを保持
            editLabelView = view as? NamingLabelView
            // スタンプの選択を解除
            stampSelectCancel()
        } else {
            // 現状はスタンプの時elseに入る
            
            // スタンプのポインタを保持
            stampView = view as? StampView
            // ラベルの選択を解除
            labelSelectCancel()
        }
    }
    
}

// MARK: UIScrollViewDelegate
extension NamingViewController: UIScrollViewDelegate {
        
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
}

// MARK: UITextViewDelegate
extension NamingViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        actionTextView = textView
        actionTextView?.delegate = textView.delegate
        actionTextView?.text = ""
        actionTextView?.textColor = UIColor.black
        return true
    }
}

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
                
                // サイズ計算用のダミーのラベル
                let settingLabel = text?.withTextColor(UIColor.white).withFont(UIFont(name: ConstText.helveticaNeue, size: 18)!).withStrokeColor(UIColor.white)
                label.namingLabel.attributedText = settingLabel
                
                label.fontSize = 18
                label.fontColor = ""
                label.namingLabel.sizeToFit()
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeImageView.bounds.height
                // ラベルの初期位置を設定
                label.frame = CGRect(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2), width: labelWidth, height: viewHeight)
                // ラベルの初期位置を保持
                label.beforFrame = CGPoint(x: pointX! - (labelWidth / 2), y: pointY! - (viewHeight * 2))
                
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
    
}

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
    
}

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
}

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
