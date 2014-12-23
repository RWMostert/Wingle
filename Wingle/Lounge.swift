//
//  Lounge.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/06.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

public class Lounge: NSObject {
    
    public var name: String
    public var descriptor: String
    public var imageCount: Int
    public var images: [Image]
    public var PFImageObjects: [PFObject]
    public var author: PFUser
    public var parseObject: PFObject?
    public var isDeleted: Bool
    public var acl:[PFUser]
    
    init(Name: String, Description: String?, Author: PFUser) {
        
        name = Name
        if let descrip = Description? {
            descriptor = descrip
        } else {
            descriptor = ""
        }
        imageCount = 0
        images = [Image]()
        PFImageObjects = [PFObject]()
        author = Author
        isDeleted = false
        acl = [PFUser]()
        super.init()
    }
    
    init(parseObject: PFObject){
        
        name = parseObject["Name"] as String
        if let descrip = parseObject["Description"] as? String {
            descriptor = descrip
        } else {
            descriptor = ""
        }
        imageCount = 0
        images = [Image]()
        author = parseObject["Author"] as PFUser
        isDeleted = false
        self.parseObject = parseObject
        PFImageObjects = [PFObject]()
        acl = [PFUser]()
        acl.append(PFUser.currentUser())
        super.init()
        
        fetchImagesFromParse()
    }
    
    public func syncToParse(){
        println("Syncing to Parse")
        
        var newLounge = PFObject(className: "Lounge")
        newLounge["Name"] = name
        newLounge["Descriptor"] = descriptor
        newLounge["Author"] = author
        
        var groupACL = PFACL()
        
        // userList is an NSArray with the users we are sending this message to.
        for user in acl {
            groupACL.setReadAccess(true, forUser:user)
        }
        
        groupACL.setWriteAccess(true, forUser: author)
        
        newLounge.ACL = groupACL
        newLounge.saveInBackgroundWithBlock { (success, error: NSError!) -> Void in
            
        }
        parseObject = newLounge
    }
    
    public func syncToParseAndRefresh(vc: LoungesTableViewController){
        println("Syncing to Parse")
        
        var newLounge = PFObject(className: "Lounge")
        newLounge["Name"] = name
        newLounge["Descriptor"] = descriptor
        newLounge["Author"] = author
        var groupACL = PFACL()
        
        // userList is an NSArray with the users we are sending this message to.
        for user in acl {
            groupACL.setReadAccess(true, forUser:user)
        }
        
        groupACL.setReadAccess(true, forUser: author)
        groupACL.setWriteAccess(true, forUser: author)
        
        newLounge.ACL = groupACL

        newLounge.saveInBackgroundWithBlock { (success, error: NSError!) -> Void in
            self.parseObject = newLounge
            vc.refreshTableView()
        }
    }
    
    public func invitePFUser(Username: String){
        
        let query = PFUser.query()
        query.whereKey("username", equalTo: Username)
        query.getFirstObjectInBackgroundWithBlock { (user: PFObject!, error: NSError!) -> Void in
            if error == nil && self.parseObject != nil {
                for image in self.images {
                    if let obj = image.parseObject? {
                        let acl = obj.ACL
                        acl.setReadAccess(true, forUser: user as PFUser)
                        self.acl.append(user as PFUser)
                        obj.saveInBackground()
                    }
                }
                /*
                let acl = self.parseObject!.ACL
                acl.setReadAccess(true, forUser: user as PFUser)
                self.parseObject!.ACL = acl
                self.acl.append(user as PFUser)
                self.parseObject!.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                    if error == nil {
                        
                    }
                })*/
            }
        }
    }
    
    public func invitePFUser(Username: String, AndNotify: EditLoungeTableViewController){
        println("InvitePFUser called")
        let query = PFUser.query()
        query.whereKey("username", equalTo: Username)
        query.getFirstObjectInBackgroundWithBlock { (user: PFObject!, error: NSError!) -> Void in
            if error == nil && self.parseObject != nil && user != nil {
                println("user found")
                for image in self.images {
                    if let obj = image.parseObject? {
                        let acl = obj.ACL
                        acl.setReadAccess(true, forUser: user as PFUser)
                        self.acl.append(user as PFUser)
                        obj.saveInBackground()
                    }
                }
            } else if error == nil {
                println("No error, but \(self.parseObject) \(user)")
                    AndNotify.notifyWithMessage("User Not Found", Title: "The username \((user as PFUser).username) is not registered, please try again")
            } else {
                println("error")
                AndNotify.notifyWithMessage("Error", Title: "\((user as PFUser).username) could not be invited.  Please try again")
            }
        }
    }
    
    public func incrementImageCount(){
        imageCount++
    }
    
    public func decrementImageCount(){
        if imageCount > 0 {
            imageCount--
        }
    }
    
    public func addImage(Img: Image){
        images.append(Img)
        incrementImageCount()
    }
    
    public func removeImage(Img: Image){
        Img.remove()
        println(images.count)
        images.removeObject(Img)
        println(images.count)
        decrementImageCount()
    }
    
    public func clearImages(){
        for image in images {
            image.remove()
        }
        images.removeAll(keepCapacity: false)
    }
    
    public func linkParseObject(object: PFObject){
        parseObject = object
    }
    
    public func remove(){
        if let object = parseObject? {
            parseObject?.deleteInBackgroundWithBlock({ (deleted, error: NSError!) -> Void in
                if (deleted) {
                    self.isDeleted = true
                    self.clearImages()
                    PFInstallation.currentInstallation().removeObject("LOUNGE_\(object.objectId)", forKey: "channels")
                    PFInstallation.currentInstallation().saveInBackground()
                }
            })
        }
    }
    
    public func fetchImagesFromParse() {
        
        if let pfObj = self.parseObject? {
            var loungeToImagesRelation = pfObj.relationForKey("Images")
            loungeToImagesRelation.query().orderByAscending("createdAt")
            loungeToImagesRelation.query().findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                print("[")
                for object in objects {
                    if !contains(self.PFImageObjects, object as PFObject){
                        self.PFImageObjects.append(object as PFObject)
                        self.addImage(Image(ParseObject: object as PFObject))
                    }
                }
            })
        }
    }
    
    public func fetchImagesFromParseAndReload(vc: EditLoungeTableViewController) {
        
        if let pfObj = self.parseObject? {
            var loungeToImagesRelation = pfObj.relationForKey("Images")
            loungeToImagesRelation.query().orderByAscending("createdAt")
            loungeToImagesRelation.query().findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                print("[")
                for object in objects {
                    if !contains(self.PFImageObjects, object as PFObject){
                        self.PFImageObjects.append(object as PFObject)
                        self.addImage(Image(ParseObject: object as PFObject))
                    }
                }
                vc.reload()
            })
        }
    }
    
   
}

extension Array {
    mutating func removeObject<U: Equatable>(object: U) {
        var index: Int?
        for (idx, objectToCompare) in enumerate(self) {
            if let to = objectToCompare as? U {
                if object == to {
                    index = idx
                }
            }
        }
        
        if((index) != nil) {
            self.removeAtIndex(index!)
        }
    }
}

