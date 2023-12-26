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
    var data:Array<Any> = []

  @IBOutlet weak var peripheralLabel: UILabel!
  @IBOutlet weak var serviceLabel: UILabel!
  @IBOutlet weak var consoleTextView: UITextView!
  @IBOutlet weak var consoleTextField: UITextField!
  @IBOutlet weak var txLabel: UILabel!
//  @IBOutlet weak var rxLabel: UILabel!
  @IBOutlet weak var captureButton: UIButton!

  @IBAction func scanningAction(_ sender: Any) {
    getData();
  }
  var db: Firestore!
  var today = "0000, Jan 01, 1990"
  var prev = 0


  override func viewDidLoad() {
      super.viewDidLoad()
    // [START setup]
    let settings = FirestoreSettings()

    Firestore.firestore().settings = settings
    // [END setup]
    db = Firestore.firestore()
      
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "y, MMM d, HH:mm"
    today = dateFormatter.string(from: date)

    keyboardNotifications()

    NotificationCenter.default.addObserver(self, selector: #selector(self.appendRxDataToTextView(notification:)), name: NSNotification.Name(rawValue: "Notify"), object: nil)

    consoleTextField.delegate = self

    peripheralLabel.text = BlePeripheral.connectedPeripheral?.name

    txLabel.text = "TX:\(String(BlePeripheral.connectedTXChar!.uuid.uuidString))"
//    rxLabel.text = "RX:\(String(BlePeripheral.connectedRXChar!.uuid.uuidString))"

      if BlePeripheral.connectedService != nil {
      serviceLabel.text = "Number of Services: \(String((BlePeripheral.connectedPeripheral?.services!.count)!))"
    } else{
      print("Service was not found")
    }
  }

  @objc func appendRxDataToTextView(notification: Notification) -> Void{
    if (abs((notification.object! as! NSString).integerValue - prev) < 5) {
        
        consoleTextView.text.append("\n[Recv]: \((notification.object! as! NSString).integerValue) \n")
        data.append((notification.object! as! NSString).integerValue)
        prev = (notification.object! as! NSString).integerValue
        var ref: DocumentReference? = nil
        ref = db.collection(today).addDocument(data: [
            "user" : "User1",
            "value": (notification.object! as! NSString).integerValue
            
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
  }

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
    
  func getData() -> Void {

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
      //Once connected, move to new view controller to manager incoming and outgoing data
      let storyboard = UIStoryboard(name: "Main", bundle: nil)

      let detailViewController = storyboard.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
        detailViewController.data = self.data

      self.navigationController?.pushViewController(detailViewController, animated: true)
    })
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
