
//
//  LoungeCreationTableview.swift
//  Wingle
//
//  Created by Rayno Mostert on 2014/12/02.
//  Copyright (c) 2014 Rayno Mostert. All rights reserved.
//

import Foundation

class LoungeCreationTableview: PFQueryTableViewController, PFLogInViewControllerDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.textKey = "YOUR_PARSE_COLOMN_YOU_WANT_TO_SHOW"
        parseClassName = "Lounge"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
        
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
        var logInController = PFLogInViewController()
        logInController.delegate = self
        self.presentViewController(logInController, animated:true, completion: nil)
    }
    
    func logInViewControllerDidCancelLogIn(logInController: PFLogInViewController!) {
        logInController.dismissViewControllerAnimated(true , completion: { () -> Void in
            
        })
    }
    
    override func objectsWillLoad() {
        super.objectsWillLoad()
    }
    
    override func objectsDidLoad(error: NSError!) {
        super.objectsDidLoad(error)
    }
    
    
}