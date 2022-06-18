//
//  UITextField + border.swift
//  VIPERSample
//
//  Created by Hikaru Kuroda on 2022/06/18.
//

import Foundation
import UIKit

class PaddingTextField: UITextField {

    private var insets: UIEdgeInsets

    init(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        self.insets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)

        super.init(frame: .zero)

        addBorder()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: insets)
    }

    private func addBorder() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 4
    }
}
