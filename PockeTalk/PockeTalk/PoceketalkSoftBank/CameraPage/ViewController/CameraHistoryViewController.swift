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
        
    private let viewModel = CameraHistoryViewModel()

    
    @IBOutlet weak var collectionView: UICollectionView!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.viewDidLoad(self)
        getHistoryImages()
        setUpViews()
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
    
    
    
}

extension CameraHistoryViewController: CameraHistoryViewModelDelegates {
    func updateViewWithImages() {
        DispatchQueue.main.async { [self] in
            collectionView.reloadData()
        }
    }
    
    
}
