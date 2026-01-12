//
//  UIImageViewExtension.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 12/01/26.
//
import UIKit

extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
