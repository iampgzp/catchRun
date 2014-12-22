//
//  Button.swift
//  button
//
//  Created by seehao on 14/12/17.
//  Copyright (c) 2014年 seehao. All rights reserved.
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
        activeButton.hidden = true
        action = buttonAction
        
        super.init()
        
        userInteractionEnabled = true
        addChild(defaultButton)
        addChild(activeButton)
    
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