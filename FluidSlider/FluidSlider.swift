//
//  FluidSlider.swift
//  Fluid Slider
//
//  Created by Nathan Ansel on 10/12/17.
//  Copyright © 2017 Nathan Ansel. All rights reserved.
//

import UIKit

@IBDesignable
public class FluidSlider: UIControl {
	
	// MARK: - Properties
	
	// MARK: Public
	
	/// The minimum value of the slider
	@IBInspectable
	public var minimumValue: Double = 0
	
	/// The maximum value of the slider.
	@IBInspectable
	public var maximumValue: Double = 1000
	
	/// The current value of the slider.
	@IBInspectable
	public var currentValue: Double = 0
	
	/// The step that the slider will snap to while dragging. If set to less than or equal to `0`, `step` will
	/// automatically get set to `nil`, as those are illegal values. If set to greater than `maximumValue - minimumValue`,
	/// `step` will automatically get set to `maximumValue - minimumValue`. If the
	@IBInspectable
	public var step: Double = 1 {
		didSet {
			guard step != 0 else { return }
			guard step > 0 else { step = 0; return }
			let maxStep = maximumValue - minimumValue
			if step > maxStep {
				step = maxStep
			}
		}
	}
	
	// MARK: Internal
	
	// MARK: Private
	
	private let trackLayer = CALayer()
	private let thumbLayer = LabelLayer()
	
	private var thumbHeight: CGFloat {
		return frame.height - (thumbInset * 2)
	}
	
	// MARK: Layout Variables
	
	private let thumbInset: CGFloat = 5
	
	// MARK: Methods
	
	// MARK: Init
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		backgroundColor = .red
		
		trackLayer.backgroundColor = UIColor.blue.cgColor
		layer.addSublayer(trackLayer)
		
		thumbLayer.backgroundColor = UIColor.green.cgColor
		layer.addSublayer(thumbLayer)
		thumbLayer.anchorPoint = .zero
		
		updateTrackLayer()
		updateThumbLayer()
	}
	
	// MARK: Layout
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		updateTrackLayer()
		updateThumbLayer()
	}
	
	private func updateTrackLayer() {
		trackLayer.frame = bounds.insetBy(dx: 0, dy: (bounds.height - 3) / 2)
	}
	
	private func updateThumbLayer() {
		thumbLayer.text = "\(currentValue)"
		
		let thumbCenterX = positionForValue(value: currentValue)
		let width = max(thumbHeight, thumbLayer.textWidth() + 16)
		let y = isTracking ? -(thumbHeight + thumbInset) : thumbInset
		thumbLayer.frame = CGRect(
			x: thumbCenterX - (width / 2),
			y: y,
			width: width,
			height: thumbHeight)
		thumbLayer.cornerRadius = thumbHeight / 2
	}
	
	private func positionForValue(value: Double) -> CGFloat {
		let top = (trackLayer.bounds.width - thumbHeight) * CGFloat(value - minimumValue)
		let bottom = CGFloat(maximumValue - minimumValue)
		return (top / bottom)  + (thumbHeight / 2.0)
	}
	
	// MARK: Value Computations
	
	private func bound(value: Double, min: Double, max: Double) -> Double {
		if value < min { return min }
		if value > max { return max }
		return nearestStep(to: value)
	}
	
	private func value(for position: CGPoint) -> Double {
		let value = (maximumValue - minimumValue) * Double(position.x - (thumbHeight / 2)) / Double(trackLayer.bounds.width - thumbHeight)
		return value
	}
	
	/// Calculates the nearest step value to a given value. If `step` is nil, this method returns the given value.
	///
	/// - parameter value: The value to calulate with.
	private func nearestStep(to value: Double) -> Double {
		guard step > 0 else { return value }
		
		let numberOfCurrentSteps = Int((value - minimumValue) / step)
		
		let minStepValue = minimumValue + (step * Double(numberOfCurrentSteps))
		var maxStepValue = minStepValue + step
		if maxStepValue > maximumValue { maxStepValue = maximumValue }
		
		let minOffset = value - minStepValue
		let maxOffset = maxStepValue - value
		
		let closestValue: Double
		if minOffset > maxOffset {
			closestValue = maxStepValue
		} else {
			closestValue = minStepValue
		}
		
		return closestValue
	}
	
	// MARK: Touch Tracking
	
	public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		let beginTracking = thumbLayer.frame.contains(location)
		if beginTracking {
			sendActions(for: .editingDidBegin)
		}
		animateThumbLayerUp()
		return beginTracking
	}
	
	public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let location = touch.location(in: self)
		let oldCurrentValue = currentValue
		
		// Update the values
		currentValue = value(for: location)
		currentValue = bound(value: currentValue, min: minimumValue, max: maximumValue)
		
		// Update the UI
		CATransaction.begin()
		CATransaction.setDisableActions(true)
		
		updateThumbLayer()
		
		CATransaction.commit()
		if oldCurrentValue != currentValue {
			sendActions(for: .valueChanged)
		}
		return true
	}
	
	public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		super.endTracking(touch, with: event)
		sendActions(for: .editingDidEnd)
		animateThumbLayerDown()
	}
	
	// MARK: - Animations
	
	private func animateThumbLayerUp() {
		let animation = CASpringAnimation(keyPath: "position")
//		animation.damping = 5
		animation.duration = 0.5
//		animation.stiffness = 50
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		animation.fromValue = thumbLayer.position
		let endPosition = CGPoint(x: thumbLayer.position.x, y: -(thumbHeight + thumbInset))
		animation.toValue = endPosition
		thumbLayer.position = endPosition
		thumbLayer.add(animation, forKey: "position")
	}
	
	private func animateThumbLayerDown() {
		let animation = CASpringAnimation(keyPath: "position")
		animation.damping = 8
		animation.duration = 0.5
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		animation.fromValue = thumbLayer.position
		let endPosition = CGPoint(x: thumbLayer.position.x, y: thumbInset)
		animation.toValue = endPosition
		thumbLayer.add(animation, forKey: "position")
		thumbLayer.position = endPosition
	}
}
