//
//  ImageCroppingViewController.swift
//  PockeTalk
//

import Foundation
import UIKit
import Photos

public typealias CameraViewCompletion = (UIImage?, PHAsset?) -> Void

class ImageCroppingViewController: BaseViewController {

    let imageView = UIImageView()
    var croppedImage = UIImage()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var centeredView: UIView!
    var imageFrameWidth = CGFloat()
    var imageFrameHeight = CGFloat()
    var fromImageProcessVC: Bool = false

    var cropBtn: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cropButton"), for: .normal)
        button.addTarget(self, action: #selector(cropButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()

    var cancelBtn: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cropCancelButton"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()
    private let overlappingView = CustomOverlappingView()
    private var cropViewLeadingConstraint = NSLayoutConstraint()
    private var cropViewtopConstraint = NSLayoutConstraint()
    private var cropViewWidth = NSLayoutConstraint()
    private var cropViewHeight = NSLayoutConstraint()
    private var layoutForFirstTime = true

    ///Floating button properties
    let offset : CGFloat = 30
    let width : CGFloat = 60
    let height : CGFloat = 60
    let leadingForRightBtn : CGFloat = 50
    let trailingForLeftBtn : CGFloat = -50
    let sideConstraint: CGFloat = 12.5

    var cropFunctionality: CropUtils! {
        didSet {
            PrintUtility.printLog(tag: "Crop Func", text: "\(String(describing: cropFunctionality))")
            overlappingView.isResizable = cropFunctionality.resizeable
            overlappingView.minCropArea = cropFunctionality.minimumSize
        }
    }

    private var scrollViewsSize: CGSize {
        let scroolViewContentInset = scrollView.contentInset
        let size = scrollView.bounds.standardized.size
        let width = size.width - scroolViewContentInset.left - scroolViewContentInset.right
        let height = size.height - scroolViewContentInset.top - scroolViewContentInset.bottom
        return CGSize(width:width, height:height)
    }

    private var scrollViewCenter: CGPoint {
        let scrollViewSize = scrollViewsSize
        return CGPoint(x: scrollViewSize.width,
                       y: scrollViewSize.height)
    }

    private let overlayViewPadding: CGFloat = 20
    private var overlappingViewSize: CGRect {
        let buttonsViewGap: CGFloat = 20 * 2 + 64
        let centerViewArea: CGRect
        if view.bounds.size.height > view.bounds.size.width {
            centerViewArea = CGRect(x: 0,
                                    y: 0,
                                    width: view.bounds.size.width,
                                    height: view.bounds.size.height - buttonsViewGap)
        } else {
            centerViewArea = CGRect(x: 0,
                                    y: 0,
                                    width: view.bounds.size.width - buttonsViewGap,
                                    height: view.bounds.size.height)
        }

        let cropOverlayWidth = min(centerViewArea.size.width, centerViewArea.size.height) - 2 * overlayViewPadding
        let cropOverlayX = centerViewArea.size.width / 2 - cropOverlayWidth / 2
        let cropOverlayY = centerViewArea.size.height / 2 - cropOverlayWidth / 2

        return CGRect(x: cropOverlayX,
                      y: cropOverlayY,
                      width: cropOverlayWidth,
                      height: cropOverlayWidth)
    }

    public var onCompletion: CameraViewCompletion?

    var image: UIImage?

    public init(image: UIImage, croppingParameters: CropUtils) {
        self.cropFunctionality = croppingParameters
        self.image = image

        super.init(nibName: "ImageCropViewController", bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        view.backgroundColor = UIColor.black

        loadScrollView()
        loadCropOverlay()

        if let image = image {
            configureWithImage(image)
            centerScrollViewContent()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if layoutForFirstTime {
            layoutForFirstTime = false
            DispatchQueue.main.async {
                self.loadOverlappingViewConstraint()
            }
        }
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    /// Inital set up of crop and cancel button
    func setUpButtons () {
        /// get full view height
        let screenBounds = UIScreen.main.bounds
        let viewHeight = screenBounds.height

        view.addSubview(cropBtn)
        cropBtn.translatesAutoresizingMaskIntoConstraints = false
        cropBtn.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor,constant: leadingForRightBtn)
            .isActive = true
        cropBtn.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(viewHeight - (viewHeight/2 + (imageView.frame.size.height/2 - offset )))).isActive = true
        cropBtn.heightAnchor.constraint(equalToConstant: height).isActive = true
        cropBtn.widthAnchor.constraint(equalToConstant: width).isActive = true
        cropBtn.layer.cornerRadius = width/2
        cropBtn.layer.masksToBounds = true

        view.addSubview(cancelBtn)
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        cancelBtn.trailingAnchor.constraint(equalTo: scrollView.centerXAnchor,constant: trailingForLeftBtn)
            .isActive = true
        cancelBtn.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -(viewHeight - (viewHeight/2 + (imageView.frame.size.height/2 - offset)))).isActive = true
        cancelBtn.heightAnchor.constraint(equalToConstant: height).isActive = true
        cancelBtn.widthAnchor.constraint(equalToConstant: width).isActive = true
        cancelBtn.layer.cornerRadius = width/2
        cancelBtn.layer.masksToBounds = true
    }

    private func loadOverlappingViewConstraint() {
        cropViewLeadingConstraint.constant = 0
        //fromImageProcessVC ? 0 : overlappingViewSize.origin.x
        cropViewtopConstraint.constant = ((screenHeight - imageView.frame.height)/2) - sideConstraint
        //fromImageProcessVC ? ((screenHeight - imageView.frame.height)/2) - CameraCropControllerMargin : overlappingViewSize.origin.y
        cropViewWidth.constant = self.view.frame.size.width
        cropViewHeight.constant = imageView.frame.height + (CameraCropControllerMargin * 2)

        cropViewLeadingConstraint.isActive = true
        cropViewtopConstraint.isActive = true
        cropViewWidth.isActive = true
        cropViewHeight.isActive = true
    }

    private func loadScrollView() {
        scrollView.addSubview(imageView)
        imageView.backgroundColor = .clear
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        centerScrollViewContent()
    }

    private func prepareScrollView() {
        let scale = getMinScale(view.bounds.size)

        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale

        DispatchQueue.main.async {
            let width = self.view.frame.size.width - (CameraCropControllerMargin * 2)
            let height = self.view.frame.size.height*0.82

            self.imageView.frame.size.width = width
            self.imageView.frame.size.height = height

            self.centerScrollViewContent()
            self.setUpButtons()
        }
    }

    private func loadCropOverlay() {
        overlappingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlappingView)

        cropViewLeadingConstraint = overlappingView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0)
        cropViewtopConstraint = overlappingView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        cropViewWidth = overlappingView.widthAnchor.constraint(equalToConstant: 0)
        cropViewHeight = overlappingView.heightAnchor.constraint(equalToConstant: 0)

        overlappingView.delegate = self
        overlappingView.isHidden = !cropFunctionality.isEnabled
        overlappingView.isResizable = cropFunctionality.resizeable
        overlappingView.isdragable = cropFunctionality.dragable
        overlappingView.minCropArea = cropFunctionality.minimumSize
    }

    private func configureWithImage(_ image: UIImage) {
        imageView.image = image
        imageView.sizeToFit()
        prepareScrollView()
    }

    private func getMinScale(_ size: CGSize) -> CGFloat {
        var _size = size

        if cropFunctionality.isEnabled {
            _size = overlappingViewSize.size
        }

        guard let image = imageView.image else {
            return 1
        }

        let scaleWidth = _size.width / image.size.width
        let scaleHeight = _size.height / image.size.height
        return min(scaleWidth, scaleHeight)
    }

    private func centerScrollViewContent() {
        guard let image = imageView.image else {
            return
        }

        let imgViewSize = imageView.frame.size
        let imageSize = image.size

        var realImgSize: CGSize
        if imageSize.width / imageSize.height > imgViewSize.width / imgViewSize.height {
            realImgSize = CGSize(width: imgViewSize.width,height: imgViewSize.width / imageSize.width * imageSize.height)
        } else {
            realImgSize = CGSize(width: imgViewSize.height / imageSize.height * imageSize.width, height: imgViewSize.height)
        }

        var frame = CGRect.zero
        frame.size = realImgSize
        imageView.frame = frame

        let screenSize  = scrollView.frame.size
        let offx = screenSize.width > realImgSize.width ? (screenSize.width - realImgSize.width) / 2 : 0
        let offy = screenSize.height > realImgSize.height ? (screenSize.height - realImgSize.height) / 2 : 0

        /// Check safe area inset available or not
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        /// Set scrollview content inset based on safe area
        let content_Inset = fromImageProcessVC ? UIEdgeInsets(top: ((self.view.frame.size.height - imageView.frame.size.height)/2)-topPadding,
                                                              left: CameraCropControllerMargin,
                                                              bottom: (self.view.frame.size.height - self.imageView.frame.size.height)/2,
                                                              right: CameraCropControllerMargin) :
        UIEdgeInsets(top: offy-(topPadding ),
                     left: offx,
                     bottom: offy-(bottomPadding ),
                     right: offx)

        scrollView.contentInset = content_Inset

        PrintUtility.printLog(tag: "scrollView.contentInset", text: "\(offy-(topPadding)), \(offx), \(offy-(bottomPadding)), \(offx)")
    }

    @IBAction func cancelButtonEventListener(_ sender: Any) {
        buttonCancelLogEvent()
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        for viewController in viewControllers {
            if viewController is HomeViewController {
                let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.popToViewController(viewController, animated: false)
            }
        }
    }

    @IBAction func cropButtonEventListener(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.isHidden = true
        croppedImage = image

        // calculate resized crop rect
        if cropFunctionality.isEnabled {
            let cropRect = makeProportionalCropRect()
            let resizedCropRect = CGRect(x: (image.size.width) * cropRect.origin.x,
                                         y: (image.size.height) * cropRect.origin.y,
                                         width: (image.size.width * cropRect.width),
                                         height: (image.size.height * cropRect.height))
            croppedImage = image.crop(rect: resizedCropRect)

            imageFrameHeight = imageView.frame.size.height*cropRect.height
            imageFrameWidth = imageView.frame.size.height*cropRect.width

            let roundedImageFrameHeight = Double(imageFrameHeight).roundToDecimal(2)
            let roundedImageFrameWidth = Double(imageView.frame.size.width*cropRect.width).roundToDecimal(2)

            let trimmingState = (roundedImageFrameHeight == Double(imageView.frame.size.height).roundToDecimal(2) && roundedImageFrameWidth == Double(imageView.frame.size.width).roundToDecimal(2)) ? false : true
            buttonCropLogEvent(trimmingState: trimmingState)
        }

        if Reachability.isConnectedToNetwork() {
            let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
            if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
                vc.image = croppedImage
                vc.cropFrameHeight = imageFrameHeight
                vc.cropFrameWidth = imageFrameWidth
                vc.maxCropFrameWidth = imageView.frame.size.width
                vc.maxCropFrameHeight = imageView.frame.size.height
                vc.originalImage = image

                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.pushViewController(vc, animated: false)
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    private func makeProportionalCropRect() -> CGRect {
        var cropRect = overlappingView.croppedRect
        cropRect.origin.x += scrollView.contentOffset.x - imageView.frame.origin.x
        cropRect.origin.y += scrollView.contentOffset.y - imageView.frame.origin.y

        let normalizedX = max(0, cropRect.origin.x / imageView.frame.width)
        let normalizedY = max(0, cropRect.origin.y / imageView.frame.height)

        let extraWidth = min(0, cropRect.origin.x)
        let extraHeight = min(0, cropRect.origin.y)

        let normalizedWidth = min(1, (cropRect.width + extraWidth) / imageView.frame.width)
        let normalizedHeight = min(1, (cropRect.height + extraHeight) / imageView.frame.height)

        return CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
    }

    deinit {
        PrintUtility.printLog(tag: "ImageCroppingViewController", text: "dismiss view controller")
    }
}

extension ImageCroppingViewController: UIScrollViewDelegate, CropOverlappingViewDelegates {
    // Device wise screen size calculation
    public var screenWidth: CGFloat {
        return self.view.frame.size.width
    }

    public var screenHeight: CGFloat {
        return self.view.frame.size.height
    }

    func didMoveOverlappingView(newFrame: CGRect) {

        var minXValue = CGFloat()
        var minYValue = CGFloat()
        var maxYValue = CGFloat()
        let topPadding = (screenHeight - imageView.frame.height)/2

        if newFrame.origin.x < 0{
            minXValue = 0
        } else if (newFrame.origin.x + newFrame.size.width) > self.view.frame.width {
            minXValue = self.view.frame.width - (overlappingView.frame.size.width)
        } else {
            minXValue = newFrame.origin.x
        }

        //PrintUtility.printLog(tag: "ImageCroppingViewController", text: "imageView.frame.maxY : \(imageView.frame.origin.y+imageView.frame.size.height+topPadding), \(self.view.frame.height)")
        if ((newFrame.origin.y) < (topPadding - CameraCropControllerMargin)){
            //PrintUtility.printLog(tag: "ImageCroppingViewController", text: "view appeared: \(newFrame.origin.y), padding : \(topPadding), \(imageView.frame.minY)")
            minYValue = (topPadding - CameraCropControllerMargin)

        } else {
            minYValue = newFrame.origin.y
            maxYValue = minYValue + newFrame.size.height
            if maxYValue > (imageView.frame.origin.y + imageView.frame.size.height + topPadding + CameraCropControllerMargin) {
                minYValue = (imageView.frame.origin.y + imageView.frame.size.height + topPadding + CameraCropControllerMargin) - (overlappingView.frame.size.height)
            } else {
                if (overlappingView.frame.size.height == imageView.frame.size.height + (CameraCropControllerMargin * 2)) {
                    overlappingView.frame.size.height = imageView.frame.size.height + (CameraCropControllerMargin * 2)
                } else {
                    minYValue = newFrame.origin.y
                }
            }
        }

        cropViewLeadingConstraint.constant = minXValue
        cropViewtopConstraint.constant =  minYValue
        cropViewWidth.constant = newFrame.size.width > imageView.frame.size.width + (CameraCropControllerMargin * 2) ? imageView.frame.size.width + (CameraCropControllerMargin * 2) : newFrame.size.width
        cropViewHeight.constant = newFrame.size.height > imageView.frame.size.height + (CameraCropControllerMargin * 2) ? imageView.frame.size.height + (CameraCropControllerMargin * 2) : newFrame.size.height
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContent()
    }
}

//MARK: - Google analytics log events
extension ImageCroppingViewController {
    private func buttonCancelLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateConfirm,
                            buttonName: analytics.buttonCancel)
    }

    private func buttonCropLogEvent(trimmingState: Bool) {
        analytics.cameraCrop(screenName: analytics.camTranslateConfirm,
                             button: analytics.buttonNext, crop: trimmingState)
    }
}
