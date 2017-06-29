//
//  GameScene.swift
//  Pachinko
//
//  Created by Alisher Abdukarimov on 6/29/17.
//  Copyright © 2017 MrAliGorithm. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode  {
                editLabel.text = "Done"
            }else{
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        // Blend mode determines how node is drawn .replace means just draw it
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        
        makeSlot(at: CGPoint(x: 128, y:0) , isGood: true)
        makeSlot(at: CGPoint(x: 384, y:0) , isGood: false)
        makeSlot(at: CGPoint(x: 640, y:0) , isGood: true)
        makeSlot(at: CGPoint(x: 896, y:0) , isGood: false)
        
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode = !editingMode
            }else{
                if editingMode {
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    
                    addChild(box)
                }else{
                let ball = SKSpriteNode(imageNamed: "ballRed")
                ball.name = "ball"
                //adds physics body to the box that is rectangle of the same size as the box created
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                
                //physics body of a node is optional, because it might not exist. We know it exists because we just created it
                ball.physicsBody!.restitution = 0.4
                ball.position = location
                addChild(ball)
               }
            }
        }
        // adds physics body to a whole scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    fileprivate func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        //isDynamic - when this is true the object will be moved by the physics simulator based on the gravity
        //if its false object still collides but does not move
        bouncer.physicsBody!.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at positon: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else{
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = positon
        slotGlow.position = positon
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody!.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisonBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        }else if object.name == "bad"{
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else {return}
        guard let nodeB = contact.bodyB.node else {return}
        
        if nodeA.name == "ball" {
            collisonBetween(ball: nodeA, object: nodeB)
        }else if nodeB.name == "ball" {
            collisonBetween(ball: nodeB, object: nodeA)
        }
        }
}
