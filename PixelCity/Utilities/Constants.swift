//
//  Constants.swift
//  PixelCity
//
//  Created by Daniel Garofalo on 3/6/19.
//  Copyright © 2019 Daniel Garofalo. All rights reserved.
//

import Foundation

//MARK:- Flickr Info
//https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=d0c764c2707c906d316334235ef2fc04&lat=42.8&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1
let FLICKR_API_KEY = "d06877f145932f664e86eda62d4935e4"
let BASEURL = "https://api.flickr.com/"


//MARK:- Functions
func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, addNumberOfPhotos number : Int) -> String{
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FLICKR_API_KEY)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.latitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


