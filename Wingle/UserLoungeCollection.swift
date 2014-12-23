//
//  UserLoungeCollection.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/06.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

public class UserLoungeCollection: NSObject {
    
    public var lounges: [Lounge]
    public var owner: PFUser?
    public var author: String?
    
    init(Owner: PFUser?, Author: String?) {
        lounges = [Lounge]()
        owner = Owner
        if let var auth = Author {
            author = auth
        } else {
            author = Owner?.username
        }
       
        super.init()
    }
    
    public func addLounge(lounge: Lounge){
        lounges.append(lounge)
    }
    
    public func loungeCount() -> Int {
        return lounges.count
    }
    
    public func loungeAtIndex(index: Int) -> Lounge {
        return lounges[index]
    }
    
    public func removeLoungeAtIndex(index: Int){
        lounges[index].remove()
        lounges.removeAtIndex(index)
    }
    
    public func removeAll(){
        lounges.removeAll(keepCapacity: true)
    }
    
}
