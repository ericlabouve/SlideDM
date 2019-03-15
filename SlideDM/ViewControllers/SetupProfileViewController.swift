//
//  SetupProfileViewController.swift
//  
//
//  Created by Eric LaBouve on 2/9/19.
//

// TODO:
// Authenticate each user with 2-factor authentication
// [] Be able to select a profile image
// [] Upload/Download from Firebase Storage https://www.youtube.com/watch?v=Bd4-6pnjjd8

import UIKit
import Firebase
import FirebaseAuth
import CodableFirebase

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}

class SetupProfileViewController: UIViewController, UITextFieldDelegate {
    
    // User Interface
    var backgroundImageView = UIImageView()
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var whyPhoneNumberButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    // Passed in from LoginViewController
    var userContacts: [Contact] = []
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userProfileImage: UIImage?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load Delegates
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        // Be able to set the profile image
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        
        // Load UI
        // TextField Background
        firstNameTextField.backgroundColor = UIColor.clear
        lastNameTextField.backgroundColor = UIColor.clear
        phoneNumberTextField.backgroundColor = UIColor.clear
        
        // TextField Bottom Border
        firstNameTextField.underlined()
        lastNameTextField.underlined()
        phoneNumberTextField.underlined()
        
        // Fill in labels if user logged in with Social Media
        firstNameTextField.text = userFirstName ?? ""
        lastNameTextField.text = userLastName ?? ""
        if let userProfileImage = userProfileImage {
            profileImage.image = userProfileImage
        }
        
        // UI
        setBackground()
        hideUI()
    }
    
    
    // MARK: - IBActions
    
    @IBAction func doneButton(_ sender: UIButton) {
        // Make sure all the labels are filled in correctly
        guard let userFirstName = firstNameTextField.text,
              let userLastName = lastNameTextField.text,
            let userEncryptedPhoneNumber = LoginViewController.cleanPhoneNumber(phoneNumber: phoneNumberTextField.text!)?.sha256() else {
                let message = "Please fill out all the fields. Make sure that your phone number has the correct amount of digits."
                let alert = UIAlertController(title: "User Alert", message: message, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(defaultAction)
                present(alert, animated: true, completion:nil)
                return
        }
        resignFirstResponder()
        // We now have enough information to create a User object
        saveUserToDatabase(user: User(first: userFirstName, last: userLastName, email: userEmail ?? "", phoneID: userEncryptedPhoneNumber, contacts: userContacts))
        // Move this to viewWillDisappear when setting up next view controller
        outAnimation()
        // Move to next screen
        performSegue(withIdentifier: "setupProfileToChatsSegue", sender: nil)
    }
    
    func saveUserToDatabase(user: User) {
        let data = try! FirestoreEncoder().encode(user)
        let ref = FirestoreService.shared.userColRef.addDocument(data: data)
        UserDefaults.standard.set(ref.documentID, forKey: "userDocID")
        UserDefaults.standard.set(user.phoneID, forKey: "userPhoneID")
        UserDefaults.standard.synchronize()
        print("Saved user")
    }
    
    
    
    @IBAction func whyPhoneNumberButton(_ sender: UIButton) {
        let message = "SlideDM uses phone numbers to uniquely identify our users and we need your explicit permission to obtain your phone number. We encrypt all phone numbers so that no one can take advantage of your personal data. You might receive an SMS message for verification and standard rates apply."
        let alert = UIAlertController(title: "Why My Phone Number?", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion:nil)
    }

    
    // MARK: - UITextField Methods
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    
    // MARK: - User Interface Animations
    
    // Nicely fade everything in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Greet the user
        // Fade "Hello!" in
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.helloLabel.alpha = 1
        }, completion: { _ in
            // Fade "Hello!" out
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                self.helloLabel.alpha = 0
            }, completion: { _ in
                // Fade Text Fields in
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.profileImage.alpha = 1
                    self.firstNameTextField.alpha = 1
                    self.lastNameTextField.alpha = 1
                    self.phoneNumberTextField.alpha = 1
                    self.whyPhoneNumberButton.alpha = 1
                    self.doneButton.alpha = 1
                })
            })
        })
    }
    
    func outAnimation() {
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.profileImage.alpha = 0
            self.firstNameTextField.alpha = 0
            self.lastNameTextField.alpha = 0
            self.phoneNumberTextField.alpha = 0
            self.whyPhoneNumberButton.alpha = 0
            self.doneButton.alpha = 0
        })
    }
    
    func setBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.image = UIImage(named: "tinyRocket")
        view.sendSubviewToBack(backgroundImageView)
    }
    
    // Remove the alpha from all UI elements to enable a nice fade in effect
    func hideUI() {
        helloLabel.alpha = 0
        firstNameTextField.alpha = 0
        lastNameTextField.alpha = 0
        phoneNumberTextField.alpha = 0
        whyPhoneNumberButton.alpha = 0
        doneButton.alpha = 0
    }
}

extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
