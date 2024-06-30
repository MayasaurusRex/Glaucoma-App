//
//  GraphViewController.swift
//  Glaucoma_App
//
//  Created by Maya Hegde on 12/19/23.
//

import UIKit
import SwiftUI
import Charts
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage


class GraphViewController: UIViewController, ChartViewDelegate {
    
    // Data
    var linechart = LineChartView()
    var db: Firestore!
    let storage = Storage.storage()
    var data:Array<Any> = []
    
    // UI
    @IBOutlet weak var saveImageButton: UIButton!
    
    @IBAction func savingAction(_ sender: Any) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        var ref: DocumentReference? = nil
        ref = db.collection("images").addDocument(data: [
            "img": image!
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        linechart.delegate = self
        // initialize firestore database
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // create the chart in the window
        linechart.frame = CGRect(x: 0, y: 0,
                                 width: self.view.frame.size.width,
                                 height: self.view.frame.size.width)
        linechart.center = view.center
        view.addSubview(linechart)
        
        // iterate through all the readings in the Firebase collection
        var entries = [ChartDataEntry]()
        db.collection("readings").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // count the documents
                var x = 1
                for document in querySnapshot!.documents {
                    x = x+1
                }
            }
        }
        
        // for each data entry, add to the line chart
        for x in 0..<data.count {
            let val = Double(data[x] as! Float)
            entries.append(ChartDataEntry(x: Double(x),
                                          y: val))
        }
        
        // show the line chert
        let set = LineChartDataSet(entries: entries)
        set.drawCirclesEnabled = false
        set.colors = ChartColorTemplates.vordiplom()

        let data = LineChartData(dataSet: set)
        linechart.data = data
        
        
    }
    

}
