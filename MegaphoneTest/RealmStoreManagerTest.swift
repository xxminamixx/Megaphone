//
//  RealmStoreManagerTest.swift
//  MegaphoneTest
//
//  Created by 南　京兵 on 2018/01/23.
//  Copyright © 2018年 南　京兵. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Megaphone

class RealmStoreManagerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     MARK: 関数の命名規則
     
     1節: テスト対象とするため「test」を固定とする
     2節: どんなテスト内容なのかを記す
     3節: テスト結果と理由を記述
     
     節の繋ぎはアンダースコア(_)とする
     
     **/
    
    /// ハコフグを永続化した状態としておくこと
    func test_ジェネリクスなfilter関数_正しくフィルタリングできるので成功() {
        let result = RealmStoreManager.filterEntityList(type: LabelOfStageEntity.self, property: "key", filter: "ハコフグ倉庫").first?.key == "ハコフグ倉庫"
        XCTAssert(result)
    }
    
}
