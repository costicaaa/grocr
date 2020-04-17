import UIKit
import Firebase

class GroceryListTableViewController: UITableViewController {

  // MARK: Constants
  
  // MARK: Properties
  var items: [GroceryItem] = []
  var user: User!
  var userCountBarButtonItem: UIBarButtonItem!
  let ref = Database.database().reference(withPath: "grocery-items")
  let usersRef = Database.database().reference(withPath: "online")

  var userName = ""; 
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle  
  override func viewDidLoad() {
    super.viewDidLoad()

    let userID = Auth.auth().currentUser?.uid!
    ref.child("users-info").child(userID!).observe(of: .value, with: { (snapshot) in
      // Get user value
      let value = snapshot.value as? NSDictionary
      self.userName = value?["userName"] as? String ?? ""
      }) { (error) in
        print(error.localizedDescription)
    }
    
    
    tableView.allowsMultipleSelectionDuringEditing = false
    
    userCountBarButtonItem = UIBarButtonItem(title: "Family Members",
                                             style: .plain,
                                             target: self,
                                             action: #selector(userCountButtonDidTouch))
    userCountBarButtonItem.tintColor = UIColor.white
    navigationItem.leftBarButtonItem = userCountBarButtonItem
    
    ref.queryOrdered(byChild: "addedByUser").observe(.value, with: { snapshot in
      var newItems: [GroceryItem] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let groceryItem = GroceryItem(snapshot: snapshot) {
          newItems.append(groceryItem)
        }
      }
      
      self.items = newItems
      self.tableView.reloadData()
    })
    
    Auth.auth().addStateDidChangeListener { auth, user in
      guard let user = user else { return }
        self.user = User(authData: user)
      
      let currentUserRef = self.usersRef.child(self.user.uid)
      currentUserRef.setValue(self.user.email)
      currentUserRef.onDisconnectRemoveValue()
    }
    
    // usersRef.observe(.value, with: { snapshot in
    //   if snapshot.exists() {
    //     self.userCountBarButtonItem?.title = snapshot.childrenCount.description
    //   } else {
    //     self.userCountBarButtonItem?.title = "0"
    //   }
    // })
  }
  
  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
    let groceryItem = items[indexPath.row]
    
    cell.textLabel?.text = groceryItem.name
    cell.detailTextLabel?.text = groceryItem.addedByUser
    
    toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let groceryItem = items[indexPath.row]
      groceryItem.ref?.removeValue()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let groceryItem = items[indexPath.row]
    let toggledCompletion = !groceryItem.completed
    toggleCellCheckbox(cell, isCompleted: toggledCompletion)
    groceryItem.ref?.updateChildValues([
      "completed": toggledCompletion
      ])
  }
  
  func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
    if !isCompleted {
      cell.accessoryType = .none
      cell.textLabel?.textColor = .black
      cell.detailTextLabel?.textColor = .black
    } else {
      cell.accessoryType = .checkmark
      cell.textLabel?.textColor = .gray
      cell.detailTextLabel?.textColor = .gray
    }
  }
  
  // MARK: Add Item  
  @IBAction func addButtonDidTouch(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Grocery Item",
                                  message: "Add an Item",
                                  preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
      guard let textField = alert.textFields?.first,
        let text = textField.text else { return }
      

      let groceryItem = GroceryItem(name: text,
                                    addedByUser: self.userName,
                                    completed: false)

      let groceryItemRef = self.ref.child(text.lowercased())
      
      groceryItemRef.setValue(groceryItem.toAnyObject())
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel)
    
    alert.addTextField()
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
  
  @objc func userCountButtonDidTouch() {
    performSegue(withIdentifier: "groceryListToFamilyMembers", sender: nil)
  }
}
