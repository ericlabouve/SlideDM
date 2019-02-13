//
//  ViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/3/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO:
// Do not proceed to next page if async call to Facebook api fails...

import UIKit
import FBSDKLoginKit
import Contacts
import CryptoSwift

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    // User Interface
    var backgroundImageView = UIImageView()
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var contactsLoginButton: UIButton!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var facebookDisclaimerLabel: UILabel!
    
    // Meta data
    var contacts = [Contact]()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Load UI
        contactsLoginButton.layer.cornerRadius = 3
        contactsLoginButton.clipsToBounds = true
        loginButton.delegate = self
//        loginButton.readPermissions = ["public_profile", "user_friends"]
        setBackground()
        hideUI()
    }
    
    // Nicely fade everything in
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 1.5, animations: {
            self.sloganLabel.alpha = 1.0
        })
        UIView.animate(withDuration: 2.0, animations: {
            self.contactsLoginButton.alpha = 1.0
            self.loginButton.alpha = 1.0
            self.facebookDisclaimerLabel.alpha = 1.0
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.alpha = 0
            self.sloganLabel.alpha = 0
            self.contactsLoginButton.alpha = 0
            self.loginButton.alpha = 0
            self.facebookDisclaimerLabel.alpha = 0
        })
    }
    
    // MARK: - User Interface Animations

    // Remove the alpha from all UI elements to enable a nice fade in effect
    func hideUI() {
        titleLabel.alpha = 0
        sloganLabel.alpha = 0
        contactsLoginButton.alpha = 0
        loginButton.alpha = 0
        facebookDisclaimerLabel.alpha = 0
    }
    
    func setBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        backgroundImageView.image = UIImage(named: "MountainBackground")
        view.sendSubviewToBack(backgroundImageView)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SetupProfileSegue" {
            print("Segueing to SetupProfileViewControler")
            (segue.destination as? SetupProfileViewController)?.userContacts = contacts
        }
    }
    
    // MARK: - Facebook
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook :)")
        requestFacebookFriends()
        // requestFacebookNameAndNumber()
        continueWithContactsClick()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    // You also cannot do this unless you have explicit permission from Facebook
    func requestFacebookNameAndNumber() {
        if((FBSDKAccessToken.current()) != nil){
            let params = ["fields": "name, first_name, last_name, phone"]
            FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let userData = result as? [String:Any] {
                        print(userData)
                    }
                } else {
                    print("Error Getting Facebook name and phone number \(String(describing: error))");
                }
            })
        }
    }
    
    // In order for this method to work, users must accept to the permission, user_friends, and your
    // app must be approved by Facebook
    // See https://developers.facebook.com/docs/facebook-login/permissions/#reference-user_friends
    func requestFacebookFriends() {
        let params = ["fields": "id, first_name, last_name"]
        let graphRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        let connection = FBSDKGraphRequestConnection()
        connection.add(graphRequest, completionHandler: { (connection, result, error) in
            if error == nil {
                if let userData = result as? [String:Any] {
                    for (key, value) in userData {
                        print("\(key)" + " : " + "\(value)")
                    }
                }
            } else {
                print("Error Getting Facebook Friends \(String(describing: error))");
            }
        })
        connection.start()
    }
    
    // MARK: - Contacts
    
    @IBAction func continueWithContactsClick(_ sender: UIButton) {
        continueWithContactsClick()
    }
    
    // Method is overloaded so that it can be called from the Facebook button
    func continueWithContactsClick() {
        fetchContacts()
        performSegue(withIdentifier: "SetupProfileSegue", sender: nil)
    }
    
    private func fetchContacts() {
        print("Attempting to fetch contacts.")
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, err) in
            if let err = err {
                print("Failed to request access: ", err)
                return
            }
            if granted {
                print("Access granted")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        var phoneIDs = [String]()
                        for number in contact.phoneNumbers {
                            let number = LoginViewController.cleanPhoneNumber(phoneNumber: number.value.stringValue)
                            // Only keep track of contacts that have valid phone numbers
                            // Hash the phone numbers so we can't sell their phone numbers later
                            if number != nil {
                                phoneIDs.append(number!.sha256())
                            }
                        }
                        // Add contacts that contain at least one valid phone number id
                        if phoneIDs.count > 0 {
                            self.contacts.append(Contact(first: contact.givenName, last: contact.familyName, phoneIDs: phoneIDs))
                        }
                    })
                } catch let err {
                    print("Failed to enumerate contacts:", err)
                }
            } else {
                print("Access denied to Contacts :(")
            }
        }
    }
    
    // Removes all punctuation from the phone number and ensures that the
    // phone number is 11 characters long.
    // Returns nil if the operation fails
    public static func cleanPhoneNumber(phoneNumber: String) -> String? {
        let americanPhoneNumberLength = 11
        var newNumber = phoneNumber
        // Remove spaces, open/close parentheses, dashes, and pluses
        newNumber = newNumber.replacingOccurrences(of: " ", with: "")
        newNumber = newNumber.replacingOccurrences(of: ")", with: "")
        newNumber = newNumber.replacingOccurrences(of: "(", with: "")
        newNumber = newNumber.replacingOccurrences(of: "-", with: "")
        newNumber = newNumber.replacingOccurrences(of: "+", with: "")
        // Assume numbers are American if no country code is included
        // Ex: _408XXXXXXX as opposed to 1408XXXXXXX
        if newNumber.count == americanPhoneNumberLength - 1 {
            newNumber = "1" + newNumber
        }
        // Only keep track of contacts that have valid phone numbers
        if newNumber.count == americanPhoneNumberLength && Int(newNumber) != nil {
            return newNumber
        }
        return nil
    }
}
