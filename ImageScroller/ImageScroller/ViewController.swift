//
//  ViewController.swift
//  ImageScroller
//
//  Created by Sergey Dunaev on 30/04/2019.
//  Copyright © 2019 SwiftLab. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
//        scrollView.contentSize = imageView.image!.size
        imageView.frame.size = imageView.image!.size
//        scrollView.minimumZoomScale = 0.1
//        scrollView.maximumZoomScale = 3
//        scrollView.zoomScale = 1 //текущее маштабирование
        setZoomParametrs(scrollView.bounds.size)
        scrollViewDidZoom(scrollView)
   
       
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setZoomParametrs(scrollView.bounds.size)
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    
    
    func setZoomParametrs(_ scrollViewSize: CGSize) {
        let imageSize = imageView.bounds.size //размер внутрненнего содержимого (картинки)
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = 3
        scrollView.zoomScale = minScale
    }
    
    //контент в центре scrollview
//    func centerContent() {
////        let centerOffsetX = (scrollView.contentSize.width - scrollView.frame.size.width) / 2
////        let centerOffsetY = (scrollView.contentSize.height - scrollView.frame.size.height) / 2
////        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
////        scrollView.setContentOffset(centerPoint, animated: true)
////        print(#function)
//
//    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }

}

extension ViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        print(#function)
//        centerContent()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(#function)
        scrollViewDidZoom(scrollView)
    }
}

