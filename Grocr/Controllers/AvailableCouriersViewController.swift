import UIKit
import Firebase

class AvailableCouriersViewController: UITableViewController {
  
  // MARK: Constants
  let userCell = "UserCell"
  
  // MARK: Properties
  var currentUsers: [String] = []
  let user = Auth.auth().currentUser!
  var items: [UserInfo] = []
  var groceryItems : [GroceryItem] = []
  var ref = Database.database().reference()
  var newOrderItems: [GroceryItem] = []
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()

    let couriersRef = Database.database().reference().child("users-info").queryOrdered(byChild: "type").queryEqual(toValue: 2)
    couriersRef.observe(.value, with: { snapshot in
      var newItems: [UserInfo] = []
      for child in snapshot.children {
        if let snapshot = child as? DataSnapshot,
          let userInfoItem = UserInfo(snapshot: snapshot) {
          newItems.append(userInfoItem)
          }
      }
      
      self.items = newItems
      self.tableView.reloadData()
    })
  }
  
  // MARK: UITableView Delegate methods
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
    let userName = items[indexPath.row].userName
    cell.textLabel?.text = userName
    return cell
  }
  
  // MARK: Actions
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    let userInfoItem = items[indexPath.row]
    // let toggledCompletion = !groceryItem.completed
    toggleCellCheckbox(cell, userInfoItem: userInfoItem)
    // groceryItem.ref?.updateChildValues([
    //   "completed": toggledCompletion
    //   ])
  }


  func toggleCellCheckbox(_ cell: UITableViewCell, userInfoItem: UserInfo) {
    print("clicked a row")
      // print(userInfoItem.key)
    print(userInfoItem.userName)

    let alert = UIAlertController(title: "Send order to " + userInfoItem.userName,
                            message: "Are you sure?",
                            preferredStyle: .alert)
      
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

    let saveAction = UIAlertAction(title: "Send", style: .default) { _ in
        print("self.user.uid in save action 111")
        print(self.user.uid)
        let dbRef = Database.database().reference()
        dbRef.child("users-info").child(self.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
        print("self.user.uid in save action 222")
        print(self.user.uid)
        
        let currentUserInfo = snapshot.value as? NSDictionary
        
        print("currentUserInfoin save action")
        print(currentUserInfo)
        
        
        let familyUID = currentUserInfo?["familyUID"] as? String ?? "what is going on"
        print("family uid = " + familyUID)
          
        let newOrderRef = Database.database().reference()
            let newOrderKey = newOrderRef.child("families").child(familyUID).child("orders").childByAutoId().key
          
            let anotherDbRef = Database.database().reference()

            anotherDbRef.child("families").child(familyUID).child("orders").child(newOrderKey).setValue([
          "deliveryUserUID": userInfoItem.key,
          "deliveryUserName": userInfoItem.userName,
          "forFamilyUID": userInfoItem.familyUID,
          "status": "processing",
          "groceryItems" : []
        ])

            let orderGroceryItemsRef = Database.database().reference().child("families").child(familyUID).child("orders").child(newOrderKey).child("groceryItems")
        for newOrderItem in self.newOrderItems {
          orderGroceryItemsRef.childByAutoId().setValue(newOrderItem.toAnyObject())
        }
              
      })
    }
      
    

    


      alert.addAction(saveAction)
      alert.addAction(cancelAction)

      
      self.ref.child("users-info").child(self.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
        let currentUserInfo = snapshot.value as? NSDictionary
        let familyUID = currentUserInfo?["familyUID"] as? String ?? ""
        self.newOrderItems = []
        self.ref = Database.database().reference(withPath: "families/\(familyUID)/grocery-items")
        self.ref.queryOrdered(byChild: "addedByUser").observe(.value, with: { snapshot in
          
          for child in snapshot.children {
            if let snapshot = child as? DataSnapshot,
                let orderItem = GroceryItem(snapshot: snapshot)  {
                self.newOrderItems.append(orderItem)
            }
              
          }
          
        self.present(alert, animated: true, completion: nil)
        })
      })
  }
}
