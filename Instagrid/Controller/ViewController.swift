//
//  ViewController.swift
//  Instagrid
//
//  Created by Zidouni on 03/12/2022.
//

import UIKit
import Photos

class ViewController: UIViewController {
    // MARK: - Public Properties
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    // MARK: - Private Properties
    private var buttonImage: UIButton?
    private var imagePicked: UIImagePickerController?
    private var buttonImageView: UIImageView?
    private var activityViewController: UIActivityViewController?
    
    // MARK: - Properties connected to storyboard
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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if checkLibraryAuthorization() {
            print("We have the permission to access at your library")
        }
        
        buttonLayout1.tag = 1
        buttonLayout2.tag = 2
        buttonLayout3.tag = 3
        
        layout3Selected.isHidden = false
        
        addSwipeGestureRecognizer()
        buttonImageViewTapped()
        
    }
    // MARK: - Security Methods
    
    // Added a function to check library authorization.
    private func checkLibraryAuthorization() -> Bool {
        var status = false
        
        let libraryAuthorization = PHPhotoLibrary.authorizationStatus()
        switch libraryAuthorization {
        case .authorized:
            status = true
            
        case .notDetermined: // If the authorization isn't determined we check if the new status is authorized or not.
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
    // MARK: - Layout Buttons Methods
    
    // Added an action to control which layout is selected.
    @IBAction func layoutButtonsTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            buttonLayout1.isSelected = true
            buttonLayout2.isSelected = false
            buttonLayout3.isSelected = false
            
            buttonUpRight.isHidden = true
            buttonDownRight.isHidden = false
            layoutIsSelected()
            
        case 2:
            buttonLayout1.isSelected = false
            buttonLayout2.isSelected = true
            buttonLayout3.isSelected = false
            
            buttonUpRight.isHidden = false
            buttonDownRight.isHidden = true
            layoutIsSelected()
            
        case 3:
            buttonLayout1.isSelected = false
            buttonLayout2.isSelected = false
            buttonLayout3.isSelected = true
            
            buttonUpRight.isHidden = false
            buttonDownRight.isHidden = false
            layoutIsSelected()
        default:
            break
        }
    }
    
    private func layoutIsSelected() {
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
    // MARK: - Grid Central Views Methods
    
    // We create a method to add a tap recognizer when the user want to add an image inside the grid central view.
    private func buttonImageViewTapped() {
        // We are a case for each button.
        let tapUpLeftButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:)))
        buttonUpLeft.isUserInteractionEnabled = true
        buttonUpLeft.addGestureRecognizer(tapUpLeftButtonRecognizer)
        
        let tapUpRightButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:)))
        buttonUpRight.isUserInteractionEnabled = true
        buttonUpRight.addGestureRecognizer(tapUpRightButtonRecognizer)
        
        let tapDownLeftButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:)))
        buttonDownLeft.isUserInteractionEnabled = true
        buttonDownLeft.addGestureRecognizer(tapDownLeftButtonRecognizer)
        
        let tapDownRightButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage(_:)))
        buttonDownRight.isUserInteractionEnabled = true
        buttonDownRight.addGestureRecognizer(tapDownRightButtonRecognizer)
        
    }
    
    // We add a method their call when the user tap the button. This method permit to choose an image inside user's library.
    @objc private func chooseImage(_ recognizer: UITapGestureRecognizer) {
        if checkLibraryAuthorization() { // We check the library autorization, if their true we permit the user to choose an image.
            let newImage = recognizer.view
            buttonImageView = newImage as! UIImageView? // We check if the button is an UIImageView
            imagePicked = UIImagePickerController()
            imagePicked?.delegate = self // We call the delegate property because she's necessary to use the picker controller.
            imagePicked?.sourceType = .savedPhotosAlbum // We use the user library for the sourceType.
            guard let imagePickerSecurity = imagePicked else { return }
    
            present(imagePickerSecurity, animated: true)
            
        } else {
            // We create an alert if the user not authorize the library acces.
            let accessDenied = UIAlertController(title: "Acces denied", message: "Please authorize the access inside your phone parameters's", preferredStyle: UIAlertController.Style.alert)
            accessDenied.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(accessDenied, animated: true, completion: nil)
        }
    }
    
    // We create a method to change the content mode of button image view.
    private func insertPickedImageIntoMainGrid(_ image: UIImage) {
        buttonImageView?.contentMode = .scaleAspectFill
        buttonImageView?.image = image
    }
    
    // MARK: - Share and Swipe Methods
    
    // We create a method to add a swipe gesture recognizer when the user want to share his layout.
    private func addSwipeGestureRecognizer() {
        // We have a swipe gesture recognizer for 2 orientation (portrait and landscape).
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridCentralView(_:)))
        swipeUpGestureRecognizer.direction = .up
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeGridCentralView(_:)))
        swipeLeftGestureRecognizer.direction = .left
        
        view.addGestureRecognizer(swipeUpGestureRecognizer)
        view.addGestureRecognizer(swipeLeftGestureRecognizer)
    }
    
    // We create a method when the swipe gesture is recognized.
    @objc func swipeGridCentralView(_ recognizer: UISwipeGestureRecognizer) {
        
        // We create a condition to control of the current device version is iOS16.
        // If this is the case, the property to control device orientation is not the same to iOS15 or less version.
        if #available(iOS 16.0, *) {
            
            guard let windowScene = view.window?.windowScene else { return }
            
            if windowScene.effectiveGeometry.interfaceOrientation.isPortrait, recognizer.direction == .up{
                self.animationPortrait()
                shareTheLayout(direction: .up)
                
            } else if windowScene.effectiveGeometry.interfaceOrientation.isLandscape, recognizer.direction == .left {
                self.animationLandscape()
                shareTheLayout(direction: .left)
            }
        } else {
            // Fallback on earlier versions
            if UIDevice.current.orientation.isPortrait, recognizer.direction == .up{
                self.animationPortrait()
                shareTheLayout(direction: .up)
                
            } else if UIDevice.current.orientation.isLandscape, recognizer.direction == .left {
                self.animationLandscape()
                shareTheLayout(direction: .left)
                
            }
        }
    }
    
    // We create a method to define animation for the Landscape orientation's.
    private func animationLandscape() {
        UIView.animate(withDuration: 0.6) {
            self.gridCentralView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
            self.swipeUpView.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: 0)
        }
    }
    
    // We create a method to define animation for the Portrait orientation's.
    private func animationPortrait() {
        UIView.animate(withDuration: 0.6) {
            self.gridCentralView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
            self.swipeUpView.transform = CGAffineTransform(translationX: 0, y: -UIScreen.main.bounds.height)
        }
    }
    
    // We create a function to display the activity view controller.
    private func shareTheLayout(direction: UISwipeGestureRecognizer.Direction){
        guard let imageView = gridCentralView.asImage() else { return } // We control if the grid central view as image.
        activityViewController = UIActivityViewController(activityItems: [imageView as UIImage], applicationActivities: nil)
        guard let activityVC = activityViewController else { return }
        
        activityVC.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            UIView.animate(withDuration: 0.4) { // We transform each view in is identity position after when we close the activity controller.
                self.gridCentralView.transform = .identity
                self.swipeUpView.transform = .identity
                self.activityViewController = nil
            }
        }
        present(activityVC, animated: true, completion: nil)
    }
}
//MARK: - Extension

// We create an extension to make the possibility, for the user, to pick an image inside their library.
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ _picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any] ) {
       
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            insertPickedImageIntoMainGrid(originalImage)
            dismiss(animated: true) {
                self.imagePicked = nil
                self.buttonImageView = nil
            }
        }
    }
}
