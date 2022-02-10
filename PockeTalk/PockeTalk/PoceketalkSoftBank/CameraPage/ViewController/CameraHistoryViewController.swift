//
//  CameraHistoryViewController.swift
//  PockeTalk
//

import UIKit

class CameraHistoryViewController: BaseViewController {
    
    private let width = UIScreen.main.bounds.width
    private let leftSpecing:CGFloat = 16
    private let rightSpecing:CGFloat = 16
    private let totalSub:CGFloat = 48
    
    let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
    private let viewModel = CameraHistoryViewModel()
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.viewDidLoad(self)
        getHistoryImages()
        setUpViews()
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTappedEvent))
        collectionView.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(backButton)
            //setupBackButton()
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
        removeFloatingButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpViews() {
        
        collectionView.delegate = self
        self.collectionView.collectionViewLayout = collectionViewLayout()
        
    }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: leftSpecing, bottom: 0, right: rightSpecing)
        let secHeight = width / 2
        layout.itemSize = CGSize(width: (width - totalSub) / 2, height: secHeight*1.2)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        
        return layout
        
    }
    
    @objc func backButtonEventListener(_ button: UIButton) {
        let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    func getHistoryImages() {
        self.viewModel.fetchCameraHistoryImages(size: 0)
    }
    
    @objc func longTappedEvent(recognizer: UILongPressGestureRecognizer)  {
        if let indexPath = self.collectionView?.indexPathForItem(at: recognizer.location(in: self.collectionView)) {
            
            //let cell = self.collectionView?.cellForItem(at: indexPath)

            if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraHistoryPopUPViewController.self)) as? CameraHistoryPopUPViewController {
                if let id = self.viewModel.cameraHistoryImages[indexPath.item].dbID {
                    vc.id = id
                }
                vc.index = indexPath.item
                vc.delegate = self
                vc.modalPresentationStyle = .overFullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            PrintUtility.printLog(tag: "CameraHistoryViewController", text: "Tapped on history image")
        }
    }

    
}

extension CameraHistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.cameraHistoryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CameraHistoryCell", for: indexPath) as! CameraHistoryCollectionViewCell
        
        cell.historyImage.image = self.viewModel.cameraHistoryImages[indexPath.item].image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == self.viewModel.cameraHistoryImages.count - 1 ) { //it's your last cell
            //Load more data & reload your collection view
            self.viewModel.fetchCameraHistoryImages(size: self.viewModel.cameraHistoryImages.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
            if let image = self.viewModel.cameraHistoryImages[indexPath.item].image {
                vc.image = image
                vc.fromHistoryVC = true
                vc.cameraHistoryImageIndex = indexPath.row
                if let id = self.viewModel.cameraHistoryImages[indexPath.item].dbID {
                    vc.historyID = id
                }
            }
            
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    func removeFloatingButton() {

        if let backButtonView = UIApplication.shared.keyWindow, backButton.isDescendant(of: backButtonView) {
            backButton.removeFromSuperview()
        }
    }

    
}

extension CameraHistoryViewController: CameraHistoryViewModelDelegates {
    func updateViewWithImages() {
        DispatchQueue.main.async { [self] in
            collectionView.reloadData()
        }
    }
}

extension CameraHistoryViewController: CameraHistoryPopUPDelegates {
    func deleteImageFromFistoryPopUp(index: Int, id: Int64) {
        if (self.viewModel.cameraHistoryImages[index].dbID == id) {
            self.viewModel.cameraHistoryImages.remove(at: index)
            self.collectionView.reloadData()
            if self.viewModel.cameraHistoryImages.count == 0 {
                let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    
    func openImageFromHistoryPopUp(index: Int) {
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
            if let image = self.viewModel.cameraHistoryImages[index].image {
                vc.image = image
                vc.fromHistoryVC = true
                vc.cameraHistoryImageIndex = index
                if let id = self.viewModel.cameraHistoryImages[index].dbID {
                    vc.historyID = id
                }
            }
            
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }

    }
    
    func shareImageFromHistoryPopUp(id: Int64) {
        
        let text = self.viewModel.getIDWiseTranslatedAndDetectedData(id: id)
        let dataToSend = [text]

        let activityViewController = UIActivityViewController(activityItems: dataToSend, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    

}
