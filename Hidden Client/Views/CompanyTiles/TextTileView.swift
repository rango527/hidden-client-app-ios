//
//  TextTileView.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol TileViewDelegate: class {
    func openMediaViewer(item: CompanyTile?)
}

class CompanyTileView: UIView {
    
    var item: CompanyTile!
    weak var delegate: TileViewDelegate?
    
    func setupTile(with item: CompanyTile) {
        self.item = item
    }
    
    @IBAction func onOpenMediaViewer(_ sender: Any) {
        delegate?.openMediaViewer(item: item)
    }
}

class TextTileView: CompanyTileView {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func setupTile(with item: CompanyTile) {
        super.setupTile(with: item)
        lblTitle.text = item.title
        lblDescription.text = item.content
    }

}
