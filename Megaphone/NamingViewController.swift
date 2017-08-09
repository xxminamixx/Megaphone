
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
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るボタンの文字を空にすることで矢印だけにする
        navigationController!.navigationBar.topItem!.title = " "
        
        imageView?.backgroundColor = UIColor.darkGray
        
        imageView?.isUserInteractionEnabled = true
        
        // スクロールビューにタップジェスチャを登録
        imageScrollView.onTap { tap in
            self.tapped(gesture: tap)
        }
        
        // スクロールビューにピンチジェスチャを登録
        imageScrollView.onPinch { pinch in
            // 編集中のラベルがなかったら何もしない
            guard let editingLabel = self.editLabelView else {
                return
            }
            
            // 編集中のラベルのレイヤーが2枚以下なら何もしない
            guard editingLabel.isSubLayer(count: 3) else {
                return
            }
            
            // 倍率
            let changeAmountScele = pinch.scale / (self.editLabelView?.befroScale)!
            
            // ピンチしたときViewの大きさを変えてフォントサイズが変更されてもテキストが見切れないようにする
            self.editLabelView?.frame = CGRect(x: (self.editLabelView?.frame.origin.x)!, y: (self.editLabelView?.frame.origin.y)!, width: (self.editLabelView?.frame.width)! * (changeAmountScele) + 30, height: (self.editLabelView?.frame.height)! * (changeAmountScele))
            // Viewに追随してラベルも大きくする
            self.editLabelView?.namingLabel.frame = CGRect.init(x: (self.editLabelView?.namingLabel.frame.origin.x)!, y: (self.editLabelView?.namingLabel.frame.origin.y)!, width: (self.editLabelView?.namingLabel.frame.width)! * (changeAmountScele) + 30, height: (self.editLabelView?.namingLabel.frame.height)! * (changeAmountScele))
            
            // フォントサイズ変更
            self.editLabelView?.fontSize = (self.editLabelView?.fontSize)! * changeAmountScele
            self.editLabelView?.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: (self.editLabelView?.fontSize)!)
            // スケール保持
            self.editLabelView?.befroScale = pinch.scale
            
            self.editLabelView?.setNeedsLayout()
            self.editLabelView?.layoutIfNeeded()
            // ラベルの大きさを文字に合わせる
            self.editLabelView?.namingLabel.sizeToFit()
            // ラベルの横幅に合わせてViewの横幅を調整
            self.editLabelView?.frame = CGRect(x: (self.editLabelView?.frame.origin.x)!, y: (self.editLabelView?.frame.origin.y)!, width: (self.editLabelView?.namingLabel.frame.width)!, height: (self.editLabelView?.namingLabel.frame.height)! + (self.editLabelView?.closeImageView.frame.height)!)
            // 破線レイヤーの更新
            self.editLabelView?.layer.sublayers?.last?.removeFromSuperlayer()
            self.editLabelView?.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
            
            if pinch.state == .ended {
                self.editLabelView?.namingLabel.sizeToFit()
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
            
            itemsView.delegate = self
            // ItemViewをimageViewのsubViewとして追加
            imageScrollView.addSubview(itemsView)
            
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
        
        var title = "保存完了"
        var message = "カメラロールに保存しました"
        
        if error != nil {
            title = "エラー"
            message = "保存に失敗しました"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // OKボタンを追加
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // UIAlertController を表示
        present(alert, animated: true, completion: nil)
    }
    
    // スクロールビューがタップされたとき呼ばれる
    func tapped(gesture: UITapGestureRecognizer) {
        
        for i in 0..<gesture.numberOfTouches {
            let point = gesture.location(ofTouch: i, in: self.view)
            pointX = point.x
            pointY = point.y
        }
        
        // 2回目にタップしたビューが同じビューではなく、前のタップしたラベルが選択状態のままの時
        if let editingLabel = self.editLabelView {
            if editingLabel.isSubLayer(count: 3) {
                // 選択状態を解除
                editingLabel.layer.sublayers?.last?.removeFromSuperlayer()
                // 閉じるボタンを非活性
                editingLabel.closeImageView.isHidden = true
                // 編集中のラベルのポインタを破棄
                self.editLabelView = nil
                
                // 色変更Viewを削除
                closeLabelSettingView()
                
                // 選択を解除したらテキスト入力画面を出したくないのでreturn
                return
            }
        }
        
        // navigationBarの高さ + ステータスバーの高さ + ItemsViewの高さ(60.0)　より下をタップした時
        if pointY! > (navigationController?.navigationBar.frame.size.height)! + UIApplication.shared.statusBarFrame.height + 60.0 {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
                let navigation = TextViewNavigationController()
                navigation.addChildViewController(viewController)
                viewController.delegate = self
                present(navigation, animated: true, completion: nil)
            }
        }

    }
    
    func onClickCloseButton() {
        if !(actionTextView?.hasText)! {
            // テキストが入力されていない
            actionTextView?.text = "名前をつけてください"
            actionTextView?.textColor = UIColor.lightGray
            actionTextView?.sizeToFit()
        }
        actionTextView?.resignFirstResponder()
    }
    
    // ImageViewにlabelを追加する
    func addLabelToImageView (label: NamingLabelView, x: CGFloat, y: CGFloat, text: String?, fontSize: CGFloat, attribute: Data) {
        label.namingLabel.text = text
        
        label.fontSize = fontSize
        label.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
        // NSDataから復元
        if let attributedText = NSKeyedUnarchiver.unarchiveObject(with: attribute) as? NSAttributedString {
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
        for subview in subviews {
            let entity = LabelEntity()
            
            // ラベルの原点格納
            entity.pointX = subview.frame.origin.x
            entity.pointY = subview.frame.origin.y
            
            // ラベルのフォントサイズ と　テキストを格納
            if let label = subview as? NamingLabelView {
                entity.fontSize = label.fontSize
                entity.text = label.namingLabel.text
                
                // TODO: 文字色・枠色・枠太さ
                let data = NSKeyedArchiver.archivedData(withRootObject: label.namingLabel.attributedText ?? "")
                
                entity.attribute = data
            }
            
 
            
            labelEntity.labelList.append(entity)
        }
        // 画面タイトルをキーに設定
        labelEntity.key = navigationItem.title
        
        // タイトルがオプショナルなので安全な取り出し
        if let title = navigationItem.title {
            // もし同じ名前のEntityが存在したら削除
            if LabelStoreManager.pic(key: title) != nil {
                LabelStoreManager.delete(key: title)
            }
        }
        
        // Entityを追加
        LabelStoreManager.add(object: labelEntity)
    }
    
    // MARK: Realmに永続化されているラベル情報を読み込み配置する
    private func loadLabels() {
        if let title = navigationItem.title {
            
            if let entity = LabelStoreManager.pic(key: title) {
                
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
        }
    }
    
    // ラベルの色を設定するViewを閉じる
    func closeLabelSettingView() {
        // 色変更のViewがあるとき
        if let settingViwe = textSettingView {
            // レイヤーから削除
            settingViwe.removeFromSuperview()
            // ポインタを破棄
            textSettingView = nil
        }
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
        closeLabelSettingView()
    }
    
    func namingLabelTapped(view: NamingLabelView) {
    
        // 2回目にタップしたビューが同じビューではなく、前のタップしたラベルが選択状態のままの時
        if let editingLabel = self.editLabelView {
            if editingLabel != view && editingLabel.isSubLayer(count: 3) {
                // 選択状態を解除
                editingLabel.layer.sublayers?.last?.removeFromSuperlayer()
                // 閉じるボタンを非活性
                editingLabel.closeImageView.isHidden = true
            }
        }
        
        // 編集用のラベルを保持
        self.editLabelView = view
        
        if view.isSubLayer(count: 3) {
            if let viewController = storyboard?.instantiateViewController(withIdentifier: TextViewController.nibName) as? TextViewController  {
                let navigation = TextViewNavigationController()
                navigation.addChildViewController(viewController)
                
                viewController.delegate = self
                present(navigation, animated: true, completion: nil)
            }
        }
    }
    
}

// MARK: TextViewControllerDelegate
extension NamingViewController: TextViewControllerDelegate {
    
    func getTextView(text: String?, completion: () -> Void) {
        
        if editLabelView != nil {
            // ラベルの編集が行われている場合
            
            // 編集中のラベルの座標
            let x = editLabelView?.beforFrame.x
            let y = editLabelView?.beforFrame.y
            
            // 新しいラベルビューを追加
            
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                let data = NSKeyedArchiver.archivedData(withRootObject: label.namingLabel.attributedText ?? "")
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
                // TODO: ここで設定した内容をNamingLabelViewのプロパティに持たせることで永続化できるようにする
                let settingLabel = text?.withTextColor(UIColor.white).withFont(UIFont(name: "HelveticaNeue-Bold", size: 18)!).withStrokeColor(UIColor.white)
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
        present(AlertControllerManager.customActionAlert(title: nil, message: "テキストを全て削除しますか？",
                                                         defaultAction: { _ in
                                                            // subViewのラベルを全て削除
                                                            for subView in (self.imageView?.subviews)! {
                                                                subView.removeFromSuperview()
                                                            }
                                                            
                                                            if let title = self.navigationItem.title {
                                                                LabelStoreManager.delete(key: title)
                                                            }
        }), animated: true, completion: nil)
    }
    
    // 色選択のViewを表示
    func showColorPicker(isFont: Bool) {
        
        // ラベルを編集集じゃなかったら以下に進まない
        guard let _ = self.editLabelView else {
            return
        }
        
        if let labelSettingView = UINib(nibName: LabelSettingView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? LabelSettingView {
            
            closeLabelSettingView()
            
            // プロパティで保持
            textSettingView = labelSettingView
            textSettingView?.delegate = self
            textSettingView?.isFontColorSelected = isFont
            if isFont {
                // フォント色変更時の初期設定
                textSettingView?.fill.drawLine(color: UIColor.brown, lineWidth: 1.0)
                
                // 現状フォント色選択時にスライダーを活用しないので非表示にする
                textSettingView?.slider.isHidden = true
                textSettingView?.sliderLeftImage.isHidden = true
                textSettingView?.sliderRightImage.isHidden = true
            } else {
                // 枠色変更時の初期設定
                textSettingView?.stroke.drawLine(color: UIColor.brown, lineWidth: 1.0)
            }
            textSettingView?.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height - 200)
            
            if let settingView = textSettingView {
                imageScrollView.addSubview(settingView)
            }
            
            // オートレイアウトの制約更新
            guard let image = imageView else {
                return
            }
            
            constrain(labelSettingView, image) { view1, view2 in
                view1.height == 200.0
                view1.width == UIScreen.main.bounds.size.width
                view1.left == view2.left
                view1.right == view2.right
                view1.bottom == view2.bottom - 60
            }
        }
    }
    
    // 塗りつぶしボタンを押した時
    func fillTapped() {
        showColorPicker(isFont: true)
    }
    
    // 枠線ボタンを押した時
    func strokeTapped() {
        showColorPicker(isFont: false)
    }
    
    func twitterTapped() {
        if let image = imageView?.castImage() {
            // ツイッター投稿画面を表示
            let twitterPostView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
            twitterPostView.add(image)
            twitterPostView.setInitialText("")
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

extension NamingViewController: LabelSettingViewDelegate {
    
    func modeChange(isFont: Bool) {
        showColorPicker(isFont: isFont)
    }
    
    func movedSlider(sender: UISlider, isFont: Bool, color: UIColor) {
        if isFont{
            // フォント選択時にスライダーを動かした時の処理
        } else {
            // 枠線選択時にスライダーを動かした時の処理
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withStrokeWidth(-1.0 * (Double(sender.value * 10))).withStrokeColor(color)
        }
    }

    func colorViewTapped(isFont: Bool, color: UIColor) {
        // TODO: editLabelの色を変更する処理
        // フォント色
        // 枠線色
        // 枠線の太さ
        if isFont {
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withTextColor(color)
        } else {
            editLabelView?.namingLabel.attributedText = editLabelView?.namingLabel.attributedText?.withStrokeColor(color).withStrokeWidth(-1.0)
        }
    }
    
}
