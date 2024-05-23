//
//  ViewFeedbackViewController.swift
//  Hidden Client
//
//  Created by Akio Takei on 2018/09/24.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

class ViewFeedbackViewController: RootController {

    @IBOutlet weak var stackView: UIStackView!
    
    var viewModel: ViewFeedbackViewModel!
    
    override func setupRx() {
        viewModel.getFeedback()
        
        viewModel.feedbacks.bind { [weak self] (feedbacks) in
            self?.stackView.removeAllArrangedSubviews()
            
            let candidateName = self?.viewModel.process.candidateName?.firstName ?? ""
            
            feedbacks.forEach({ (item) in
                let itemView = ViewFeedbackView.fromNib() as! ViewFeedbackView
                itemView.setupView(with: item, candidateName: candidateName)
                self?.stackView.addArrangedSubview(itemView)

                if item !== feedbacks.last!, let separatorView = self?.getSeparatorView() {
                    self?.stackView.addArrangedSubview(separatorView)
                }
            })

        }.disposed(by: disposeBag)
    }
    
    private func getSeparatorView() -> UIView {
        let separatorView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 1)))
        let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width * 0.8, height: 1)))
        label.center = separatorView.center
        label.backgroundColor = UIColor.colorFrom(rgb: 0xb3b2b2, alpha: 0.25)
        separatorView.backgroundColor = UIColor.clear
        separatorView.addSubview(label)
        return separatorView
    }
}
