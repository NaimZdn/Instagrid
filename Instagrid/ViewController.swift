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
    private var imageTest: UIImageView?
    private var activityViewController: UIActivityViewController?
    private var imageTapped: UIImageView?
    
    @IBOutlet weak var swipeUpView: UIStackView!
    
    @IBOutlet weak var buttonUpLeft: UIImageView!
    @IBOutlet weak var buttonUpRight: UIImageView!
    @IBOutlet weak var buttonDownLeft: UIImageView!
    @IBOutlet weak var buttonDownRight: UIImageView!
    
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
        tapGesture()
        
    }
    
    func tapGesture() {
        let tapUpLeftButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            buttonUpLeft.isUserInteractionEnabled = true
            buttonUpLeft.addGestureRecognizer(tapUpLeftButtonRecognizer)
        
        
        let tapUpRightButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            buttonUpRight.isUserInteractionEnabled = true
            buttonUpRight.addGestureRecognizer(tapUpRightButtonRecognizer)
        
      
        let tapDownLeftButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            buttonDownLeft.isUserInteractionEnabled = true
            buttonDownLeft.addGestureRecognizer(tapDownLeftButtonRecognizer)
    
 
        let tapDownRightButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            buttonDownRight.isUserInteractionEnabled = true
            buttonDownRight.addGestureRecognizer(tapDownRightButtonRecognizer)
        
    }
    
    @objc func imageTapped(_ recognizer: UITapGestureRecognizer) {
        var newImage = recognizer.view
        imageTest = newImage as! UIImageView?
        if checkLibraryAuthorization() {
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
            shareTheLayout(direction: .up)
            
        } else if UIDevice.current.orientation.isLandscape, recognizer.direction == .left {
            
            self.animationLandscape()
            shareTheLayout(direction: .left)
            
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
    
    private func shareTheLayout(direction: UISwipeGestureRecognizer.Direction){
        guard let imageView = gridCentralView.asImage() else { return }
        activityViewController = UIActivityViewController(activityItems: [imageView as UIImage], applicationActivities: nil)
        guard let activityVC = activityViewController else { return }
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            
            UIView.animate(withDuration: 0.4) {
                self.gridCentralView.transform = .identity
                self.swipeUpView.transform = .identity
                self.activityViewController = nil
            }
            
        }
        present(activityVC, animated: true, completion: nil)
        
    }

    func insertPickedImageIntoMainGrid(_ image: UIImage) {
        print(imageTest?.contentMode == .scaleAspectFill)
        imageTest?.contentMode = .scaleAspectFill
        imageTest?.image = image
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
            insertPickedImageIntoMainGrid(originalImage)
            dismiss(animated: true) {
                self.imagePicked = nil
                self.imageTest = nil
            }
        }
    }
}
