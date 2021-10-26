//
//  CameraHistoryViewController.swift
//  PockeTalk
//
//  Created by BJIT LTD on 15/9/21.
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(true)
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
    
    @IBAction func backButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHistoryImages() {
        self.viewModel.fetchCameraHistoryImages()
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
            self.navigationController?.pushViewController(vc, animated: true)
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
            self.navigationController?.pushViewController(vc, animated: true)
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
