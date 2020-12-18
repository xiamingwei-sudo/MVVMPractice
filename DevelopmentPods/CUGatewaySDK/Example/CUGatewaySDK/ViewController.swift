//
//  ViewController.swift
//  CUGatewaySDK
//
//  Created by Come-Mile on 12/18/2020.
//  Copyright (c) 2020 Come-Mile. All rights reserved.
//

import UIKit
import CUGatewaySDK
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        MWRHGatewayIPManager.findGateway()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

