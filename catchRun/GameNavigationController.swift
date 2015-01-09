//
//  GameNavigationController.swift
//  catchRun
//
//  Created by Xiaoping Li on 1/8/15.
//  Copyright (c) 2015 LUSS. All rights reserved.
//

import Foundation

//used for navigate user to authentication page if user is not authenticated
class GameNavigationController: UINavigationController{
    
    func viewDidLoad(animated:Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showAuthenticationViewController", name: presentAuthentication, object: nil);
        GameCenterConnector.sharedInstance().authenticatePlayer()
        
    }
    
    //example to show the authenticatedViewController
    func showAuthenticationViewController() {
        //present this viewController
        self.topViewController .presentViewController(GameCenterConnector.sharedInstance().authenticationViewController!, animated: true, completion: nil)
        //GameCenterConnector.sharedInstance().authenticationViewController
    }
    
}
