//
//  ViewController.swift
//  DDDemo
//
//  Created by Mars Geldard on 30/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var clearButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var classifyButton: UIButton!
    
    @IBAction func clearButtonPressed(_ sender: Any) { clear() }
    @IBAction func undoButtonPressed(_ sender: Any) { undo() }
    @IBAction func classifyButtonPressed(_ sender: Any) { classify() }
    
    var classification: String? = nil
    private var strokes: [CGMutablePath] = []
    private var currentStroke: CGMutablePath? { return strokes.last }
    private var imageViewSize: CGSize { return imageView.frame.size }
    private let classifier = DrawingClassifierModelStrokes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        undoButton.disable()
        classifyButton.disable()
    }
    
    // new stroke started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let newStroke = CGMutablePath()
        newStroke.move(to: touch.location(in: imageView))
        strokes.append(newStroke)
        refresh()
    }
    
    // stroke moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let currentStroke = self.currentStroke else { return }
        
        currentStroke.addLine(to: touch.location(in: imageView))
        refresh()
    }
    
    
    // stroke ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let currentStroke = self.currentStroke else { return }
        
        currentStroke.addLine(to: touch.location(in: imageView))
        refresh()
    }
    
    // undo last stroke
    func undo() {
        let _ = strokes.removeLast()
        refresh()
    }
    
    // clear all strokes
    func clear() {
        strokes = []
        classification = nil
        refresh()
    }
    
    // refresh view to reflect paths
    func refresh() {
        if self.strokes.isEmpty { self.imageView.image = nil }
        
        let drawing = makeImage(from: self.strokes)
        self.imageView.image = drawing
        
        if classification != nil {
            undoButton.disable()
            clearButton.enable()
            classifyButton.disable()
        } else if !strokes.isEmpty {
            undoButton.enable()
            clearButton.enable()
            classifyButton.enable()
        } else {
            undoButton.disable()
            clearButton.disable()
            classifyButton.disable()
        }
        
        classLabel.text = classification ?? ""
    }
    
    // draw strokes on image
    func makeImage(from strokes: [CGMutablePath]) -> UIImage? {
        let image = CGContext.create(size: imageViewSize) { context in
            context.setStrokeColor(UIColor.black.cgColor)
            context.setLineWidth(8.0)
            context.setLineJoin(.round)
            context.setLineCap(.round)
            
            for stroke in strokes {
                context.beginPath()
                context.addPath(stroke)
                context.strokePath()
            }
        }

        return image
    }
    
    func classify() {
        guard let grayscaleImage = imageView.image?.applying(filter: .noir) else { return }
        
        classifyButton.disable()
        classifier.classify(grayscaleImage) { result in
            self.classification = result?.icon
            
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
}

