//
//  MinimalCircleGraph.swift
//  Group Poll
//
//  Created by Andrew H on 8/1/16.
//  Copyright © 2016 Andrew H. All rights reserved.
//

import UIKit

public class MinimalPieChart: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    static let defaultColors = [#colorLiteral(red: 0.3137254902, green: 0.8235294118, blue: 0.7607843137, alpha: 1), #colorLiteral(red: 0.9333333333, green: 0.5607843137, blue: 0.431372549, alpha: 1), #colorLiteral(red: 1, green: 0.2, blue: 0.4, alpha: 1), #colorLiteral(red: 0.7294117647, green: 0.4666666667, blue: 1, alpha: 1)]
    
    public var items: [CGFloat]
    public var lineWidth: CGFloat
    
    private var pathLayers = [CAShapeLayer]()
    private var orderedIndices: [Int]
    private let colors: [UIColor]
    private var oldFrame: CGRect?
    
    public init?(frame: CGRect, items: [CGFloat], colors: [UIColor] = defaultColors, lineWidth: CGFloat = 3.0) {
        guard colors.count >= items.count else { return nil }
        
        self.items = items
        self.colors = colors
        self.lineWidth = lineWidth
        
        self.orderedIndices = items.indices.sorted(by: { return items[$0] > items[$1] })
        
        super.init(frame: frame)
        
        let sum = items.reduce(0.0, { $0 + $1 })
        var currentPercent: CGFloat = 0.0
        var tempLayers = [CAShapeLayer?](repeating: nil, count: self.items.count)
        for index in orderedIndices {
            let partPercent = self.items[index] / sum
            
            let partLayer = CAShapeLayer()
            // partLayer.path will be set in layoutSubviews
            partLayer.fillColor = UIColor.clear.cgColor
            partLayer.strokeColor = colors[index].cgColor
            partLayer.lineWidth = lineWidth
            
            partLayer.strokeStart = currentPercent
            currentPercent += partPercent
            partLayer.strokeEnd = currentPercent
            
            self.layer.addSublayer(partLayer)
            tempLayers[index] = partLayer
        }
        pathLayers = tempLayers.flatMap({ $0 })
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not implemented yet for MinimalPieChart")
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        guard layer == self.layer else {
            super.layoutSublayers(of: layer)
            return
        }
        
        updatePathIfNeeded()
    }
    
    private func updatePathIfNeeded() {
        guard self.frame != oldFrame else { return }
        oldFrame = self.frame
        
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let radius = min(self.frame.size.width, self.frame.size.height) / 2.0 - lineWidth
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI * 2.0 - M_PI_2), clockwise: true).cgPath
        
        for pathLayer in pathLayers {
            pathLayer.path = path
        }
    }
    
    public func animate() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 1.0
        anim.fromValue = 0.0
        anim.toValue = 1.0
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        for pathLayer in pathLayers {
            pathLayer.add(anim, forKey: "strokeEndAnimation")
        }
    }
    
    public func update(animated: Bool) {
        guard pathLayers.count == items.count else { fatalError("You cannot add or remove items") }
        
        let sum = items.reduce(0.0, { $0 + $1 })
        
        var currentPercent: CGFloat = 0.0
        
        CATransaction.begin()
        CATransaction.setDisableActions(!animated)
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut))
        
        for index in orderedIndices {
            let partPercent = items[index] / sum
            let partLayer = pathLayers[index]

            partLayer.strokeStart = currentPercent
            currentPercent += partPercent
            partLayer.strokeEnd = currentPercent

        }
        CATransaction.commit()

    }
    
}
