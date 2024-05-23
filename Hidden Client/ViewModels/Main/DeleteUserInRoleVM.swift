//
//  DeleteUserInRoleVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/14/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class DeleteUserInRoleVM: RootVM {

    var jobId: String!

    override init() {
        super.init()
    }

    func deleteUserInJobRole(_ id: String, role: String, clientId: Int, cascade: Bool, _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.removeUserInJobRole(id, role, clientId, cascade)).subscribe(onNext: { (item: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    completion?()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }

}
