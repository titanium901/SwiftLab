//
//  Restarant.swift
//  RestorantRating
//
//  Created by Yury Popov on 02/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class Restarant: NSObject, NSCoding {
    var name = ""
    var note = ""
    var image = ""
    var staff = ""
    
    override init() {
        super.init()
    }
    
//    init(name: String, image: String, note: String) {
//        self.name = name
//        self.note = note
//        self.image = image
//    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        note = aDecoder.decodeObject(forKey: "Note") as! String
        image = aDecoder.decodeObject(forKey: "Image") as! String
        staff = aDecoder.decodeObject(forKey: "Staff") as! String
        super.init()
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(note, forKey: "Note")
        aCoder.encode(image, forKey: "Image")
        aCoder.encode(staff, forKey: "Staff")
    }
}
