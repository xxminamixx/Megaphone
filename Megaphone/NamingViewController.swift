
//  NamingViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import Cartography
import GestureRecognizerClosures
import SwiftyAttributes

class NamingViewController: UIViewController {
    
    static let identifier = "NamingViewController"
    var imageView: UIImageView?
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
            self.pinch(gesture: pinch)
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
            
            // プロパティでItemsViewを保持(打ち消し線を引くため)
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
    
    // MARK: 背景ピンチ時
    func pinch(gesture: UIPinchGestureRecognizer) {
        guard let editingLabel = self.editLabelView else {
            // 編集中のラベル、スタンプがなかったらステージ画像をズーム
            guard let editStamp = self.stampView else {
                self.imageScrollView.zoomScale = gesture.scale
                return
            }
            
            // 倍率
            let changeAmountScele = gesture.scale / editStamp.befroScale
            // スタンプの親Viewの大きさをピンチで変化させる
            editStamp.frame.size = CGSize(width: editStamp.frame.width * changeAmountScele, height: editStamp.frame.height * changeAmountScele)
            // スタンプの親Viewの拡大・縮小に追随してスタンプ画像も変化させる
            editStamp.stamp.frame.size = CGSize(width: editStamp.stamp.frame.width * changeAmountScele, height: editStamp.stamp.frame.height * changeAmountScele)
            editStamp.befroScale = gesture.scale
            
            // 破線レイヤーの更新
            editStamp.layer.sublayers?.last?.removeFromSuperlayer()
            editStamp.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
            
            return
        }
        
        /* 以下ラベル選択中の処理 */
        
        // 倍率
        let changeAmountScele = gesture.scale / editingLabel.befroScale
        
        editingLabel.frame.size = CGSize(width: editingLabel.frame.width * changeAmountScele + 30, height: editingLabel.frame.width * changeAmountScele)
        editingLabel.namingLabel.frame.size = CGSize(width: editingLabel.namingLabel.frame.width * changeAmountScele + 30, height: editingLabel.namingLabel.frame.height * changeAmountScele)
        
        // ピンチしたときViewの大きさを変えてフォントサイズが変更されてもテキストが見切れないようにする
        // フォントサイズ変更
        editingLabel.fontSize = editingLabel.fontSize * changeAmountScele
        editingLabel.namingLabel.font = UIFont(name: ConstText.helveticaNeue, size: editingLabel.fontSize)
        // スケール保持
        editingLabel.befroScale = gesture.scale
        
        editingLabel.setNeedsLayout()
        editingLabel.layoutIfNeeded()
        // ラベルの大きさを文字に合わせる
        editingLabel.namingLabel.sizeToFit()
        
        // Viewの大きさをラベルの大きさ変更に合わせて調整
        editingLabel.frame.size = CGSize(width: editingLabel.namingLabel.frame.width, height: editingLabel.namingLabel.frame.height + editingLabel.closeImageView.frame.height)
        
        // 破線レイヤーの更新
        editingLabel.layer.sublayers?.last?.removeFromSuperlayer()
        editingLabel.drawDashedLine(color: UIColor.gray, lineWidth: 2, lineSize: 3, spaceSize: 3, type: .All)
        
        if gesture.state == .ended {
            editingLabel.namingLabel.sizeToFit()
        }

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
    
    // MARK: ラベル読み込み処理
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
