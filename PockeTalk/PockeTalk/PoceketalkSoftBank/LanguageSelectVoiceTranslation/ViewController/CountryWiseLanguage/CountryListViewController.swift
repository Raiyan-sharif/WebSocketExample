//
//  CountryListViewController.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 8/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class CountryListViewController: UIViewController {

    @IBOutlet weak var viewEnglishName: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryListCollectionView: UICollectionView!
    var countryList = [CountryListItemElement]()
    var dataShowingAsEnlish = false
    var dataShowingLanguageCode = LanguageManager.shared.currentLanguage.rawValue
    let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
    @IBAction func onBackButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickOnEnglishButton(_ sender:UITapGestureRecognizer){
        print("\(CountryListViewController.self) Clickedn on english button")
        if dataShowingAsEnlish{
            dataShowingLanguageCode = sysLangCode
            countryList.removeAll()
            countryList = CountryWiseLanguageSelectionViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: dataShowingLanguageCode)!.countryList
            viewEnglishName.backgroundColor = .white
            dataShowingAsEnlish = false
            countryNameLabel.text = "Region".localiz()
        }else{
            dataShowingLanguageCode = systemLanguageCodeEN
            countryList.removeAll()
            countryList = CountryWiseLanguageSelectionViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: dataShowingLanguageCode)!.countryList
            dataShowingAsEnlish = true
            viewEnglishName.backgroundColor = ._skyBlueColor()
            countryNameLabel.text = "Region"
        }
        countryListCollectionView.reloadData()
    }
    
    fileprivate func configureCollectionView() {
        countryList.removeAll()
        countryList = CountryWiseLanguageSelectionViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: sysLangCode)!.countryList
        let layout = UICollectionViewFlowLayout()
        countryListCollectionView.collectionViewLayout = layout
        countryListCollectionView.register(CountryListCollectionViewCell.nib(), forCellWithReuseIdentifier: CountryListCollectionViewCell.identifier)
        countryListCollectionView.delegate = self
        countryListCollectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countryNameLabel.text = "Region".localiz()
        if sysLangCode == systemLanguageCodeEN{
            dataShowingAsEnlish = true
            viewEnglishName.isHidden = true
        }else{
            dataShowingAsEnlish = false
            viewEnglishName.isHidden = false
        }
        configureCollectionView()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clickOnEnglishButton(_:)))
        self.viewEnglishName.addGestureRecognizer(gesture)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CountryListViewController : UICollectionViewDelegate{

    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension CountryListViewController : UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let countryItem = countryList[indexPath.row] as CountryListItemElement
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryListCollectionViewCell", for: indexPath) as! CountryListCollectionViewCell
        var countryName = ""
        switch dataShowingLanguageCode {
            case systemLanguageCodeJP:
                countryName = countryItem.countryName.ja
            default:
                countryName = countryItem.countryName.en
        }
        cell.countryNameLabel.text = countryName
        cell.configureFlagImage(with: UIImage(named: countryItem.countryName.en)!)
        return cell
    }
    
}

extension CountryListViewController : UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        return CGSize(width: width, height: 140)
    }
}
