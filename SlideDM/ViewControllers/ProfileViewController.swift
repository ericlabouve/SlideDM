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
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var greetingTagTextView: UITextView!
    var greetingTagOldText: String = ""

    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = "\(user.first) \(user.last)"
        self.greetingTagTextView.text = user.greetingTag
        self.greetingTagOldText = self.greetingTagTextView.text
        
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
