//
//  UIActivityIndicator+Extensions.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 05.09.2020.
//

import UIKit


extension UIActivityIndicatorView {
    
    func stopAndHide() {
        DispatchQueue.main.async {
            self.stopAnimating()
            self.isHidden = true
        }
    }
    
    func startAndShow() {
        DispatchQueue.main.async {
            self.startAnimating()
            self.isHidden = false
        }
    }
    
}
