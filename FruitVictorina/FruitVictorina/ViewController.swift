//
//  ViewController.swift
//  FruitVictorina
//
//  Created by Yury Popov on 26/06/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var pickerFruits: UIPickerView!
    @IBOutlet var matchButton: UIButton!
    
    var rusFruitsNames = ["Банан", "Груша", "Яблоко", "Апельсин", "Вишня", "Ананас", "Клубника"]
    var engFruitsNames = ["Banan", "Pear", "Apple", "Orange", "Cherry", "Pineapple", "Strawberry"]
    var rusSave = [String]()
    var engSave = [String]()
    
    let answers = ["Банан": "Banan", "Груша": "Pear", "Яблоко": "Apple", "Апельсин": "Orange", "Вишня": "Cherry", "Ананас": "Pineapple", "Клубника": "Strawberry"]
    var score = 0 {
        didSet {
            scoreLabel.text = "\(score)"
        }
    }
    var correctAnswers = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        matchButton.layer.cornerRadius = 10
        pickerFruits.delegate = self
        pickerFruits.dataSource = self
        rusSave = rusFruitsNames
        engSave = engFruitsNames
        
        startGame()
        
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 0 {
            var label = UILabel()
            if let v = view {
                label = v as! UILabel
            }
            label.font = UIFont (name: "Marker Felt", size: 30)
            label.text =  rusFruitsNames[row]
            label.textAlignment = .center
            label.textColor = .red
            return label
        } else {
            var label = UILabel()
            if let v = view {
                label = v as! UILabel
            }
            label.font = UIFont (name: "Marker Felt", size: 30)
            label.text =  engFruitsNames[row]
            label.textAlignment = .center
            return label
        }
        
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component < 1 ?  rusFruitsNames.count :  engFruitsNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return component < 1 ?  rusFruitsNames[row] :  engFruitsNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            imageView.image = UIImage(named: rusFruitsNames[row])
        }
    }
    
    func startGame() {
        score = 0
        rusFruitsNames.shuffle()
        engFruitsNames.shuffle()
        pickImage()
        
    }

    @IBAction func matchButton(_ sender: UIButton) {
        let rowRus = pickerFruits.selectedRow(inComponent: 0)
        let rusValue = rusFruitsNames[rowRus]
        let rowEng = pickerFruits.selectedRow(inComponent: 1)
        let engValue = engFruitsNames[rowEng]
        var title: String
        var message: String
        
        
        
        if answers[rusValue] == engValue {
            score += 1
            correctAnswers += 1
            title = "Win! 🥳"
            message = "+1 point"
            if correctAnswers == 7 {
                imageView.image = UIImage(named: "gameOver")
                gameOverAlert()
            } else {
                showAlert(title: title, message: message)
                nextRound(rowRus: rowRus, rowEng: rowEng)
            }
            
            
        } else {
            score -= 1
            title = "Lose! 😭"
            message = "-1 point"
            showAlert(title: title, message: message)
        }
        
    }
    
    func gameOverAlert() {
        let ac = UIAlertController(title: "Game Over", message: "Your score is \(score)", preferredStyle: .alert)
        let restart = UIAlertAction(title: "Restart", style: .cancel) { (_) in
            self.restartGame()
        }
        ac.addAction(restart)
        present(ac, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let next = UIAlertAction(title: "Next", style: .cancel, handler: nil)
        ac.addAction(next)
        present(ac, animated: true)
    }
    func nextRound(rowRus: Int, rowEng: Int) {
        rusFruitsNames.remove(at: rowRus)
        engFruitsNames.remove(at: rowEng)
        
        pickerFruits.reloadAllComponents()
        pickImage()
    }
    
    func pickImage() {
        let rowRus = pickerFruits.selectedRow(inComponent: 0)
        imageView.image = UIImage(named: rusFruitsNames[rowRus])
        
    }
    
    func restartGame() {
        rusFruitsNames = rusSave
        engFruitsNames = engSave
        startGame()
        pickerFruits.selectRow(0, inComponent: 0, animated: false)
        pickerFruits.selectRow(0, inComponent: 1, animated: false)
        pickerFruits.reloadAllComponents()
    }
    
    @IBAction func restartButton(_ sender: UIButton) {
        restartGame()
    }
    
    
}

