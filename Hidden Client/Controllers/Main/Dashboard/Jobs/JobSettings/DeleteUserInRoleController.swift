//
//  DeleteUserInRoleController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/14/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import PKHUD

class DeleteUserInRoleController: RootController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var segmentUserScope: UISegmentedControl!

    weak var actionDelegate: JobSettingsActionDelegate?

    var viewModel = DeleteUserInRoleVM()
    var jobId: String?
    var client: HClient?
    var roleType: String!
    var roleTitle: String!
    var bCascade: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func setupUI() {
        segmentUserScope.font(name: Constants.Fonts.Avenir.book, size: 12)
        lblTitle.text = String(format: "Removing %@ from the %@", client?.firstName ?? "", roleTitle)

        let segmentColor = UIColor.init(hex: "F2EFEF")
        segmentUserScope.backgroundColor = segmentColor
        segmentUserScope.layer.borderColor = segmentColor.cgColor
        if #available(iOS 13.0, *) {
            segmentUserScope.selectedSegmentTintColor = UIColor.white
        }
        segmentUserScope.layer.borderWidth = 3
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.hcDarkBlue]
        segmentUserScope.setTitleTextAttributes(titleTextAttributes, for:.normal)
        let titleTextAttributes1 = [NSAttributedString.Key.foregroundColor: UIColor.hcDarkBlue]
        segmentUserScope.setTitleTextAttributes(titleTextAttributes1, for:.selected)
    }

    @IBAction func onDelete(_ sender: UIButton) {
        guard let jobId = self.jobId else { return }
        guard let clientId = client?.uid else { return }

        if let type = Constants.JobSettings.RoleTypes(rawValue: roleType!) {
            viewModel.deleteUserInJobRole(jobId, role: type.typeValue, clientId: Int(clientId) ?? 0, cascade: bCascade) { [weak self] in

                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                    self?.actionDelegate?.onActionCompleted(message: "User removed")
                }
            }
        }
    }

    @IBAction func onTip(_ sender: UIButton) {
        let vc = HelpInfoController.fromNib()
        vc.helpInfo = Constants.JobSettings.removeUserInRoleHelp
        self.openController(vc)
    }

    @IBAction func onSelectNewUserScope(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            bCascade = false
        } else {
            bCascade = true
        }
    }
}
