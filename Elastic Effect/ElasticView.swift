//
//  ElasticView.swift
//  Elastic Effect
//
//  Created by Fellipe Calleia on 2/11/18.
//  Copyright © 2018 Calleia. All rights reserved.
//

import UIKit

class ElasticView: UIView {
    
    private let topControlPointView = UIView()
    private let leftControlPointView = UIView()
    private let bottomControlPointView = UIView()
    private let rightControlPointView = UIView()
    
    private let elasticShape = CAShapeLayer()
    
    private lazy var displayLink : CADisplayLink = {
        let displayLink = CADisplayLink(target: self, selector: #selector(updateLoop))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        return displayLink
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupComponents()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        startUpdateLoop()
        animateControlPoints()
    }
    
    private func setupComponents() {
        elasticShape.fillColor = backgroundColor?.cgColor
        elasticShape.path = UIBezierPath(rect: self.bounds).cgPath
        layer.addSublayer(elasticShape)
        
        for controlPoint in [topControlPointView, leftControlPointView, bottomControlPointView, rightControlPointView] {
            
            addSubview(controlPoint)
            controlPoint.frame = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
            controlPoint.backgroundColor = UIColor.blue
        }
        
        positionControlPoints()
    }
    
    private func positionControlPoints(){
        topControlPointView.center = CGPoint(x: bounds.midX, y: 0.0)
        leftControlPointView.center = CGPoint(x: 0.0, y: bounds.midY)
        bottomControlPointView.center = CGPoint(x:bounds.midX, y: bounds.maxY)
        rightControlPointView.center = CGPoint(x: bounds.maxX, y: bounds.midY)
    }
    
    private func bezierPathForControlPoints() -> CGPath {
        
        // Create a UIBezierPath to hold your shape
        let path = UIBezierPath()
        
        // Extract the control point positions into four constants
        let top = topControlPointView.layer.presentation()?.position
        let left = leftControlPointView.layer.presentation()?.position
        let bottom = bottomControlPointView.layer.presentation()?.position
        let right = rightControlPointView.layer.presentation()?.position
        
        let width = frame.size.width
        let height = frame.size.height
        
        // Create the path by adding curves from corner to corner of the rectangle
        path.move(to: CGPoint.zero)
        path.addQuadCurve(to: CGPoint(x: width, y: 0), controlPoint: top!)
        path.addQuadCurve(to: CGPoint(x: width, y: height), controlPoint: right!)
        path.addQuadCurve(to: CGPoint(x: 0, y: height), controlPoint: bottom!)
        path.addQuadCurve(to: CGPoint(x: 0, y: 0), controlPoint: left!)
        
        return path.cgPath
    }
    
    @objc func updateLoop() {
        elasticShape.path = bezierPathForControlPoints()
    }
    
    private func startUpdateLoop() {
        displayLink.isPaused = false
    }
    
    private func stopUpdateLoop() {
        displayLink.isPaused = true
    }
    
    func animateControlPoints() {
        
        // How much control points will move
        let overshootAmount: CGFloat = 10.0
        
        // Wraps the upcoming UI changes in a single spring animation
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.5, options: [], animations: {
            
            // Move the control points up, left, down or right
            self.topControlPointView.center.y -= overshootAmount
            self.leftControlPointView.center.x -= overshootAmount
            self.bottomControlPointView.center.y += overshootAmount
            self.rightControlPointView.center.x += overshootAmount
            
            // Create another spring animation to bounce everything back
        }, completion: { _ in UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 0.15, initialSpringVelocity: 5.5, options: [], animations: {
            
            // Reset the control point positions
            self.positionControlPoints()
            
            // Stop the display link once things stop moving
        }, completion: { _ in
            self.stopUpdateLoop()
        })
        })
    }
}
