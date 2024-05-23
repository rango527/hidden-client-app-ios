//
//  ShortListsVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/07/24.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD
import ObjectMapper

struct ShortListFilter: Equatable {
    var id: String?
    var job: String?
    var location: String?
    
    func isEmpty() -> Bool {
        return job == nil && location == nil
    }
    
    static func == (lhs: ShortListFilter, rhs: ShortListFilter) -> Bool {
        return  lhs.id == rhs.id
    }
}

class ShortListsVM: RootVM {
    var clientId = BehaviorRelay(value: "")
    var avatarUrl = BehaviorRelay(value: "")
    var firstName = BehaviorRelay(value: "")
    var title = BehaviorRelay(value: "")
    var items = BehaviorRelay(value: [Candidate]())
    var candidates = BehaviorRelay(value: [Candidate]())
    var filter: BehaviorRelay<ShortListFilter> = BehaviorRelay(value: ShortListFilter())
    var filters = BehaviorRelay(value: [ShortListFilter()])
    var focusedItem = BehaviorRelay(value: Candidate())

    var backgrounds = ["blue.png", "aqua.png", "cobalt.png", "coral.png", "green.png", "indigo.png", "mint.png", "orange.png", "pink.png", "purple.png", "red.png", "silver.png"]
    
    var consents = BehaviorRelay(value: [Consent]())
    
    override init() {
        super.init()
        getClient()
        getConsentUpdate()
    }
    
    override func bind() {
        Observable.combineLatest(candidates.asObservable(), filter.asObservable()).subscribe(onNext: { [weak self] (candidates, filter) in
            if let jobId = filter.id {
                let filteredItems = candidates.filter({ (candidate) -> Bool in
                    return candidate.jobId == jobId
                })
                
                self?.items.accept(filteredItems)
            } else {
                self?.items.accept(candidates)
            }
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(items.asObservable(), firstName.asObservable(), filter.asObservable()).subscribe(onNext: {
            [weak self] (items, fullName, filter) in
            let firstName = fullName.firstName
            let jobTitle = filter.job ?? "various"
            switch items.count {
            case 0:
                self?.title.accept("<title>Hello \(firstName)</title>\n<desc>Sorry, there are no new profiles in your <bold>\(jobTitle)</bold> shortlists</desc>")
            case 1:
                self?.title.accept("<title>Hello \(firstName)</title>\n<desc>Please review a new profile in your <bold>\(jobTitle)</bold> shortlists</desc>")
            default:
                self?.title.accept("<title>Hello \(firstName)</title>\n<desc>Please review the \(items.count) new profiles in your <bold>\(jobTitle)</bold> shortlists</desc>")
            }
            
            self?.backgrounds = items.map({ (candidate) -> String in
                if Constants.ShortListCard.background.contains(candidate.avatarColor ?? "") {
                    return "\(candidate.avatarColor ?? "").png"
                } else {
                    return "blue.png"
                }
            })
        }).disposed(by: disposeBag)
    }
    
    func getClient(_ forceRefresh: Bool? = nil, completion: (()->())? = nil) {
        let cache = !(forceRefresh ?? false)
        let request = APIManager.getShortList(cache)
        let client: HClient? = CacheManager.shared.readObject(request)

        if client == nil {
            DispatchQueue.main.async {HUD.show(.progress)}
        }

        APIManager.getObject(request).subscribe(onNext: { [weak self] (item: HClient) in
            DispatchQueue.main.async {
                HUD.hide()

                if item.hasError() {
                    PKHUD.flashOnTop(with: item.getErrorMessage(), UIColor.hcRed)
                } else {
                    if cache == false {
                        CacheManager.shared.storeObject(item, r: request)
                    }
                    self?.updateClient(item)
                }
                completion?()
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
            completion?()
        }).disposed(by: disposeBag)
    }
    
    func updateClient(_ item: HClient) {
        if AppManager.shared.user == nil || AppManager.shared.user?.firstName == nil {
            AppManager.shared.updateUser(item.toUser())
        }
        
        var filters = [ShortListFilter()]
        for candidate in item.candidates ?? [] {
            if let id = candidate.jobId, let job = candidate.jobTitle, let loc = candidate.jobCity {
                let filter = ShortListFilter(id: id, job: job, location: loc)
                if filters.contains(filter) == false {
                    filters.append(filter)
                }
            }
        }
        
        if self.filter.value.isEmpty() == false && filters.contains(self.filter.value) == false {
            self.filter.accept(ShortListFilter())
        }
        
        self.filters.accept(filters)
        self.clientId.accept(item.uid ?? "")
        self.firstName.accept(item.firstName ?? "")
        self.avatarUrl.accept(item.avatar ?? "")
        self.candidates.accept(item.candidates ?? [])
    }
    
    func getConsentUpdate() {
        APIManager
            .getList(.getConsentUpdate)
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<[Consent]> in
                return Observable.just([])
            })
            .bind(to: consents)
            .disposed(by: disposeBag)
    }
}
