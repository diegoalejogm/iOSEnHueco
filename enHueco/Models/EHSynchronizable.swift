//
//  EHObject.swift
//  enHueco
//
//  Created by Diego on 9/16/15.
//  Copyright © 2015 Diego Gómez. All rights reserved.
//

import Foundation

class EHSynchronizable: NSObject, NSCoding
{
    let ID: String
    var lastUpdatedOn: NSDate
    
    init(ID: String, lastUpdatedOn: NSDate)
    {
        self.ID = ID
        self.lastUpdatedOn = lastUpdatedOn
    }
    
    required init?(coder decoder: NSCoder)
    {
        guard
            let ID = decoder.decodeObjectForKey("ID") as? String,
            let lastUpdatedOn = decoder.decodeObjectForKey("lastUpdatedOn") as? NSDate
        else
        {
            self.ID = ""
            self.lastUpdatedOn = NSDate()
            
            super.init()
            return nil
        }
        
        self.ID = ID
        self.lastUpdatedOn = lastUpdatedOn
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder)
    {
        coder.encodeObject(ID, forKey: "ID")
        coder.encodeObject(lastUpdatedOn, forKey: "lastUpdatedOn")
    }
}