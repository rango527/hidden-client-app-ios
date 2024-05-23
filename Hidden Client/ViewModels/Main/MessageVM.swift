//
//  MessageVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class MessageVM: RootVM {
    
    var conversation: Conversation?
    var items = BehaviorRelay(value: [Message]())
    var process: Process!
    
    convenience init(_ process: Process) {
        self.init()
        self.process = process
        getMessages()
    }
    
    func getMessages(_ forceRefresh: Bool? = nil, completion: ((Bool)->(Void))? = nil) {
        guard let id = process.conversationId else { return }
        
        let cache = !(forceRefresh ?? false)
        let request = APIManager.getMessages(id, cache)

        APIManager.getObject(request).subscribe(onNext: { [weak self] (item: Conversation) in
            self?.conversation = item
            let messages = item.messages?.filter({ (msg) -> Bool in
                return (msg.text != nil && msg.text != "") ||
                        (msg.assetUrl != nil && msg.assetUrl != "")
            }) ?? []

            completion?(true)
            self?.items.accept(messages)

            if cache == false {
                CacheManager.shared.storeObject(item, r: request)
            }
        }, onError: { (error) in
            completion?(false)
            DispatchQueue.main.async {
                delay(2.0) {
                    PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    func sendMessage(text: String, _ completion: (()->())? = nil) {
        guard let id = process.conversationId else { return }
        
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.getObject(.sendMessage(id, text)).subscribe(onNext: { [weak self] (item: Model) in
            DispatchQueue.main.async { HUD.hide() }

            if item.hasError() {
                DispatchQueue.main.async {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                }
            } else {
                self?.getMessages()
                completion?()
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
    
    func uploadDocument(url: URL, _ completion: (()->())? = nil ) {
        guard let id = process.conversationId else { return }
        DispatchQueue.main.async { HUD.show(.progress) }
        APIManager.uploadFile(url, .sendMessage(id, "")).subscribe(onNext: { [weak self] (item: Model) in
            DispatchQueue.main.async { HUD.hide() }

            if item.hasError() {
                DispatchQueue.main.async {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                }
            } else {
                self?.getMessages()
                completion?()
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
}
