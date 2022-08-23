//
//  CaptureImageProcessVC.swift
//  PockeTalk
//

import UIKit
import CallKit
import WXImageCompress
import MarqueeLabel

class CaptureImageProcessVC: BaseViewController {

    private let TAG = "\(CaptureImageProcessVC.self)"

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidth: NSLayoutConstraint!

    private let iTTServerViewModel = ITTServerViewModel()
    private let cameraHistoryViewModel = CameraHistoryViewModel()
    var socketManager = SocketManager.sharedInstance

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
    var nativeLanguageItem:LanguageItem?
    var targetLanguageItem:LanguageItem?
    var playNative = true
    var isClickable = true
    var isLoading = Bool()

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

    var originalImage = UIImage()
    var image = UIImage()
    var cropFrameWidth = CGFloat()
    var cropFrameHeight = CGFloat()
    var maxCropFrameHeight = CGFloat()
    var maxCropFrameWidth = CGFloat()
    var callObserver = CXCallObserver()
    //var image = UIImage(named: "vv")
    var urlStrings:[String] = []
    var multipartAudioPlayer: MultipartAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        socketManager.connect()
        UserDefaults.standard.set(false, forKey: "modeSwitchState")
        UserDefaults.standard.set(false, forKey: isTransLationSuccessful)

        PrintUtility.printLog(tag: TAG, text: "screen maxCropFrameHeight: \(Int(maxCropFrameHeight)), \(Int(maxCropFrameWidth))")
        callObserver.setDelegate(self, queue: nil)
        cameraImageView.center = self.view.center
        self.iTTServerViewModel.viewDidLoad(self)
        self.iTTServerViewModel.socketManager = socketManager
        fromHistoryVC ? setUpViewForHistoryVC() : setUpViewForCapturedImage()

        scrollView.delegate = self
        scrollView.maximumZoomScale = 3.0
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollView.addGestureRecognizer(scrollViewTap)

        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,            object: nil)
        multipartAudioPlayer = MultipartAudioPlayer(controller: self, delegate: self)
    }

    @objc func applicationDidBecomeActive() {
        let isTransLateSuccessful = UserDefaults.standard.value(forKey: isTransLationSuccessful) as! Bool
        let modeSwitchState = UserDefaults.standard.value(forKey: "modeSwitchState") as! Bool
        PrintUtility.printLog(tag: "modeSwitchState: ", text: "\(modeSwitchState)")
        if iTTServerViewModel.timer != nil {
            iTTServerViewModel.timer?.invalidate()
            iTTServerViewModel.timer = nil
        }
        isClickable = true
        backButton.isUserInteractionEnabled = true
        if ((modeSwitchState == false) &&  (isTransLateSuccessful == false)) {

            if isLoading == false {
                PrintUtility.printLog(tag: "is loading ", text: "False ")
            } else {
                if self.fromHistoryVC == true {
                    //
                } else {
                    startConfirmController()
                }
                ActivityIndicator.sharedInstance.hide()
            }
        } else if ((modeSwitchState == true) && (isTransLateSuccessful == false))  {

            if self.fromHistoryVC{
                let translatedData: TranslatedTextJSONModel? = CameraHistoryDBModel().getTranslatedData(id: historyID)

                if let translatedData = translatedData {
                    let blockData = translatedData.block?.translatedText
                    let lineData = translatedData.line?.translatedText

                    if blockData!.count > 0 && lineData!.count == 0{
                        modeSwitchButton.setImage(UIImage(named: blockMode), for: .normal)
                        UserDefaults.standard.set(blockMode, forKey: modeSwitchType)

                    } else {
                        modeSwitchButton.setImage(UIImage(named: lineMode), for: .normal)
                        UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                    }
                }
            } else {
                ActivityIndicator.sharedInstance.hide()
                modeSwitchButtonEventListener(modeSwitchButton)
            }
        }
    }

    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
        AudioPlayer.sharedInstance.stop()
    }

    func setUpViewForCapturedImage() {

        let heightInPoints = image.size.height
        let widthInPoints = image.size.width
        PrintUtility.printLog(tag: "Captured Image heightInPoints: \(heightInPoints)", text: ", widthInPoints: \(widthInPoints)")

        let imgData: NSData = image.jpegData(compressionQuality: 1)! as NSData
        PrintUtility.printLog(tag: TAG, text: "Size of Original Image: \(imgData.count) bytes")

        //image = UIImage(data: image.jpeg(.highest)!)!
        image = image.wxCompress()

        let imgData1: NSData = image.jpegData(compressionQuality: 1)! as NSData
        PrintUtility.printLog(tag: TAG, text: "Size of Compressed Image: \(imgData1.count) bytes")

        let heightInPoints1 = image.size.height
        let widthInPoints1 = image.size.width
        PrintUtility.printLog(tag: "Compressed Image heightInPoints: \(heightInPoints1)", text: ", widthInPoints: \(widthInPoints1)")

        let window = UIApplication.shared.keyWindow
        let topPadding = window?.safeAreaInsets.top ?? 0
        let bottomPadding = window?.safeAreaInsets.bottom ?? 0

        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height - CGFloat(topPadding + bottomPadding)

        PrintUtility.printLog(tag: TAG, text: "screen Width: \(screenWidth), \(screenHeight)")

        //image = resizeImage(image: image)
        var resizeWidth: Int = Int(image.size.width)
        var resizeHeight: Int = Int(image.size.height)

        if(image.size.width > CGFloat(screenWidth)) {
            resizeWidth = Int(screenWidth)
        }

        if(image.size.height > CGFloat(screenHeight)){
            resizeHeight = Int(screenHeight)
        }

        PrintUtility.printLog(tag: TAG, text: "screen >>>: \(resizeWidth), \(resizeHeight)")
        if Int(cropFrameWidth) < Int(maxCropFrameWidth) {
            resizeWidth = Int(cropFrameWidth)
        }
        if Int(cropFrameHeight) < Int(maxCropFrameHeight){
            resizeHeight = Int(cropFrameHeight)
        }

        PrintUtility.printLog(tag: TAG, text: "screen: \(resizeWidth), \(resizeHeight)")
        let image1 = resizeImage(image: image, targetSize: CGSize.init(width: resizeWidth, height: resizeHeight))   // resized bitmap
        //UIImageWriteToSavedPhotosAlbum(image1, nil, nil, nil)
        let heightInPoints2 = image.size.height
        let widthInPoints2 = image.size.width

        PrintUtility.printLog(tag: "Resized Image1 heightInPoints: \(image1.size.height)", text: ", widthInPoints: \(image1.size.width)")

        let imgData2: NSData = image.jpegData(compressionQuality: 1)! as NSData
        PrintUtility.printLog(tag: TAG, text: "Size of Resized Image: \(imgData2.count) bytes")

        //        imageWidth = imageWidth
        //        imageHeight = imageHeight * 3
        let image2 = resizeImage(image: image, targetSize: CGSize(width: cropFrameWidth, height: cropFrameHeight))
        PrintUtility.printLog(tag: TAG, text: "screen Frame imageWidth: \(Int(cropFrameWidth)), imageHeight: \(Int(cropFrameHeight))")        //UIImageWriteToSavedPhotosAlbum(image2, nil, nil, nil)
        imageView.image = image1

        self.iTTServerViewModel.capturedImage = image1
        self.iTTServerViewModel.imageWidth = cropFrameWidth
        self.iTTServerViewModel.imageHeight = cropFrameHeight

        imageView.frame = CGRect(x: 0, y: 0, width: cropFrameWidth  , height:  cropFrameHeight)
        cameraImageView.addSubview(imageView)
        setUpImageViewConstraint()

        self.iTTServerViewModel.getITTData(from: image1) { [weak self] (data, error) in

            if error != nil {
                if error?.localizedDescription == "error_no_text_detected"{
                    PrintUtility.printLog(tag: self!.TAG, text: "Error message: \(error!.localizedDescription)")
                    self!.showErrorAlert(message: "error_no_text_detected".localiz())
                }

                if error?.localizedDescription == "error_network"{
                    PrintUtility.printLog(tag: self!.TAG, text: "Error message: \(error!.localizedDescription)")
                    self!.showErrorAlert(message: "error_network".localiz())
                }

                PrintUtility.printLog(tag: "ERROR :", text: "\(String(describing: error))")
            } else {
                if let detectedData = data {
                    if Reachability.isConnectedToNetwork() {
                        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
                        if(modeSwitchTypes == nil) {
                            UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                        }
                        self?.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: modeSwitchTypes ?? blockMode, isFromHistoryVC: self!.fromHistoryVC)
                    } else {
                        GlobalMethod.showNoInternetAlert()
                    }
                }
            }
        }
    }

    func setUpViewForHistoryVC() {
        isLoading = false
        imageView.image = image
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width  , height:  image.size.height)
        cameraImageView.addSubview(imageView)
        setUpImageViewConstraint()
        self.iTTServerViewModel.capturedImage = image
        PrintUtility.printLog(tag: "row index", text: "\(historyID)")
        self.iTTServerViewModel.historyID = historyID

        showHistoryData(historyID: historyID)
    }
    deinit{
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        ttsResponsiveView.removeObserver()
    }

    func showHistoryData(historyID: Int64) {
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
                UserDefaults.standard.set(true, forKey: isTransLationSuccessful)
                self.iTTServerViewModel.getTextviewListForCameraHistory(detectedData: detectedData, translatedData: translatedData)
            } else if (blockData!.count>0) {
                if modeSwitchTypes != blockMode {
                    UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                }
                UserDefaults.standard.set(translatedData.block?.languageCodeTo, forKey: KCameraTargetLanguageCode)
                self.iTTServerViewModel.getSelectedModeTextViewListFromHistory(detectedData: detectedData, translatedData: translatedData, selectedMode: blockMode)

            } else if (lineData!.count > 0) {
                if modeSwitchTypes != lineMode {
                    UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                }
                UserDefaults.standard.set(translatedData.line?.languageCodeTo, forKey: KCameraTargetLanguageCode)
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
            text = text.replacingOccurrences(of: "\"", with: "")
        }else{
            lang = targetLang
            text = targetText
            text = text.replacingOccurrences(of: "\"", with: "")
        }

        let languageManager = LanguageSelectionManager.shared
        if(languageManager.hasTtsSupport(languageCode: lang)){
            PrintUtility.printLog(tag: TAG,text: "checkTtsSupport has TTS support \(lang)")
            PrintUtility.printLog(tag: "Translate ", text: "lang: \(lang) text: \(text)" )

            if let _ = LanguageEngineParser.shared.getTtsValueByCode(code:lang){
                if(!isSpeaking){
                    urlStrings = []
                    getTtsValue(langCode: lang)
                    ttsResponsiveView.checkSpeakingStatus()
                    ttsResponsiveView.setRate(rate: rate)
                    ttsResponsiveView.TTSPlay(voice: voice,text: text.components(separatedBy: .newlines).joined())
                }
            }else{
                AudioPlayer.sharedInstance.delegate = self
                if !AudioPlayer.sharedInstance.isPlaying{
                    AudioPlayer.sharedInstance.getTTSDataAndPlay(translateText: text, targetLanguageItem: lang, tempo: "normal")
                }
            }
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
        multipartAudioPlayer?.stop()
        AudioPlayer.sharedInstance.stop()
    }

    /// Retreive tts value from respective language code
    func getTtsValue (langCode: String) {
        let item = LanguageEngineParser.shared.getTtsValue(langCode: langCode)
        self.voice = item.voice
        self.rate = item.rate
        PrintUtility.printLog(tag: "getTtsValue ", text: "voice: \(voice) rate: \(rate)" )

    }

    func showErrorAlert(message: String){
        DispatchQueue.main.async {
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithoutTitleWithOkButtonAction(message: message) {
                if self.fromHistoryVC == true {
                    print("no translation")
                } else {
                    self.startConfirmController()
                }
            }
            self.present(alert, animated: true, completion: nil)
        }

    }

    open var onCompletion: CameraViewCompletion?

    private func startConfirmController() {
        PrintUtility.printLog(tag: "original Image", text: "\(originalImage)")
        let vc = ImageCroppingViewController(image: originalImage, croppingParameters: CropUtils(enabled: true, resizeable: true, dragable: true, minimumSize: CGSize(width: 80, height: 80)))
        vc.fromImageProcessVC = true
        vc.onCompletion = { [weak self] image, asset in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }

            guard let image = image else {
                return
            }
            self?.onCompletion?(image, asset)
            self?.onCompletion = nil
        }

        let transition = CATransition()
        transition.duration = 0.4
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    func showNetworkError() {
        hideLoader()
        self.showErrorAlert(message: "error_network".localiz())
    }

    func showErrorAlert() {
        hideLoader()
        showErrorAlert(message: "can_not_translate".localiz())
    }

    func updateView() {
        DispatchQueue.main.async {[self] in
            UserDefaults.standard.set(true, forKey: isTransLationSuccessful)
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
                    textViews[i].view.backgroundColor = UIColor(rgb: 0x000000).withAlphaComponent(0.5)
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

        //backButton.isUserInteractionEnabled = true
    }

    func showTTSDialog(nativeText: String, nativeLanguage: String, translateText: String, translateLanguage: String){
        cameraTTSDiaolog.fromLanguageLabel.text = nativeText

        if (nativeLanguage == BURMESE_MY_LANGUAGE_CODE) {
            cameraTTSDiaolog.fromLanguageLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
        }else {
            cameraTTSDiaolog.fromLanguageLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
        }
        cameraTTSDiaolog.fromLanguageLabel.textAlignment = .center

        let languageManager = LanguageSelectionManager.shared
        // Hide or show play button accoring to tts supported and not supported language
        if(languageManager.hasTtsSupport(languageCode: nativeLanguage)) {
            cameraTTSDiaolog.fromLangPlayButton.isHidden = false
        } else {
            cameraTTSDiaolog.fromLangPlayButton.isHidden = true
        }
        if(languageManager.hasTtsSupport(languageCode: translateLanguage)){
            cameraTTSDiaolog.toLangPlayButton.isHidden = false
        } else {
            cameraTTSDiaolog.toLangPlayButton.isHidden = true
        }

        //TODO remove this code after Language detection API implementation
        var nativeLangItem: LanguageItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode:systemLanguageCodeEN)!
        if nativeLanguage == LANGUAGE_CODE_UND || nativeLanguage == CHINESE_LANGUAGE_CODE_ZH {
            cameraTTSDiaolog.fromTranslateLabel.text = nativeLanguage
        }
        else {
            nativeLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: nativeLanguage)!
            cameraTTSDiaolog.fromTranslateLabel.text = getTTSDialogLanguageName(languageItem: nativeLangItem)
        }

        cameraTTSDiaolog.toLanguageLabel.text = translateText

        if (translateLanguage == BURMESE_MY_LANGUAGE_CODE) {
            cameraTTSDiaolog.toLanguageLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
        }else {
            cameraTTSDiaolog.toLanguageLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
        }

        cameraTTSDiaolog.toLanguageLabel.textAlignment = .center
        fromLanguage = nativeLangItem.sysLangName
        toLanguage = translateText

        let targetLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: translateLanguage)
        cameraTTSDiaolog.toTranslateLabel.text = getTTSDialogLanguageName(languageItem: targetLangItem!)
        gNativeLanguage = targetLangItem!.sysLangName
        gTranslateLanguage = nativeText
        self.nativeText = nativeText
        self.nativeLang = nativeLanguage
        self.targetText = translateText
        self.targetLang = translateLanguage
        self.nativeLanguageItem = nativeLangItem
        self.targetLanguageItem = targetLangItem
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
        if(!isSpeaking && !AudioPlayer.sharedInstance.isPlaying){
            playTTS()
        }
        else{
            AudioPlayer.sharedInstance.stop()
            stopTTS()
        }
    }

    @objc func actionTappedOnTargetTTSText(sender:UITapGestureRecognizer) {
        //ttsResponsiveView.isSpeaking()
        playNative = false
        if(!isSpeaking && !AudioPlayer.sharedInstance.isPlaying){
            playTTS()
        }else{
            AudioPlayer.sharedInstance.stop()
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
            //backButton.isUserInteractionEnabled = false
            setupBackButton(view)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callObserver.setDelegate(self, queue: nil)
        removeFloatingButton()
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        AudioPlayer.sharedInstance.stop()
        stopTTS()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        PrintUtility.printLog(tag: TAG, text: "viewDidDisappear")

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
        buttonModeSwitchLogEvent()
        UserDefaults.standard.set(true, forKey: "modeSwitchState")
        UserDefaults.standard.set(false, forKey: isTransLationSuccessful)
        socketManager.connect()
        let id = try? CameraHistoryDBModel().getMaxId()
        if !fromHistoryVC {
            self.iTTServerViewModel.historyID = Int64(id!)
            self.iTTServerViewModel.fromHistoryVC = false
        }

        self.iTTServerViewModel.historyID = fromHistoryVC ? historyID : Int64(id!)

        let translatedData = fromHistoryVC ? CameraHistoryDBModel().getTranslatedData(id: historyID) : CameraHistoryDBModel().getTranslatedData(id: Int64(id!))
        PrintUtility.printLog(tag: "TranslatedData.line count", text: "\(translatedData.block!.translatedText.count)")
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
                    if Reachability.isConnectedToNetwork() {
                        showLoader()
                        PrintUtility.printLog(tag: "Mode switch button action", text: "1111")
                        showLoader()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if let detectedData = self.iTTServerViewModel.detectedJSON {
                                self.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: lineMode, isFromHistoryVC: self.fromHistoryVC)
                                UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
                            }
                        }
                    } else {
                        GlobalMethod.showNoInternetAlert()
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
                    if Reachability.isConnectedToNetwork() {
                        showLoader()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            if let detectedData = self.iTTServerViewModel.detectedJSON {
                                self.iTTServerViewModel.getblockAndLineModeData(detectedData, _for: blockMode, isFromHistoryVC: self.fromHistoryVC)
                                UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                            }
                        }
                    } else {
                        GlobalMethod.showNoInternetAlert()
                    }
                }
            }
        }
    }

    @objc func backButtonEventListener(_ button: UIButton) {
        if isClickable {
            if fromHistoryVC {
                let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.popViewController(animated: false)
            } else {
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                PrintUtility.printLog(tag: "CaptureImageProcessVC", text: "\(viewControllers)")
                for viewController in viewControllers {
                    if viewController is HomeViewController {
                        let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                        self.view.window!.layer.add(transition, forKey: kCATransition)
                        self.navigationController?.popToViewController(viewController, animated: false)
                    }
                }
            }
        }
    }

    func setupModeSwitchButton() {
        NSLayoutConstraint.activate([
            modeSwitchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            modeSwitchButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:0),
            modeSwitchButton.heightAnchor.constraint(equalToConstant: 45),
            modeSwitchButton.widthAnchor.constraint(equalToConstant: 45)
        ])
        modeSwitchButton.layer.cornerRadius = 17.5
        modeSwitchButton.layer.masksToBounds = true
    }

    func setupBackButton(_ view: UIView) {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:0),
            backButton.heightAnchor.constraint(equalToConstant: 45),
            backButton.widthAnchor.constraint(equalToConstant: 45)
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

//MARK: - UIScrollViewDelegate
extension CaptureImageProcessVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cameraImageView
    }
}

//MARK: - LoaderDelegate
extension CaptureImageProcessVC: LoaderDelegate{
    func showLoader() {
        DispatchQueue.main.async { [self] in
            ActivityIndicator.sharedInstance.show()
            isClickable = false
            isLoading = true
            backButton.isUserInteractionEnabled = false
        }
    }

    func hideLoader() {
        socketManager.disconnect()
        ActivityIndicator.sharedInstance.hide()
        isClickable = true
        isLoading = false
        backButton.isUserInteractionEnabled = true
    }
}

//MARK: - CameraTTSDialogProtocol
extension CaptureImageProcessVC: CameraTTSDialogProtocol {
    func removeDialogEvent() {
        buttonBackLogEvent()
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
        if(!isSpeaking && !AudioPlayer.sharedInstance.isPlaying){
            playTTS()
        }else{
            AudioPlayer.sharedInstance.stop()
            stopTTS()
        }
    }

    func cameraTTSDialogFromPlaybutton() {
        playNative = true
        if(!isSpeaking && !AudioPlayer.sharedInstance.isPlaying){
            playTTS()
        }else{
            AudioPlayer.sharedInstance.stop()
            stopTTS()
        }
    }

    func cameraTTSDialogShowContextMenu() {
        buttonMenuLogEvent()
        stopTTS()
        self.view.addSubview(cameraTTSContextMenu)
    }

    func shareTranslation(){
        let sharedData = "Translated language: \(gNativeLanguage)\n" + "\(toLanguage) \n\n" +
        "Original language: \(fromLanguage)\n" + "\(gTranslateLanguage)"

        let dataToSend = [sharedData]

        PrintUtility.printLog(tag: TAG, text: "sharedData \(sharedData)")
        let activityViewController = UIActivityViewController(activityItems: dataToSend, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = { [weak self] (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            guard let `self` = self else {return}
            if completed, let activityString = activityType?.rawValue{
                self.cameraTranslateResultMenuShareLogEvent(activityString: activityString)
            }
        }

        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }

    func copyTextToClipBoard() {
        guard let target = targetLanguageItem, let native = nativeLanguageItem else {
            return
        }
        UIPasteboard.general.string = ""
        UIPasteboard.general.string = GlobalMethod.getClipBoardTextOfCameraTranslation(targetText, target, nativeText, native)
    }
}

//MARK: - CameraTTSContextMenuProtocol
extension CaptureImageProcessVC: CameraTTSContextMenuProtocol {
    func cameraTTSContextMenuSendMail() {
        // Send an email implementaiton goes here
        buttonShareLogEvent()
        PrintUtility.printLog(tag: "TAG", text: "Share in Camera")
        self.dismiss(animated: true, completion: nil)
        shareTranslation()
    }


    func cameraTTSContextMenuCancel() {
        buttonCancelLogEvent()
    }

    func cameraTTSContextMenuCopyText() {
        copyLogEvent()
        PrintUtility.printLog(tag: "CaptureImageProcessVC", text: "Copy text to clipboard")
        copyTextToClipBoard()
    }
}

//MARK: -  UIImage Extension
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

//MARK: -  TTSResponsiveViewDelegate
extension CaptureImageProcessVC : TTSResponsiveViewDelegate {
    func onMultipartUrlReceived(url: String) {
        if(!url.isEmpty){
            urlStrings.append(url)
        }
    }

    func onMultipartUrlEnd() {
        multipartAudioPlayer?.playMultipartAudio(urls: urlStrings)
    }

    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
        PrintUtility.printLog(tag: TAG, text: " speaking: \(isSpeaking)")
    }

    func onVoiceEnd() { }

    func onReady() {}
}

//MARK: -  CXCallObserverDelegate
extension CaptureImageProcessVC: CXCallObserverDelegate{
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        PrintUtility.printLog(tag: TAG, text: "callObserver")
        stopTTS()
        if call.hasConnected {
            stopTTS()
        }

        if call.isOutgoing {
            stopTTS()
        }

        if call.hasEnded {
            self.dismiss(animated: false, completion: nil)
        }

        if call.isOnHold {
            stopTTS()
        }
        AudioPlayer.sharedInstance.stop()
        //        TtsAlertController.ttsResponsiveView.stopTTS()
    }
}

//MARK: -  SocketManagerDelegate
extension CaptureImageProcessVC : SocketManagerDelegate{
    func faildSocketConnection(value: String) {
        PrintUtility.printLog(tag: TAG, text: value)
    }

    func getText(text: String) {
        //speechProcessingVM.setTextFromScoket(value: text)
        PrintUtility.printLog(tag: "TtsAlertController Retranslation: ", text: text)
    }

    func getData(data: Data) {}
}

//MARK: -  AudioPlayerDelegate
extension CaptureImageProcessVC :AudioPlayerDelegate{
    func didStartAudioPlayer() {}
    func didStopAudioPlayer(flag: Bool) {}
}

extension CaptureImageProcessVC : MultipartAudioPlayerProtocol{
    func onSpeakStart() {
        self.isSpeaking = true
    }

    func onSpeakFinish() {
        self.isSpeaking = false
    }

    func onError() {
        self.isSpeaking = false
    }
}

//MARK: - Google analytics log events
extension CaptureImageProcessVC {
    private func cameraTranslateResultMenuShareLogEvent(activityString: String) {
        analytics.translateResultMenuShare(screenName: analytics.cameraTranslationResultDetailsMenuShare,
                                           eventParamName: analytics.app,
                                           sharedAppName: activityString)
    }

    private func buttonModeSwitchLogEvent() {
        let modeState = UserDefaults.standard.string(forKey: modeSwitchType) == "lineMode" ? "line_mode" : "not"
        analytics.cameraResult(screenName: analytics.camTranslateResult,
                               button: analytics.buttonDisplayHistory,
                               mode: modeState)
    }

    private func buttonBackLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateResultDetail,
                            buttonName: analytics.buttonBack)
    }

    private func buttonMenuLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateResultDetail,
                            buttonName: analytics.buttonMenu)
    }

    private func buttonShareLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateResultDetailMenu,
                            buttonName: analytics.buttonShare)
    }

    private func copyLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateResultDetailMenu,
                            buttonName: analytics.buttonCopy)
    }

    private func buttonCancelLogEvent() {
        analytics.buttonTap(screenName: analytics.camTranslateResultDetailMenu,
                            buttonName: analytics.buttonCancel)
    }
}
