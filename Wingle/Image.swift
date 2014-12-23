//
//  Image.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/06.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

public class Image: NSObject {
    
    public var name: String
    public var descriptor: String
    public var graphic: UIImage?
    public var thumbnail: UIImage?
    public var lounge: Lounge?
    public var parseObject: PFObject?
    public var imageURL: String?
    public var aspectRatio: Float
    public var author: String
    
    init(Name: String, Description: String?, Graphic: UIImage, Lnge: Lounge?, Thumbnail: UIImage?) {
        
        name = Name
        if let Descrip = Description? {
            descriptor = Descrip
        } else {
            descriptor = ""
        }
        graphic = Image.compressImage(Graphic)
        lounge = Lnge
        thumbnail = Thumbnail
        aspectRatio = Float(Graphic.size.width/Graphic.size.height)
        author = PFUser.currentUser().username
        
        super.init()
    }
    
    init(ParseObject: PFObject) {
        
        name = ParseObject["Name"] as String
        descriptor = ParseObject["Descriptor"] as String
        
        lounge = ParseObject["Lounge"] as? Lounge
        parseObject = ParseObject
        let ParseFile: PFFile = ParseObject["Graphic"] as PFFile
        imageURL = (ParseObject["Graphic"] as PFFile).url
        if (ParseObject["Graphic"] as PFFile).isDataAvailable {
            graphic = UIImage(data: (ParseObject["Graphic"] as PFFile).getData())
        } else {
            graphic = UIImage()
        }
        thumbnail = UIImage()
        aspectRatio = ParseObject["AspectRatio"] as Float
        author = ParseObject["Author"] as String
        super.init()
        
        //fetchThumbnailFromParse(ParseObject)
    }
    
    public func fetchFullGraphicFromParse(ParseObject: PFObject){
        let userImageFile = ParseObject["Graphic"] as PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                self.graphic = UIImage(data:imageData)!
            }
        }
    }
    
    func fetchThumbnailFromParse(ParseObject: PFObject){
        let userImageFile = ParseObject["Thumbnail"] as PFFile
        userImageFile.getDataInBackgroundWithBlock {
            (imageData: NSData!, error: NSError!) -> Void in
            if error == nil {
                self.thumbnail = UIImage(data:imageData)!
            }
        }
    }
    
    public func syncToParse() {
        println("Sync to Parse!!")
        if let lng = lounge? {
            
            let imageData = UIImagePNGRepresentation(graphic)
            let imageFile = PFFile(name:"\(name).png", data:imageData)
            
            let thmbData = UIImagePNGRepresentation(thumbnail)
            let thmbFile = PFFile(name:"\(name)_THUMBNAIL.png", data:imageData)
            
            KVNProgress.showProgress(0, status: "Uploading Photo")
            
            var userPhoto = PFObject(className:"Image")
            userPhoto["Name"] = self.name
            userPhoto["Descriptor"] = self.descriptor
            //userPhoto["Thumbnail"] = thmbFile
            userPhoto["Lounge"] = lng.parseObject?
            userPhoto["AspectRatio"] = aspectRatio
            userPhoto["Author"] = author
            userPhoto["Graphic"] = imageFile
            
            var groupACL = PFACL()
            
            // userList is an NSArray with the users we are sending this message to.
            for user in lng.acl {
                groupACL.setReadAccess(true, forUser:user)
            }
            
            groupACL.setWriteAccess(true, forUser: lng.author)
            
            userPhoto.ACL = groupACL
            
            //userPhoto.pinInBackground()
            
            imageFile.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                
                if let pfObj = lng.parseObject? {
                    KVNProgress.showWithStatus("Finalizing Metadata")
                    userPhoto.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                        self.parseObject = userPhoto
                        self.imageURL = (userPhoto["Graphic"] as PFFile).url
                        
                        var loungToImagesRelation = pfObj.relationForKey("Images")
                        loungToImagesRelation.addObject(userPhoto)
                        pfObj.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                            println("First Sync Complete!!")
                            KVNProgress.showSuccessWithStatus("Upload Successful")
                        })
                    })
                } else {
                    userPhoto.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                        self.parseObject = userPhoto
                        self.imageURL = (userPhoto["Graphic"] as PFFile).url
                        KVNProgress.showSuccessWithStatus("Upload Successful")
                    })
                }
                
                }, progressBlock: { (progress: Int32) -> Void in
                    let fl = (CGFloat(progress)/100)
                    KVNProgress.updateProgress(fl, animated: true)
                    println(fl)
            })
            
        } else {
            let imageData = UIImagePNGRepresentation(graphic)
            let imageFile = PFFile(name:"\(name).png", data:imageData)
            let newImage = PFObject(className: "Image")
            newImage["Name"] = name
            newImage["Descriptor"] = descriptor
            newImage["Graphic"] = imageFile
            newImage["AspectRatio"] = aspectRatio
            newImage["Author"] = author
            
            //newImage.pinInBackground()
            
            imageFile.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                
                newImage.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
                    self.parseObject = newImage
                    self.imageURL = (newImage["Graphic"] as PFFile).url
                    KVNProgress.showSuccessWithStatus("Upload Successful")
                })
                
                }, progressBlock: { (progress: Int32) -> Void in
                    let fl = (CGFloat(progress)/100)
                    KVNProgress.updateProgress(fl, animated: true)
            })
            
           
        }
    }
    
    public func remove(){
        if let object = parseObject? {
            parseObject?.deleteInBackgroundWithBlock({ (deleted, error: NSError!) -> Void in
                if (deleted) {
                    self.graphic = nil
                    self.thumbnail = nil
                }
            })
        }
    }
    
    class func compressImage(image: UIImage) -> UIImage {
        
        var actualHeight = image.size.height as CGFloat
        var actualWidth = image.size.width as CGFloat
        let maxHeight = 600.0 as CGFloat
        let maxWidth = 800.0 as CGFloat
        var imgRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        let compressionQuality = 0.5 as CGFloat//50 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth) {
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();
        
        return UIImage(data: imageData)!
    }
    
}
