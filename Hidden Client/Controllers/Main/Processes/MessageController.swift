//
//  MessageController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/15.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit
import RSKPlaceholderTextView
import MobileCoreServices
import RxDocumentPicker
import PKHUD
import ObjectMapper
import CCBottomRefreshControl

class MessageController: RootController {

    @IBOutlet weak var tblViewItems: UITableView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var textView: RSKPlaceholderTextView!
    
    var initialLoad = true
    var messageCnt = 0
    var mediaPicker: RxMediaPicker!
    
    var viewModel: MessageVM!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.getMessages()
        avatarImageView.setImage(with: viewModel?.process?.avatar, key: .candidate(viewModel?.process?.uid))
    }
    
    override func setupRx() {
        tblViewItems.register(UINib(nibName: "TextMessageCellView", bundle: nil), forCellReuseIdentifier: "TextMessageCellView")
        tblViewItems.register(UINib(nibName: "DocumentMessageCellView", bundle: nil), forCellReuseIdentifier: "DocumentMessageCellView")
        tblViewItems.register(UINib(nibName: "ImageMessageCellView", bundle: nil), forCellReuseIdentifier: "ImageMessageCellView")
        tblViewItems.dataSource = self


        let bottomRefreshCtrl = UIRefreshControl()
        tblViewItems.bottomRefreshControl = bottomRefreshCtrl
        tblViewItems.bottomRefreshControl!.rx.controlEvent(UIControl.Event.valueChanged).subscribe(onNext: { [weak self] in
            self?.viewModel.getMessages(true, completion:{ result in
                DispatchQueue.main.async { self?.tblViewItems.bottomRefreshControl?.endRefreshing() }
            })
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)

        viewModel.items.subscribe(onNext: { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateUI()
            }
        }).disposed(by: disposeBag)
    }
    
    func updateUI() {
        let cnt = viewModel.items.value.count
        if cnt > 0 {
            let scrollToBottom = cnt != messageCnt || initialLoad == true
            if cnt > messageCnt {
                tblViewItems.beginUpdates()
                tblViewItems.insertRows(at: (messageCnt..<cnt).map {IndexPath(row: $0, section: 0)}, with: .automatic)
                tblViewItems.endUpdates()
            } else if cnt < messageCnt {
                tblViewItems.beginUpdates()
                tblViewItems.deleteRows(at: (cnt..<messageCnt).map {IndexPath(row: $0, section: 0)}, with: .automatic)
                tblViewItems.endUpdates()
            }
            if scrollToBottom == true {
                tblViewItems.scrollToRow(at: IndexPath(row: cnt - 1, section: 0), at: .top, animated: true)
                initialLoad = false
            }
        }
    }
    
    override func sendRequest() {
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty == false {
            viewModel.sendMessage(text: text) { [weak self] in
                DispatchQueue.main.async {
                    self?.textView.text = ""
                }
            }
        }
    }
    
    func uploadDocument(_ url: URL) {
        viewModel.uploadDocument(url: url)
    }
    
    @IBAction func onSend(_ sender: UIButton) {
        sendRequest()
    }
    
    @IBAction func onSendDocument(_ sender: UIButton) {
        //let docTypes = [kUTTypePDF as String, "com.microsoft.word.doc", "com.microsoft.excel.xls"]
        let docTypes = [kUTTypePDF as String]
        if #available(iOS 11.0, *) {
            let picker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
            picker.allowsMultipleSelection = false
            picker.rx.didPickDocumentsAt.subscribe(onNext: { [weak self] (urls) in
                if let url = urls.last {
                    self?.uploadDocument(url)
                }
            }).disposed(by: disposeBag)
            present(picker, animated: true)
        } else {
            let menu = UIDocumentMenuViewController(documentTypes: docTypes, in: .import)
            menu.rx.didPickDocumentPicker.do(onNext: { [weak self] (picker) in
                self?.present(picker, animated: true)
            }).flatMap {$0.rx.didPickDocumentAt}.subscribe(onNext: { [weak self] (url) in
                self?.uploadDocument(url)
            }).disposed(by: disposeBag)
            present(menu, animated: true)
        }
    }
    
    @IBAction func onSendMedia(_ sender: UIButton) {
        if mediaPicker == nil {
            mediaPicker = RxMediaPicker(delegate: self)
        }
        
        let alert = UIAlertController(title: "Media Picker", message: "Please choose an option", preferredStyle: .actionSheet)
        if mediaPicker.deviceHasCamera == true {
            alert.addAction(UIAlertAction(title: "Take Video", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.mediaPicker.recordVideo(maximumDuration: 60, editable: true).subscribe(onNext: { url in
                    self?.viewModel.uploadDocument(url: url)
                }, onError: { error in
                    DispatchQueue.main.async {
                        delay(2.0) {
                            PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                        }
                    }
                }).disposed(by: strongSelf.disposeBag)
            }))
            
            alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.mediaPicker.takePhoto(editable: true).subscribe(onNext: { (image, url) in
                    self?.viewModel.uploadDocument(url: url)
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        delay(2.0) {
                            PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                        }
                    }
                }).disposed(by: strongSelf.disposeBag)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Choose Video", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.mediaPicker.selectVideo(maximumDuration: 10, editable: true).subscribe(onNext: { url in
                self?.viewModel.uploadDocument(url: url)
            }, onError: { error in
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                    }
                }
            }).disposed(by: strongSelf.disposeBag)
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.mediaPicker.selectImage(editable: true).subscribe(onNext: { (image, url) in
                self?.viewModel.uploadDocument(url: url)
            }, onError: { (error) in
                DispatchQueue.main.async {
                    delay(2.0) {
                        PKHUD.flashOnTop(with: error.localizedDescription, UIColor.hcRed)
                    }
                }
            }).disposed(by: strongSelf.disposeBag)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        present(alert, animated: true)
    }
    
    @IBAction func onOpenCandidateDetail(_ sender: Any) {
        let vc = CandidateDetailVC.fromNib()
        let nav = UINavigationController(rootViewController: vc)
        let candidate = Mapper<Candidate>().map(JSON: viewModel.process.toJSON())!
        
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        nav.hero.isEnabled = true
        nav.hero.navigationAnimationType = .cover(direction: .up)
        vc.viewModel = CandidateDetailVM(candidate, true)
        vc.isShortlist = false
        vc.view.layoutIfNeeded()
        
        self.present(nav, animated: true)
    }
    
    @IBAction func onOpenProcess(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
}

extension MessageController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messageCnt = viewModel.items.value.count
        return viewModel.items.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items.value[indexPath.row]
        let assetType = item.assetType ?? ""
        var cell: MessageCellView!
        
        switch assetType {
        case Constants.Message.AssetType.text:
            cell = tableView.dequeueReusableCell(withIdentifier: "TextMessageCellView") as? TextMessageCellView
        case Constants.Message.AssetType.image, Constants.Message.AssetType.video:
            cell = tableView.dequeueReusableCell(withIdentifier: "ImageMessageCellView") as? ImageMessageCellView
            cell.delegate = self
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "DocumentMessageCellView") as? DocumentMessageCellView
            cell.delegate = self
        }
        
        if indexPath.row > 0 {
            cell.setupCell(with: item, viewModel.items.value[indexPath.row - 1])
        } else {
            cell.setupCell(with: item)
        }
        
        return cell
    }
}

extension MessageController: MessageCellViewDelegate {
    func onMessageAction(_ item: Message, _ action: String?) {
        
        if item.assetType == Constants.Message.AssetType.pdf || item.assetType == Constants.Message.AssetType.document {
            let vc = PDFViewerController.fromNib()
            vc.modalPresentationStyle = .fullScreen
            vc.documentUrl = item.assetUrl
            present(vc, animated: true)
            return
        }
        
        var index = 0
        var selectedIndex = -1
        var assets = [Message]()
        
        viewModel.items.value.forEach { (msg) in
            if msg.assetType == Constants.Message.AssetType.image ||
                msg.assetType == Constants.Message.AssetType.video {
                assets.append(msg)
                if msg.id == item.id {
                    selectedIndex = index
                }
                index += 1
            }
        }
        
        if selectedIndex < 0 { return }
        
        let items = assets.map { (msg) -> MediaViewerImage in
            if msg.assetType == Constants.Message.AssetType.image {
                return MediaViewerImage(key: .message(msg.id), imageURL: msg.assetUrl, text: msg.dateString)
            } else {
                return MediaViewerImage(key: .message(msg.id), imageURL: msg.assetUrl?.thumbnail, text: msg.dateString, videoURL: msg.assetUrl)
            }
        }
        
        let mediaViewer = MediaViewerController(images: items, startIndex: selectedIndex)
        mediaViewer.dynamicBackground = true
        mediaViewer.hero.isEnabled = true
        
        DispatchQueue.main.async { [weak self] in
            self?.present(mediaViewer, animated: true)
        }
    }
}

extension MessageController: RxMediaPickerDelegate {
    func present(picker: UIImagePickerController) {
        self.present(picker, animated: true)
    }
    
    func dismiss(picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
