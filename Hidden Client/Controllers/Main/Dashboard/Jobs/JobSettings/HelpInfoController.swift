//
//  HelpInfoController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/13/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class HelpInfoController: RootController {

    @IBOutlet weak var lblHelpDesc: UILabel!

    var helpInfo: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        lblHelpDesc.text = helpInfo
    }

}
