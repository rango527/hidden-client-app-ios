//
//  EditProfileVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//


import RxSwift
import RxCocoa
import PKHUD
import Kingfisher

class EditProfileVM: RootVM {
    
    //var name = BehaviorRelay(value: "")
    var firstName = BehaviorRelay(value: "")
    var lastName = BehaviorRelay(value: "")
    var email = BehaviorRelay(value: "")
    var title = BehaviorRelay(value: "")
    
    var photoUrl: BehaviorRelay<URL?> = BehaviorRelay(value: nil)
    var image: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    var validInput = BehaviorRelay(value: false)
    
    override init() {
        super.init()
    }
    
    override func bind() {
        Observable.combineLatest(
            firstName.asObservable(),
            lastName.asObservable(),
            email.asObservable(),
            title.asObservable()).map { (firstName, lastName, email, title) -> Bool in
                if firstName.length == 0 || lastName.length == 0 || email.length == 0 || title.length == 0 {
                    return false
                }
                let emailTest = NSPredicate(format:"SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
                return emailTest.evaluate(with: email)
        }.bind(to: validInput).disposed(by: disposeBag)
    }
    
    func updateProfile(_ completion: (()->())? = nil) {
        DispatchQueue.main.async { HUD.show(.progress) }
        
        let user = User()
        user.email = email.value
        user.firstName = firstName.value
        user.lastName = lastName.value
        user.jobTitle = title.value
        
        var observable: Observable<Model>!
        if let url =  photoUrl.value {
            observable = APIManager.uploadFile(url, .updateProfile(user), "photo")
        } else {
            observable = APIManager.getObject(.updateProfile(user))
        }
        
        observable.subscribe(onNext: { [weak self] (response: Model) in
            DispatchQueue.main.async {
                HUD.hide()

                if response.hasError() {
                    PKHUD.flashOnTop(with: response.getErrorMessage(), UIColor.hcRed)
                } else {
                    self?.updateCache()
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
    
    func updateCache() {
        AppManager.shared.user?.firstName = firstName.value
        AppManager.shared.user?.lastName = lastName.value
        AppManager.shared.user?.email = email.value
        AppManager.shared.user?.jobTitle = title.value
        if let img =  image.value {
            ImageCache.default.store(img, forKey: ImageKey.client(AppManager.shared.user?.uid).name)
        }
    }
    
}
