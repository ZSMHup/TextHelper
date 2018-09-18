//
//  ViewController.swift
//  AYTextHelper
//
//  Created by 张书孟 on 2018/5/15.
//  Copyright © 2018年 ZSM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let testLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        testLabel.numberOfLines = 0
        testLabel.textColor = UIColor.orange
        testLabel.text = "等你我等了那么久花开花落不见你回头多少个日夜想你泪儿流望穿秋水盼你几多愁想你我想了那么久春去秋来燕来又飞走日日夜夜守着你那份温柔不知何时能和你相守就这样默默想着你就这样把你记心头天上的云懒散的在游走你可知道我的忧愁就这样默默爱着你海枯石烂我不放手不管未来的路有多久宁愿这样为你守候宁愿这样为你守候"
        view.addSubview(testLabel)
        
        testLabel.tap { (index, charAttributedString) in
            print("index: \(index)")
            print("charAttributedString: \(charAttributedString)")
        }
    }
}

