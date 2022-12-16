//
//  ViewController.swift
//  Instagrid
//
//  Created by Zidouni on 03/12/2022.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    private var buttonImage: UIButton?
    private var imagePicked: UIImagePickerController?
    private var activityViewController: UIActivityViewController?
    
    @IBOutlet weak var swipeUpView: UIStackView!
    
    @IBOutlet weak var buttonUpLeft: UIButton!
    @IBOutlet weak var buttonUpRight: UIButton!
    @IBOutlet weak var buttonDownLeft: UIButton!
    @IBOutlet weak var buttonDownRight: UIButton!
    
    @IBOutlet weak var buttonLayout1: UIButton!
    @IBOutlet weak var buttonLayout2: UIButton!
    @IBOutlet weak var buttonLayout3: UIButton!
    
    @IBOutlet weak var layout1Selected: UIImageView!
    @IBOutlet weak var layout2Selected: UIImageView!
    @IBOutlet weak var layout3Selected: UIImageView!
    
    @IBOutlet weak var gridCentralView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if checkLibraryAuthorization() {
            print("We have the permission to access at your library")
        }
        
        buttonLayout1.tag = 1
        buttonLayout2.tag = 2
        buttonLayout3.tag = 3
        
        layout3Selected.isHidden = false
     
        addSwipGestureRecognizer()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func addSwipGestureRecognizer() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridCentralView(_:)))
        swipeUpGestureRecognizer.direction = .up
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridCentralView(_:)))
        swipeLeftGestureRecognizer.direction = .left
       
        
        view.addGestureRecognizer(swipeUpGestureRecognizer)
        view.addGestureRecognizer(swipeLeftGestureRecognizer)
    }
    
    @objc func swipeGridCentralView(_ recognizer: UISwipeGestureRecognizer) {
 
        if UIDevice.current.orientation.isPortrait, recognizer.direction == .up{
            self.animationPortrait()
            
            
        } else if UIDevice.current.orientation.isLandscape, recognizer.direction == .left {
            
            self.animationLandscape()
           
            
        }
    }
    
    func animationLandscape() {
        UIView.animate(withDuration: 0.6) {
            self.gridCentralView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
            self.swipeUpView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        }
    }
    
    func animationPortrait() {
        UIView.animate(withDuration: 0.6) {
            self.gridCentralView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
            self.swipeUpView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        }
    }
    
    @IBAction func addPhoto(_ sender: UIButton) {
        if checkLibraryAuthorization() {
            buttonImage = sender
            imagePicked = UIImagePickerController()
            imagePicked?.delegate = self
            imagePicked?.sourceType = .savedPhotosAlbum
            guard let imagePickerSecurity = imagePicked else { return }

            present(imagePickerSecurity, animated: true)
            
        } else {
            let accessDenied = UIAlertController(title: "Acces denied", message: "Please authorize the access inside your phone parameters's", preferredStyle: UIAlertController.Style.alert)
            accessDenied.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(accessDenied, animated: true, completion: nil)
        }
    }

    @IBAction func layoutButtonsTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            buttonLayout1.isSelected = true
            buttonLayout2.isSelected = false
            buttonLayout3.isSelected = false
            
            buttonUpRight.isHidden = true
            buttonDownRight.isHidden = false
            isSelected()
        
        case 2:
            buttonLayout1.isSelected = false
            buttonLayout2.isSelected = true
            buttonLayout3.isSelected = false
            
            buttonUpRight.isHidden = false
            buttonDownRight.isHidden = true
            isSelected()
            
        case 3:
            buttonLayout1.isSelected = false
            buttonLayout2.isSelected = false
            buttonLayout3.isSelected = true
            
            buttonUpRight.isHidden = false
            buttonDownRight.isHidden = false
            isSelected()
        default:
            break
        }
    }
    
    func isSelected() {
        if buttonLayout1.isSelected == true {
            layout1Selected.isHidden = false
            layout2Selected.isHidden = true
            layout3Selected.isHidden = true
        } else if buttonLayout2.isSelected == true {
            layout1Selected.isHidden = true
            layout2Selected.isHidden = false
            layout3Selected.isHidden = true
        } else if buttonLayout3.isSelected == true {
            layout1Selected.isHidden = true
            layout2Selected.isHidden = true
            layout3Selected.isHidden = false
        }
    }
    
    func checkLibraryAuthorization() -> Bool {
        var status = false
        
        let libraryAuthorization = PHPhotoLibrary.authorizationStatus()
        switch libraryAuthorization {
        case .authorized:
            status = true
        
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    status = true
                }
            })
            
        case .restricted, .denied:
            break
            
        case .limited:
            print("Access Limited")
            
        @unknown default :
            break
        }
       
        return status
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ) {
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            buttonImage?.setImage(originalImage, for: .normal)
            dismiss(animated: true) {
                self.imagePicked = nil
                self.buttonImage = nil
            }
        }
    }
}
