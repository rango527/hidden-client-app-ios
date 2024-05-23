//
//  TermsPrivacyVM.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/09/18.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import RxSwift
import RxCocoa
import PKHUD

class TermsPrivacyVM: RootVM {
    
    var item = BehaviorRelay(value: Privacy())
    
    func getHTMLContent() -> String {
        let content = """
        <html><head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style type='text/css'>
        body{ font-size: 18px; font-family: "Avenir-Medium"; padding: 20px; color: #000040; }
            .block { margin-left: 15px; padding: 5px 0;}
            .block .topic { cursor: pointer; padding: 5px 0; margin-left: 15px;}
            strong { font-weight: 300; }
            .block .topic strong { font-weight: 600; }
            .block p { margin-left: 30px;}
                .block .arrow:after { font-size: 12px; transform: scale(0.58333333) rotate(90deg); display: inline-block;
                    content: '\\27A4'; font-weight: bold; transition: transform .3s; margin-left: -12px; }
        .block.closed .arrow:after { transform: scale(0.58333333) rotate(0deg); }
        .block .content { border-left: 1px dotted; }
            .block.closed .content { display: none; }
        </style></head><body>
        <div id='content'>
        </div>
        <script language='javascript'>
        function toggleBlock(element) {
            element.parentElement.classList.toggle('closed');
        }
        let content = `\(item.value.content ?? "")`;
        const prefix = '[T';
        const suffix = '<\\/strong>';
        const prefixLen = prefix.length;
        const suffixLen = suffix.length;
        let depth = -1;
        let indexes = [];
        let length = content.length;
        for (var i = 0; i < length; i++) {
            if (content.substring(i, i+prefixLen) == prefix) {
                const startBlock = content.indexOf(']', i);
                const level = parseInt(content.substring(i+prefixLen, startBlock));
                if(level>0) {
                    if (depth > 0 && level <= depth) {
                        for (var j = 0; j <= depth - level; j++) {
                            indexes.push(i);
                        }
                    }
                    depth = level;
                }
                content = content.substring(0, i) + '<div class=\\'block closed\\'><div class=\\'topic\\' onclick=\\'toggleBlock(this);\\'><span class=\\'arrow\\'></span>' + content.substring(startBlock + 1);
                const endBlock = content.indexOf(suffix, i);
                content = content.substring(0, endBlock) + '</div><div class=\\'content\\'>' + content.substring(endBlock + suffixLen);
                i = endBlock + 3;
                length = content.length;
            }
        }
        for(var i = 0; i < depth; i++) {
            content += '</div></div>';
        };
        
        String.prototype.insertAt=function(index, string) {
            return this.substr(0, index) + string + this.substr(index);
        };
        
        const indexLength = indexes.length;
        for (var i = indexLength - 1; i >= 0; i--) {
            content = content.insertAt(indexes[i], '</div></div>');
        }
        document.getElementById('content').innerHTML = content;
        </script>
        </body>
        </html>
        """
        return content
    }
    
    func getContent(_ type: String){
        
        let request = APIManager.getContent(type)
        let cachedObject: Privacy? = CacheManager.shared.readObject(request)

        if cachedObject == nil {
            DispatchQueue.main.async { HUD.show(.progress) }
        }
        APIManager.getObject(request).subscribe(onNext: { [weak self] (item: Privacy) in
            DispatchQueue.main.async { HUD.hide() }
            self?.item.accept(item)
        }, onError: { (error) in
            DispatchQueue.main.async {
                HUD.hide()
                PKHUD.flashOnTop(with: (error as? APIManagerError)?.message() ?? "Error", UIColor.hcRed)
            }
        }).disposed(by: disposeBag)
    }
}
