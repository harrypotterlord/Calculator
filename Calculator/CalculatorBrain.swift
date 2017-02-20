//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by levanha711 on 2017/02/14.
//  Copyright © 2017 BlueStanford. All rights reserved.
//

import Foundation

private func powOfTen(oper: Double) -> Double {
    return pow(10, oper)
}

private func eeFunction(opr1: Double, opr2: Double) -> Double {
    return opr1 * pow(10, opr2)
}

private func randomFunc() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

private func xFunc(opr: Double) -> Double {
    if opr < 0 {
        return -1
    }
    if opr <= 1{
        return 1
    }
    return opr * xFunc(opr: opr - 1)
}

private func squareThreeFunc(opr: Double) -> Double {
    return pow(opr, 1.0 / 3.0)
}

struct CalculatorBrain {
    private var accumulator: Double?
    var description = ""
    private var formatter = NumberFormatter()
    
    init () {
        formatter.maximumFractionDigits = 6
        formatter.minimumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
    }

    private enum Operation {
        case constant(Double)
        case noneOperation(() -> Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "∏": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "±": Operation.unaryOperation({-$0}),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "−": Operation.binaryOperation({$0 - $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "=": Operation.equals,
        
        "10ˣ": Operation.unaryOperation(powOfTen),
        "log₁₀": Operation.unaryOperation(log10),
        "EE": Operation.binaryOperation(eeFunction),
        "Rand": Operation.noneOperation(randomFunc),
        "%": Operation.unaryOperation({$0 / 100.0}),
        "eˣ": Operation.unaryOperation(exp),
        "ln": Operation.unaryOperation(log),
        "x!": Operation.unaryOperation(xFunc),
        "tan": Operation.unaryOperation(tan),
        "sin": Operation.unaryOperation(sin),
        "1/x": Operation.unaryOperation({1.0 / $0}),
        "x²": Operation.unaryOperation({$0 * $0}),
        "x³": Operation.unaryOperation({$0 * $0 * $0}),
        "³√x": Operation.unaryOperation(squareThreeFunc)
        
    ]
    
    
    mutating func performOperation(_ symbol: String) {
        if let oper = operations[symbol] {
            switch  oper {
            case .constant(let value):
                description += symbol
                accumulator = value
                break
            case .noneOperation(let function):
                description = resultIsPending! ? description.substring(to: description.index(description.endIndex, offsetBy: -(String(accumulator!)).characters.count)) + symbol + String(accumulator!) : symbol + "()"
                accumulator = function()
                break
            case .unaryOperation(let function):
                if accumulator != nil {
                    description = resultIsPending! ? description.substring(to: description.index(description.endIndex, offsetBy: -(String(accumulator!)).characters.count)) + symbol + String(accumulator!) : symbol + "(" + description + ")"
                    accumulator = function(accumulator!)
                }
                break
            case .binaryOperation(let function):
                if accumulator != nil {
                    performPendingBinaryOperation()
                    description += symbol
                    pbo = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                }
                break
            case .equals:
                performPendingBinaryOperation()
                break
            }
            
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pbo != nil && accumulator != nil {
            accumulator = pbo!.perform(with: accumulator!)
            pbo = nil
        }
        
    }
    
    private var pbo: PendingBinaryOperation?
    private struct PendingBinaryOperation {
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
        
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        description += formatter.string(from: NSNumber(value: operand))!
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool? {
        get {
            return pbo != nil
        }
    }
}
