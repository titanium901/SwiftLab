//
//  User.swift
//  GroceryList
//
//  Created by Sergey Dunaev on 01/08/2019.
//  Copyright © 2019 SwiftLab. All rights reserved.
//

import UIKit

struct User {
    
    let uid: String
    let email: String
    var photo: UIImage?
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
