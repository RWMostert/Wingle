//
//  FeedViewController.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/13.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

class FeedViewController: PFQueryTableViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Image"
        textKey = "Image"
        objectsPerPage = 1000
        paginationEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
    }
    
    override func objectsDidLoad(error: NSError!) {
        super.objectsDidLoad(error)
       
        /*
        var count = 0
        if let value = NSUserDefaults.valueForKey("URLCount") as? Int{
            var count = value
        }
        for object in objects {
             NSUserDefaults.setValue((object["Graphic"] as PFFile).url , forKey: "URL\(count)")
            count++
        }
        NSUserDefaults.setValue(objects.count , forKey: "URLCount")*/
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell2") as PFImageTableViewCell?
        if cell == nil {
            cell = PFImageTableViewCell(style: .Default, reuseIdentifier: "cell2")
        }
        
        cell!.textLabel!.text = object["title"] as? String
        
        let file = object["Graphic"] as PFFile
    
        cell!.progressBar.setProgress(0, animated: true)
        cell!.feedImageView.alpha = 0;
        cell!.progressBar.alpha = 1;
        cell!.AuthorLabel.text = object["Author"] as? String
        cell!.feedImageView.file = file
        
        if let date = object.createdAt {
            cell!.DateLabel.text = MHPrettyDate.prettyDateFromDate(date, withFormat: MHPrettyDateLongRelativeTime)
        }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        (cell as PFImageTableViewCell).loadingIndicator.startAnimating()
        (cell as PFImageTableViewCell).feedImageView.loadInBackground { (image: UIImage!, error: NSError!) -> Void in
           
            
            (cell as PFImageTableViewCell).loadingIndicator.stopAnimating()
                (cell as PFImageTableViewCell).feedImageView.contentMode = UIViewContentMode.ScaleAspectFit
            
                (cell as PFImageTableViewCell).progressBar.alpha = 0;
            
            (cell as PFImageTableViewCell).feedImageView.alpha = 1
            
        }
        
    }
    
    /*override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
    var cell = tableView.dequeueReusableCellWithIdentifier("cell2") as PFImageTableViewCell?
    if cell == nil {
    cell = PFImageTableViewCell(style: .Default, reuseIdentifier: "cell2")
    }
    cell!.textLabel!.text = object["title"] as? String
    
    let file = object["Graphic"] as PFFile
    
    cell!.progressBar.setProgress(0, animated: true)
    cell!.feedImageView.alpha = 0;
    cell!.progressBar.alpha = 1;
    cell!.AuthorLabel.text = object["Author"] as? String
    
    if let date = object.createdAt {
    cell!.DateLabel.text = MHPrettyDate.prettyDateFromDate(date, withFormat: MHPrettyDateLongRelativeTime)
    }
    file.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
    
    cell!.feedImageView.contentMode = UIViewContentMode.ScaleAspectFit
    cell?.feedImageView.image = UIImage(data: data)
    cell!.progressBar.alpha = 0;
    
    UIImageView.animateWithDuration(0.2, animations: {
    cell!.feedImageView.alpha = 1
    }, completion: {
    (value: Bool) in })
    
    }, progressBlock: { (int: Int32) -> Void in
    if self.objects[indexPath.row] as PFObject == object {
    cell!.progressBar.setProgress(Float(int)/100, animated: true)
    cell!.progressBar.alpha = 1;
    } else {
    cell?.feedImageView.alpha = 0
    }
    })
    return cell;
    }*/
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return view.frame.width/CGFloat((objects[indexPath.row] as PFObject)["AspectRatio"] as Float)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let object = objects[indexPath.row] as PFObject
        let author = object["Author"] as String
        var alertController = UIAlertController(title: "Rate Photo", message: "Rate the photo by \(author)", preferredStyle: UIAlertControllerStyle.Alert)
        
        //Create Push Notification
        let lounge = (object["Lounge"] as PFObject).objectId
        let push = PFPush()
        push.setChannel("LOUNGE_\(lounge)")
        
        let Rate1 = UIAlertAction(title: "🌟", style: .Default) { (_) in
            object.addObject(1, forKey: "Ratings")
            object.addObject(PFUser.currentUser(), forKey: "Raters")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                
                push.setMessage("\(PFUser.currentUser().username) just rated your photo 🌟")
                push.sendPushInBackground()
                }
            })
            KVNProgress.showSuccessWithStatus("Rated 🌟")
            tableView.cellForRowAtIndexPath(indexPath)?.userInteractionEnabled = false
        }
        
        let Rate2 = UIAlertAction(title: "👍", style: .Default) { (_) in
            object.addObject(2, forKey: "Ratings")
            object.addObject(PFUser.currentUser(), forKey: "Raters")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                    
                push.setMessage("\(PFUser.currentUser().username) just rated your photo 👍")
                push.sendPushInBackground()
                }
            })
            KVNProgress.showSuccessWithStatus("Rated 👍")
            tableView.cellForRowAtIndexPath(indexPath)?.userInteractionEnabled = false
        }
        
        let Rate3 = UIAlertAction(title: "✊", style: .Default) { (_) in
            object.addObject(3, forKey: "Ratings")
            object.addObject(PFUser.currentUser(), forKey: "Raters")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                    
                    push.setMessage("\(PFUser.currentUser().username) just rated your photo ✊")
                    push.sendPushInBackground()
                }
            })
            KVNProgress.showSuccessWithStatus("Rated ✊")
            tableView.cellForRowAtIndexPath(indexPath)?.userInteractionEnabled = false
        }
        
        let Rate4 = UIAlertAction(title: "👎", style: .Default) { (_) in
            object.addObject(4, forKey: "Ratings")
            object.addObject(PFUser.currentUser(), forKey: "Raters")
            object.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                if error == nil {
                    
                    push.setMessage("\(PFUser.currentUser().username) just rated your photo 👎")
                    push.sendPushInBackground()
                }
            })
            KVNProgress.showSuccessWithStatus("Rated 👎")
            tableView.cellForRowAtIndexPath(indexPath)?.userInteractionEnabled = false
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) { (_) in
        }
        
        alertController.addAction(Rate1)
        alertController.addAction(Rate2)
        alertController.addAction(Rate3)
        alertController.addAction(Rate4)
        alertController.addAction(cancel)
        
        presentViewController(alertController, animated: true) { () -> Void in
            
        }

    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func queryForTable() -> PFQuery! {
        let query = PFQuery(className: parseClassName)
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if (self.objects.count == 0) {
            query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        }
        
        query.orderByDescending("createdAt")
        
        return query;
    }
    
}
