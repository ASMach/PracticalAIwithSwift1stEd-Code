//
//  Drawing.swift
//  DDDemo
//
//  Created by Mars Geldard on 30/6/19.
//  Copyright © 2019 Mars Geldard. All rights reserved.
//

// BEGIN ddnew_drawing_imports
import UIKit
import Vision
// END ddnew_drawing_imports

// BEGIN ddnew_drawing_enum
enum Drawing: String, CaseIterable {
    /// These only include those the model was trained on
    /// For others that can be included in the training phase, see the 
    /// full list of categories in the dataset:
    /// https://raw.githubusercontent.com/googlecreativelab/
    ///     quickdraw-dataset/master/categories.txt
    case apple, banana, bread, broccoli, cake, carrot, coffee, cookie
    case donut, grapes, hotdog, icecream, lollipop, mushroom, peanut, pear
    case pineapple, pizza, potato, sandwich, steak, strawberry, watermelon
    
    // BEGIN ddnew_drawing_enum0
    init?(rawValue: String) {
        if let match = 
            Drawing.allCases.first(where: { $0.rawValue == rawValue }) {
            self = match
        } else {
            switch rawValue {
                case "coffee cup":  self = .coffee
                case "hot dog":     self = .hotdog
                case "ice cream":   self = .icecream
                default: return nil
            }
        }
    }
    // END ddnew_drawing_enum0
    
    // BEGIN ddnew_drawing_enum1
    var icon: String {
        switch self {
        case .apple: return "🍎"
        case .banana: return "🍌"
        case .bread: return "🍞"
        case .broccoli: return "🥦"
        case .cake: return "🎂"
        case .carrot: return "🥕"
        case .coffee: return "☕️"
        case .cookie: return "🍪"
        case .donut: return "🍩"
        case .grapes: return "🍇"
        case .hotdog: return "🌭"
        case .icecream: return "🍦"
        case .lollipop: return "🍭"
        case .mushroom: return "🍄"
        case .peanut: return "🥜"
        case .pear: return "🍐"
        case .pineapple: return "🍍"
        case .pizza: return "🍕"
        case .potato: return "🥔"
        case .sandwich: return "🥪"
        case .steak: return "🥩"
        case .strawberry: return "🍓"
        case .watermelon: return "🍉"
        }
    }
    // END ddnew_drawing_enum1
}
// END ddnew_drawing_enum

// BEGIN ddnew_drawing_vnirh
extension VNImageRequestHandler {
    convenience init?(uiImage: UIImage) {
        guard let ciImage = CIImage(image: uiImage) else { return nil }
        let orientation = uiImage.cgImageOrientation
        
        self.init(ciImage: ciImage, orientation: orientation)
    }
}
// END ddnew_drawing_vnirh

// BEGIN ddnew_drawing_dcm
extension DrawingClassifierModel {    
    func classify(_ image: UIImage?, 
        completion: @escaping (Drawing?) -> ()) {

        guard let image = image,
            let model = try? VNCoreMLModel(for: self.model) else {
                return completion(nil)
        }
        
        let request = VNCoreMLRequest(model: model)
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let handler = VNImageRequestHandler(uiImage: image) {

                try? handler.perform([request])

                let results = request.results 
                    as? [VNClassificationObservation]

                let highestResult = 
                    results?.max { $0.confidence < $1.confidence }

                print(results?.list ?? "")

                completion(
                    Drawing(rawValue: highestResult?.identifier ?? "")
                )
            } else {
                completion(nil)
            }
        }
    }
}
// END ddnew_drawing_dcm

// BEGIN ddnew_drawing_collection
extension Collection where Element == VNClassificationObservation {
    var list: String {
        var string = ""
        for element in self {
            string += "\(element.identifier): " +
                "\(element.confidence * 100.0)%\n"
        }
        return string
    }
}
// END ddnew_drawing_collection
