import UIKit
import Firebase

class OnlineUsersTableViewController: UITableViewController {
  
  // MARK: Constants
  let userCell = "UserCell"
  
  // MARK: Properties
  var currentUsers: [String] = []
  let user = Auth.auth().currentUser!


    var familyUID = "";

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let ref = Database.database().reference()
    ref.child("users-info").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
    // Get user value
    let value = snapshot.value as? NSDictionary
        self.familyUID = value?["familyUID"] as? String ?? ""
        
        let familyRef = Database.database().reference(withPath: "families/\(self.familyUID)/users")
        
        familyRef.observe(.childAdded, with: { snap in
        
            let temp = snap.value as? NSDictionary
            self.currentUsers.append(temp?["userName"] as? String ?? "")
          let row = self.currentUsers.count - 1
          let indexPath = IndexPath(row: row, section: 0)
          self.tableView.insertRows(at: [indexPath], with: .top)
          
        })
    }) { (error) in
      print(error.localizedDescription)
    }
    
    
    
    
    
    // usersRef.observe(.childRemoved, with: { snap in
    //   guard let emailToFind = snap.value as? String else { return }
    //   for (index, email) in self.currentUsers.enumerated() {
    //     if email == emailToFind {
    //       let indexPath = IndexPath(row: index, section: 0)
    //       self.currentUsers.remove(at: index)
    //       self.tableView.deleteRows(at: [indexPath], with: .fade)
    //     }
    //   }
    // })
  }
  
  // MARK: UITableView Delegate methods  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return currentUsers.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
    let onlineUserEmail = currentUsers[indexPath.row]
    cell.textLabel?.text = onlineUserEmail
    return cell
  }
  
  // MARK: Actions
  @IBAction func signoutButtonPressed(_ sender: AnyObject) {
    let user = Auth.auth().currentUser!
    let onlineRef = Database.database().reference(withPath: "online/\(user.uid)")
    onlineRef.removeValue { (error, _) in
      if let error = error {
        print("Removing online failed: \(error)")
        return
      }
      do {
        try Auth.auth().signOut()
        self.dismiss(animated: true, completion: nil)
      } catch (let error) {
        print("Auth sign out failed: \(error)")
      }
    }
  }
}
