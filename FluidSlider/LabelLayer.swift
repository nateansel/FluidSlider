//
//  LabelLayer.swift
//  FluidSlider
//
//  Created by Nathan Ansel on 10/12/17.
//  Copyright © 2017 Nathan Ansel. All rights reserved.
//

import UIKit

class LabelLayer: CALayer {
	
	// MARK: - Properties
	
	// MARK: Internal
	
	var text: String? {
		didSet {
			// Don't do anything if the text has stayed the same
			if oldValue != text {
				if let text = text {
					let paragraphStyle = NSMutableParagraphStyle()
					paragraphStyle.alignment = .center
					let fullRange = NSRange(location: 0, length: text.count)
					
					attrString = NSMutableAttributedString(string: text)
					attrString.addAttribute(
						.paragraphStyle,
						value: paragraphStyle,
						range: fullRange)
					attrString.addAttribute(
						.font,
						value: UIFont.systemFont(ofSize: 10),
						range: fullRange)
				} else {
					attrString = NSMutableAttributedString()
				}
				
				setNeedsDisplay()
			}
		}
	}
	
	// MARK: Private
	
	private var attrString = NSMutableAttributedString()
	
	// MARK: - Methods
	
	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)
		if let text = text {
			ctx.setFillColor(UIColor.darkText.cgColor)
			
			UIGraphicsPushContext(ctx)
			
			let fullRange = NSRange(location: 0, length: text.count)
			attrString.removeAttribute(.baselineOffset, range: fullRange)
			let baselineOffset = NSNumber(value: -Double((bounds.height / 2) - (attrString.size().height / 2)))
			attrString.addAttribute(
				.baselineOffset,
				value: baselineOffset,
				range: fullRange)
			
			attrString.draw(in: bounds)
			
			UIGraphicsPopContext()
		}
	}
}
