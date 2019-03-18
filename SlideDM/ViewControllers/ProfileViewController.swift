//
//  ProfileViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//
// TODO:
// [] Load profile picture from local storage

import UIKit
import CodableFirebase

class ProfileViewController: UIViewController {
    
    // Images
    var backgroundImageView = UIImageView()
    @IBOutlet weak var profileImage: UIImageView!
    // Labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingTabLabel: UILabel!
    // Input Areas
    @IBOutlet weak var greetingTagTextView: UITextView!
    // Bookkeepings
    var greetingTagOldText: String = ""
    var profileImageChanged: Bool = false
    // Buttons
    @IBOutlet weak var backButton: UIButton!
    
    
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "\(user.first) \(user.last)"
        self.nameLabel.textColor = .white
        
        self.greetingTabLabel.textColor = .white
        
        self.greetingTagTextView.text = user.greetingTag
        self.greetingTagTextView.textColor = .white
        self.greetingTagTextView.backgroundColor = .clear
        self.greetingTagOldText = self.greetingTagTextView.text
        
        backButton.setTitleColor(.white, for: .normal)
        
        setBackground()
        
        // Be able to set the profile image
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        
        // Dismiss keyboard when user taps anywhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        //Set the profile picture
        user.downloadProfileImage { image in
            DispatchQueue.main.async {
                self.profileImage.image = image
                self.profileImage.rounded()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        greetingTagTextView.resignFirstResponder()
        user.greetingTag = self.greetingTagTextView.text
        
        // Check for changes so that we can update the database
        if greetingTagOldText != user.greetingTag {
            let userData = try! FirestoreEncoder().encode(user)
            user.ref?.setData(userData)
        }
        if profileImageChanged {
            FirestoreService.shared.uploadImageToFirebaseStorage(image: profileImage.image!, withPath: "\(String(describing: user.ref?.documentID))/profileImage.png")
        }
    }
    
    // Dismiss keyboard if user taps outside greetingtagtextview
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        greetingTagTextView.resignFirstResponder()
    }
    
    
    
    // MARK: - GUI and User Interface Animations
    
    func setBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let colors: [CGColor] = [UIColor.blue.cgColor, UIColor.darkGray.cgColor]
        let background = UIImage.gradientImage(colors: colors)
        backgroundImageView.image = background
        
        view.sendSubviewToBack(backgroundImageView)
    }
    
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc
    func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
            profileImageChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
