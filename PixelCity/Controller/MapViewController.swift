//
//  MapViewController.swift
//  PixelCity
//
//  Created by Daniel Garofalo on 2/28/19.
//  Copyright © 2019 Daniel Garofalo. All rights reserved.
//

import UIKit
import MapKit
import Alamofire


class MapViewController: UIViewController {
    
    //MARK:- Properties
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK:- Outlets
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
    }
    


    //MARK:- Buttons
    @IBAction func centerWhenPressed(_ sender: UIButton) {
        
        
    }
    
    
    
    
    
    //MARK:- Custom functions
    
    
    

}


extension MapViewController: MKMapViewDelegate {
    
}


