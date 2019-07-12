//
//  ShapeView.swift
//  GesrRecogniserTwo
//
//  Created by Yury Popov on 09/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class ShapeView2: UIView {

    let size: CGFloat = 150
    let lineWidth: CGFloat = 3
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        center = origin
        backgroundColor = UIColor.clear
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10)
        
        randomColor().setFill()
        path.fill()
        
//         далее код для рамки

        path.lineWidth = lineWidth
        UIColor.black.setStroke()
        path.stroke()
    }

    

    

    
    // random color
    func randomColor() -> UIColor {
        let hue: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
        
    }
}



