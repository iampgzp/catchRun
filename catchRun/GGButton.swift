//
//  Button.swift
//  button
//
//  A good game button class to avoid the use of UIbutton
//
//  Created by seehao on 14/12/17.
//  Copyright (c) 2014 seehao. All rights reserved.
//

import Foundation
import SpriteKit

class GGButton: SKNode {
    var defaultButton: SKSpriteNode
    var activeButton: SKSpriteNode
    var action:() -> Void

    init(defaultButtonImage: String, activeButtonImage: String, buttonAction: () -> Void){
        defaultButton = SKSpriteNode(imageNamed: defaultButtonImage)
        activeButton = SKSpriteNode(imageNamed: activeButtonImage)
        action = buttonAction
        
        super.init()
        
        addChild(defaultButton)
        addChild(activeButton)
        activeButton.hidden = true
        userInteractionEnabled = true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        activeButton.hidden = false
        defaultButton.hidden = true
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location) {
            activeButton.hidden = false
            defaultButton.hidden = true
        } else {
            activeButton.hidden = true
            defaultButton.hidden = false
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var touch: UITouch = touches.allObjects[0] as UITouch
        var location: CGPoint = touch.locationInNode(self)
        
        if defaultButton.containsPoint(location){
            action()
        }
        
        activeButton.hidden = true
        defaultButton.hidden = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("needed")
    }
}