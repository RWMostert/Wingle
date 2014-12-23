//
//  ViewController.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/02.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PFLogInViewControllerDelegate {
    
    var loginViewController:  PFLogInViewController

    required init(coder aDecoder: NSCoder) {
        loginViewController = PFLogInViewController()
        super.init(coder: aDecoder)
        loginViewController.delegate = self
       // var v = JMBackgroundCameraView(frame: view.frame, position: .Front, blur: .Light)
        //view.addSubview(v)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        println("Check 1")
        if PFUser.currentUser() != nil {
            //performSegueWithIdentifier("toLoungeCreation", sender: nil)
            println("Check 2")
        } else {
            self.presentViewController(loginViewController, animated:true, completion: nil)
        }
        
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //performSegueWithIdentifier("toLoungeCreation", sender: nil)
    }
}

