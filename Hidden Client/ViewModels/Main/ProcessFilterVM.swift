//
//  ProcessFilterVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 5/7/19.
//  Copyright © 2019 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD
import ObjectMapper

struct JobFilter: Equatable {
    var id: String?
    var job: String?
    var location: String?

    func isEmpty() -> Bool {
        return job == nil && location == nil
    }

    static func == (lhs: JobFilter, rhs: JobFilter) -> Bool {
        return  lhs.id == rhs.id
    }
}

struct StageFilter: Equatable {
    var stage: String?

    func isEmpty() -> Bool {
        return stage == nil
    }

    static func == (lhs: StageFilter, rhs: StageFilter) -> Bool {
        return  lhs.stage == rhs.stage
    }
}

struct ReadStatusFilter: Equatable {
    var status: String?

    func isEmpty() -> Bool {
        return status == nil
    }

    static func == (lhs: ReadStatusFilter, rhs: ReadStatusFilter) -> Bool {
        return  lhs.status == rhs.status
    }
}

struct SortByFilter: Equatable {
    var mode: String?

    func isEmpty() -> Bool {
        return mode == nil
    }

    static func == (lhs: SortByFilter, rhs: SortByFilter) -> Bool {
        return  lhs.mode == rhs.mode
    }
}

class ProcessFilterVM: RootVM {


    override init() {
        super.init()
    }

    override func bind() {
    }

}
