//
//  ViewController.swift
//  GameEngine
//
//  Created by Edmund Mok on 6/2/17.
//  Copyright © 2017 nus.cs3217.a0093960x. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var bubbleGrid: UICollectionView!
    @IBOutlet weak var gameArea: UIView!
    @IBOutlet weak var cannon: UIImageView!
    
    @IBOutlet var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    // BubbleGame
    private var bubbleGame: BubbleGame!
    
    // model
    var bubbleGridModel: BubbleGridModel = BubbleGridModelManager(
        numSections: Constants.bubbleGridNumSections,
        numRows: Constants.bubbleGridNumRows
    )
    
    // delegates
    private var gameViewControllerDataSource: GameViewControllerDataSource?
    private var gameViewControllerDelegate: GameViewControllerDelegate?

    override func viewDidLoad() {
        // Register collectionview cell
        bubbleGrid.register(BubbleCell.self, forCellWithReuseIdentifier: Constants.bubbleCellIdentifier)

        // Setup delegates
        gameViewControllerDataSource = GameViewControllerDataSource(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
        gameViewControllerDelegate = GameViewControllerDelegate(bubbleGrid: bubbleGrid,
            bubbleGridModel: bubbleGridModel)
                        
        // Configure gestures
        panGestureRecognizer.delegate = self
        longPressGestureRecognizer.delegate = self
        longPressGestureRecognizer.minimumPressDuration = Constants.minimumLongPressDuration
        
        // Request to layout and adjust constraints for game setup
        gameArea.layoutIfNeeded()
        bubbleGrid.layoutIfNeeded()
        
        // Setup the game and start the game
        bubbleGame = BubbleGame(gameSettings: GameSettings(), bubbleGridModel: bubbleGridModel,
                                bubbleGrid: bubbleGrid, gameArea: gameArea)
        bubbleGame.startGame()
    }

    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        // Point at finger location on a single tap
        if sender.state == .began {
            updateCannonAngle(sender)
            return
        }
        
        // Check if the long press has ended
        guard sender.state == .ended else {
            return
        }
        
        // If long press ended, fire the bubble!
        fireCannon()
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        updateCannonAngle(sender)
    }
    
    // Update the angle of the cannon image to face the user's finger location
    private func updateCannonAngle(_ sender: UIGestureRecognizer) {
        // Calculating the new angle
        let angle = atan2(sender.location(in: view).y - cannon.center.y,
                          sender.location(in: view).x - cannon.center.x)
        
        // Find the difference between old and new angle
        let angleChange = angle + CGFloat(M_PI_2)
        // Set the cannon to move by the difference in angle so
        // it now points at the new angle
        cannon.transform = CGAffineTransform(rotationAngle: angleChange)
    }
    
    // Fires the cannon in the bubble game
    private func fireCannon() {
        let angle = atan2(cannon.transform.b, cannon.transform.a) - CGFloat(M_PI_2)
        bubbleGame.fireBubble(from: cannon.center, at: angle)
    }
    
}

// MARK: UIGestureRecognizerDelegate
extension GameViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == longPressGestureRecognizer && otherGestureRecognizer == panGestureRecognizer)
    }
}
