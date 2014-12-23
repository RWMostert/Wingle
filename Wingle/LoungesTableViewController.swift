//
//  LoungesTableViewController.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/06.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

public class LoungesTableViewController: UITableViewController, UITextFieldDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    var currentLoungeCollection: UserLoungeCollection
    var coder: NSCoder
    var selectedLounge: Lounge?
    var loginViewController:  PFLogInViewController
   

    required public init(coder aDecoder: NSCoder) {
        currentLoungeCollection = UserLoungeCollection(Owner: nil, Author: nil)
       
        coder = aDecoder
        loginViewController = PFLogInViewController()
        
        super.init(coder: aDecoder)
        
        loginViewController.delegate = self
        loginViewController.signUpController.delegate = self
        loginViewController.fields = .DismissButton | .Facebook | .LogInButton | .PasswordForgotten | .SignUpButton | .Twitter | .UsernameAndPassword

        loginViewController.facebookPermissions = [ "public_profile", "email", "user_friends" ]

    }

    override public func viewDidLoad() {
        super.viewDidLoad()
         currentLoungeCollection = UserLoungeCollection(Owner: PFUser.currentUser(), Author: nil)
        parseFetch()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        var logoView = UIImageView();
        loginViewController.logInView.logo = logoView; // logo can be any UIView
        
        var headerView = ParallaxHeaderView.parallaxHeaderViewWithImage(UIImage(named: "FriendsBackground"), forSize: CGSizeMake(tableView.frame.size.height, 300)) as ParallaxHeaderView
        tableView.tableHeaderView = headerView
        if let user = PFUser.currentUser() {
            (tableView.tableHeaderView? as ParallaxHeaderView).headerTitleLabel.text = user.username
        }
        
        
        
        let query = PFQuery(className: "Image")
        query.orderByAscending("CreatedAt")
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if (error == nil) {
                let file = object["Graphic"] as PFFile
                file.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
                    if (error == nil){
                        
                        (self.tableView.tableHeaderView? as ParallaxHeaderView).headerImage = UIImage(data: data)
                    }
                })
            }
        }
       
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
    
    override public func  scrollViewDidScroll(scrollView: UIScrollView) {
        
        let header = tableView.tableHeaderView as ParallaxHeaderView
        header.layoutHeaderViewForScrollViewOffset(scrollView.contentOffset)
        
        tableView.tableHeaderView = header
    }
    
    public override func viewDidAppear(animated: Bool) {
        
        if PFUser.currentUser() != nil {
            //performSegueWithIdentifier("toLoungeCreation", sender: nil)
            println("Check 2")
        } else {
            self.presentViewController(loginViewController, animated:true, completion: nil)
        }
    }

    @IBAction func userProfileButtonPressed(sender: AnyObject) {
        if PFUser.currentUser() != nil {
            
            var alertController = UIAlertController(title: "Account", message: "You are logged in as \(PFUser.currentUser().username)", preferredStyle: UIAlertControllerStyle.Alert)
            
            let userInviteAction = UIAlertAction(title: "Logout", style: .Default) { (_) in
                PFUser.logOut()
                self.currentLoungeCollection = UserLoungeCollection(Owner: PFUser.currentUser(), Author: nil)
                self.parseFetch()
                self.presentViewController(self.loginViewController, animated:true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
            
            alertController.addAction(cancelAction)
            alertController.addAction(userInviteAction)
            
            self.presentViewController(alertController, animated: true) { () -> Void in
                
            }
            
        } else {
            self.presentViewController(loginViewController, animated:true, completion: nil)
        }
    }
    
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
        return currentLoungeCollection.loungeCount()
    }
    
    func parseFetch(){
        var query = PFQuery(className: "Lounge")
       // query.whereKey("Author", equalTo: PFUser.currentUser())
       // query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            self.currentLoungeCollection.removeAll()
            if error == nil {
                println(objects)
                
                for object in objects {
                    self.currentLoungeCollection.addLounge(Lounge(parseObject: object as PFObject))
                    PFInstallation.currentInstallation().addUniqueObject("LOUNGE_\(object.objectId)", forKey: "channels")
                }
                PFInstallation.currentInstallation().saveInBackground()
                self.tableView.reloadData()
                
            } else {
                println(error)
                println(error.userInfo!)
            }
        }
    }
    
    @IBAction func newLoungeButtonPressed(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "New Lounge", message: "Enter a name and description for the lounge:", preferredStyle: UIAlertControllerStyle.Alert)
        
        let loungeCreationAction = UIAlertAction(title: "Create", style: .Default) { (_) in
            let nameTextField = alertController.textFields![0] as UITextField
            let descriptionTextField = alertController.textFields![1] as UITextField
            
            let newLounge = Lounge(Name: nameTextField.text, Description: descriptionTextField.text, Author: PFUser.currentUser())
            self.currentLoungeCollection.addLounge(newLounge)
            newLounge.syncToParseAndRefresh(self)
        }
        
        loungeCreationAction.enabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Name"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue()) { (notification) in
                loungeCreationAction.enabled = textField.text != ""
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Description"
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(loungeCreationAction)
        
        
        self.presentViewController(alertController, animated: true) { () -> Void in
            
        }
        
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("loungeCell", forIndexPath: indexPath) as LoungeTableViewCell

        // Configure the cell...
        cell.textLabel?.text = currentLoungeCollection.loungeAtIndex(indexPath.row).name
        cell.detailTextLabel?.text = currentLoungeCollection.loungeAtIndex(indexPath.row).descriptor
        cell.selectionStyle = .Blue

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override public func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            currentLoungeCollection.removeLoungeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    public func refreshTableView(){
        parseFetch()
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.selectedLounge = currentLoungeCollection.loungeAtIndex(indexPath.row)
        performSegueWithIdentifier("toLoungeDetails", sender: self)
        
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override public func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toLoungeDetails" {
            let vc = segue.destinationViewController as EditLoungeTableViewController
            vc.lounge = self.selectedLounge
        }
        else if segue.identifier == "toMyFeed" {
            let vc = segue.destinationViewController as FeedViewController
            //vc.loungeCollection = currentLoungeCollection
        }
    }
    
    // MARK: - LoginViewController Delegate
    
    public func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        self.currentLoungeCollection = UserLoungeCollection(Owner: PFUser.currentUser(), Author: nil)
        self.parseFetch()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.currentLoungeCollection = UserLoungeCollection(Owner: PFUser.currentUser(), Author: nil)
        self.parseFetch()
        self.dismissViewControllerAnimated(true, completion: nil)
        //performSegueWithIdentifier("toLoungeCreation", sender: nil)
        
        if !(user.valueForKey("DisplayName")?.length > 1) {
            if PFFacebookUtils.isLinkedWithUser(user) {
                FBRequestConnection.startForMeWithCompletionHandler { (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                    if error == nil {
                        println(result)
                        if let facebookId = result.objectForKey("name") as? String {
                            user.setValue(facebookId, forKey: "DisplayName")
                            println(facebookId)
                        }
                        if let email = result.objectForKey("email") as? String {
                            user.email = email
                            println(email)
                        }
                        user.saveEventually()
                    }
                }
            }
        }
    }
    
    public func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        PFUser.currentUser().setValue(user.username, forKey: "DisplayName")
    }
    
}
