//
//  FirstViewController.swift
//  HexaCalc
//
//  Created by Anthony Hopkins on 2020-07-20.
//  Copyright © 2020 Anthony Hopkins. All rights reserved.
//

import UIKit

class HexadecimalViewController: UIViewController {

    
    //MARK: Properties
    var stateController: StateController?
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var hexVStack: UIStackView!
    @IBOutlet weak var hexHStack1: UIStackView!
    @IBOutlet weak var hexHStack2: UIStackView!
    @IBOutlet weak var hexHStack3: UIStackView!
    @IBOutlet weak var hexHStack4: UIStackView!
    @IBOutlet weak var hexHStack5: UIStackView!
    @IBOutlet weak var hexHStack6: UIStackView!
    
    @IBOutlet weak var ACBtn: RoundButton!
    @IBOutlet weak var DELBtn: RoundButton!
    @IBOutlet weak var XORBtn: RoundButton!
    @IBOutlet weak var ORBtn: RoundButton!
    @IBOutlet weak var ANDBtn: RoundButton!
    @IBOutlet weak var NOTBtn: RoundButton!
    @IBOutlet weak var DIVBtn: RoundButton!
    @IBOutlet weak var CBtn: RoundButton!
    @IBOutlet weak var DBtn: RoundButton!
    @IBOutlet weak var EBtn: RoundButton!
    @IBOutlet weak var FBtn: RoundButton!
    @IBOutlet weak var MULTBtn: RoundButton!
    @IBOutlet weak var Btn8: RoundButton!
    @IBOutlet weak var Btn9: RoundButton!
    @IBOutlet weak var ABtn: RoundButton!
    @IBOutlet weak var BBtn: RoundButton!
    @IBOutlet weak var SUBBtn: RoundButton!
    @IBOutlet weak var Btn4: RoundButton!
    @IBOutlet weak var Btn5: RoundButton!
    @IBOutlet weak var Btn6: RoundButton!
    @IBOutlet weak var Btn7: RoundButton!
    @IBOutlet weak var PLUSBtn: RoundButton!
    @IBOutlet weak var Btn0: RoundButton!
    @IBOutlet weak var Btn1: RoundButton!
    @IBOutlet weak var Btn2: RoundButton!
    @IBOutlet weak var Btn3: RoundButton!
    @IBOutlet weak var EQUALSBtn: RoundButton!
    
    //MARK: Variables
    var runningNumber = ""
    var leftValue = ""
    var rightValue = ""
    var result = ""
    var currentOperation:Operation = .NULL
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        outputLabel.text = "0"
    }
    
    override func viewDidLayoutSubviews() {
        
        let screenWidth = UIScreen.main.bounds.width
        
        //iPhone SE (1st generation) special case
        if (screenWidth == 320){
           setupSEConstraints()
        }
        //All other screensizes can use these constraints
        else {
            let constraints = [
                hexVStack.widthAnchor.constraint(equalToConstant: 350),
                hexVStack.heightAnchor.constraint(equalToConstant: 420),
                hexHStack1.widthAnchor.constraint(equalToConstant: 350),
                hexHStack1.heightAnchor.constraint(equalToConstant: 65),
                hexHStack2.widthAnchor.constraint(equalToConstant: 350),
                hexHStack2.heightAnchor.constraint(equalToConstant: 65),
                hexHStack3.widthAnchor.constraint(equalToConstant: 350),
                hexHStack3.heightAnchor.constraint(equalToConstant: 65),
                hexHStack4.widthAnchor.constraint(equalToConstant: 350),
                hexHStack4.heightAnchor.constraint(equalToConstant: 65),
                hexHStack5.widthAnchor.constraint(equalToConstant: 350),
                hexHStack5.heightAnchor.constraint(equalToConstant: 65),
                hexHStack6.widthAnchor.constraint(equalToConstant: 350),
                hexHStack6.heightAnchor.constraint(equalToConstant: 65)
            ]
            NSLayoutConstraint.activate(constraints)
        }
        
    }
    //Load the current converted value from either of the other calculator screens
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ((stateController?.convValues.largerThan64Bits)!) {
            outputLabel.text = "Error! Integer overflow!"
        }
        else {
            var newLabelValue = stateController?.convValues.hexVal.uppercased()
            
            if (newLabelValue == "0"){
                outputLabel.text = "0"
                runningNumber = ""
                leftValue = ""
                rightValue = ""
                currentOperation = .NULL
            }
            else {
                //Need special case to convert negative values
                if (newLabelValue!.contains("-")){
                    newLabelValue = formatNegativeHex(hexToConvert: newLabelValue ?? "0").uppercased()
                }
                runningNumber = newLabelValue ?? "0"
                currentOperation = .NULL
                outputLabel.text = newLabelValue
            }
        }
    }
    
    //MARK: Button Actions
    @IBAction func ACPressed(_ sender: RoundButton) {
        runningNumber = ""
        leftValue = ""
        rightValue = ""
        result = ""
        currentOperation = .NULL
        outputLabel.text = "0"
        
        stateController?.convValues.largerThan64Bits = false
        stateController?.convValues.decimalVal = "0"
        stateController?.convValues.hexVal = "0"
        stateController?.convValues.binVal = "0"
    }
    
    @IBAction func deletePressed(_ sender: RoundButton) {
        if (runningNumber == "0"){
            //Do nothing
        }
        else {
            if (runningNumber != ""){
                runningNumber.removeLast()
            }
            //Need to be careful if runningNumber becomes NIL
            if (runningNumber == ""){
                stateController?.convValues.largerThan64Bits = false
                stateController?.convValues.decimalVal = "0"
                stateController?.convValues.hexVal = "0"
                stateController?.convValues.binVal = "0"
                outputLabel.text = "0"
            }
            else {
                outputLabel.text = runningNumber
                quickUpdateStateController()
            }
        }
    }
    
    @IBAction func digitPressed(_ sender: RoundButton) {
        //Need to keep the hex value under 64 bits
        if (runningNumber.count <= 15) {
            let digit = "\(sender.tag)"
            if ((digit == "0") && (outputLabel.text == "0")) {
                //if 0 is pressed and calculator is showing 0 then do nothing
            }
            else {
                let convertedDigit = tagToHex(digitToConvert: digit)
                runningNumber += convertedDigit
                outputLabel.text = runningNumber
                quickUpdateStateController()
            }
        }
    }
    
    @IBAction func XORPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func ORPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func ANDPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func NOTPressed(_ sender: RoundButton) {
        
        if (stateController?.convValues.largerThan64Bits == true){
            return
        }
        //Need to flip every bit
        var currentValue = runningNumber
        if (runningNumber == ""){
            currentValue = "0"
        }
        //Need to extend to 64 bits
        while (currentValue.count < 16){
            currentValue = "0" + currentValue
        }
        //Convert from hex to binary
        let binaryValue = hexToBin(hexToConvert: currentValue)
        
        var flippedBitsBinary = ""
        
        //Perform the bit flipping
        for i in 0..<binaryValue.count {
            if (binaryValue[binaryValue.index(binaryValue.startIndex, offsetBy: i)] == "0"){
                flippedBitsBinary += "1"
            }
            else {
                flippedBitsBinary += "0"
            }
        }
        
        //Convert back to hex and update state controller
        if (flippedBitsBinary.first == "1"){
            stateController?.convValues.binVal = flippedBitsBinary
            stateController?.convValues.decimalVal = String(Int64(bitPattern: UInt64(flippedBitsBinary, radix: 2)!))
            var hexCurrentVal = String(Int64(bitPattern: UInt64(flippedBitsBinary, radix: 2)!), radix: 16)
            hexCurrentVal = formatNegativeHex(hexToConvert: hexCurrentVal).uppercased()
            stateController?.convValues.hexVal = hexCurrentVal
            runningNumber = hexCurrentVal
            outputLabel.text = runningNumber
        }
        else {
            let asInt = Int(flippedBitsBinary)
            let removedLeadingZeroes = "\(asInt ?? 0)"
            stateController?.convValues.binVal = removedLeadingZeroes
            stateController?.convValues.decimalVal = String(Int(removedLeadingZeroes, radix: 2)!)
            let hexCurrentVal = String(Int(removedLeadingZeroes, radix: 2)!, radix: 16).uppercased()
            stateController?.convValues.hexVal = hexCurrentVal
            
            if (hexCurrentVal == "0"){
                runningNumber = ""
            }
            else {
                runningNumber = hexCurrentVal
            }
            
            outputLabel.text = hexCurrentVal
        }
    }
    
    @IBAction func dividePressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func multiplyPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func minusPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func addPressed(_ sender: RoundButton) {
        
    }
    
    @IBAction func equalsPressed(_ sender: RoundButton) {
        
    }
    
    //MARK: Private Functions
    
    //Perform a quick update to keep the state controller variables in sync with the calculator label
    private func quickUpdateStateController() {
        //Need to keep the state controller updated with what is on the screen
        stateController?.convValues.hexVal = runningNumber
        //Need to convert differently if binary is positive or negative
        var binCurrentVal = ""
        var decCurrentVal = ""
        //We are dealing with a negative number
        if ((!outputLabel.text!.first!.isNumber || ((outputLabel.text!.first == "9") || (outputLabel.text!.first == "8"))) && (outputLabel.text!.count == 16)){
            //Need to perform special operation here
            var currentLabel = runningNumber
            currentLabel = hexToBin(hexToConvert: currentLabel)
            binCurrentVal = currentLabel
            decCurrentVal = String(Int64(bitPattern: UInt64(currentLabel, radix: 2)!))
        }
        else {
            binCurrentVal = String(Int(runningNumber, radix: 16)!, radix: 2)
            decCurrentVal = String(Int(runningNumber, radix: 16)!)
        }
        stateController?.convValues.binVal = binCurrentVal
        stateController?.convValues.decimalVal = decCurrentVal
    }
    
    //Helper function to convert the button tags to hex digits
    func tagToHex(digitToConvert: String) -> String {
        var result = ""
        if (Int(digitToConvert)! < 10){
            result = digitToConvert
        }
        else {
            if (Int(digitToConvert)! == 10) {
                result = "A"
            }
            else if (Int(digitToConvert)! == 11) {
                result = "B"
            }
            else if (Int(digitToConvert)! == 12) {
                result = "C"
            }
            else if (Int(digitToConvert)! == 13) {
                result = "D"
            }
            else if (Int(digitToConvert)! == 14) {
                result = "E"
            }
            else if (Int(digitToConvert)! == 15) {
                result = "F"
            }
            else {
                //Should not occur ...
            }
        }
        return result
    }
    
    //Helper function to convert hex to binary
    func hexToBin(hexToConvert: String) -> String {
        var result = ""
        var copy = hexToConvert
        
        for _ in 0..<hexToConvert.count {
            let currentDigit = copy.first
            copy.removeFirst()
            
            switch currentDigit {
            case "0":
                result += "0000"
            case "1":
                result += "0001"
            case "2":
                result += "0010"
            case "3":
                result += "0011"
            case "4":
                result += "0100"
            case "5":
                result += "0101"
            case "6":
                result += "0110"
            case "7":
                result += "0111"
            case "8":
                result += "1000"
            case "9":
                result += "1001"
            case "A":
                result += "1010"
            case "B":
                result += "1011"
            case "C":
                result += "1100"
            case "D":
                result += "1101"
            case "E":
                result += "1110"
            case "F":
                result += "1111"
            default:
                fatalError("Unexpected Operation...")
            }
        }
        
        return result
    }
    //Helper function to convert negative hexadecimal number to sign extended equivalent
    func formatNegativeHex(hexToConvert: String) -> String {
        var manipulatedString = hexToConvert
        manipulatedString.removeFirst()
        
        //Need to convert the binary, then flip all the bits, add 1 and convert back to hex
        let binaryInitial = String(Int(manipulatedString, radix:16)!, radix: 2)
        var invertedBinary = ""
        
        //Flip all bits
        for i in 0..<binaryInitial.count {
            if (binaryInitial[binaryInitial.index(binaryInitial.startIndex, offsetBy: i)] == "0"){
                invertedBinary += "1"
            }
            else {
                invertedBinary += "0"
            }
        }
        
        //Add 1 to the string
        let index = invertedBinary.lastIndex(of: "0") ?? (invertedBinary.endIndex)
        var newSubString = String(invertedBinary.prefix(upTo: index))
        
        
        if (newSubString.count < invertedBinary.count) {
            newSubString = newSubString + "1"
        }
        
        while (newSubString.count < invertedBinary.count) {
            newSubString = newSubString + "0"
        }
        
        //Sign extend
        while (newSubString.count < 64) {
            newSubString = "1" + newSubString
        }
        
        //Finally, convert to hexadecimal manually
        var hexResult = ""
        for _ in 0..<16 {
            //Take last 4 bits and convert to hex
            let currentIndex = newSubString.index(newSubString.endIndex, offsetBy: -4)
            let currentBinary = String(newSubString.suffix(from: currentIndex))
            newSubString.removeLast(4)
            
            switch currentBinary {
            case "0000":
                hexResult = "0" + hexResult
            case "0001":
                hexResult = "1" + hexResult
            case "0010":
                hexResult = "2" + hexResult
            case "0011":
                hexResult = "3" + hexResult
            case "0100":
                hexResult = "4" + hexResult
            case "0101":
                hexResult = "5" + hexResult
            case "0110":
                hexResult = "6" + hexResult
            case "0111":
                hexResult = "7" + hexResult
            case "1000":
                hexResult = "8" + hexResult
            case "1001":
                hexResult = "9" + hexResult
            case "1010":
                hexResult = "a" + hexResult
            case "1011":
                hexResult = "b" + hexResult
            case "1100":
                hexResult = "c" + hexResult
            case "1101":
                hexResult = "d" + hexResult
            case "1110":
                hexResult = "e" + hexResult
            case "1111":
                hexResult = "f" + hexResult
            default:
                fatalError("Unexpected Operation...")
            }
        }
        
        return hexResult
    }
    
    //Helper function to set custon layout for iPhone SE screen size
    func setupSEConstraints(){
        let oldConstraints = [
            outputLabel.widthAnchor.constraint(equalToConstant: 350),
            outputLabel.heightAnchor.constraint(equalToConstant: 64),
            ACBtn.widthAnchor.constraint(equalToConstant: 205),
            ACBtn.heightAnchor.constraint(equalToConstant: 65),
            DELBtn.widthAnchor.constraint(equalToConstant: 135),
            DELBtn.heightAnchor.constraint(equalToConstant: 65),
            XORBtn.widthAnchor.constraint(equalToConstant: 65),
            XORBtn.heightAnchor.constraint(equalToConstant: 65),
            ORBtn.widthAnchor.constraint(equalToConstant: 65),
            ORBtn.heightAnchor.constraint(equalToConstant: 65),
            ANDBtn.widthAnchor.constraint(equalToConstant: 65),
            ANDBtn.heightAnchor.constraint(equalToConstant: 65),
            NOTBtn.widthAnchor.constraint(equalToConstant: 65),
            NOTBtn.heightAnchor.constraint(equalToConstant: 65),
            DIVBtn.widthAnchor.constraint(equalToConstant: 65),
            DIVBtn.heightAnchor.constraint(equalToConstant: 65),
            CBtn.widthAnchor.constraint(equalToConstant: 65),
            CBtn.heightAnchor.constraint(equalToConstant: 65),
            DBtn.widthAnchor.constraint(equalToConstant: 65),
            DBtn.heightAnchor.constraint(equalToConstant: 65),
            EBtn.widthAnchor.constraint(equalToConstant: 65),
            EBtn.heightAnchor.constraint(equalToConstant: 65),
            FBtn.widthAnchor.constraint(equalToConstant: 65),
            FBtn.heightAnchor.constraint(equalToConstant: 65),
            MULTBtn.widthAnchor.constraint(equalToConstant: 65),
            MULTBtn.heightAnchor.constraint(equalToConstant: 65),
            ABtn.widthAnchor.constraint(equalToConstant: 65),
            ABtn.heightAnchor.constraint(equalToConstant: 65),
            BBtn.widthAnchor.constraint(equalToConstant: 65),
            BBtn.heightAnchor.constraint(equalToConstant: 65),
            SUBBtn.widthAnchor.constraint(equalToConstant: 65),
            SUBBtn.heightAnchor.constraint(equalToConstant: 65),
            PLUSBtn.widthAnchor.constraint(equalToConstant: 65),
            PLUSBtn.heightAnchor.constraint(equalToConstant: 65),
            EQUALSBtn.widthAnchor.constraint(equalToConstant: 65),
            EQUALSBtn.heightAnchor.constraint(equalToConstant: 65),
            Btn0.widthAnchor.constraint(equalToConstant: 65),
            Btn0.heightAnchor.constraint(equalToConstant: 65),
            Btn1.widthAnchor.constraint(equalToConstant: 65),
            Btn1.heightAnchor.constraint(equalToConstant: 65),
            Btn2.widthAnchor.constraint(equalToConstant: 65),
            Btn2.heightAnchor.constraint(equalToConstant: 65),
            Btn3.widthAnchor.constraint(equalToConstant: 65),
            Btn3.heightAnchor.constraint(equalToConstant: 65),
            Btn4.widthAnchor.constraint(equalToConstant: 65),
            Btn4.heightAnchor.constraint(equalToConstant: 65),
            Btn5.widthAnchor.constraint(equalToConstant: 65),
            Btn5.heightAnchor.constraint(equalToConstant: 65),
            Btn6.widthAnchor.constraint(equalToConstant: 65),
            Btn6.heightAnchor.constraint(equalToConstant: 65),
            Btn7.widthAnchor.constraint(equalToConstant: 65),
            Btn7.heightAnchor.constraint(equalToConstant: 65),
            Btn8.widthAnchor.constraint(equalToConstant: 65),
            Btn8.heightAnchor.constraint(equalToConstant: 65),
            Btn9.widthAnchor.constraint(equalToConstant: 65),
            Btn9.heightAnchor.constraint(equalToConstant: 65)
        ]
        
        //NSLayoutConstraint.deactivate(oldConstraints)
        for oldConstraint in oldConstraints {
            oldConstraint.isActive = false
        }
        
        let buttons = [
            Btn0,
            Btn1,
            Btn2,
            Btn3,
            Btn4,
            Btn5,
            Btn6,
            Btn7,
            Btn8,
            Btn9,
            ACBtn,
            DELBtn,
            NOTBtn,
            XORBtn,
            ORBtn,
            ANDBtn,
            DIVBtn,
            MULTBtn,
            PLUSBtn,
            SUBBtn,
            EQUALSBtn,
            ABtn,
            BBtn,
            CBtn,
            DBtn,
            EBtn,
            FBtn
        ]
        
        for button in buttons {
            button!.layer.cornerRadius = 0
            button!.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        }
        
        //Need to change the font size of the text label for smaller screen
        outputLabel?.font = UIFont(name: "Avenir Next", size: 50)
        
        
        let constraints = [
            hexVStack.widthAnchor.constraint(equalToConstant: 295),
            hexVStack.heightAnchor.constraint(equalToConstant: 330),
            outputLabel.widthAnchor.constraint(equalToConstant: 295),
            outputLabel.heightAnchor.constraint(equalToConstant: 64),
            ACBtn.widthAnchor.constraint(equalToConstant: 175),
            ACBtn.heightAnchor.constraint(equalToConstant: 50),
            DELBtn.widthAnchor.constraint(equalToConstant: 110),
            DELBtn.heightAnchor.constraint(equalToConstant: 50),
            XORBtn.widthAnchor.constraint(equalToConstant: 50),
            XORBtn.heightAnchor.constraint(equalToConstant: 50),
            ORBtn.widthAnchor.constraint(equalToConstant: 50),
            ORBtn.heightAnchor.constraint(equalToConstant: 50),
            ANDBtn.widthAnchor.constraint(equalToConstant: 50),
            ANDBtn.heightAnchor.constraint(equalToConstant: 50),
            NOTBtn.widthAnchor.constraint(equalToConstant: 50),
            NOTBtn.heightAnchor.constraint(equalToConstant: 50),
            DIVBtn.widthAnchor.constraint(equalToConstant: 50),
            DIVBtn.heightAnchor.constraint(equalToConstant: 50),
            CBtn.widthAnchor.constraint(equalToConstant: 50),
            CBtn.heightAnchor.constraint(equalToConstant: 50),
            DBtn.widthAnchor.constraint(equalToConstant: 50),
            DBtn.heightAnchor.constraint(equalToConstant: 50),
            EBtn.widthAnchor.constraint(equalToConstant: 50),
            EBtn.heightAnchor.constraint(equalToConstant: 50),
            FBtn.widthAnchor.constraint(equalToConstant: 50),
            FBtn.heightAnchor.constraint(equalToConstant: 50),
            MULTBtn.widthAnchor.constraint(equalToConstant: 50),
            MULTBtn.heightAnchor.constraint(equalToConstant: 50),
            ABtn.widthAnchor.constraint(equalToConstant: 50),
            ABtn.heightAnchor.constraint(equalToConstant: 50),
            BBtn.widthAnchor.constraint(equalToConstant: 50),
            BBtn.heightAnchor.constraint(equalToConstant: 50),
            SUBBtn.widthAnchor.constraint(equalToConstant: 50),
            SUBBtn.heightAnchor.constraint(equalToConstant: 50),
            PLUSBtn.widthAnchor.constraint(equalToConstant: 50),
            PLUSBtn.heightAnchor.constraint(equalToConstant: 50),
            EQUALSBtn.widthAnchor.constraint(equalToConstant: 50),
            EQUALSBtn.heightAnchor.constraint(equalToConstant: 50),
            Btn0.widthAnchor.constraint(equalToConstant: 50),
            Btn0.heightAnchor.constraint(equalToConstant: 50),
            Btn1.widthAnchor.constraint(equalToConstant: 50),
            Btn1.heightAnchor.constraint(equalToConstant: 50),
            Btn2.widthAnchor.constraint(equalToConstant: 50),
            Btn2.heightAnchor.constraint(equalToConstant: 50),
            Btn3.widthAnchor.constraint(equalToConstant: 50),
            Btn3.heightAnchor.constraint(equalToConstant: 50),
            Btn4.widthAnchor.constraint(equalToConstant: 50),
            Btn4.heightAnchor.constraint(equalToConstant: 50),
            Btn5.widthAnchor.constraint(equalToConstant: 50),
            Btn5.heightAnchor.constraint(equalToConstant: 50),
            Btn6.widthAnchor.constraint(equalToConstant: 50),
            Btn6.heightAnchor.constraint(equalToConstant: 50),
            Btn7.widthAnchor.constraint(equalToConstant: 50),
            Btn7.heightAnchor.constraint(equalToConstant: 50),
            Btn8.widthAnchor.constraint(equalToConstant: 50),
            Btn8.heightAnchor.constraint(equalToConstant: 50),
            Btn9.widthAnchor.constraint(equalToConstant: 50),
            Btn9.heightAnchor.constraint(equalToConstant: 50),
            hexHStack1.widthAnchor.constraint(equalToConstant: 295),
            hexHStack1.heightAnchor.constraint(equalToConstant: 50),
            hexHStack2.widthAnchor.constraint(equalToConstant: 295),
            hexHStack2.heightAnchor.constraint(equalToConstant: 50),
            hexHStack3.widthAnchor.constraint(equalToConstant: 295),
            hexHStack3.heightAnchor.constraint(equalToConstant: 50),
            hexHStack4.widthAnchor.constraint(equalToConstant: 295),
            hexHStack4.heightAnchor.constraint(equalToConstant: 50),
            hexHStack5.widthAnchor.constraint(equalToConstant: 295),
            hexHStack5.heightAnchor.constraint(equalToConstant: 50),
            hexHStack6.widthAnchor.constraint(equalToConstant: 295),
            hexHStack6.heightAnchor.constraint(equalToConstant: 50)
        ]
        for constraint in constraints {
            constraint.isActive = true
        }
    }

}

//Adds state controller to the view controller
extension HexadecimalViewController: StateControllerProtocol {
  func setState(state: StateController) {
    self.stateController = state
  }
}
