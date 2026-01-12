//
//  PaddingLabel.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import UIKit

final class PaddingLabel: UILabel {

    var insets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
}
