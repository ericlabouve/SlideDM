//
//  ProfileViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/12/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import UIKit
import CodableFirebase

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingTagTextView: UITextView!
    var greetingTagOldText: String = ""

    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "\(user.first) \(user.last)"
        self.greetingTagTextView.text = user.greetingTag
        self.greetingTagOldText = self.greetingTagTextView.text
        
        // Be able to set the profile image
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        
        // Dismiss keyboard when user taps anywhere
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        greetingTagTextView.resignFirstResponder()
        user.greetingTag = self.greetingTagTextView.text
        
        // Check for changes so that we can update the database
        if greetingTagOldText != user.greetingTag {
            let userData = try! FirestoreEncoder().encode(user)
            user.ref?.setData(userData)
        }
        
        print("viewWillDisappear")
    }
    
    // Dismiss keyboard if user taps outside greetingtagtextview
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        greetingTagTextView.resignFirstResponder()
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
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
