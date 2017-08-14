
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
    var stampSelectView: StampSelectView?
    // ItemsViewを保持
    var topItemsView: ItemView?
    // ピンチした中心座標を保持
    var pinchCenter = CGPoint.zero
    
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るボタンの文字を空にすることで矢印だけにする
        navigationController!.navigationBar.topItem!.title = " "
        
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
            // 編集中のラベルがなかったらステージ画像をズーム
            guard let editingLabel = self.editLabelView else {
                self.imageScrollView.zoomScale = pinch.scale
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
            self.editLabelView?.namingLabel.frame = CGRect(x: (self.editLabelView?.namingLabel.frame.origin.x)!, y: (self.editLabelView?.namingLabel.frame.origin.y)!, width: (self.editLabelView?.namingLabel.frame.width)! * (changeAmountScele) + 30, height: (self.editLabelView?.namingLabel.frame.height)! * (changeAmountScele))
            
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
    
    // MARK: スクロールビューがタップされたとき呼ばれる
    func tapped(gesture: UITapGestureRecognizer) {
        
        for i in 0..<gesture.numberOfTouches {
            let point = gesture.location(ofTouch: i, in: self.view)
            pointX = point.x
            pointY = point.y
        }
        
        // タップしたときstampSelectViewがあるとき
        if let _ = stampSelectView {
            // スタンプ選択画面を閉じる
            closeStampSelectView()
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
                viewController.navigationItem.title = "新規作成"
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
        for subview in subviews {
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
            
            if let missNameEntity = LabelStoreManager.pic(key: "海女美術館") {
                LabelStoreManager.save {
                    missNameEntity.key = "海女美術大学"
                }
            }
            
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
                
                viewController.navigationItem.title = "編集中"
                viewController.delegate = self
                viewController.text = view.namingLabel.text
                
                present(navigation, animated: true, completion: nil)
            }
        } else {
            // 選択状態にした時
            deleteCancelLineToFontConfig()
            self.imageScrollView.isScrollEnabled = false
        }
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
        // TODO: 下からスタンプ画像選択のコレクションViewをアニメーション表示
        
        if let stampSelectView = UINib(nibName: StampSelectView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StampSelectView {
            
            guard let image = imageView else {
                return
            }
            
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
            twitterPostView.setInitialText("#Splatoon2 #スプラトゥーン2\n#めがほん\n")
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
    
    // スタンプ選択画面を閉じる
    func closeStampSelectView() {
        guard let stampView = self.stampSelectView else {
            return
        }
        
        func delete() {
            self.stampSelectView?.removeFromSuperview()
            self.stampSelectView = nil
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .allowAnimatedContent, animations: {
            stampView.frame.origin.y += stampView.frame.size.height
        }, completion: { fin in
            delete()
        })
    }
    
    // スタンプViewの閉じるボタンが押された時
    func stampSelectCloseTapped() {
        closeStampSelectView()
    }
    
    func stampSelectImageTapped(image: UIImage) {
        // スタンプをタップしたとき呼ばれる
        // TODO: ここはカスタムViewにしてタップ判定を受けられるようにする
        
        if let stampView = UINib(nibName: StampView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? StampView {
            
            stampView.delegate = self
            stampView.stamp.image = image
            
            // とりあえず画面の中心に配置
            let screen = UIScreen.main.bounds.size
            let origin = CGPoint(x: screen.width / 2, y: screen.height / 2)
            stampView.beforeFrame = origin
            stampView.frame.origin = origin
            stampView.frame.size = CGSize(width: 100, height: 100)
            
            self.imageView?.addSubview(stampView)

        }
        
    }
    
}

extension NamingViewController: StampViewDelegate {
    
    func stampCloseTapped(view: UIView) {
        view.removeFromSuperview()
    }
    
    
}
