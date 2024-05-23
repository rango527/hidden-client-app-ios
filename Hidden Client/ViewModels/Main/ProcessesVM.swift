//
//  ProcessesVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/02.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

struct ProcessFilter: Equatable {

    var title: String?

    var id: String?
    var job: String?
    var location: String?

    var stage: String?
    var stageId: String?

    var readStatus: String?
    var sortBy: String?

    mutating func initWith(idValue: String, jobValue: String, locValue: String) {
        id = idValue
        job = jobValue
        location = locValue
    }

    func isJobEmpty() -> Bool {
        return job == nil && location == nil
    }

    func isStageEmpty() -> Bool {
        return stage == nil && stageId == nil
    }

    func isReadStatusEmpty() -> Bool {
        return readStatus == nil
    }

    func isSortByEmpty() -> Bool {
        return sortBy == nil
    }

    static func == (lhs: ProcessFilter, rhs: ProcessFilter) -> Bool {
        return  lhs.id == rhs.id
    }
}

class ProcessesVM: RootVM {
    
    var items = BehaviorRelay(value: [Process]())
    var filteredItems = BehaviorRelay(value: [Process]())

    var filterMenus = BehaviorRelay(value: [String()])
    var jobFilterContents = BehaviorRelay(value: [ShortListFilter()])
    var extraFilterContents = BehaviorRelay(value: [String()])

    var jobFilters = BehaviorRelay(value: [ProcessFilter()])
    var stageFilters = BehaviorRelay(value: [ProcessFilter()])
    var statusFilter: BehaviorRelay<ProcessFilter> = BehaviorRelay(value: ProcessFilter())
    var sortFilter: BehaviorRelay<ProcessFilter> = BehaviorRelay(value: ProcessFilter())

    override init() {
        super.init()
        getProcesses()
    }

    func isProcessFiltersEmpty() -> Bool {
        let result: Bool!
        var jobFilterResult = jobFilters.value.isEmpty
        var stageFilterResult = stageFilters.value.isEmpty

        jobFilterResult = jobFilters.value.allSatisfy({$0.isJobEmpty()})
        stageFilterResult = stageFilters.value.allSatisfy({$0.isStageEmpty()})

        result = jobFilterResult && stageFilterResult
            && statusFilter.value.isReadStatusEmpty()
            && sortFilter.value.isSortByEmpty()

        return result
    }

    func getProcesses(_ forceRefresh: Bool? = nil, completion: ((Bool)->(Void))? = nil) {
        let cache = !(forceRefresh ?? false)
        let request = APIManager.getProcesses(cache)

        APIManager.getList(request).subscribe(onNext: { [weak self] (items: [Process]) in
            self?.items.accept(items)
            if forceRefresh == true {
                completion?(true)
            }

            if cache == false {
                CacheManager.shared.storeList(items, r: request)
            }
        }, onError: { (error) in
            completion?(false)
            delay(2.0) {
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }

    func setJobFilters() {
        var filters = [ShortListFilter()]
        items.asObservable().subscribe(onNext: { [weak self] (items: [Process]) in
            for candidate in items {
                if let id = candidate.jobId, let job = candidate.jobTitle, let loc = candidate.jobCity {
                    let filter = ShortListFilter(id: id, job: job, location: loc)
                    if filters.contains(filter) == false {
                        filters.append(filter)
                    }
                }
            }
            self?.jobFilterContents.accept(filters)
        }).disposed(by: disposeBag)
    }

    func applyFilter() {
        var processes = items.value

        // Filter by Jobs
        let jobFilters = self.jobFilters.value.filter({$0.id != nil})
        if  jobFilters.isEmpty == false, processes.filter({jobFilters.map{$0.id}.contains($0.jobId)}).isEmpty == false {
            processes = processes.filter({jobFilters.map{$0.id}.contains($0.jobId)})
        }

        // Filter by ProcessStages
        let stageFilters = self.stageFilters.value.filter({$0.stage != nil})
        if stageFilters.isEmpty == false {
             processes = processes.filter({$0.filterProcesses(by: stageFilters) == true})
        }

        // Filter by ReadStatus
        if statusFilter.value.isReadStatusEmpty() == false {
            if statusFilter.value.readStatus == Constants.ReadStatus.hasUnreadStatus {
                    processes = processes.filter({Int($0.unread ?? "0")! > 0})
            } else if statusFilter.value.readStatus == Constants.ReadStatus.noUnreadStatus {
                    processes = processes.filter({Int($0.unread ?? "0")! == 0})
            }
        }

        // Sort by ...
        if sortFilter.value.isSortByEmpty() == false {
            switch sortFilter.value.sortBy {
            case Constants.SortBy.mostRecent:
                processes.sort(by: {$0.compareMsgReceivedWith(anotherProcess: $1) == .orderedDescending})
                break
            case Constants.SortBy.processStage:
                processes.sort(by: {$0.compareProcessStageWith(anotherProcess: $1) == .orderedDescending})
                break
            case Constants.SortBy.shortlistingDate  :
                processes.sort(by: {$0.compareShortlistedDateWith(anotherProcess: $1) == .orderedDescending})
                break
            default:
                break
            }
        }

        items.accept(processes)
    }

    func clearFilter() {
        jobFilters.accept([])
        stageFilters.accept([])
        statusFilter.accept(ProcessFilter())
        sortFilter.accept(ProcessFilter())
        
        
//        jobFilters = BehaviorRelay(value: [ProcessFilter()])
//        stageFilters = BehaviorRelay(value: [ProcessFilter()])
//        statusFilter = BehaviorRelay(value: ProcessFilter())
//        sortFilter = BehaviorRelay(value: ProcessFilter())
    }


}
