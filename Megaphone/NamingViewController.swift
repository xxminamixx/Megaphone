//
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // TODO: 永続化処理をここでしたい
        if let viewControllers = self.navigationController?.viewControllers {
            var existsSelfInViewControllers = true
            for viewController in viewControllers {
                // viewWillDisappearが呼ばれる時に、
                // 戻る処理を行っていれば、NavigationControllerのviewControllersの中にselfは存在していない
                if viewController == self {
                    existsSelfInViewControllers = false
                    // selfが存在した時点で処理を終える
                    break
                }
            }
            
            if existsSelfInViewControllers {
                saveLabels()
            }
        }
        
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
        
    private func saveLabels() {
        // imageViewのsubviewであるNamingViewを全て取得したい
        guard let subviews = imageView?.subviews else {
            return
        }
        
        let labelEntity = LabelOfStageEntity()
        for subview in subviews {
            let entity = LabelEntity()
            
            entity.pointX = subview.frame.origin.x
            entity.pointY = subview.frame.origin.y
            let label = subview as! NamingLabelView
            entity.fontSize = label.fontSize
            entity.text = label.namingLabel.text
            
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
    
    // Realmに永続化されているラベル情報を読み込み配置する
    private func loadLabels() {
        if let title = navigationItem.title {
            
            if let entity = LabelStoreManager.pic(key: title) {
                
                // このfor文で永続化永続化している複数のラベル座標からラベルを配置する
                for labelEntity in entity.labelList {
                    
                    if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                        
                        // サイズ計算用のダミーのラベル
                        label.namingLabel.text = labelEntity.text
                        label.fontSize = labelEntity.fontSize
                        label.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: labelEntity.fontSize)
                        label.namingLabel.sizeToFit()
                        let labelWidth = label.namingLabel.bounds.width
                        let viewHeight = label.namingLabel.bounds.height + label.closeImageView.bounds.height
                        // ラベルの初期位置を設定
                        label.frame = CGRect(x: labelEntity.pointX, y: labelEntity.pointY, width: labelWidth, height: viewHeight)
                        // ラベルの初期位置を保持
                        label.beforFrame = CGPoint(x: labelEntity.pointX , y: labelEntity.pointY)
                        
                        label.delegate = self
                        imageView?.addSubview(label)
                    }
                }
            }
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
        
        func addLabelView(x: CGFloat, y: CGFloat) {
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                // サイズ計算用のダミーのラベル
                label.namingLabel.text = text
                
                if let fontSize = self.editLabelView?.fontSize {
                    label.fontSize = fontSize
                    label.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: fontSize)
                }
                label.namingLabel.sizeToFit()
                let labelWidth = label.namingLabel.bounds.width
                let viewHeight = label.namingLabel.bounds.height + label.closeImageView.bounds.height
                // ラベルの初期位置を設定
                label.frame = CGRect(x: x, y: y, width: labelWidth, height: viewHeight)
                // ラベルの初期位置を保持
                label.beforFrame = CGPoint(x: x, y: y)
                
                label.delegate = self
                imageView?.addSubview(label)
            }

        }
        
        if editLabelView != nil {
            // ラベルの編集が行われている場合
            
            // 編集中のラベルの座標
            let x = editLabelView?.beforFrame.x
            let y = editLabelView?.beforFrame.y
            
            // 新しいラベルビューを追加
            addLabelView(x: x!, y: y!)
            // 編集中のラベルを削除
            editLabelView?.removeFromSuperview()
            // 何度もこのif文に入らないように破棄
            editLabelView = nil
        } else {
            // NamingLabelViewを生成する
            if let label = UINib(nibName: NamingLabelView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? NamingLabelView {
                
                // サイズ計算用のダミーのラベル
                label.namingLabel.text = text
                label.fontSize = 18
                label.namingLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
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
