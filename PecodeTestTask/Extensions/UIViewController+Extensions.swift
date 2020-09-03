//
//  UIViewController+Extensions.swift
//  PecodeTestTask
//
//  Created by Денис Данилюк on 03.09.2020.
//

import UIKit


extension UIViewController {
    
    class var identifier: String {
        return String(describing: self)
    }
}
