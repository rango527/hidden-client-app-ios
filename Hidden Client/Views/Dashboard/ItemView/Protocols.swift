//
//  Protocols.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

protocol DashboardItemViewActions {
    func setupView(with item: DashboardItem, delegate: DashboardItemViewDelegate?)
}

protocol DashboardItemViewDelegate: class {
    func onHandleAction(item: DashboardItem, info: DashboardTile?)
}
