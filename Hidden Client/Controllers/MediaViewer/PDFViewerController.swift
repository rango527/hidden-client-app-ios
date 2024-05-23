//
//  PDFViewerController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/30.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import WebKit

class PDFViewerController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    var documentUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: documentUrl ?? "") {
            let request = URLRequest(url: url)
            webView.navigationDelegate = self
            webView.load(request)
        }
        
        webView.showLoading()
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        webView.hideLoading()
        dismiss(animated: true)
    }
}

/*extension PDFViewerController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        webView.hideLoading()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webView.hideLoading()
    }
}*/

extension PDFViewerController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        webView.hideLoading()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.hideLoading()
    }
}
