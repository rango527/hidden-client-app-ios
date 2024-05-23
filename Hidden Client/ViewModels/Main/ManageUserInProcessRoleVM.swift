//
//  ManageUserInProcessRoleVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2/16/20.
//  Copyright © 2020 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class ManageUserInProcessRoleVM: RootVM {

    var processId: String!
    var availableUsers = BehaviorRelay(value: [HClient]())
    var selectedIndices = BehaviorRelay(value: [Int]())
    var validInput = BehaviorRelay(value: false)

    override init() {
        super.init()
    }

    convenience init(_ processId: String) {
        self.init()
        self.processId = processId
    }

    override func bind() {
        selectedIndices.asObservable().map{!$0.isEmpty}.bind(to: validInput).disposed(by: disposeBag)
    }

    func getAvailableInterviewersToProcess(_ id: String, interviewId: String) {
        processId = id
        APIManager.getList(.getAvailableInterviewersToProcess(id, interviewId)).subscribe(onNext: { [weak self] (users: [HClient]) in
            self?.availableUsers.accept(users)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }

    func addInterviewersToInterview(_ id: String, interviewId: String, clients: [Int], _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.addUsersToInterview(id, interviewId, clients)).subscribe(onNext: { (item: Model) in
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

    func deleteInterviewerInInterview(_ id: String, interviewId: String, clientId: Int, _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.removeUserInInterview(id, interviewId, clientId)).subscribe(onNext: { (item: Model) in
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

    func getAvailableUserToAddProcessRoles(_ id: String, role: String) {
        processId = id
        APIManager.getList(.getAvailableUsersToAddProcessRole(id, role)).subscribe(onNext: { [weak self] (users: [HClient]) in
            self?.availableUsers.accept(users)
        }, onError: { (error) in
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }

    func addUsersToProcessRole(_ id: String, role: String, clients: [Int], _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.addUsersToProcessRole(id, role, clients)).subscribe(onNext: { (item: Model) in
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

    func deleteUserInProcessRole(_ id: String, role: String, clientId: Int, _ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }

        APIManager.getObject(.removeUserInProcessRole(id, role, clientId)).subscribe(onNext: { (item: Model) in
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
