//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Apollonian on 4/24/16.
//  Copyright © 2016 WWITDC. All rights reserved.
//

import Foundation

class CalculatorBrain{

  private var accumulator = 0.0

    func setOperand(_ operand: Double) {
        accumulator = operand
    }

   private var operations : [String: Operation] = [
        "π": Operation.constant(M_PI),
        "e": Operation.constant(M_E),
        "±": Operation.unaryOperation({ -$0 }),
        "√": Operation.unaryOperation(sqrt),
        "cos": Operation.unaryOperation(cos),
        "×": Operation.binaryOperation({$0 * $1}),
        "÷": Operation.binaryOperation({$0 / $1}),
        "+": Operation.binaryOperation({$0 + $1}),
        "−": Operation.binaryOperation({$0 - $1}),
        "=": Operation.equals
    ]

    enum Operation{
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
    }

    func performOperation(_ symbol: String){
        if let operation = operations[symbol]{
            switch operation {
            case .constant(let value):
                accumulator = value
            case .unaryOperation(let function):
                accumulator = function(accumulator)
            case .binaryOperation(let function):
                executeBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: accumulator)
            case .equals:
                executeBinaryOperation()
            }
        }
    }

   private func executeBinaryOperation(){
        if pending != nil{
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            pending = nil
        }
    }

    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) ->Double
        var firstOperand: Double
    }

    var result: Double{
        get{
            return accumulator
        }
    }
}
