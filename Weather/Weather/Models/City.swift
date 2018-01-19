//
//  City.swift
//  Weather
//
//  Created by user134583 on 1/17/18.
//  Copyright © 2018 user134583. All rights reserved.
//

import Foundation

class City: NSObject, NSCoding {
    var name: String?
    var id: Int32
    
    init(json: NSDictionary) {
        self.name = json["name"] as? String
        self.id = json["id"] as! Int32
    }
    
    init(name: String, id: Int32) {
        self.name = name
        self.id = id
    }
    
    required convenience init? (coder decoder: NSCoder) {
        guard let name = decoder.decodeObject(forKey: "name") as? String
        else {return nil}
        
        let id = decoder.decodeInt32(forKey: "id")
        self.init(name: name, id: id)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encodeCInt(self.id, forKey: "id")
    }
}
