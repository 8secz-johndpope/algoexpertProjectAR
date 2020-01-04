
import Foundation
import AVFoundation
import UIKit
import ModelIO
import SceneKit.ModelIO

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
  
    private let session = AVCaptureSession()
    var content : String = "" // contain the value of the QRCODE.
    let json = ARJson(identi: "")
    
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        session.stopRunning()
        super.viewWillDisappear(animated)
    }
    
    
    //Scanning for a specificable QRcode with different things.
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        
        let devices = discoverySession.devices
        
        
        if let backCamera = devices.first {
            do {
                
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        
                        
                        self.session.startRunning()
                    }
                }
            } catch {
                print("Error occured while creating video device input: \(error)")
            }
        }
    }
    
    
    @IBAction func press(_ sender: UIButton) {
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
      
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            
            if metadata.type != .qr { continue }
            
            
            if metadata.stringValue == nil { continue }
            
            self.content = metadata.stringValue!
          
          
            
            if let url = URL(string: metadata.stringValue!) {
                
                self.session.stopRunning()
             /*  let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "ScanViewController")
                self.navigationController!.pushViewController(vc, animated: true)
                */
                
                //  UIApplication.shared.open(url, options: [:], completionHandler: nil)
             //    navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController, animated: true)
                break
            }
        }
    }
    
    /*
     * All structures with data settings
     */
    struct OverlayData : Decodable {
        let Equipment : String
        let Id: String
        let Temperature : String
        let Workorder : String
    }
    
    struct ComplexStruct : Decodable {
        let OverlayData : OverlayData
        let Model3D : String
        let IoT : String
    }
    
    struct datas :  Decodable{
        let _id : String
        let _rev : String
        let id : String
        let temp : String
        let humidity : String
        let pressure : String
        let accelY : String
        let status : String
    }
    
    var model : ARModel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let finalView  = segue.destination as? LoadViewController else { return }
  
        let gitUrl = URL(string: "https://ar4swim.mybluemix.net/GetEquipmentDetails?id="+String(content)) //else { return }
        
        
        let dispatchGroup = DispatchGroup() // <===
        dispatchGroup.enter() //
        
        URLSession.shared.dataTask(with: gitUrl!) { (data, response
            , error) in
            
            guard let data = data else {  dispatchGroup.leave()
                return }
            do {
                
                let decoder = JSONDecoder()
                let gitData = try decoder.decode(ComplexStruct.self, from: data)
                
               
              
               self.json.setModel(value: gitData.Model3D)
               self.json.setEquipment(value: gitData.OverlayData.Equipment)
               self.json.setId(value: gitData.OverlayData.Id)
               self.json.setTemperature(value: gitData.OverlayData.Temperature)
               self.json.setWorkorder(value: gitData.OverlayData.Workorder)
               self.json.IoT = gitData.IoT
                //....
                
                //  self.detailParse(s: gitData.IoT)
                
                
                
                dispatchGroup.leave()
            } catch let err {
                print("Err", err)
                dispatchGroup.leave()
            }
            
            }.resume()
        dispatchGroup.wait()
        
        
         self.detailParse(s: self.json.IoT)
        
        finalView.json = json
        let model = ARModel(v : SCNVector3(0.0 , 0.0 , -3.0),n : /*"http://smp1.ls.lagaude.ibm.com/c222.scn"*/json.getModel())
         var node = SCNNode()
        node = model.DownloadModel(scale: SCNVector3(0.0 , 0.0 , -3.0) , lien : json.getModel())
        finalView.doc = model.documents
        
        finalView.node = node
        finalView.model = model
        
    }
    
    
    /*
     * this function allows the programm to parse another Json on the Json.
     */
    func detailParse(s : String){
        guard let gitUrl = URL(string: s) else { return }
          let dispatchGroup2 = DispatchGroup() // <===
          dispatchGroup2.enter()
          
        URLSession.shared.dataTask(with: gitUrl) { (data, response
            , error) in
            
            guard let data = data else { 
             dispatchGroup2.leave()
            return }
            do {
                
                let decoder = JSONDecoder()
                let gitData = try decoder.decode([datas].self, from: data)
                
               //  self.json.liste.append(Container(id: gitData[0]._id, rev: gitData[0]._rev, id2: gitData[0].id, temp: gitData[0].temp, humidity: gitData[0].humidity, pressure: gitData[0].pressure, acc: gitData[0].accelY, status: gitData[0].status))
                  for i in 0..<gitData.count {
                //download all datas 
                 self.json.liste.append(Container(id: gitData[i]._id, rev: gitData[i]._rev, id2: gitData[i].id, temp: gitData[i].temp, humidity: gitData[i].humidity, pressure: gitData[i].pressure, acc: gitData[i].accelY, status: gitData[i].status))
                
                }
                //print(gitData[0]._id) // Example of value
                 dispatchGroup2.leave()
            } catch let err {
                print("Err", err)
                 dispatchGroup2.leave()
            }
            
            }.resume()
             dispatchGroup2.wait()
        
    }
    
}

