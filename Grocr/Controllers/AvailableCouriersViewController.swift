import UIKit
import Firebase

class AvailableCouriersViewController: UITableViewController {
  
  // MARK: Constants
  let userCell = "UserCell"
  
  // MARK: Properties
  var currentUsers: [String] = []
  let user = Auth.auth().currentUser!

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // MARK: UIViewController Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let couriersRef = Database.database().reference().child("users-info").queryOrdered(byChild: "type").queryEqual(toValue: 2)
    couriersRef.observe(.childAdded, with: { snap in
      let temp = snap.value as? NSDictionary
      self.currentUsers.append(temp?["userName"] as? String ?? "")
      let row = self.currentUsers.count - 1
      let indexPath = IndexPath(row: row, section: 0)
      self.tableView.insertRows(at: [indexPath], with: .top)
    })

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
 
}
