//
//  ViewController.swift
//  Calculator
//
//  Created by levanha711 on 2017/02/14.
//  Copyright © 2017 BlueStanford. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    private var formatter = NumberFormatter()
    
    
    var userInTheMiddleOfTypeing = false
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle
        let range = display.text?.range(of: ".")
        if userInTheMiddleOfTypeing {
            if range == nil || (range != nil && digit != ".") {
                let textCurrent = display.text!
                display.text = textCurrent + digit!
            }
        } else {
            display.text = (digit == ".") ? "0.": digit!
            userInTheMiddleOfTypeing = true
        }
    }

    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            formatter.maximumFractionDigits = 6
            formatter.minimumFractionDigits = 0
            formatter.minimumIntegerDigits = 1
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    private var brain: CalculatorBrain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userInTheMiddleOfTypeing {
            brain.setOperand(displayValue)
            userInTheMiddleOfTypeing = false
        }
        if let symbol = sender.currentTitle {
            brain.performOperation(symbol)
        }
        if let result = brain.result {
            displayValue = result
        }
        // update description
        descriptionLabel.text = brain.resultIsPending! ? brain.description + "...": brain.description + "="
    }
    
    
    
    func drawHorizontalLine(from startX: Double, to endX: Double, using color: UIColor) {
        
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain = CalculatorBrain()
        display.text = String("0")
        descriptionLabel.text = " "
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        var currentDisplay = self.display.text!
        if currentDisplay.characters.count > 0 {
            currentDisplay.remove(at: currentDisplay.index(before: currentDisplay.endIndex))
            self.display.text = currentDisplay.characters.count > 0 ? currentDisplay: " "
        }
    }
    
    var storedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func save() {
        storedProgram = brain.program
    }

    @IBAction func store() {
        if storedProgram != nil {
            brain.program = storedProgram as CalculatorBrain.PropertyList
            if brain.result != nil {
                displayValue = brain.result!
            }
            userInTheMiddleOfTypeing = false;
            self.descriptionLabel.text = brain.description
        }
    }
    
    @IBAction func getVariable(_ sender: UIButton) {
        brain.setOperand((sender.titleLabel?.text!)!)
        if brain.result != nil {
            displayValue = brain.result!
        }
        
        userInTheMiddleOfTypeing = false
    }
    
    @IBAction func setVariable(_ sender: UIButton) {
        let variable = sender.titleLabel!.text!.substring(from: sender.titleLabel!.text!.index(before: sender.titleLabel!.text!.endIndex))
        if brain.variableValues.keys.contains(variable) {
            brain.variableValues[variable] = displayValue
            displayValue = brain.result!
        }
        userInTheMiddleOfTypeing = false
    }
    
    @IBAction func undoProcess(_ sender: UIButton) {
        if userInTheMiddleOfTypeing {
            backspace(sender)
        } else {
            if var program = brain.program as? [AnyObject] {
                if !program.isEmpty {
                    program.removeLast()
                    brain.program = program as CalculatorBrain.PropertyList
                    if brain.result != nil {
                        displayValue = brain.result!
                    }
                    self.descriptionLabel.text = brain.description
                }
            }
        }
    }
    
    
}

