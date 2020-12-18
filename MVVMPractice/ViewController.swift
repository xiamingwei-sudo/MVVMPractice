//
//  ViewController.swift
//  MVVMPractice
//
//  Created by 夏明伟 on 2020/12/18.
//

import UIKit
import CUGatewaySDK
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        MWRHGatewayIPManager.findGateway()
    }


}

