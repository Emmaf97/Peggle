//
//  GameScene.swift
//  Peggle
//
//  Created by Emma Fahey on 18/10/2019.
//  Copyright © 2019 Emma Fahey. All rights reserved.
//

import SpriteKit
import GameplayKit


var scoreLabel: SKLabelNode!
var totalballsLabel: SKLabelNode!
var balltextures = [SKTexture]()

var score = 0 {
    didSet {
        scoreLabel.text = "Score: \(score)"
    }
}
var editLabel: SKLabelNode!
var boxcreated = false
var multiboxScore = 0
var totalballs = 5 {
    didSet {
        totalballsLabel.text = "Remaining balls \(totalballs)"
    }
}

var editingMode: Bool = true {
    didSet {
        if editingMode {
            editLabel.text = "Done"
        } else {
            editLabel.text = "Edit"
        }
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self

        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)

        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        totalballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        totalballsLabel.text = "Remaining balls: 5"
        totalballsLabel.horizontalAlignmentMode = .right
        totalballsLabel.position = CGPoint(x: 680, y: 700)
        addChild(totalballsLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Done"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        balltextures.append(SKTexture(imageNamed: "ballBlue"))
        balltextures.append(SKTexture(imageNamed: "ballCyan"))
        balltextures.append(SKTexture(imageNamed: "ballGreen"))
        balltextures.append(SKTexture(imageNamed: "ballGrey"))
        balltextures.append(SKTexture(imageNamed: "ballPurple"))
        balltextures.append(SKTexture(imageNamed: "ballRed"))
        balltextures.append(SKTexture(imageNamed: "ballYellow"))
        
        
//        let bouncer = SKSpriteNode(imageNamed: "bouncer")
//        bouncer.position = CGPoint(x: 512, y: 0)
//        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
//        bouncer.physicsBody?.isDynamic = false
//        addChild(bouncer)
    }
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            if totalballs > 0 {
                totalballs += 1
                
            }
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
        else if object.name == "yokes"{
            destroy(box: object)
            multiboxScore += 1
            if multiboxScore > 5 {
                //need to put a timer in to get score to reset back to one after a certain amount of time
                score*=2
            }
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
    }
    
    func destroy(box: SKNode){
        box.removeFromParent()
        }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        //guard let nodeC = contact.bodyC.node else { return }
        
        if nodeA.name == "ball" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {

            let location = touch.location(in: self)
            
            let objects = nodes(at: location)
            
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    // create a box
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16)
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.position = location
                    
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    box.name = "yokes"
                    
                    for objects in objects{
                        objects.nodes(at: location)
                        
                        if objects.name == "yokes"{
                            objects.removeFromParent()
                            break;
                        }
                        addChild(box)
                        break;
                    }
                }
                else {
                    
                    // create a ball
                    if totalballs > 0 {
                    totalballs -= 1
                    let rand = Int(arc4random_uniform(UInt32(balltextures.count)))
                    let texture = balltextures[rand] as SKTexture
                    let ball = SKSpriteNode(imageNamed: "")
                    ball.texture = texture
                    ball.size = texture.size()

                    ball.name = "ball"
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                    ball.physicsBody?.restitution = 0.4
                    ball.position =  CGPoint(x: location.x, y: 720)
                    addChild(ball)
                    }
            }
        }
    }
}
}
