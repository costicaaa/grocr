import Foundation
import Firebase

struct GroceryItem {
  
  let ref: DatabaseReference?
  let key: String
  let userName: String
  let type: Number
  let familyUID: String
  
  init(userName: String, type: Number, familyUID: String, key: String = "") {
    self.ref = nil
    self.key = key
    self.userName = userName
    self.type = type
    self.familyUID = familyUID
  }
  
  init?(snapshot: DataSnapshot) {
    guard
      let value = snapshot.value as? [String: AnyObject],
      let userName = value["userName"] as? String,
      let type = value["type"] as? Number,
      let familyUID = value["familyUID"] as? String,
      return nil
    }
    
    self.ref = snapshot.ref
    self.key = snapshot.key
    self.userName = userName
    self.type = type
    self.familyUID = familyUID
  }
  
  func toAnyObject() -> Any {
    return [
      "userName": userName,
      "type": type,
      "familyUID": familyUID
    ]
  }
}
