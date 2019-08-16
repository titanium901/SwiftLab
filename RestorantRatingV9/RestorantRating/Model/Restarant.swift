//
//  Restarant.swift
//  RestorantRating
//
//  Created by Yury Popov on 02/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit
import Firebase
//в прошлой версии  + NSCoding
class Restarant {
    var name = ""
    var note = ""
    var image = ""
    var staff = ""
    var foto = ""
    var location = ["latitude": "", "longitude": ""]
    var latitude: Double = 0
    var longitude: Double = 0
    var ref: DatabaseReference?
    
    init(name: String, note: String, image: String, staff: String, foto: String, location: [String : String]) {
        self.name = name
        self.note = note
        self.image = image
        self.staff = staff
        self.foto = foto
        self.location = location
        self.ref = nil
    }
    
    init(snapshot: DataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        note = snapshotValue["note"] as! String
        image = snapshotValue["image"] as! String
        staff = snapshotValue["staff"] as! String
        foto = snapshotValue["foto"] as! String
        latitude = snapshotValue["latitude"] as! Double
        longitude = snapshotValue["longitude"] as! Double

        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "note": note,
            "image": image,
            "staff": staff,
            "foto": foto,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
    
    
    
//    init(name: String, image: String, note: String) {
//        self.name = name
//        self.note = note
//        self.image = image
//    }
    
//    required init?(coder aDecoder: NSCoder) {
//        name = aDecoder.decodeObject(forKey: "Name") as! String
//        note = aDecoder.decodeObject(forKey: "Note") as! String
//        image = aDecoder.decodeObject(forKey: "Image") as! String
//        staff = aDecoder.decodeObject(forKey: "Staff") as! String
//        foto = aDecoder.decodeObject(forKey: "Foto") as! String
//        location = aDecoder.decodeObject(forKey: "Location") as! Dictionary
//
//        super.init()
//    }
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: "Name")
//        aCoder.encode(note, forKey: "Note")
//        aCoder.encode(image, forKey: "Image")
//        aCoder.encode(staff, forKey: "Staff")
//        aCoder.encode(foto, forKey: "Foto")
//        aCoder.encode(location, forKey: "Location")
//
//    }
}
