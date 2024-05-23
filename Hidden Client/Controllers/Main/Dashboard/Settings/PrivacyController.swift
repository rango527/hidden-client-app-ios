//
//  PrivacyController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/08.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import WebKit

class PrivacyController: RootController {

    @IBOutlet weak var webView: WKWebView!
    let viewModel = TermsPrivacyVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getContent("privacy")
    }
    
    override func setupRx() {
        viewModel.item.subscribe(onNext: { [weak self] (item) in
            DispatchQueue.main.async {
                self?.setupUI()
            }
        }).disposed(by: disposeBag)
    }
    
    func setupUI() {
        let content = viewModel.getHTMLContent()
        webView.loadHTMLString(content, baseURL: nil)
        webView.navigationDelegate = self
    }
}

extension PrivacyController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        //link to intercept www.example.com
        // navigation types: linkActivated, formSubmitted,
        //                   backForward, reload, formResubmitted, other
        if navigationAction.navigationType == .linkActivated {
            if navigationAction.request.url?.absoluteString == TERMS_URL {
                self.openController(TermsController.fromNib())
                
                //this tells the webview to cancel the request
                decisionHandler(.cancel)
                return
            }            
        }
        
        //this tells the webview to allow the request
        decisionHandler(.allow)
    }
}
