//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//

import UIKit

class CaptureImageProcessVC: BaseViewController {
    
    private let TAG = "\(CaptureImageProcessVC.self)"
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!
    
    private let iTTServerViewModel = ITTServerViewModel()
    private let cameraHistoryViewModel = CameraHistoryViewModel()
    private let activity = ActivityIndicator()
    
    var imageView = UIImageView()
    var fromHistoryVC: Bool = false
    var cameraHistoryImageIndex = Int()
    var historyID = Int64()
    var fromLanguage: String = ""
    var toLanguage: String = ""
    var gNativeLanguage: String = ""
    var gTranslateLanguage: String = ""
    var mTranslatedLanguage: String = ""
    var mDetectedLanguage: String = ""
    
    var ttsResponsiveView = TTSResponsiveView()
    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    var nativeLang : String = ""
    var targetLang : String = ""
    var nativeText: String = ""
    var targetText: String = ""
    var playNative = true

    lazy var modeSwitchButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        if modeSwitchTypes == blockMode {
            button.setImage(UIImage(named: blockMode), for: .normal)
        } else {
            button.setImage(UIImage(named: lineMode), for: .normal)
        }
        button.addTarget(self, action: #selector(modeSwitchButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var cameraTTSDiaolog: CameraTTSDialog = {
        let cameraTTSDialog = CameraTTSDialog(frame: CGRect(x: 0, y: 0, width: SIZE_WIDTH, height: SIZE_HEIGHT))
        cameraTTSDialog.delegate = self
        return cameraTTSDialog
    }()
    
    private lazy var cameraTTSContextMenu: CameraTTSContextMenu = {
        let cameraTTSContextMenu = CameraTTSContextMenu(frame: CGRect(x: 0, y: 0, width: SIZE_WIDTH, height: SIZE_HEIGHT))
        cameraTTSContextMenu.delegate = self
        return cameraTTSContextMenu
    }()
    
    //    let modeSwitchType: String = {
    //        return UserDefaults.standard.string(forKey: "modeSwitchType") ?? "blockMode"
    //    }()
    
    var image = UIImage()
    var imageWidth = CGFloat()
    var imageHeight = CGFloat()
    //var image = UIImage(named: "vv")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraImageView.center = self.view.center
        self.iTTServerViewModel.viewDidLoad(self)
        fromHistoryVC ? setUpViewForHistoryVC() : setUpViewForCapturedImage()
        
        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollView.addGestureRecognizer(scrollViewTap)
        
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
        
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
    }
    
    func setUpViewForCapturedImage() {
        
        let heightInPoints = image.size.height
        let widthInPoints = image.size.width
        PrintUtility.printLog(tag: "Captured Image heightInPoints: \(heightInPoints)", text: ", widthInPoints: \(widthInPoints)")
        
        image = UIImage(data: image.jpeg(.medium)!)!
        
        let heightInPoints1 = image.size.height
        let widthInPoints1 = image.size.width
        PrintUtility.printLog(tag: "Compressed Image heightInPoints: \(heightInPoints1)", text: ", widthInPoints: \(widthInPoints1)")
        
        //image = resizeImage(image: image)
        var resizeWidth: Int = Int(image.size.width)
        var resizeHeight: Int = Int(image.size.height)
        if(image.size.width > CGFloat(IMAGE_WIDTH)) {
            resizeWidth = Int(IMAGE_WIDTH)
        }
        
        if(image.size.height > CGFloat(IMAGE_HEIGHT)){
            resizeHeight = Int(IMAGE_HEIGHT)
        }
        //image = resizeImage(image: image, targetSize: CGSize.init(width: resizeWidth, height: resizeHeight))   // resized bitmap
        
        let heightInPoints2 = image.size.height
        let widthInPoints2 = image.size.width
        PrintUtility.printLog(tag: "Resized Image heightInPoints: \(heightInPoints2)", text: ", widthInPoints: \(widthInPoints2)")
        
        if imageWidth>self.view.frame.width {
            imageWidth = self.view.frame.width
        }
        let image1 = resizeImage(image: image, targetSize: CGSize(width: imageWidth, height: imageHeight))
        PrintUtility.printLog(tag: "Resized Image1 heightInPoints: \(image1.size.height)", text: ", widthInPoints: \(image1.size.width)")
        imageView.image = image1
        self.iTTServerViewModel.capturedImage = image1
        
        imageView.frame = CGRect(x: 0, y: 0, width: imageWidth  , height:  imageHeight)
        cameraImageView.addSubview(imageView)
        setUpImageViewConstraint()
        
        //self.cameraImageView.contentMode = .scaleAspectFit
        
        //        GoogleCloudOCR().detect(from: image) { ocrResult in
        //            guard let ocrResult = ocrResult else {
        //                fatalError("Did not recognize any text in this image")
        //            }
        //        }
        
        self.iTTServerViewModel.getITTData(from: image1) { [weak self] (data, error) in
            
            if error != nil {
                PrintUtility.printLog(tag: "ERROR :", text: "\(String(describing: error))")
            } else {
                if let detectedData = data {
                    let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
                    PrintUtility.printLog(tag: "previously selected mode: ", text: "\(String(describing: modeSwitchTypes))")
                    self?.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: modeSwitchTypes ?? blockMode, isFromHistoryVC: self!.fromHistoryVC)
                }
            }
        }
    }
    
    func setUpViewForHistoryVC() {
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width  , height:  image.size.height)
        cameraImageView.addSubview(imageView)
        setUpImageViewConstraint()
        self.iTTServerViewModel.capturedImage = image
        
        PrintUtility.printLog(tag: "row index", text: "\(historyID)")
        self.iTTServerViewModel.historyID = historyID
        let translatedData: TranslatedTextJSONModel? = CameraHistoryDBModel().getTranslatedData(id: historyID)
        let detectedData: DetectedJSON? = CameraHistoryDBModel().getDetectedData(id: historyID)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(translatedData)
        let detectedData1 = try? encoder.encode(detectedData)
        //PrintUtility.printLog(tag: TAG, text: " translatedData setUpViewForHistoryVC() >> Detected Data: \(String(data: data!, encoding: .utf8)!)")
        //PrintUtility.printLog(tag: TAG, text: " detected setUpViewForHistoryVC() >> Detected Data: \(String(data: detectedData1!, encoding: .utf8)!)")
        
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        if let detectedData = detectedData, let translatedData = translatedData {
            
            let data = translatedData
            let blockData = data.block?.translatedText
            let lineData = data.line?.translatedText
            self.iTTServerViewModel.detectedJSON = detectedData
            
            PrintUtility.printLog(tag: "block data count : \(String(describing: blockData?.count))", text: "line data count: \(String(describing: lineData?.count))")
            if (( blockData!.count > 0) && (lineData!.count > 0)) {
                self.iTTServerViewModel.getTextviewListForCameraHistory(detectedData: detectedData, translatedData: translatedData)
            } else if (blockData!.count>0) {
                if modeSwitchTypes != blockMode {
                    UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                }
                self.iTTServerViewModel.getSelectedModeTextViewListFromHistory(detectedData: detectedData, translatedData: translatedData, selectedMode: blockMode)
                
            } else if (lineData!.count > 0) {
                if modeSwitchTypes != lineMode {
                    UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                }
                self.iTTServerViewModel.getSelectedModeTextViewListFromHistory(detectedData: detectedData, translatedData: translatedData, selectedMode: lineMode)
            }
        }
        
        else {
            PrintUtility.printLog(tag: "Detected or Translated data not found", text: "")
        }
    }
    
    @objc func scrollViewTapped(sender : UITapGestureRecognizer) {
        let view = sender.view
        let touchpoint = sender.location(in: view)
        var textViews = [TextViewWithCoordinator]()
        if let modeSwitchType = UserDefaults.standard.string(forKey: modeSwitchType) {
            
            if modeSwitchType == blockMode {
                textViews.removeAll()
                textViews = self.iTTServerViewModel.blockModeTextViewList
                
            } else {
                textViews.removeAll()
                textViews = self.iTTServerViewModel.lineModetTextViewList
            }
        }
        
        for (index,each) in textViews.enumerated() {
            let zoomScale = scrollView.zoomScale
            var x = each.view.frame
            
            x.origin.x = (each.view.frame.origin.x * zoomScale) + (imageView.frame.origin.x*zoomScale)
            x.origin.y = (each.view.frame.origin.y * zoomScale) + (imageView.frame.origin.y*zoomScale)
            x.size.width = each.view.frame.size.width * zoomScale
            x.size.height = each.view.frame.size.height * zoomScale
            
            
            if (x.contains(touchpoint)) {
                
                if let modeSwitchType = UserDefaults.standard.string(forKey: modeSwitchType) {
                                        
                    let id = try? CameraHistoryDBModel().getMaxId()
                    
                    let translatedData = fromHistoryVC ? CameraHistoryDBModel().getTranslatedData(id: historyID) :  CameraHistoryDBModel().getTranslatedData(id: Int64(id!))
                    
                    if modeSwitchType == blockMode {
                        mTranslatedLanguage = (translatedData.block!.languageCodeTo)
                        mDetectedLanguage = self.iTTServerViewModel.blockListFromJson[index].detectedLanguage!
                        PrintUtility.printLog(tag: "translateLanguage block mode: ", text: "\(mTranslatedLanguage)")
                        showTTSDialog(nativeText: textViews[index].detectedText, nativeLanguage: textViews[index].detectedLanguage, translateText: textViews[index].translatedText, translateLanguage: mTranslatedLanguage)
                        PrintUtility.printLog(tag: "touched view tag :", text: "\(each.view.tag), index: \(index)")
                        PrintUtility.printLog(tag: "text:", text: "\(String(describing: self.iTTServerViewModel.blockListFromJson[index].text))")
                        
                    } else {
                        mTranslatedLanguage = (translatedData.line!.languageCodeTo)
                        mDetectedLanguage = self.iTTServerViewModel.lineListFromJson[index].detectedLanguage!
                        
                        showTTSDialog(nativeText: textViews[index].detectedText, nativeLanguage: textViews[index].detectedLanguage, translateText: textViews[index].translatedText, translateLanguage: mTranslatedLanguage)
                        PrintUtility.printLog(tag: "touched view tag :", text: "\(each.view.tag), index: \(index)")
                        PrintUtility.printLog(tag: "text:", text: "\(String(describing: self.iTTServerViewModel.lineListFromJson[index].text))")
                    }
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playTTS(){
        var lang = ""
        var text = ""
        if(playNative){
            lang = nativeLang
            text = nativeText
        }else{
            lang = targetLang
            text = targetText
        }
        
        let languageManager = LanguageSelectionManager.shared
        if(languageManager.hasTtsSupport(languageCode: lang)){
                PrintUtility.printLog(tag: TAG,text: "checkTtsSupport has TTS support \(lang)")
            PrintUtility.printLog(tag: "Translate ", text: "lang: \(lang) text: \(text)" )

            getTtsValue(langCode: lang)
            ttsResponsiveView.checkSpeakingStatus()
            ttsResponsiveView.setRate(rate: rate)
            ttsResponsiveView.TTSPlay(voice: voice,text: text )
            }else{
                PrintUtility.printLog(tag: TAG,text: "checkTtsSupport don't have TTS support \(lang)")
                let seconds = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.stopTTS()
                }
            }
    }
    func stopTTS(){
        ttsResponsiveView.stopTTS()
    }
    
    /// Retreive tts value from respective language code
    func getTtsValue (langCode: String) {
        let item = LanguageEngineParser.shared.getTtsValue(langCode: langCode)
        self.voice = item.voice
        self.rate = item.rate
        PrintUtility.printLog(tag: "getTtsValue ", text: "voice: \(voice) rate: \(rate)" )

    }
    
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    
    func updateView() {
        DispatchQueue.main.async {[self] in
            let blockModeTextViews = self.iTTServerViewModel.blockModeTextViewList
            let lineModeTextViews = self.iTTServerViewModel.lineModetTextViewList
            PrintUtility.printLog(tag: "blockModeTextViews & lineModeTextViews", text: "\(self.iTTServerViewModel.blockModeTextViewList.count), \(self.iTTServerViewModel.lineModetTextViewList.count)")
            //if (blockModeTextViews.count != 0 || lineModeTextViews.count != 0) {
            hideLoader()
            
            if let modeSwitchType = UserDefaults.standard.string(forKey: modeSwitchType) {
                PrintUtility.printLog(tag: "modeSwitchType for update Views", text: "\(modeSwitchType)")
                if modeSwitchType == blockMode {
                    for each in lineModeTextViews {
                        each.view.removeFromSuperview()
                    }
                    plotLineOrBlock(using: blockModeTextViews)
                    
                } else {
                    for each in blockModeTextViews {
                        each.view.removeFromSuperview()
                    }
                    plotLineOrBlock(using: lineModeTextViews)
                }
            } else {
                UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                plotLineOrBlock(using: blockModeTextViews)
            }
            // }
        }
    }
    
    
    func plotLineOrBlock(using textViews: [TextViewWithCoordinator]) {
        
        let screenRect = UIScreen.main.bounds
        _ = screenRect.size.width
        _ = screenRect.size.height
        
        // TO Do: will remove static image
        //let image1 = UIImage(named: "vv")
        
        //        let imageView = UIImageView(image: image)
        //
        //        let heightInPoints = image.size.height
        //        let heightInPixels = heightInPoints * image.scale
        //
        //        let widthInPoints = image.size.width
        //        let widthInPixels = widthInPoints * image.scale
        //
        //        imageView.frame = CGRect(x: 0, y: 0, width: widthInPixels, height: heightInPixels) // To do : This will be actual cropped & processed image height width
        //
        //        self.view.addSubview(imageView)
        
        if textViews.count > 0 {
            for i in 0..<textViews.count {
                DispatchQueue.main.async {
                    textViews[i].view.backgroundColor = UIColor.gray.withAlphaComponent(0.4)
                    
                    textViews[i].view.tag = i
                    
                    self.imageView.addSubview(textViews[i].view)
                    textViews[i].view.isUserInteractionEnabled = true
                }
            }
        }
        
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(modeSwitchButton)
            setupModeSwitchButton()
        }
        backButton.isUserInteractionEnabled = true
        
    }
    
    func showTTSDialog(nativeText: String, nativeLanguage: String, translateText: String, translateLanguage: String){
        cameraTTSDiaolog.fromLanguageLabel.text = nativeText
        
        let nativeLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: nativeLanguage)
        cameraTTSDiaolog.fromTranslateLabel.text = getTTSDialogLanguageName(languageItem: nativeLangItem!)
        cameraTTSDiaolog.toLanguageLabel.text = translateText
        fromLanguage = nativeLangItem!.sysLangName
        toLanguage = translateText
        
        let targetLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: translateLanguage)
        cameraTTSDiaolog.toTranslateLabel.text = getTTSDialogLanguageName(languageItem: targetLangItem!)
        gNativeLanguage = targetLangItem!.sysLangName
        gTranslateLanguage = nativeText
        self.nativeText = nativeText
        self.nativeLang = nativeLanguage
        self.targetText = translateText
        self.targetLang = translateLanguage
        /// Just showing the TTS dialog for testing.
        let tapForNativeTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnNativeTTSText(sender:)))
        cameraTTSDiaolog.fromLanguageLabel.isUserInteractionEnabled = true
        cameraTTSDiaolog.fromLanguageLabel.addGestureRecognizer(tapForNativeTTS)
        
        let tapForTargetTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTargetTTSText(sender:)))
        cameraTTSDiaolog.toLanguageLabel.isUserInteractionEnabled = true
        cameraTTSDiaolog.toLanguageLabel.addGestureRecognizer(tapForTargetTTS)
        
        self.view.addSubview(cameraTTSDiaolog)
        removeFloatingButton()
    }
    
    @objc func actionTappedOnNativeTTSText(sender:UITapGestureRecognizer) {
        //ttsResponsiveView.isSpeaking()
        playNative = true
        if(!isSpeaking){
            playTTS()
        }else{
            stopTTS()
        }
    }
    
    @objc func actionTappedOnTargetTTSText(sender:UITapGestureRecognizer) {
        //ttsResponsiveView.isSpeaking()
        playNative = false
        if(!isSpeaking){
            playTTS()
        }else{
            stopTTS()
        }
    }
    
    
    func getTTSDialogLanguageName(languageItem: LanguageItem) -> String{
        var result: String = ""
        result = languageItem.sysLangName + "(" + languageItem.name + ")"
        return result
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(backButton)
            backButton.isUserInteractionEnabled = false
            setupBackButton(view)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeFloatingButton()
    }
    
    func removeFloatingButton() {
        if let view = UIApplication.shared.keyWindow, modeSwitchButton.isDescendant(of: view) {
            modeSwitchButton.removeFromSuperview()
        }
        if let backButtonView = UIApplication.shared.keyWindow, backButton.isDescendant(of: backButtonView) {
            backButton.removeFromSuperview()
        }
    }
    
    @objc func modeSwitchButtonEventListener(_ button: UIButton) {
        
        let id = try? CameraHistoryDBModel().getMaxId()
        if !fromHistoryVC {
            self.iTTServerViewModel.historyID = Int64(id!)
            self.iTTServerViewModel.fromHistoryVC = false
        }
        
        self.iTTServerViewModel.historyID = fromHistoryVC ? historyID : Int64(id!)
        
        let translatedData = fromHistoryVC ? CameraHistoryDBModel().getTranslatedData(id: historyID) : CameraHistoryDBModel().getTranslatedData(id: Int64(id!))
        
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        PrintUtility.printLog(tag: "translated data : -", text: "\(String(describing: translatedData))")
        if modeSwitchTypes == blockMode {
            modeSwitchButton.setImage(UIImage(named: lineMode), for: .normal)
            if let data = translatedData.line {
                if data.translatedText.count > 0 {
                    UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                    
                    for each in self.iTTServerViewModel.blockModeTextViewList {
                        each.view.removeFromSuperview()
                    }
                    updateView()
                } else {
                    activity.showLoading(view: self.view)
                    if let detectedData = self.iTTServerViewModel.detectedJSON {
                        self.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: lineMode, isFromHistoryVC: fromHistoryVC)
                        UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                    }
                }
            }
        } else {
            modeSwitchButton.setImage(UIImage(named: blockMode), for: .normal)
            if let data = translatedData.block {
                if data.translatedText.count > 0 {
                    UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                    for each in self.iTTServerViewModel.lineModetTextViewList {
                        each.view.removeFromSuperview()
                    }
                    updateView()
                } else {
                    activity.showLoading(view: self.view)
                    if let detectedData = self.iTTServerViewModel.detectedJSON {
                        self.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: blockMode, isFromHistoryVC: fromHistoryVC)
                        UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                    }
                }
            }
        }
    }
    
    @objc func backButtonEventListener(_ button: UIButton) {
        if fromHistoryVC {
            self.navigationController?.popViewController(animated: true)
        } else {
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    func setupModeSwitchButton() {
        NSLayoutConstraint.activate([
            modeSwitchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modeSwitchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:20),
            modeSwitchButton.heightAnchor.constraint(equalToConstant: 35),
            modeSwitchButton.widthAnchor.constraint(equalToConstant: 35)
        ])
        modeSwitchButton.layer.cornerRadius = 17.5
        modeSwitchButton.layer.masksToBounds = true
    }
    
    func setupBackButton(_ view: UIView) {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:20),
            backButton.heightAnchor.constraint(equalToConstant: 35),
            backButton.widthAnchor.constraint(equalToConstant: 35)
        ])
        backButton.layer.cornerRadius = 17.5
        backButton.layer.masksToBounds = true
    }
    
    func setUpImageViewConstraint() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let xConstraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self.cameraImageView, attribute: .centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self.cameraImageView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([xConstraint, yConstraint])
    }
    
}

extension CaptureImageProcessVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cameraImageView
    }
    
}


extension CaptureImageProcessVC: LoaderDelegate{
    
    func showLoader() {
        DispatchQueue.main.async { [self] in
            activity.showLoading(view: self.view)
        }
    }
    
    func hideLoader() {
        activity.hideLoading()
    }
}

//MARK: - CameraTTSDialogProtocol

extension CaptureImageProcessVC: CameraTTSDialogProtocol {
    func removeDialogEvent() {
        self.stopTTS()
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(backButton)
            setupBackButton(view)
        }
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(modeSwitchButton)
            setupModeSwitchButton()
        }
    }
    
    func cameraTTSDialogToPlaybutton() {
        playNative = false
        if(!isSpeaking){
            playTTS()
        }else{
            stopTTS()
        }
    }
    
    func cameraTTSDialogFromPlaybutton() {
        playNative = true
        if(!isSpeaking){
            playTTS()
        }else{
            stopTTS()
        }
    }
    
    func cameraTTSDialogShowContextMenu() {
        self.view.addSubview(cameraTTSContextMenu)
    }
    func shareTranslation(){
        let sharedData = "Translated language: \(gNativeLanguage)\n" + "\(toLanguage) \n\n" +
        "Original language: \(fromLanguage)\n" + "\(gTranslateLanguage)"

        let dataToSend = [sharedData]

        PrintUtility.printLog(tag: TAG, text: "sharedData \(sharedData)")
        let activityViewController = UIActivityViewController(activityItems: dataToSend, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

//MARK: - CameraTTSContextMenuProtocol

extension CaptureImageProcessVC: CameraTTSContextMenuProtocol {
    func cameraTTSContextMenuSendMail() {
        // Send an email implementaiton goes here
        PrintUtility.printLog(tag: "TAG", text: "Share in Camera")
        self.dismiss(animated: true, completion: nil)
        shareTranslation()
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension CaptureImageProcessVC : TTSResponsiveViewDelegate {
    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
        PrintUtility.printLog(tag: TAG, text: " speaking: \(isSpeaking)")
    }
    
    func onVoiceEnd() { }
    
    func onReady() {}
}
