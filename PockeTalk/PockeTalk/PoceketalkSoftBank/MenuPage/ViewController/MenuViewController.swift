//
//  SlideMenuViewController.swift
//  PockeTalk
//

import UIKit


class MenuViewController: BaseViewController {

    @IBOutlet weak var mSlideMenuCollectionView: UICollectionView!
    private let sectionInsets = UIEdgeInsets(top: 0.0, left: 20.0, bottom: 0.0, right: 20.0)
    private let itemsPerRow: CGFloat = 2
    var slideMenuViewModel = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        initViewModel()
        // Do any additional setup after loading the view.
    }

    func initViewModel() {
        slideMenuViewModel.reloadCollectionView = {
            DispatchQueue.main.async {
                self.mSlideMenuCollectionView.reloadData()
            }
        }
        slideMenuViewModel.getData()
    }

    @IBAction func onPressBackButton(_ sender: UIButton) {
        navigationController?.popToViewController(ofClass: HomeViewController.self)
    }

}

//MARK: - UICollectionViewDataSource

extension MenuViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slideMenuViewModel.numberOfCells;
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MenuCollectionViewCell.self), for: indexPath) as? MenuCollectionViewCell else {
            fatalError("Cell not exists in storyboard")
        }
        let cellVM = slideMenuViewModel.getCellViewModel( at: indexPath )
        cell.menuItemImageView.image = UIImage.init(named: cellVM.menuItemImageName)
        cell.menuItemLabel.text = cellVM.menuItemLabel.localiz()
        cell.menuItemLabel.textColor = UIColor.white
        return cell;
    }
    
}

//MARK: - UICollectionViewDelegate

extension MenuViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let menuType = MenuItemType(rawValue: indexPath.item) else {
            return
        }
        switch menuType {
        case .settings:
            let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
            if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
                self.navigationController?.pushViewController(settinsViewController, animated: true)
            }
        case .camera:
            let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
            
            //TODO change CaptureImageProcessVC to CameraViewController to capture image. This change is made to run on simulator
            if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
                self.navigationController?.pushViewController(cameraViewController, animated: true)
            }
        case .favorite:
            PrintUtility.printLog(tag: "INDEXPATH", text:"\(indexPath.item)")
        default:
            break
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension MenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow

        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
