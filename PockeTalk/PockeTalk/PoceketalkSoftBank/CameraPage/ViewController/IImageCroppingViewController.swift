//
//  ImageCroppingViewController.swift
//  PockeTalk
//
//  Created by BJIT LTD on 18/9/21.
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
    @IBOutlet weak var menuButton: UIButton!
    
    var imageFrameWidth = CGFloat()
    var imageFrameHeight = CGFloat()
    
    var cropBtn: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "cropButton"), for: .normal)
        button.addTarget(self, action: #selector(cropButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()

    var cancelBtn: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(named: "demo_mode_reboot_cancel_button"), for: .normal)
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
                DispatchQueue.main.async {
                    self.overlappingView.frame.origin.x = 12.5
                    self.overlappingView.frame.origin.y = (self.view.frame.height/2) - (self.overlappingView.frame.height/2)
                }
            }
            
        }

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
        cropViewLeadingConstraint.constant = overlappingViewSize.origin.x
        cropViewtopConstraint.constant = overlappingViewSize.origin.y
        cropViewWidth.constant = self.view.frame.size.width - 25
        cropViewHeight.constant = imageView.frame.height
        
        
        cropViewLeadingConstraint.isActive = true
        cropViewtopConstraint.isActive = true
        cropViewWidth.isActive = true
        cropViewHeight.isActive = true
        
    }
    
    private func loadScrollView() {
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1
        centerScrollViewContent()
    }
    
    private func prepareScrollView() {
        let scale = getMinScale(view.bounds.size)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        
        
        DispatchQueue.main.async {
            let width = self.view.frame.size.width - 25
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
        scrollView.contentInset = UIEdgeInsets(top: offy-(topPadding ),
                                               left: offx,
                                               bottom: offy-(bottomPadding ),
                                               right: offx)
    }

    @IBAction func menuTapAction(_ sender: UIButton) {
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            self.navigationController?.pushViewController(settinsViewController, animated: true)
        }
    }

    @IBAction func cancelButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func cropButtonEventListener(_ sender: Any) {
        guard let image = imageView.image else {
            return
        }
        imageView.isHidden = true
        croppedImage = image
        
        if cropFunctionality.isEnabled {
            let cropRect = makeProportionalCropRect()
            let resizedCropRect = CGRect(x: (image.size.width) * cropRect.origin.x,
                                         y: (image.size.height) * cropRect.origin.y,
                                         width: (image.size.width * cropRect.width),
                                         height: (image.size.height * cropRect.height))
            croppedImage = image.crop(rect: resizedCropRect)
            
            imageFrameHeight = imageView.frame.size.height*cropRect.height
            imageFrameWidth = imageView.frame.size.height*cropRect.width

            
        }
        
        
        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
            vc.image = croppedImage
            vc.imageHeight = imageFrameHeight
            vc.imageWidth = imageFrameWidth
            self.navigationController?.pushViewController(vc, animated: true)
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
    
}

extension ImageCroppingViewController: UIScrollViewDelegate, CropOverlappingViewDelegates {
    
    func didMoveOverlappingView(newFrame: CGRect) {
        cropViewLeadingConstraint.constant = newFrame.origin.x
        cropViewtopConstraint.constant = newFrame.origin.y
        cropViewWidth.constant = newFrame.size.width
        cropViewHeight.constant = newFrame.size.height
    }
    
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContent()
    }
}
