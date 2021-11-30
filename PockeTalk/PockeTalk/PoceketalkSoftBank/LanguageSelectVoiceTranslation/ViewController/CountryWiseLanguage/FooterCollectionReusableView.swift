//
//  FooterCollectionReusableView.swift
//  PockeTalk
//
//  Created by BJIT on 1/12/21.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
    static let identifier = "FooterCollectionReusableView"
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
