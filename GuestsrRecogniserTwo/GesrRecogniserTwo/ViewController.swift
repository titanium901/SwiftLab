//
//  ViewController.swift
//  GesrRecogniserTwo
//
//  Created by Yury Popov on 09/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //три тапа подрят создают треугольник
        let tapGR3 = UITapGestureRecognizer(target: self, action: #selector(didTapMakeTriangle))
        tapGR3.numberOfTapsRequired = 3
        view.addGestureRecognizer(tapGR3)
        
        //четыре тапа подрят создают квадрат
        let tapGR4 = UITapGestureRecognizer(target: self, action: #selector(didTapMakeSquare))
        tapGR4.numberOfTapsRequired = 4
        view.addGestureRecognizer(tapGR4)
        
        //пять тапов подрят создают пятиугольник
        let tapGR5 = UITapGestureRecognizer(target: self, action: #selector(didTapMakPentagone))
        tapGR5.numberOfTapsRequired = 5
        view.addGestureRecognizer(tapGR5)
        
        // нажатия одним пальцем сразу создают треугольник
        let tapGR6 = UITapGestureRecognizer(target: self, action: #selector(didTapMakeTriangle))
        tapGR6.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGR6)
        
        //нажатие двумя пальцами создают квадрат
        let tapGR7 = UITapGestureRecognizer(target: self, action: #selector(didTapMakeSquare))
        tapGR7.numberOfTouchesRequired = 2
        view.addGestureRecognizer(tapGR7)
        
        //нажатие тремя пальцами создают пятиугольник
        let tapGR8 = UITapGestureRecognizer(target: self, action: #selector(didTapMakPentagone))
        tapGR8.numberOfTouchesRequired = 3
        view.addGestureRecognizer(tapGR8)
        
        
        
        //что бы жесты как бы не пересекались 
        tapGR3.require(toFail: tapGR4)
        tapGR4.require(toFail: tapGR5)
        //первый там подождет не выполниться ли 3 и более быстрых нажатий
        tapGR6.require(toFail: tapGR5)
        tapGR6.require(toFail: tapGR7)
        tapGR7.require(toFail: tapGR8)
    }
    

    
    //создаем треуголбник
    @objc func didTapMakeTriangle(tapGR: UITapGestureRecognizer) {
        print(#function)
        let tapPoint = tapGR.location(in: view)
        let shapeView = TriangleView(frame: CGRect(x: 0, y: 0, width: 150, height: 170))
        shapeView.center = tapPoint
        let randomRotate: [CGFloat] = [90, 180, 360, 0]
        shapeView.rotate(angle: randomRotate.randomElement()!)
        
        view.addSubview(shapeView)
    }
    
    //создаем квадрат
    @objc func didTapMakeSquare(tapGR: UITapGestureRecognizer) {
        let tapPoint = tapGR.location(in: view)
        let shapeView = ShapeView2(origin: tapPoint)
        view.addSubview(shapeView)
    }
    
    //создаем пятиугольник
    @objc func didTapMakPentagone(tapGR: UITapGestureRecognizer) {
        let tapPoint = tapGR.location(in: view)
        let shapeView = PentagonView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        shapeView.center = tapPoint
        let randomRotate: [CGFloat] = [90, 180, 360, 0]
        shapeView.rotate(angle: randomRotate.randomElement()!)
        view.addSubview(shapeView)
    }


}

//метот для переворота view
extension UIView {
    
    /**
     Rotate a view by specified degrees
     
     - parameter angle: angle in degrees
     */
    func rotate(angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
    }
    
}
