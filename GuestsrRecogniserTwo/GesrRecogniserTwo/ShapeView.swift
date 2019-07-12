//
//  ShapeView.swift
//  GesrRecogniserTwo
//
//  Created by Yury Popov on 09/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class ShapeView: UIView {

    let size: CGFloat = 150
    let lineWidth: CGFloat = 3
    
    init(origin: CGPoint) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        center = origin
        backgroundColor = UIColor.clear
        
        initGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let insetRect = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        let path = UIBezierPath(roundedRect: insetRect, cornerRadius: 10)
        
        randomColor().setFill()
        path.fill()
        
        path.lineWidth = lineWidth
        UIColor.black.setStroke()
        path.stroke()
    }
    
    func initGestureRecognizers() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        addGestureRecognizer(panGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinc))
        addGestureRecognizer(pinchGR)
        
        let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
        addGestureRecognizer(rotationGR)
        
        panGR.delegate = self
        pinchGR.delegate = self
        rotationGR.delegate = self
        
    }
    
    @objc func didPan(panGR: UIPanGestureRecognizer) {
        superview?.bringSubviewToFront(self)
        
        var translation = panGR.translation(in: self) //вместо self можно поставить superview и эффект будет как со строчкой ниже. ЕЕ можно удалить
        // для плавного перемещения
        translation = translation.applying(transform)
        
        center.x += translation.x
        center.y += translation.y
        
        panGR.setTranslation(.zero, in: self)
    }
    
    @objc func didPinc(pinchGR: UIPinchGestureRecognizer) {
        superview?.bringSubviewToFront(self)
        
        let scale = pinchGR.scale
        
        transform = transform.scaledBy(x: scale, y: scale)
        
        pinchGR.scale = 1.0
    }
    
    @objc func didRotate(rotationGR: UIRotationGestureRecognizer) {
        //поднятие вью наверх
        superview?.bringSubviewToFront(self)
        
        let rotation = rotationGR.rotation
        
        transform = transform.rotated(by: rotation)
        
        rotationGR.rotation = 0
    }
    
    // random color
    func randomColor() -> UIColor {
        let hue: CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        return UIColor(hue: hue, saturation: 0.8, brightness: 1.0, alpha: 0.8)
        
    }
}
//метот что бы одновременно крутить и маштабировать, по умолчанию можно одновремменно делать один жест
extension ShapeView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


