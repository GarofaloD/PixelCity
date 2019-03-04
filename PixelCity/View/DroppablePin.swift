//
//  DroppablePin.swift
//  PixelCity
//
//  Created by Daniel Garofalo on 3/1/19.
//  Copyright © 2019 Daniel Garofalo. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//To create a custom pin
class DroppablePin : NSObject, MKAnnotation { //REquires two extra classes
    
    //MARK:- Properties
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier : String
    
    //MARK:- Custom Functions
    init(coordinate: CLLocationCoordinate2D, identifier: String ) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
