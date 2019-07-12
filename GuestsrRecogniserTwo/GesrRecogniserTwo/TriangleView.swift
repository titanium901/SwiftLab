//
//  ShapeView.swift
//  GesrRecogniserTwo
//
//  Created by Yury Popov on 09/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        
       
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: 70, y: 40)) // поднесли карандаш к данной точке
        //меняем  y для более острого треугольника
        path.addLine(to: CGPoint(x: 130, y: 160)) // провели линию от точки выше к (130, 140)
        path.addLine(to: CGPoint(x: 5, y: 160)) // провели еще лини от точки выше к (5, 140)
        
        path.close() // закрыли путь, т.е. провели линию от последней точки (5, 140) к первой точке (70, 40)
        
        randomColor().setFill()    // задали цвет заливки
        UIColor.black.setStroke() // задали цвет линии пути
        path.lineWidth = 3.0             // ширина линии пути
        path.fill()                      // залили треугольник
        path.stroke()                    // отрисовали путь
        
        
 

        
    }
    
    func randomColor() -> UIColor {
        let hue: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
        
    }
}


//еще один способ

//class TriangleView : UIView {
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    override func draw(_ rect: CGRect) {
//
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//
//        context.beginPath()
//        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
//        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
//        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
//        context.closePath()
//
//        context.setFillColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.60)
//        context.fillPath()
//    }
//}
