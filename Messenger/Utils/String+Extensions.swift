//
//  Utils.swift
//  Messenger
//
//  Created by Alena on 5/12/17.
//  Copyright © 2017 Alena Babykina. All rights reserved.
//

import AVFoundation

extension String {
    
    func isValidEmail() -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailTest.evaluate(with: self)
        }
    
}

