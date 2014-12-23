//
//  EditLoungeTableViewController.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/06.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit
import MobileCoreServices

public class EditLoungeTableViewController: UITableViewController, CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    public var lounge: Lounge?
    var assets: [ALAsset]
    var foreignAssetImages: [Image]
    
    required public init(coder aDecoder: NSCoder) {
        assets = [ALAsset]()
        foreignAssetImages = [Image]()
        super.init(coder: aDecoder)
        hidesBottomBarWhenPushed = true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Plain, target: self, action: "pickAssets")
        
        navigationItem.rightBarButtonItem = addButton
        
        if let lng = lounge? {
            navigationItem.title = lng.name
            
            for image in lng.images {
                foreignAssetImages.append(image)
            }
        }
        
        navigationController?.hidesBarsOnSwipe = true
    }
    
    public override func viewDidAppear(animated: Bool) {
        if self.tableView.numberOfRowsInSection(0)>3{
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.tableView.numberOfRowsInSection(0)-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }
    
    @IBAction func inviteUser(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "Invite User", message: "Invite a username to the lounge:", preferredStyle: UIAlertControllerStyle.Alert)
        
        let userInviteAction = UIAlertAction(title: "Invite", style: .Default) { (_) in
            let nameTextField = alertController.textFields![0] as UITextField
            
            self.lounge?.invitePFUser(nameTextField.text, AndNotify: self)
        }
        
        userInviteAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Username"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                userInviteAction.enabled = textField.text != ""
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(userInviteAction)
        
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
    }
    
    public func notifyWithMessage(message: NSString, Title: NSString){
        var alertController = UIAlertController(title: Title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Okay", style: .Cancel) { (_) in }
        alertController.addAction(cancelAction)
        presentViewController(alertController, animated: true) { () -> Void in }
    }
    
    func pickAssets(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.mediaTypes = [kUTTypeImage]
        //picker.allowsEditing = true
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
        println(assets)
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            let image = info[UIImagePickerControllerOriginalImage] as UIImage
            //let dict = info[UIImagePickerControllerMediaMetadata] as NSDictionary
            
            var alertController = UIAlertController(title: "Image Data", message: "Imput the image metadata:", preferredStyle: UIAlertControllerStyle.Alert)
            
            let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
                let nameTextField = alertController.textFields![0] as UITextField
                let detailsTextField = alertController.textFields![1] as UITextField
                if let lng = self.lounge? {
                    var img = Image(Name: nameTextField.text, Description: detailsTextField.text, Graphic: image, Lnge: self.lounge, Thumbnail: nil)
                    lng.addImage(img)
                    img.syncToParse()
                }
            }
            
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Image Name"
            }
            
            alertController.addTextFieldWithConfigurationHandler { (textField) in
                textField.placeholder = "Details"
            }
            
            alertController.addAction(confirmAction)
            
            self.presentViewController(alertController, animated: true, completion: { () -> Void in
                
            })
            
            self.reload()
        })
    }
    
    
    /*
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject])
    {
    println(assets)
    picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
    let image = info[UIImagePickerControllerEditedImage] as UIImage
    if let lng = self.lounge? {
    
    let imageData = UIImagePNGRepresentation(image)
    let string = "\(PFUser.currentUser()) \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle), withFormat: MHPrettyDateFormatWithTime)).png"
    let imageFile = PFFile(name:string, data:imageData)
    
    var progressView = UIProgressView()
    
    var alertController = UIAlertController(title: "Image Data", message: "Imput the image metadata:", preferredStyle: UIAlertControllerStyle.Alert)
    
    let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
    let nameTextField = alertController.textFields![0] as UITextField
    let detailsTextField = alertController.textFields![1] as UITextField
    
    self.syncToParse(imageFile, name: nameTextField.text, descriptor: detailsTextField.text, aspectRatio: Float(image.size.width/image.size.height))
    }
    
    confirmAction.enabled = false
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Image Name"
    
    
    }
    
    alertController.addTextFieldWithConfigurationHandler { (textField) in
    textField.placeholder = "Details"
    }
    
    alertController.view.addSubview(progressView)
    
    alertController.addAction(confirmAction)
    
    imageFile.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
    
    confirmAction.enabled = true
    
    }, progressBlock: { (progress: Int32) -> Void in
    progressView.progress = Float(progress)/100
    
    })
    
    
    self.presentViewController(alertController, animated: true) { () -> Void in
    
    }
    
    
    }
    
    self.reload()
    })
    }
    
    public func syncToParse(imageFile: PFFile, name: String, descriptor: String, aspectRatio: Float) {
    println("Sync to Parse!!")
    if let lng = lounge? {
    
    KVNProgress.showProgress(0, status: "Uploading Photo")
    
    var userPhoto = PFObject(className:"Image")
    userPhoto["Name"] = name
    userPhoto["Descriptor"] = descriptor
    //userPhoto["Thumbnail"] = thmbFile
    userPhoto["Lounge"] = lng.parseObject?
    userPhoto["AspectRatio"] = aspectRatio
    userPhoto["Author"] = PFUser.currentUser().username
    userPhoto["Graphic"] = imageFile
    
    userPhoto.pinInBackground()
    
    
    if let pfObj = lng.parseObject? {
    KVNProgress.showWithStatus("Finalizing Metadata")
    userPhoto.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
    
    
    var loungToImagesRelation = pfObj.relationForKey("Images")
    loungToImagesRelation.addObject(userPhoto)
    pfObj.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
    println("First Sync Complete!!")
    KVNProgress.showSuccessWithStatus("Upload Successful")
    
    lng.addImage(Image(ParseObject: pfObj))
    
    })
    })
    } else {
    userPhoto.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
    
    KVNProgress.showSuccessWithStatus("Upload Successful")
    })
    }
    
    
    
    } else {
    
    let newImage = PFObject(className: "Image")
    newImage["Name"] = name
    newImage["Descriptor"] = descriptor
    newImage["Graphic"] = imageFile
    newImage["AspectRatio"] = aspectRatio
    newImage["Author"] = PFUser.currentUser().username
    
    newImage.pinInBackground()
    
    
    newImage.saveInBackgroundWithBlock({ (done: Bool, error: NSError!) -> Void in
    
    KVNProgress.showSuccessWithStatus("Upload Successful")
    })
    }
    }
    */
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return assets.count + foreignAssetImages.count
    }
    
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        if (indexPath.row < foreignAssetImages.count){
            let image = foreignAssetImages[indexPath.row]
            print(image.lounge)
            print(image.lounge?.author)
            image.lounge?.author.fetchIfNeeded()
            if let PFObject = image.parseObject {
                if let detail = PFObject["Descriptor"] as String? {
                    cell.detailTextLabel?.text = "\(MHPrettyDate.prettyDateFromDate(PFObject.createdAt, withFormat: MHPrettyDateLongRelativeTime))\n \(detail)"
                } else {
                    cell.detailTextLabel?.text = "\(MHPrettyDate.prettyDateFromDate(PFObject.createdAt, withFormat: MHPrettyDateLongRelativeTime))"
                }
                cell.textLabel?.text = PFObject["Name"] as String?
            }
            cell.imageView?.image = image.graphic
        } else {
            // Configure the cell...
            let asset = assets[indexPath.row - foreignAssetImages.count]
            cell.textLabel?.text = asset.valueForProperty(ALAssetPropertyType) as? String
            cell.imageView?.image = UIImage(CGImage: asset.thumbnail().takeUnretainedValue())
        }
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("\(indexPath)")
        if indexPath.row < foreignAssetImages.count {
            //Save to photo album
            println("if")
            let library = ALAssetsLibrary()
            let asset = ALAsset()
            let image = foreignAssetImages[indexPath.row].thumbnail
            let meta = NSDictionary(dictionary: [NSString(string: "Date:"): NSDate(timeIntervalSinceReferenceDate: 0)])
            asset.setImageData(UIImagePNGRepresentation(image), metadata: meta, completionBlock: { (url: NSURL!, error: NSError!) -> Void in
                let vc = CTAssetsPageViewController(assets: [asset])
                self.navigationController?.pushViewController(vc, animated: true)
            })
            
            library.writeImageToSavedPhotosAlbum(image?.CGImage, orientation: ALAssetOrientation.Up, completionBlock: { (url: NSURL!, error: NSError!) -> Void in
                if error == nil {
                }
            })
        } else {
            println("else")
            let vc = CTAssetsPageViewController(assets: assets)
            vc.pageIndex = indexPath.row + foreignAssetImages.count
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    public func assetsPickerController(picker: CTAssetsPickerController!, isDefaultAssetsGroup group: ALAssetsGroup!) -> Bool {
        return true;
    }
    
    public func assetsPickerController(picker: CTAssetsPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        println(assets)
        picker.presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            for asset in assets {
                var ast = asset as ALAsset
                //self.assets.append(ast)
                let img = UIImage(CGImage: ast.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
                let thumbnail = UIImage(CGImage: asset.thumbnail().takeUnretainedValue())
                if let lng = self.lounge? {
                    var img = Image(Name: asset.valueForProperty(ALAssetPropertyType) as String, Description: asset.description, Graphic: img!, Lnge: self.lounge, Thumbnail:thumbnail)
                    lng.addImage(img)
                    img.syncToParse()
                }
            }
            self.reload()
        })
    }
    
    public func downloadNewAssetsFromParse(){
        lounge?.fetchImagesFromParseAndReload(self)
    }
    
    public func reload(){
        if let lng = lounge? {
            foreignAssetImages.removeAll(keepCapacity: true)
            for image in lng.images {
                foreignAssetImages.append(image)
            }
        }
        tableView.reloadData()
    }
    
    public func assetsPickerController(picker: CTAssetsPickerController!, shouldEnableAsset asset: ALAsset!) -> Bool {
        return true
    }
    
    public func assetsPickerController(picker: CTAssetsPickerController!, shouldSelectAsset asset: ALAsset!) -> Bool {
        
        return picker.selectedAssets.count < 10 && asset.defaultRepresentation() != nil
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the specified item to be editable.
    return true
    }==-dsu§s§§§§§§§§r
    */
    
    // Override to support editing the table view.
    override public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            
            if (indexPath.row < foreignAssetImages.count){
                let image = foreignAssetImages[indexPath.row]
                print(image.lounge)
                print(image.lounge?.author)
                //image.remove()
                lounge?.removeImage(image)
                foreignAssetImages.removeAtIndex(indexPath.row)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
            
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
