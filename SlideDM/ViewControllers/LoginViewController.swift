//
//  ViewController.swift
//  SlideDM
//
//  Created by Eric LaBouve on 2/3/19.
//  Copyright © 2019 Eric LaBouve. All rights reserved.
//

// TODO:
// [] Sign in with google: https://www.youtube.com/watch?v=7Mt2yf4h6lQ and https://stackoverflow.com/questions/42545249/firebase-ui-auth-provider-ios-swift-example
// [] Do not proceed to next page if async call to Facebook api fails...
// [] Logout button in upper right hand corner does not log out of facebook
// [] Extend functionality to grab user friends. I think the graph reference is "/me/friends" also see https://developers.facebook.com/docs/facebook-login/permissions/#reference-user_friends

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
    
    // User meta data
    var contacts = [Contact]()
    var userFirstName: String?
    var userLastName: String?
    var userEmail: String?
    var userProfileImage: UIImage?

    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Load UI
        contactsLoginButton.layer.cornerRadius = 3
        contactsLoginButton.clipsToBounds = true
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
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
            let dest = segue.destination as? SetupProfileViewController
            dest?.userContacts = contacts
            dest?.userFirstName = userFirstName
            dest?.userLastName = userLastName
            dest?.userEmail = userEmail
            dest?.userProfileImage = userProfileImage
        }
    }
    
    
    
    
    
    
    // MARK: - Facebook
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil { print(error); return }
        requestFacebook()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    // You also cannot do this unless you have explicit permission from Facebook
    func requestFacebook() {
        if((FBSDKAccessToken.current()) != nil){
            let params = ["fields": "first_name, last_name, email, picture.width(200).height(200)"]
            FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    if let userData = result as? [String:Any] {
                        // print(userData)
                        self.userFirstName = userData["first_name"] as? String
                        self.userLastName = userData["last_name"] as? String
                        self.userEmail = userData["email"] as? String
                        if let pictureObj = userData["picture"] as? NSDictionary {
                            if let pictureData = pictureObj["data"] as? [String:Any] {
                                let url = pictureData["url"] as! String
                                let session = URLSession(configuration: URLSessionConfiguration.default)
                                let request = URLRequest(url: URL(string: url)!)
                                let task: URLSessionDataTask = session.dataTask(with: request)
                                { (receivedData, response, error) -> Void in
                                    if let data = receivedData {
                                        self.userProfileImage = UIImage(data: data)
                                        DispatchQueue.main.async {
                                            self.continueWithContactsClick()
                                        }
                                    }
                                }
                                task.resume()
                            }
                        }
                    }
                } else {
                    print("Facebook Error: \(String(describing: error))");
                }
            })
        }
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
                print("Access granted to contacts")
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    print("Printing Your Contacts. Format is <First Name> <Last Name> <Encrypted Phone Numbers>")
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
                            print("\(contact.givenName) \(contact.familyName): \(phoneIDs)")
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
