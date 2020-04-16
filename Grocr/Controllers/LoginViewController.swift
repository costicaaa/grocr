/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  // MARK: Constants
  let loginToList = "LoginToList"
  
  // MARK: Outlets
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  @IBOutlet weak var textFieldUserName: UITextField!
  @IBOutlet weak var textFamilyUID: UITextField!
  @IBOutlet weak var textFamilyName: UITextField!

  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Auth.auth().addStateDidChangeListener() { auth, user in
      if user != nil {
        self.textFieldLoginEmail.text = nil
        self.textFieldLoginPassword.text = nil
        self.textFieldUserName = nil
        self.textFamilyUID = nil
        self.textFamilyName = nil
      }
    }
  }
  
  // MARK: Actions
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    guard
      let email = textFieldLoginEmail.text,
      let password = textFieldLoginPassword.text,
      email.count > 0,
      password.count > 0
      else {
        return
    }
    
    Auth.auth().signIn(withEmail: email, password: password) { user, error in
      if let error = error, user == nil {
        let alert = UIAlertController(title: "Sign In Failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
      }
    }
  }
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Register",
                                  message: "Register",
                                  preferredStyle: .alert)
    //create or join family
    let createOrJoinFamilyAlert = UIAlertController(title: "Join or create a family",
                                                  message: "",
                                                  preferredStyle: .alert)
    
    let createFamilyAlert = UIAlertController(title: "Create a family",
    message: "Insert family name",
    preferredStyle: .alert)

    let joinFamilyAlert = UIAlertController(title: "Join a family",
    message: "Insert family UID",
    preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      
      let emailField = alert.textFields![1]
      let passwordField = alert.textFields![2]
      let nameField = alert.textFields![0]
      
      Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
        if error == nil {
          Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
                             password: self.textFieldLoginPassword.text!)
        
            let user = Auth.auth().currentUser!
            let currentUserRef = Database.database().reference(withPath: "users-info/\(user.uid)")
            currentUserRef.updateChildValues(
                    [
                        "userName": nameField.text!,
                        "type": 1,
                        "familyUID": ""
                ]
            ) { (error, ref) in
                if(error != nil){
                    print("Error",error)
                }else{
                    self.present(createOrJoinFamilyAlert, animated: true, completion: nil)
                }
            }


        }
      }
    }

    
    
    
    
    alert.addTextField { textUserName in
      textUserName.placeholder = "Enter your name"
    }
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    


    let joinFamilyAction = UIAlertAction(title: "Join", style: .default) { _ in 
        self.present(joinFamilyAlert, animated: true, completion: nil)
    }

    let createFamilyAction = UIAlertAction(title: "Create", style: .default) { _ in 
        self.present(createFamilyAlert, animated: true, completion: nil)
    }

    // createOrJoinFamilyAlert.addAction(joinFamilyAction)
    createOrJoinFamilyAlert.addAction(createFamilyAction)
    createOrJoinFamilyAlert.addAction(joinFamilyAction)

    //end

    createFamilyAlert.addTextField  { textFamilyName in
      textFamilyName.placeholder = "Family Name"
    }

    joinFamilyAlert.addTextField  { textFamilyUID in
      textFamilyUID.placeholder = "Family UID ( ask a family member for it )"
    }

    let createAction = UIAlertAction(title: "Create family", style: .default){ _ in
      print("muhahahaha it works")
      // let newFamUID = UUID().uuidString



      // let familyRef =  Database.database().reference(withPath: "families/\(newFamUID)")
      // familyRef.updateChildValues([
      //   "familyName": alert.textFields![0],
      // ]) { (error, ref) in
      //     if(error != nil){
      //         print("Error",error)
      //     }else{

      //       familyRef.child("users").childByAutoId()
      //       print("now redirect to some listing")
      //     }
      // }

      let user = Auth.auth().currentUser!
      let familiesRef = Database.database().reference()
      guard let key = ref.child("families").childByAutoId().key else { return }
      let family = ["familyName": alert.textFields![0]]
      let childUpdates = ["/families/\(key)": family,
                          "/users-info/\(user.uid)/familyUID/": key]
      familiesRef.updateChildValues(childUpdates)

      // let currentUserRef = Database.database().reference(withPath: "users-info/\(user.uid)")
      // currentUserRef.updateChildValues(
      //         [
      //             "familyUID": ""
      //     ]
      // ) { (error, ref) in
      //     if(error != nil){
      //         print("Error",error)
      //     }else{
      //         self.present(createOrJoinFamilyAlert, animated: true, completion: nil)
      //     }
      // }

      // end create family
    }


    let joinAction = UIAlertAction(title: "Join family", style: .default){ _ in
      // todo :: join a family by uid
      print("join action complete")
    }
    createFamilyAlert.addAction(createAction)
    joinFamilyAlert.addAction(joinAction)

    present(alert, animated: true, completion: nil)
  }  
}

extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
}
