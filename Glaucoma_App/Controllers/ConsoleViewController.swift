//
//  ConsoleViewController.swift
//  Glaucoma_App
//
//  Created by Maya Hegde on 12/19/23.
//

import UIKit
import CoreBluetooth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation


class ConsoleViewController: UIViewController {

  //Data
  var peripheralManager: CBPeripheralManager?
  var peripheral: CBPeripheral?
  var periperalTXCharacteristic: CBCharacteristic?
  var data:Array<Any> = [] // local data array
  var db: Firestore!
  var today = "0000, Jan 01, 1990"
  var prev = 0

  // UI
  @IBOutlet weak var peripheralLabel: UILabel!
  @IBOutlet weak var serviceLabel: UILabel!
  @IBOutlet weak var consoleTextView: UITextView!
  @IBOutlet weak var consoleTextField: UITextField!
  @IBOutlet weak var txLabel: UILabel!
  @IBOutlet weak var captureButton: UIButton!
    @IBAction func scanningAction(_ sender: Any) {
        Task { @MainActor in
            await getData();
        }
    }

  override func viewDidLoad() {
      super.viewDidLoad()
    // initialize firestore database
    let settings = FirestoreSettings()
    Firestore.firestore().settings = settings
    db = Firestore.firestore()
      
    // create date object to for databse entry
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y, MMM d, HH:mm"
    today = dateFormatter.string(from: date)
      
    // add a new specific document to the database
    // this code chunk must be implemented before data can be written to the document in Firebase
    db.collection(today).document("Patient1").setData([
        "CCT": "0",
    ])
    print("Document successfully written!")
    

    keyboardNotifications()

    NotificationCenter.default.addObserver(self, selector: #selector(self.appendRxDataToTextView(notification:)), name: NSNotification.Name(rawValue: "Notify"), object: nil)

    consoleTextField.delegate = self

    peripheralLabel.text = BlePeripheral.connectedPeripheral?.name

    txLabel.text = "TX:\(String(BlePeripheral.connectedTXChar!.uuid.uuidString))"

      if BlePeripheral.connectedService != nil {
      serviceLabel.text = "Number of Services: \(String((BlePeripheral.connectedPeripheral?.services!.count)!))"
    } else{
      print("Service was not found")
    }
  }

  // Function that receives  data from the BLE device
  @objc func appendRxDataToTextView(notification: Notification) -> Void{
    
    // print data recieved
    consoleTextView.text.append("\n[Recv]: \(notification.object! as! NSString) \n")
      
    // create some sort of buffer to ensure that data was not lost in transmission
    if (abs((notification.object! as! NSString).integerValue - prev) < 5) {
        
        // append recieved value into local array
        data.append((notification.object! as! NSString).floatValue)
        prev = Int((notification.object! as! NSString).floatValue)
        
        // add value to current collection in Firebase
        var ref: DocumentReference? = nil
        
        // find EXISTING document (must be defined first, otherwise values will not save, and no error message is given)
        ref = db.collection(today).document("Patient1")
        
        // add values to the given field
        ref!.updateData([
          "readings":FieldValue.arrayUnion([(notification.object! as! NSString).floatValue])

        // error check document and collection values in the database
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
  }

  // function used for sending data via app console
  func appendTxDataToTextView(){
    consoleTextView.text.append("\n[Sent]: \(String(consoleTextField.text!)) \n")
  }

  func keyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }

  // MARK:- Keyboard
  @objc func keyboardWillChange(notification: Notification) {

    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

      let keyboardHeight = keyboardSize.height
      print(keyboardHeight)
      view.frame.origin.y = (-keyboardHeight + 50)
    }
  }

  @objc func keyboardDidHide(notification: Notification) {
    view.frame.origin.y = 0
  }

  @objc func disconnectPeripheral() {
    print("Disconnect for peripheral.")
  }

  // Write functions
  func writeOutgoingValue(data: String){
      let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
      //change the "data" to valueString
    if let blePeripheral = BlePeripheral.connectedPeripheral {
          if let txCharacteristic = BlePeripheral.connectedTXChar {
              blePeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)
          }
      }
  }

  func writeCharacteristic(incomingValue: Int8){
    var val = incomingValue

    let outgoingData = NSData(bytes: &val, length: MemoryLayout<Int8>.size)
    peripheral?.writeValue(outgoingData as Data, for: BlePeripheral.connectedTXChar!, type: CBCharacteristicWriteType.withResponse)
  }
    
    func getData() async -> Void {
        
        // example of reading data from Firebase
        await getDoc()

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      //Once connected, move to new view controller to manager incoming and outgoing data
      let storyboard = UIStoryboard(name: "Main", bundle: nil)

      let detailViewController = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
        detailViewController.data = self.data

      self.navigationController?.pushViewController(detailViewController, animated: true)
    })
    
  }
    func getDoc() async -> Void {
        
        // https://firebase.google.com/docs/firestore/query-data/get-data
        // From the source above, Swift does not support the ability to display all collections by name, it is required to look at a specific collection and document
        // This is because Swift is a mobile/client so does not have full function support
        
        // find the document specified
        let docRef = db.collection(today).document("Patient1")

          do {
              // try accessing the document
              let document = try await docRef.getDocument()
            
              //if it exists, print values
              if document.exists {
              let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                  consoleTextView.text.append(document.data().map(String.init(describing:)) ?? "nil")
              print("Document data: \(dataDescription)")
          
              // otherwise it doesn't exist
              } else {
                  print("Document does not exist")
                  consoleTextView.text.append("Document does not exist")
            }
        
          // check for errors
          } catch {
            print("Error getting document: \(error)")
              consoleTextView.text.append("Error getting document: \(error)")
          }
    }
    
}

extension ConsoleViewController: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }


  //Check when someone subscribe to our characteristic, start sending the data
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
      print("Device subscribe to characteristic")
  }

}

extension ConsoleViewController: UITextViewDelegate {

}

extension ConsoleViewController: UITextFieldDelegate {

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    writeOutgoingValue(data: textField.text ?? "")
    appendTxDataToTextView()
    textField.resignFirstResponder()
    textField.text = ""
    return true

  }

  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    textField.clearsOnBeginEditing = true
    return true
  }

}
