//
//  MediaViewerController.swift
//  Hidden Client
//
//  Created by Hideo Den on 2018/08/27.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import UIKit

protocol MediaViewerControllerPageDelegate: class {
    func MediaViewerController(_ controller: MediaViewerController, didMoveToPage page: Int)
}

protocol MediaViewerControllerDismissalDelegate: class {
    func MediaViewerControllerWillDismiss(_ controller: MediaViewerController)
}

protocol MediaViewerControllerTouchDelegate: class {
    func MediaViewerController(_ controller: MediaViewerController, didTouch image: MediaViewerImage, at index: Int)
}

class MediaViewerController: UIViewController {

    // MARK: - Internal views

    lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast

        return scrollView
    }()

    lazy var overlayTapGestureRecognizer: UITapGestureRecognizer = { [unowned self] in
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(overlayViewDidTap(_:)))

        return gesture
    }()

    lazy var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return view
    }()

    lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return view
    }()

    // MARK: - views

    fileprivate(set) lazy var headerView: HeaderView = { [unowned self] in
        let view = HeaderView()
        view.delegate = self

        return view
    }()

    fileprivate(set) lazy var footerView: FooterView = { [unowned self] in
        let view = FooterView()
        view.delegate = self

        return view
    }()

    fileprivate(set) lazy var overlayView: UIView = { [unowned self] in
        let view = UIView(frame: CGRect.zero)
        let gradient = CAGradientLayer()

        let colors = [UIColor.colorFrom(rgb: 0x040404, alpha: 0.5), UIColor.colorFrom(rgb: 0x040404)]

        view.addGradientLayer(colors)
        view.alpha = 0

        return view
    }()

    // MARK: - Properties

    fileprivate(set) var currentPage = 0 {
        didSet {
            currentPage = min(numberOfPages - 1, max(0, currentPage))
            footerView.updatePage(currentPage + 1, numberOfPages)
            footerView.updateText(pageViews[currentPage].image.text)

            if currentPage == numberOfPages - 1 {
                seen = true
            }

            reconfigurePagesForPreload()

            pageDelegate?.MediaViewerController(self, didMoveToPage: currentPage)

            if let image = pageViews[currentPage].imageView.image, dynamicBackground {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.125) {
                    self.loadDynamicBackground(image)
                }
            } else if dynamicBackground {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.125) {
                    self.loadDynamicBackground(UIImage(named: "process-gradient.png")!)
                }
            }
        }
    }

    var numberOfPages: Int {
        return pageViews.count
    }

    var dynamicBackground: Bool = false {
        didSet {
            if dynamicBackground == true {
                effectView.frame = view.frame
                backgroundView.frame = effectView.frame
                view.insertSubview(effectView, at: 0)
                view.insertSubview(backgroundView, at: 0)
            } else {
                effectView.removeFromSuperview()
                backgroundView.removeFromSuperview()
            }
        }
    }

    var spacing: CGFloat = 20 {
        didSet {
            configureLayout(view.bounds.size)
        }
    }

    var images: [MediaViewerImage] {
        get {
            return pageViews.map { $0.image }
        }
        set(value) {
            initialImages = value
            configurePages(value)
        }
    }

    weak var pageDelegate: MediaViewerControllerPageDelegate?
    weak var dismissalDelegate: MediaViewerControllerDismissalDelegate?
    weak var imageTouchDelegate: MediaViewerControllerTouchDelegate?
    var presented = false
    fileprivate(set) var seen = false

    lazy var transitionManager: MediaViewerTransition = MediaViewerTransition()
    var pageViews = [PageView]()
    var statusBarHidden = false

    fileprivate var initialImages: [MediaViewerImage]
    fileprivate let initialPage: Int

    // MARK: - Initializers

    init(images: [MediaViewerImage] = [], startIndex index: Int = 0) {
        self.initialImages = images
        self.initialPage = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        statusBarHidden = UIApplication.shared.isStatusBarHidden

        view.backgroundColor = UIColor.black
        transitionManager.MediaViewerController = self
        transitionManager.scrollView = scrollView
        transitioningDelegate = transitionManager

        [scrollView, overlayView, headerView, footerView].forEach { view.addSubview($0) }
        overlayView.addGestureRecognizer(overlayTapGestureRecognizer)

        configurePages(initialImages)

        goTo(initialPage, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !presented {
            presented = true
            configureLayout(view.bounds.size)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.frame = view.bounds
        let bottomPadding: CGFloat
        if #available(iOS 11, *) {
            bottomPadding = view.safeAreaInsets.bottom
        } else {
            bottomPadding = 0
        }
        footerView.frame.size = CGSize(
            width: view.bounds.width,
            height: 100 + bottomPadding
        )

        footerView.frame.origin = CGPoint(
            x: 0,
            y: view.bounds.height - footerView.frame.height
        )

        headerView.frame = CGRect(
            x: 0,
            y: 16,
            width: view.bounds.width,
            height: 100
        )
    }

    override var prefersStatusBarHidden: Bool {
        return MediaViewerConfig.hideStatusBar
    }

    // MARK: - Rotation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.configureLayout(size)
        }, completion: nil)
    }

    // MARK: - Configuration

    func configurePages(_ images: [MediaViewerImage]) {
        pageViews.forEach { $0.removeFromSuperview() }
        pageViews = []

        let preloadIndicies = calculatePreloadIndicies()

        for i in 0..<images.count {
            let pageView = PageView(image: preloadIndicies.contains(i) ? images[i] : MediaViewerImageStub())
            pageView.pageViewDelegate = self

            scrollView.addSubview(pageView)
            pageViews.append(pageView)
        }

        configureLayout(view.bounds.size)
    }
  
    func reconfigurePagesForPreload() {
        let preloadIndicies = calculatePreloadIndicies()

        for i in 0..<initialImages.count {
            let pageView = pageViews[i]
            if preloadIndicies.contains(i) {
                if type(of: pageView.image) == MediaViewerImageStub.self {
                    pageView.update(with: initialImages[i])
                }
            } else {
                if type(of: pageView.image) != MediaViewerImageStub.self {
                    pageView.update(with: MediaViewerImageStub())
                }
            }
        }
    }

    // MARK: - Pagination

    func goTo(_ page: Int, animated: Bool = true) {
        guard page >= 0 && page < numberOfPages else {
            return
        }

        currentPage = page

        var offset = scrollView.contentOffset
        offset.x = CGFloat(page) * (scrollView.frame.width + spacing)

        let shouldAnimated = view.window != nil ? animated : false

        scrollView.setContentOffset(offset, animated: shouldAnimated)
    }

    func next(_ animated: Bool = true) {
        goTo(currentPage + 1, animated: animated)
    }

    func previous(_ animated: Bool = true) {
        goTo(currentPage - 1, animated: animated)
    }

    // MARK: - Actions

    @objc func overlayViewDidTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        footerView.expand(false)
    }

    // MARK: - Layout

    func configureLayout(_ size: CGSize) {
        scrollView.frame.size = size
        scrollView.contentSize = CGSize(
            width: size.width * CGFloat(numberOfPages) + spacing * CGFloat(numberOfPages - 1),
            height: size.height)
        scrollView.contentOffset = CGPoint(x: CGFloat(currentPage) * (size.width + spacing), y: 0)

        for (index, pageView) in pageViews.enumerated() {
            var frame = scrollView.bounds
            frame.origin.x = (frame.width + spacing) * CGFloat(index)
            pageView.frame = frame
            pageView.configureLayout()
            if index != numberOfPages - 1 {
                pageView.frame.size.width += spacing
            }
        }

        [headerView, footerView].forEach { ($0 as AnyObject).configureLayout() }

        overlayView.frame = scrollView.frame
        overlayView.resizeGradientLayer()
    }

    fileprivate func loadDynamicBackground(_ image: UIImage) {
        backgroundView.image = image
        backgroundView.layer.add(CATransition(), forKey: CATransitionType.fade.rawValue)
    }

    func toggleControls(pageView: PageView?, visible: Bool, duration: TimeInterval = 0.1, delay: TimeInterval = 0) {
        let alpha: CGFloat = visible ? 1.0 : 0.0

        //pageView?.playButton.isHidden = !visible

        UIView.animate(withDuration: duration, delay: delay, options: [], animations: {
            self.headerView.alpha = alpha
            self.footerView.alpha = alpha
            //pageView?.playButton.alpha = alpha
        }, completion: nil)
    }
  
    // MARK: - Helper functions
  
    func calculatePreloadIndicies () -> [Int] {
        var preloadIndicies: [Int] = []
        let preload = MediaViewerConfig.preload
        if preload > 0 {
            let lb = max(0, currentPage - preload)
            let rb = min(initialImages.count, currentPage + preload)
            for i in lb..<rb {
                preloadIndicies.append(i)
            }
        } else {
            preloadIndicies = [Int](0..<initialImages.count)
        }
        return preloadIndicies
    }
}

// MARK: - UIScrollViewDelegate

extension MediaViewerController: UIScrollViewDelegate {

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var speed: CGFloat = velocity.x < 0 ? -2 : 2

        if velocity.x == 0 {
            speed = 0
        }

        let pageWidth = scrollView.bounds.width + spacing
        var x = scrollView.contentOffset.x + speed * 60.0

        if speed > 0 {
            x = ceil(x / pageWidth) * pageWidth
        } else if speed < -0 {
            x = floor(x / pageWidth) * pageWidth
        } else {
            x = round(x / pageWidth) * pageWidth
        }

        targetContentOffset.pointee.x = x
        currentPage = Int(x / pageWidth)
    }
}

// MARK: - PageViewDelegate

extension MediaViewerController: PageViewDelegate {

    func remoteImageDidLoad(_ image: UIImage?, imageView: UIImageView) {
        guard let image = image, dynamicBackground else {
            return
        }

        let imageViewFrame = imageView.convert(imageView.frame, to: view)
        guard view.frame.intersects(imageViewFrame) else {
            return
        }

        loadDynamicBackground(image)
    }

    func pageViewDidZoom(_ pageView: PageView) {
        let duration = pageView.hasZoomed ? 0.1 : 0.5
        toggleControls(pageView: pageView, visible: !pageView.hasZoomed, duration: duration, delay: 0.5)
    }

    func pageView(_ pageView: PageView, didTouchPlayButton videoURL: String) {
        MediaViewerConfig.handleVideo(self, videoURL)
    }

    func pageViewDidTouch(_ pageView: PageView) {
        guard !pageView.hasZoomed else { return }

        imageTouchDelegate?.MediaViewerController(self, didTouch: images[currentPage], at: currentPage)

        let visible = (headerView.alpha == 1.0)
        toggleControls(pageView: pageView, visible: !visible)
    }
}

// MARK: - HeaderViewDelegate

extension MediaViewerController: HeaderViewDelegate {

    func headerView(_ headerView: HeaderView, didPressDeleteButton deleteButton: UIButton) {
        deleteButton.isEnabled = false

        guard numberOfPages != 1 else {
            pageViews.removeAll()
            self.headerView(headerView, didPressCloseButton: headerView.closeButton)
            return
        }

        let prevIndex = currentPage

        if currentPage == numberOfPages - 1 {
            previous()
        } else {
            next()
            currentPage -= 1
        }

        self.pageViews.remove(at: prevIndex).removeFromSuperview()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.configureLayout(self.view.bounds.size)
            self.currentPage = Int(self.scrollView.contentOffset.x / self.view.bounds.width)
            deleteButton.isEnabled = true
        }
    }

    func headerView(_ headerView: HeaderView, didPressCloseButton closeButton: UIButton) {
        closeButton.isEnabled = false
        presented = false
        dismissalDelegate?.MediaViewerControllerWillDismiss(self)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - FooterViewDelegate

extension MediaViewerController: FooterViewDelegate {

    func footerView(_ footerView: FooterView, didExpand expanded: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayView.alpha = expanded ? 1.0 : 0.0
            self.headerView.deleteButton.alpha = expanded ? 0.0 : 1.0
        })
    }
}
