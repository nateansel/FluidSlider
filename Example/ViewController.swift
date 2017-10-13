//
//  ViewController.swift
//  Example
//
//  Created by Nathan Ansel on 10/12/17.
//  Copyright © 2017 Nathan Ansel. All rights reserved.
//

import UIKit
import FluidSlider

class ViewController: UIViewController {

	@IBOutlet weak var slider: FluidSlider!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.setNeedsDisplay()
	}
	
	@objc
	private func sliderDidStartMoving(_ sender: FluidSlider) {
		print("Slider: \(sender) started moving.")
	}
	
	@objc
	private func sliderDidStopMoving(_ sender: FluidSlider) {
		print("Slider: \(sender) stopped moving.")
	}
	
	@objc
	private func sliderChangedValued(_ sender: FluidSlider) {
		print("Slider: \(sender) changed value: \(sender.currentValue).")
	}
}

