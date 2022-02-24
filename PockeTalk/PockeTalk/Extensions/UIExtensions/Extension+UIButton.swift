//
//  Extension+UIButton.swift
//  PockeTalk
//

import UIKit

extension UIButton {
    func addRightIcon(image: UIImage, edgeInsetRight: CGFloat, width: CGFloat, height: CGFloat, leadingAnchor: CGFloat) {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        titleEdgeInsets.right += edgeInsetRight

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.titleLabel!.trailingAnchor, constant: leadingAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.titleLabel!.centerYAnchor, constant: 1),
            imageView.widthAnchor.constraint(equalToConstant: width),
            imageView.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    func setButtonAttributes(cornerRadius: CGFloat? = nil, title: String? = nil, backgroundColor: UIColor? = nil){
        self.layer.cornerRadius = cornerRadius ?? 0.0
        self.setTitle(title ?? "", for: .normal)
        self.backgroundColor = backgroundColor ?? UIColor()
    }
}
