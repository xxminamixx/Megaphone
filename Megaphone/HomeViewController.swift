//
//  HomeViewController.swift
//  Megaphone
//
//  Created by 南　京兵 on 2017/07/18.
//  Copyright © 2017年 南　京兵. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Toucan

class HomeViewController: UIViewController {

    @IBOutlet weak var stageTableView: UITableView!
    @IBOutlet weak var bannerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 広告の設定
        let banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        // AdMobで発行された広告ユニットIDを設定
        banner.adUnitID = "ここに広告ID埋め込む"
        banner.delegate = self
        banner.rootViewController = self
        let gadRequest:GADRequest = GADRequest()
        
        // テスト用の広告を表示する時のみ使用（申請時に削除）
        gadRequest.testDevices = [kGADSimulatorID]
        
        banner.load(gadRequest)
        self.bannerView.addSubview(banner)
        
        // テーブルビューの初期設定
        stageTableView.delegate = self
        stageTableView.dataSource = self
        let nib = UINib(nibName: StageTableViewCell.nibName, bundle: nil)
        stageTableView.register(nib, forCellReuseIdentifier: StageTableViewCell.nibName)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ table: UITableView,didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(withIdentifier: NamingViewController.identifier) as! NamingViewController
        // TODO: ここに遷移先に施したい処理を書く
        let stageEntity = JsonManager.shared.stages?[indexPath.row]
        viewController.navigationItem.title = stageEntity?.stageName
        
        // TODO: 画面サイズに合うように画像をリサイズしたい
        let size = viewController.view.bounds

        if let imageName = stageEntity?.imageName {
            // 画像を生成
            if let image = UIImage(named: imageName) {
                // 画像を画面横に合わせて縮小
                let ratio = image.size.width / size.width
                
                // イメージビューの位置
                let imageViewRect = CGRect(x: 0, y: 0, width: image.size.width / ratio, height: image.size.height / ratio)
                // スクロールビューの位置
                let scrollViewRect = CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.size.height)!, width: image.size.width / ratio, height: image.size.height / ratio)
                
                // イメージビュー生成
                let imageView = UIImageView(frame: imageViewRect)
                imageView.image = image
                
                // スクロールビュー生成
                let scrollView = UIScrollView(frame: scrollViewRect)
                scrollView.contentSize = imageView.bounds.size
                scrollView.delegate = viewController
                scrollView.minimumZoomScale = 0.5
                scrollView.maximumZoomScale = 3.0
                scrollView.addSubview(imageView)
                viewController.scrollView = scrollView
                
                viewController.view.addSubview(viewController.scrollView!)

            }
        }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return JsonManager.shared.stageCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = stageTableView.dequeueReusableCell(withIdentifier: StageTableViewCell.nibName, for: indexPath) as! StageTableViewCell
        
        guard let stageList = JsonManager.shared.stages else {
            // jsonのパースに失敗していた場合ステージ名をセットせずリターン
            return cell
        }
        
        cell.stageName.text = stageList[indexPath.row].stageName
        return cell
    }
    
}

extension HomeViewController: GADBannerViewDelegate {
    
}
