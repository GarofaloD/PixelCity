//
//  PopViewController.swift
//  PixelCity
//
//  Created by Daniel Garofalo on 3/10/19.
//  Copyright © 2019 Daniel Garofalo. All rights reserved.
//

import UIKit

class PopViewController: UIViewController, UIGestureRecognizerDelegate {

    //MARK:- Outlets
    @IBOutlet weak var popImageView: UIImageView!
    
    
    //MARK:- Properties
    var passedImage : UIImage!
    
    
    //MARK:- Load up functions
    override func viewDidLoad() {
        super.viewDidLoad()

        popImageView.image = passedImage
        addDoubleTap()
    }
    
    //MARK:- Custom functions
    func initData(forImage image: UIImage){
        self.passedImage = image
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(PopViewController.screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped(){
        dismiss(animated: true, completion: nil)
    }
    
    
    
    

}
