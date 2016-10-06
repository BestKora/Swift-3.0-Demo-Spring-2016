//
//  ViewController.swift
//  Calculator
//
//  Created by Tatiana Kornilova on 5/7/16.
//  Copyright © 2016 Tatiana Kornilova. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet weak var stack0: UIStackView!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var stack4: UIStackView!
    
    @IBOutlet weak var multiplyButton: UIButton!
    @IBOutlet weak var divideButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    
    fileprivate var userIsInTheMiddleOfTyping = false
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping{
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
    }
    
    fileprivate var displayValue : Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let methematicalSymbol = sender.currentTitle{
            brain.performOperation(methematicalSymbol)
        }
        displayValue = brain.result
    }
    override func willTransition(to newCollection: UITraitCollection,
                                                  with coordinator:UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection,
                                              with: coordinator)
        configureView(newCollection.verticalSizeClass)
    }
    
    fileprivate func configureView(_ verticalSizeClass: UIUserInterfaceSizeClass) {
        if (verticalSizeClass == .compact)  {
            stack1.insertArrangedSubview(multiplyButton, at: 0)
            stack2.insertArrangedSubview(divideButton, at: 0)
            stack3.insertArrangedSubview(plusButton, at: 0)
            stack4.insertArrangedSubview(minusButton, at: 0)
            stack0.isHidden = true
        } else {
            stack0.isHidden = false
            stack0.addArrangedSubview(multiplyButton)
            stack0.addArrangedSubview(divideButton)
            stack0.addArrangedSubview(plusButton)
            stack0.addArrangedSubview(minusButton)
           
        }
    }

}

