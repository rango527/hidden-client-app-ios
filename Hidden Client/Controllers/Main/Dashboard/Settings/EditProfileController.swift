//
//  EditProfileController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import PKHUD

class EditProfileController: RootController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtTitle: UITextField!
    
    @IBOutlet weak var btnSave: UIButton!
    
    let viewModel = EditProfileVM()
    var mediaPicker: RxMediaPicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupRx() {
        setupUI()
        txtFirstName.rx.text.orEmpty.bind(to: viewModel.firstName).disposed(by: disposeBag)
        txtLastName.rx.text.orEmpty.bind(to: viewModel.lastName).disposed(by: disposeBag)
        txtEmail.rx.text.orEmpty.bind(to: viewModel.email).disposed(by: disposeBag)
        txtTitle.rx.text.orEmpty.bind(to: viewModel.title).disposed(by: disposeBag)
        viewModel.validInput.bind(to: btnSave.rx.isEnabled).disposed(by: disposeBag)
        
        viewModel.image.skip(1).bind(to: avatarImageView.rx.image).disposed(by: disposeBag)
    }
    
    func setupUI() {
        let user = AppManager.shared.user
        avatarImageView.setImage(with: user?.avatar, key: .client(user?.uid))
        txtFirstName.text = user?.firstName
        txtLastName.text = user?.lastName
        txtEmail.text = user?.email
        txtTitle.text = user?.jobTitle
    }
    
    override func sendRequest() {
        guard viewModel.validInput.value == true else {
            shakeView(txtFirstName.superview)
            return
        }
        
        view.endEditing(true)
        viewModel.updateProfile { [weak self] in
            self?.hero.dismissViewController(completion: {
                PKHUD.flashOnTop(with: "Details Saved!")
            })
        }
    }
    
    @IBAction func onChangePhoto(_ sender: UIButton) {
        if mediaPicker == nil {
            mediaPicker = RxMediaPicker(delegate: self)
        }
        
        let alert = UIAlertController(title: "Select New Photo", message: "", preferredStyle: .actionSheet)
        if mediaPicker.deviceHasCamera == true {
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.mediaPicker.takePhoto(editable: true).subscribe(onNext: { (image, url) in
                    self?.viewModel.photoUrl.accept(url)
                    self?.viewModel.image.accept(image)
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        delay(2.0) {
                            PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                        }
                    }
                }).disposed(by: strongSelf.disposeBag)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Select Existing Photo", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.mediaPicker.selectImage(editable: true).subscribe(onNext: { (image, url) in
                self?.viewModel.photoUrl.accept(url)
                self?.viewModel.image.accept(image)
            }, onError: { (error) in
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                    }
                }
            }).disposed(by: strongSelf.disposeBag)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    
    @IBAction func onSave(_ sender: Any) {
        sendRequest()
    }
}

extension EditProfileController: RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        self.present(picker, animated: true)
    }
    
    func dismiss(picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}

