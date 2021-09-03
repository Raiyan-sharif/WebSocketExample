//
//  SlideMenuViewModel.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/2/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit
class MenuViewModel {

    var datas: [MenuModel] = [MenuModel]()
    var slideMenuItemNames = ["Settings", "Camera"]
    var slideMenuIconNames = ["icon_menu_settings", "icon_menu_camera"]
    var reloadCollectionView: (()->())?

    private var cellViewModels: [SlideMenuListCellViewModel] = [SlideMenuListCellViewModel]() {
        didSet {
            self.reloadCollectionView?()
        }
    }

    func getData(){
        var data = [MenuModel]()
        if !UserDefaultsUtility.getBoolValue(forKey: kUserDefaultIsMenuFavorite) {
            slideMenuItemNames.append("Favorite")
            slideMenuIconNames.append("icon_menu_favorite")
        }
        for position in 0..<slideMenuIconNames.count {
            data.append(MenuModel(menuItemLabel: slideMenuItemNames[position], menuItemImageName: slideMenuIconNames[position]))
        }
        createCell(datas: data)
    }



    var numberOfCells: Int {
        return cellViewModels.count
    }

    func getCellViewModel( at indexPath: IndexPath ) -> SlideMenuListCellViewModel {
        return cellViewModels[indexPath.item]
    }

    func createCell(datas: [MenuModel]){
        self.datas = datas
        var vms = [SlideMenuListCellViewModel]()
        for data in datas {
            vms.append(SlideMenuListCellViewModel(menuItemImageName: data.menuItemImageName, menuItemLabel: data.menuItemLabel))
        }
        cellViewModels = vms
    }
}

struct SlideMenuListCellViewModel {
    let menuItemImageName: String
    let menuItemLabel: String
}
