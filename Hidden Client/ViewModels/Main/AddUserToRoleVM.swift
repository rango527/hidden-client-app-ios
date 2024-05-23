//
//  AddUserToRoleVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/14/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class AddUserToRoleVM: RootVM {

    var jobId: String!
    var availableUsers = BehaviorRelay(value: [HClient]())
    var selectedIndices = BehaviorRelay(value: [Int]())
    var validInput = BehaviorRelay(value: false)

    override init() {
        super.init()
    }

    override func bind() {
        selectedIndices.asObservable().map{!$0.isEmpty}.bind(to: validInput).disposed(by: disposeBag)
    }

    func getAvailableUserToAddJobRoles(_ id: String, role: String) {
        jobId = id
        APIManager.getList(.getAvailableUsersToAddAJobRole(id, role)).subscribe(onNext: { [weak self] (users: [HClient]) in
            self?.availableUsers.accept(users)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }

    func addUsersToJobRole(_ id: String, role: String, clients: [Int], cascade: Bool, _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.addUsersToJobRole(id, role, clients, cascade)).subscribe(onNext: { (item: Model) in
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
