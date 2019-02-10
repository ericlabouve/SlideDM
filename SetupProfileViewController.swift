//
//  SetupProfileViewController.swift
//  
//
//  Created by Eric LaBouve on 2/9/19.
//

import UIKit

class SetupProfileViewController: UIViewController {
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var whyPhoneNumberButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideUI()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Nicely fade everything in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Greet the user
        // Fade "Hello!" in
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.helloLabel.alpha = 1
        }, completion: { _ in
            // Fade "Hello!" out
            UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                self.helloLabel.alpha = 0
            }, completion: { _ in
                // Fade Text Fields in
                UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
                    self.firstNameTextField.alpha = 1
                    self.lastNameTextField.alpha = 1
                    self.phoneNumberTextField.alpha = 1
                    self.whyPhoneNumberButton.alpha = 1
                })
            })
        })
    }
    
    @IBAction func doneButton(_ sender: UIButton) {
        let number = LoginViewController.cleanPhoneNumber(phoneNumber: phoneNumberTextField.text!)
        if number != nil {
            userPhoneNumber = number!.sha256()
        }
    }
    
    @IBAction func whyPhoneNumberButton(_ sender: UIButton) {
        let message = "SlideDM uses phone numbers to uniquely identify our users and we need your explicit permission to obtain them. We encrypt all phone numbers and then throw away the key so that no one can take advantage of your personal data."
        let alert = UIAlertController(title: "Phone Numbers", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion:nil)
    }
    
    // Remove the alpha from all UI elements to enable a nice fade in effect
    func hideUI() {
        helloLabel.alpha = 0
        firstNameTextField.alpha = 0
        lastNameTextField.alpha = 0
        phoneNumberTextField.alpha = 0
        whyPhoneNumberButton.alpha = 0
    }

}
