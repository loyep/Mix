//
//  PlusViewController.swift
//  Mix
//
//  Created by Maxwell on 31/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit

class PlusViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.dismiss(animated: true, completion: nil)
    }

}
