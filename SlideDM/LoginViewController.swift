//
//  ViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/3/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Contacts
import CryptoSwift

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    var backgroundImageView = UIImageView()
    var contacts = [Contact]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sloganLabel: UILabel!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var facebookDisclaimerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            self.loginButton.alpha = 1.0
            self.facebookDisclaimerLabel.alpha = 1.0
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.animate(withDuration: 1.0, animations: {
            self.titleLabel.alpha = 0
            self.sloganLabel.alpha = 0
            self.loginButton.alpha = 0
            self.facebookDisclaimerLabel.alpha = 0
        })
    }

    // Remove the alpha from all UI elements to enable a nice fade in effect
    func hideUI() {
        titleLabel.alpha = 0
        sloganLabel.alpha = 0
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
    
    // MARK: - Facebook
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        print("Successfully logged in with facebook :)")
        requestFacebookFriends()
//        requestFacebookNameAndNumber()
        fetchContacts()
        for contact in contacts {
            var hashes = ""
            for hash in contact.ids {
                hashes += hash + ", "
            }
            if contact.first == "Eric" {
                print("-------------------------------------")
            }
            print(contact.first + " " + contact.last + " " + hashes)
        }
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
                let americanPhoneNumberLength = 11
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        var ids = [String]()
                        for number in contact.phoneNumbers {
                            var numberStr = number.value.stringValue
                            // Remove spaces, open/close parentheses, dashes, and pluses
                            numberStr = numberStr.replacingOccurrences(of: " ", with: "")
                            numberStr = numberStr.replacingOccurrences(of: ")", with: "")
                            numberStr = numberStr.replacingOccurrences(of: "(", with: "")
                            numberStr = numberStr.replacingOccurrences(of: "-", with: "")
                            numberStr = numberStr.replacingOccurrences(of: "+", with: "")
                            // Assume numbers are American if no country code is included
                            // Ex: _408XXXXXXX as opposed to 1408XXXXXXX
                            if numberStr.count == americanPhoneNumberLength - 1 {
                                numberStr = "1" + numberStr
                            }
                            // Only keep track of contacts that have valid phone numbers
                            // Hash the phone numbers so we can't sell their phone numbers later
                            if numberStr.count == americanPhoneNumberLength {
                                ids.append(numberStr.sha256())
                            }
                        }
                        // Add contacts that contain at least one valid phone number id
                        if ids.count > 0 {
                            self.contacts.append(Contact(first: contact.givenName, last: contact.familyName, ids: ids))
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
}
