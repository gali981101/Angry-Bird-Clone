//
//  GameScene.swift
//  AngryBird
//
//  Created by Terry Jason on 2023/8/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var bird = SKSpriteNode()
    var box = SKSpriteNode()
    var sf = SKSpriteNode()
    
    var gameStarted = false
    
    var originalPosition: CGPoint?
    
    var score = 0
    var scoreLabel = SKLabelNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case SF = 2
        case Ground = 3
    }
    
    override func didMove(to view: SKView) {
        setting()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        collisionsDetect(contact: contact)
    }
    
    func touchDown(atPoint pos : CGPoint) {}
    
    func touchMoved(toPoint pos : CGPoint) {}
    
    func touchUp(atPoint pos : CGPoint) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBird(touches: touches, throwBird: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBird(touches: touches, throwBird: false)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveBird(touches: touches, throwBird: true)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {}
    
    
    override func update(_ currentTime: TimeInterval) {
        updateBird()
    }
    
}


// MARK: Setting Func

extension GameScene: SKPhysicsContactDelegate {
    
    private func setting() {
        sceneSet()
        physics()
        createScoreLabel()
        createBird()
        createBoxes()
        createSF()
    }
    
    private func sceneSet() {
        self.scene?.scaleMode = .aspectFit
    }
    
    private func physics() {
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        self.physicsWorld.contactDelegate = self
    }
    
    private func createScoreLabel() {
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 0, y: self.frame.height / 4)
        scoreLabel.zPosition = 2
        
        self.addChild(scoreLabel)
    }
    
    private func createBird() {
        bird = childNode(withName: "bird") as! SKSpriteNode
        
        let birdTexture = SKTexture(imageNamed: "bird")
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 18)
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.mass = 0.25
        
        originalPosition = bird.position
        
        bird.physicsBody?.contactTestBitMask = ColliderType.Bird.rawValue
        bird.physicsBody?.categoryBitMask = ColliderType.Bird.rawValue
//        bird.physicsBody?.collisionBitMask = ColliderType.SF.rawValue
    }
    
    private func createBoxes() {
        let boxTexture = SKTexture(imageNamed: "brick")
        let size = CGSize(width: boxTexture.size().width/5, height: boxTexture.size().height/5)
        
        loopForCreateBox(size: size)
    }
    
    private func createSF() {
        let sfTexture = SKTexture(imageNamed: "sf")
        let size = CGSize(width: sfTexture.size().width, height: sfTexture.size().height)
        
        loopForCreateSF(size: size)
    }
    
    private func loopForCreateBox(size: CGSize) {
        for var n in 1...5 {
            createSingleBox(size: size, boxName: "box\(n)")
            n+=1
        }
    }
    
    private func loopForCreateSF(size: CGSize) {
        for var n in 1...3 {
            createSingleSF(size: size, sfName: "sf\(n)")
            n+=1
        }
    }
    
    private func createSingleBox(size: CGSize, boxName: String) {
        box = childNode(withName: boxName) as! SKSpriteNode
        box.physicsBody = SKPhysicsBody(rectangleOf: size)
        box.physicsBody?.isDynamic = true
        box.physicsBody?.affectedByGravity = true
        box.physicsBody?.allowsRotation = true
        box.physicsBody?.mass = 0.4
    }
    
    private func createSingleSF(size: CGSize, sfName: String) {
        sf = childNode(withName: sfName) as! SKSpriteNode
        sf.physicsBody = SKPhysicsBody(rectangleOf: size)
        sf.physicsBody?.isDynamic = true
        sf.physicsBody?.affectedByGravity = true
        sf.physicsBody?.allowsRotation = true
        sf.physicsBody?.mass = 0.4
        
        sf.physicsBody?.collisionBitMask = ColliderType.Bird.rawValue
    }
    
}


// MARK: Move Bird Func

extension GameScene {
    
    private func moveBird(touches: Set<UITouch>, throwBird: Bool) {
        if gameStarted == false {
            handleFirstTouch(touches: touches, throwBird: throwBird)
        }
    }
    
    private func handleFirstTouch(touches: Set<UITouch>, throwBird: Bool) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: self)
            let touchNodes = nodes(at: touchLocation)
            
            handleNode(touchNodes: touchNodes, touchLocation: touchLocation, throwBird: throwBird)
        }
    }
    
    private func handleNode(touchNodes: [SKNode], touchLocation: CGPoint, throwBird: Bool) {
        if touchNodes.isEmpty == false {
            loopGetNode(touchNodes: touchNodes, touchLocation: touchLocation, throwBird: throwBird)
        }
    }
    
    private func loopGetNode(touchNodes: [SKNode], touchLocation: CGPoint, throwBird: Bool) {
        for node in touchNodes {
            checkSprite(node: node, touchLocation: touchLocation, throwBird: throwBird)
        }
    }
    
    private func checkSprite(node: SKNode, touchLocation: CGPoint, throwBird: Bool) {
        if let sprite = node as? SKSpriteNode {
            handleBird(sprite: sprite, touchLocation: touchLocation, throwBird: throwBird)
        }
    }
    
    private func handleBird(sprite: SKSpriteNode, touchLocation: CGPoint, throwBird: Bool) {
        if sprite == bird {
            setBirdLocation(touchLocation: touchLocation, throwBird: throwBird)
        }
    }
    
    private func setBirdLocation(touchLocation: CGPoint, throwBird: Bool) {
        if throwBird {
            throwBirdToTheAir(touchLocation: touchLocation)
        } else {
            bird.position = touchLocation
        }
    }
    
}


// MARK: Throw Bird Func

extension GameScene {
    
    private func throwBirdToTheAir(touchLocation: CGPoint) {
        let dx = -(touchLocation.x - originalPosition!.x)
        let dy = -(touchLocation.y - originalPosition!.y)
        
        let impulse = CGVector(dx: dx, dy: dy)
        
        bird.physicsBody?.applyImpulse(impulse)
        bird.physicsBody?.affectedByGravity = true
        
        gameStarted = true
    }
    
}


// MARK: Update Bird Func

extension GameScene {
    
    private func updateBird() {
        if let birdPhysicsBody = bird.physicsBody {
            velocityCheck(physicsBody: birdPhysicsBody)
        }
    }
    
    private func velocityCheck(physicsBody: SKPhysicsBody) {
        if physicsBody.velocity.dx <= 0.1 && physicsBody.velocity.dy <= 0.1 && physicsBody.angularVelocity <= 0.1 && gameStarted == true {
            setPhysicsBody(physicsBody: physicsBody)
        }
    }
    
    private func setPhysicsBody(physicsBody: SKPhysicsBody) {
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody?.angularVelocity = 0
        bird.zPosition = 1
        bird.position = originalPosition!
        
        score = 0
        scoreLabel.text = String(score)
            
        gameStarted = false
    }
    
}


// MARK: Collisions Detect Func

extension GameScene {
    
    private func collisionsDetect(contact: SKPhysicsContact) {
        if contact.bodyA.collisionBitMask == ColliderType.Bird.rawValue || contact.bodyB.collisionBitMask == ColliderType.Bird.rawValue {
            score += 1
            scoreLabel.text = String(score)
        }
    }
    
}















