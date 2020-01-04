import Foundation
import AVFoundation
import UIKit
import ModelIO
import SceneKit.ModelIO

class LoadViewController: UIViewController {
    var node : SCNNode!
    var model : ARModel!
    var doc : String!
    var json = ARJson(identi: "")
    
    
    @IBOutlet weak var inf1: UILabel!
    @IBOutlet weak var inf2: UILabel!
    @IBOutlet weak var inf3: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inf1.text = "Temperature : " + json.getTemperature()
        inf2.text = "Equipment : " + json.getEquipment()
        inf3.text = "workoder : " + json.getWorkorder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let finalView  = segue.destination as? ScanViewController else { return }
        finalView.parseJson = json
        finalView.doc = model.documents
        finalView.node = node
        finalView.model = model
    }
}
