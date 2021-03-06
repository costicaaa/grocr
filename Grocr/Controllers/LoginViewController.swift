import UIKit
import Firebase

class LoginViewController: UIViewController {
  
  var userName = "";

  // MARK: Constants
  let familyMembers = "LoginToList"
  
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
        
        self.performSegue(withIdentifier: "LoginToList", sender: self)
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
      else{
        self.performSegue(withIdentifier: "LoginToList", sender: self)
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
      self.userName = nameField.text!
        
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

      let user = Auth.auth().currentUser!
      let dbRef = Database.database().reference()
      let key = dbRef.child("families").childByAutoId().key
      dbRef.child("families").child(key).child("familyName").setValue(createFamilyAlert.textFields![0].text!)
      dbRef.child("families").child(key).child("users").childByAutoId().setValue([
        "userUID": user.uid,
        "userName": self.userName
      ])
      let childUpdates = [
        "/users-info/\(user.uid)/familyUID/": key
      ] as [String : Any]
      dbRef.updateChildValues(childUpdates)
      
        self.performSegue(withIdentifier: self.familyMembers, sender: nil)
    }


    let joinAction = UIAlertAction(title: "Join family", style: .default){ _ in
      let user = Auth.auth().currentUser!

      let dbRef = Database.database().reference()
      dbRef.child("families").child(joinFamilyAlert.textFields![0].text!).child("users").childByAutoId().setValue([
        "userUID": user.uid,
        "userName": self.userName
      ])
      let childUpdates = [
        "/users-info/\(user.uid)/familyUID/": joinFamilyAlert.textFields![0].text!
      ]
      dbRef.updateChildValues(childUpdates)

        self.performSegue(withIdentifier: self.familyMembers, sender: nil)
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
