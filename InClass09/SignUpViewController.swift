//
//  SignUpViewController.swift
//  InClass09
//
//  Created by student on 8/2/16.
//  Copyright © 2016 MNR_iOS. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelCreation(sender: UIButton) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func submitCreation(sender: AnyObject) {
        let name = nameField.text
        let email = emailField.text
        let password = passwordField.text
        let confirmPasswordVal = confirmPassword.text
        
        if name == nil || name == "" || email == nil || email == "" || password == nil || password == "" || confirmPasswordVal == nil || confirmPasswordVal == ""  {
            let alert = UIAlertController(title: "Alert", message: "Enter Your Details", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else if password != confirmPasswordVal {
            let alert = UIAlertController(title: "Alert", message: "Passwords do not match", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            FIRAuth.auth()?.createUserWithEmail(email!, password: password!, completion: { (newUser, error) in
                if error != nil {
                    let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let ref = FIRDatabase.database().reference()
                    ref.child("Users").child((newUser?.uid)!).setValue(["name": name!,"email": email!,"password": password!])
                    //print("login from here")
                    FIRAuth.auth()?.signInWithEmail(email!, password: password!, completion: { (newUser, error) in
                        if error != nil {
                            let alert = UIAlertController(title: "Alert", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                        } else {
                            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc : UIViewController = storyboard.instantiateViewControllerWithIdentifier("NotebooksStoryBoard") as UIViewController
                            self.presentViewController(vc, animated: true, completion: nil)
                        }
                    })
                    
                }
            })
        }
    }
    
    @IBOutlet weak var nameField: UITextField!
    
    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPassword: UITextField!
}
