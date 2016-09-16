//
//  ViewController.swift
//  FaceIt
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController
{
    // MARK: Model

    var expression = FacialExpression(eyes: .closed, eyeBrows: .relaxed, mouth: .smirk) {
        didSet {
            updateUI() // Model changed, so update the View
        }
    }

    // MARK: View

    // the didSet here is called only once
    // when the outlet is connected up by iOS
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(
                target: faceView, action: #selector(FaceView.changeScale(_:))
            ))

            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.increaseHappiness)
            )
            happierSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)

            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.decreaseHappiness)
            )
            sadderSwipeGestureRecognizer.direction = .down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)

            // ADDED AFTER LECTURE 5
            faceView.addGestureRecognizer(UIRotationGestureRecognizer(
                target: self, action: #selector(FaceViewController.changeBrows(_:))
            ))

            updateUI() // View connected for first time, update it from Model
        }
    }
    
    // here the Controller is doing its job
    // of interpreting the Model (expression) for the View (faceView)
    
    fileprivate func updateUI() {
        switch expression.eyes {
        case .open: faceView.eyesOpen = true
        case .closed: faceView.eyesOpen = false
        case .squinting: faceView.eyesOpen = false
        }
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
    
    fileprivate var mouthCurvatures = [FacialExpression.Mouth.frown:-1.0,.grin:0.5,.smile:1.0,.smirk:-0.5,.neutral:0.0 ]
    fileprivate var eyeBrowTilts = [FacialExpression.EyeBrows.relaxed:0.5,.furrowed:-0.5,.normal:0.0]
    
    // MARK: Gesture Handlers
    
    // gesture handler for swipe to increase happiness
    // changes the Model (which will, in turn, updateUI())
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }

    // gesture handler for swipe to decrease happiness
    // changes the Model (which will, in turn, updateUI())
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    // gesture handler for taps
    //
    // toggles the open/closed state of the eyes in the Model
    // and all changes to the Model automatically updateUI()
    // (see the didSet for the Model var expression above)
    // so our faceView will also change its eyes
    //
    // this handler was added directly in the storyboard
    // by dragging a UITapGestureHandler onto the faceView
    // then ctrl-dragging from the tap gesture
    // (at the top of the scene in the storyboard)
    // here to our Controller
    // (so there's no need to call addGestureRecognizer)
    
    @IBAction func toggleEyes(_ recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch expression.eyes {
            case .open: expression.eyes = .closed
            case .closed: expression.eyes = .open
            case .squinting: break // we don't know how to toggle "Squinting"
            }
        }
    }
    
    // ADDED AFTER LECTURE 5
    // gesture handler to change the Model's brows with a rotation gesture
    func changeBrows(_ recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
        case .changed,.ended:
            if recognizer.rotation > CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreRelaxedBrow()
                recognizer.rotation = 0.0
            } else if recognizer.rotation < -CGFloat(M_PI/4) {
                expression.eyeBrows = expression.eyeBrows.moreFurrowedBrow()
                recognizer.rotation = 0.0
            }
        default:
            break
        }
    }
}
