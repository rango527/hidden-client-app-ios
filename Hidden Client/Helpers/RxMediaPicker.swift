import Foundation
import MobileCoreServices
import RxSwift
import UIKit
import AVFoundation

enum RxMediaPickerAction {
    case photo(observer: AnyObserver<(UIImage, URL)>)
    case video(observer: AnyObserver<URL>, maxDuration: TimeInterval)
}

enum RxMediaPickerError: Error {
    case generalError
    case canceled
    case videoMaximumDurationExceeded
}

@objc protocol RxMediaPickerDelegate {
    func present(picker: UIImagePickerController)
    func dismiss(picker: UIImagePickerController)
}

@objc class RxMediaPicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: RxMediaPickerDelegate?
    
    var currentAction: RxMediaPickerAction?
    
    var deviceHasCamera: Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    init(delegate: RxMediaPickerDelegate) {
        self.delegate = delegate
    }
    
    func recordVideo(device: UIImagePickerController.CameraDevice = .rear,
                     quality: UIImagePickerController.QualityType = .typeMedium,
                          maximumDuration: TimeInterval = 600, editable: Bool = false) -> Observable<URL> {
        return Observable.create { observer in
            self.currentAction = RxMediaPickerAction.video(observer: observer, maxDuration: maximumDuration)
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.videoMaximumDuration = maximumDuration
            picker.videoQuality = quality
            picker.allowsEditing = editable
            picker.delegate = self
            
            if UIImagePickerController.isCameraDeviceAvailable(device) {
                picker.cameraDevice = device
            }
            
            self.presentPicker(picker)
            
            return Disposables.create()
        }
    }
    
    func selectVideo(source: UIImagePickerController.SourceType = .photoLibrary,
                          maximumDuration: TimeInterval = 600,
                          editable: Bool = false) -> Observable<URL> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.video(observer: observer, maxDuration: maximumDuration)
            
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.allowsEditing = editable
            picker.delegate = self
            picker.videoMaximumDuration = maximumDuration
            
            self.presentPicker(picker)
            
            return Disposables.create()
        }
    }
    
    func takePhoto(device: UIImagePickerController.CameraDevice = .rear,
                   flashMode: UIImagePickerController.CameraFlashMode = .auto,
                        editable: Bool = false) -> Observable<(UIImage, URL)> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.photo(observer: observer)
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.allowsEditing = editable
            picker.delegate = self
            
            if UIImagePickerController.isCameraDeviceAvailable(device) {
                picker.cameraDevice = device
            }
            
            if UIImagePickerController.isFlashAvailable(for: picker.cameraDevice) {
                picker.cameraFlashMode = flashMode
            }
            
            self.presentPicker(picker)
            
            return Disposables.create()
        }
    }
    
    func selectImage(source: UIImagePickerController.SourceType = .photoLibrary,
                          editable: Bool = false) -> Observable<(UIImage, URL)> {
        return Observable.create { [unowned self] observer in
            self.currentAction = RxMediaPickerAction.photo(observer: observer)
            
            let picker = UIImagePickerController()
            picker.sourceType = source
            picker.allowsEditing = editable
            picker.delegate = self
            
            self.presentPicker(picker)
            
            return Disposables.create()
        }
    }
    
    func processPhoto(info: [UIImagePickerController.InfoKey : AnyObject],
                      observer: AnyObserver<(UIImage, URL)>) {
        guard let image = info[.originalImage] as? UIImage else {
            observer.on(.error(RxMediaPickerError.generalError))
            return
        }

        if let editedImage = info[.editedImage] as? UIImage{
            if let url = getURLOfImage(editedImage) {
                observer.on(.next((editedImage, url)))
                observer.on(.completed)
                return
            }
        } else {
            if #available(iOS 11, *), let url = info[.imageURL] as? URL {
                observer.on(.next((image, url)))
                observer.on(.completed)
                return
            } else {
                if let url = getURLOfImage(image) {
                    observer.on(.next((image, url)))
                    observer.on(.completed)
                    return
                }
            }
            return
        }
        
        observer.on(.error(RxMediaPickerError.generalError))
    }
    
    func getURLOfImage(_ image: UIImage) -> URL? {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let editedPhotoURL = URL(fileURLWithPath: cachesDirectory).appendingPathComponent("\(UUID().uuidString).jpg", isDirectory: false)
        if let data = image.jpegData(compressionQuality: 0.5) {
            do {
                try data.write(to: editedPhotoURL, options: [.atomic])
            } catch {
                return nil
            }
            
            return editedPhotoURL
        }
        
        return nil
    }
    
    func processVideo(info: [UIImagePickerController.InfoKey : Any],
                      observer: AnyObserver<URL>,
                      maxDuration: TimeInterval,
                      picker: UIImagePickerController) {
        guard let videoURL = info[.mediaURL] as? URL else {
            observer.on(.error(RxMediaPickerError.generalError))
            dismissPicker(picker)
            return
        }

        let editingStartedKey = UIImagePickerController.InfoKey(rawValue: "_UIImagePickerControllerVideoEditingStart")
        let editingEndedKey = UIImagePickerController.InfoKey(rawValue: "_UIImagePickerControllerVideoEditingEnd")

        guard let editedStart = info[editingStartedKey] as? NSNumber,
              let editedEnd = info[editingEndedKey] as? NSNumber else {
            processVideo(url: videoURL, observer: observer, maxDuration: maxDuration, picker: picker)
            return
        }

        let start = Int64(editedStart.doubleValue * 1000)
        let end = Int64(editedEnd.doubleValue * 1000)
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let editedVideoURL = URL(fileURLWithPath: cachesDirectory).appendingPathComponent("\(UUID().uuidString).mp4", isDirectory: false)
        let asset = AVURLAsset(url: videoURL)
        
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) {
            exportSession.outputURL = editedVideoURL
            exportSession.outputFileType = .mp4
            exportSession.timeRange = CMTimeRange(start: CMTime(value: start, timescale: 1000), duration: CMTime(value: end - start, timescale: 1000))
            
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .completed:
                    self.processVideo(url: editedVideoURL, observer: observer, maxDuration: maxDuration, picker: picker)
                case .failed: fallthrough
                case .cancelled:
                    observer.on(.error(RxMediaPickerError.generalError))
                    self.dismissPicker(picker)
                default: break
                }
            })
        }
    }
    
    fileprivate func processVideo(url: URL,
                                  observer: AnyObserver<URL>,
                                  maxDuration: TimeInterval,
                                  picker: UIImagePickerController) {
        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        
        if duration > maxDuration {
            observer.on(.error(RxMediaPickerError.videoMaximumDurationExceeded))
        } else {
            observer.on(.next(url))
            observer.on(.completed)
        }
        
        dismissPicker(picker)
    }

    fileprivate func presentPicker(_ picker: UIImagePickerController) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.present(picker: picker)
        }
    }
    
    fileprivate func dismissPicker(_ picker: UIImagePickerController) {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.dismiss(picker: picker)
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let action = currentAction {
            switch action {
            case .photo(let observer):
                processPhoto(info: info as [UIImagePickerController.InfoKey : AnyObject], observer: observer)
                dismissPicker(picker)
            case .video(let observer, let maxDuration):
                processVideo(info: info, observer: observer, maxDuration: maxDuration, picker: picker)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissPicker(picker)
        
        if let action = currentAction {
            switch action {
            case .photo(let observer):
                //observer.on(.error(RxMediaPickerError.canceled))
                observer.on(.completed)
            case .video(let observer, _):
                //observer.on(.error(RxMediaPickerError.canceled))
                observer.on(.completed)
            }
        }
    }
}
