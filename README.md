# algoexpertProjectAR
here is a project for the algoexpert

Cool project using swift and the Augmented reality project ARKIT.
The goal of this little mobile application is to create an app that scan a QRCODe then return an Id( random for instance ?)
and then we will get the 3d object linked to the id number.

For instance we will use bluemix for the servor part 


App using Arkit 

Protoyp : The first version of the app can scan a QRcode which return an ID , **then type the screen one time**
, then the app
call a web service in bluemix : https://ar4swim.mybluemix.net/GetEquipmentDetails?id{IdNumber} , ***It can take a few time to download the model*** , 
here an example : 
```json
{
	"OverlayData": {
		"Equipment": "Centrifugal pump",
		"Id": "10000027",
		"Temperature": "65°C",
		"Workorder": "'4001720"
	},
	"Model3D": "http://smp1.ls.lagaude.ibm.com/c222.scn",
	"IoT": "http://iot4swim.mybluemix.net/CentrifugalPumpData"
}
```
and parse the JSon file return
to extract the 3D model linked and all informations about it (Temperature, (...))

**Then an UI with a button "load", push it to load it in front of the camera.**

*Note : The 3D model for the prototyp used is a centrifugal as the original SWIM project.
The 3D model is a little big, so that takes times to load the object.It is mainly a problem.




### Video Demo
This is what should do the application : 
https://drive.google.com/file/d/1Q0g8XgPo_QcAP4kEVx9DtqQpgt3SqXBN/view

### Main Use case

* The app started with the QR code scanner and try to find a qrcode which contains a value (ID) 
the main function used metadatas come from the AVCCaptureSession 
```swift
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
```

* We download bit per bit the 3D file. We firstable dowload it on the Document file of the device.When it is finished, a button can load it on the screen Camera.
```swift
func DownloadModel(scale : SCNVector3 , lien : String) -> SCNNode{
         let urlString = lien
         let url = URL.init(string: urlString)
         let request = URLRequest(url: url!)
         let session = URLSession.shared
        
        let dispatchGroup = DispatchGroup() // <===
        dispatchGroup.enter() //
        
         let downloadTask = session.downloadTask(with: request,
         completionHandler: { (location:URL?, response:URLResponse?, error:Error?)
         -> Void in
         print("location:\(String(describing: location))")
         let locationPath = location!.path
            self.documents = NSHomeDirectory() + "/Documents/c222.scn"
         var ls = NSHomeDirectory() + "/Documents"
         let fileManager = FileManager.default
            if (fileManager.fileExists(atPath: self.documents)){
                try! fileManager.removeItem(atPath: self.documents)
         }
            try! fileManager.moveItem(atPath: locationPath, toPath: self.documents)
            print("new location:\(self.documents)")
           
            dispatchGroup.leave()
         })
         downloadTask.resume()
        dispatchGroup.wait()
      
        
         return self.node
     }
```

* We have now the possibility to rotate, move, scale (...) 

* New feature, we can now use the speech to text app, there is now commands : 
1. expand
2. collapse
3. zoom
4. unzoom
(...)
We used the intern library Speech as following : 
```swift
import Speech

  recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                let bestString = result.bestTranscription.formattedString   
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
               self.whatAction(dot: lastString) 
            } 
```

### Code organisation

The code has a pretty simple organisation : 

* viewController ->  it is the first interface and the qrcode detecter
* ARModel -> All Model stuff gesture is on, espescially the function collapse and expand 
* ARGestureUtil -> all calculation stuff for moving an object 
* ARZoom -> stuffs for zoom and unzoom
* ARJson, Container -> containers for downloading the json format file.For each informations ...
* ScanViewController -> Is the main file with all functions linked


### 3D stuffs
Encountered problems,  the loading file is a SCN format 3d, to have a good downloading of a component ARKIT need to have SCN files, that is why directly on the server we have set an scn file converted thanks to blender.

* Blender stuffs : For the moment we used a software to change the size of the component, and change the Pivot Point.
#### Update : We are now able to modify the pivot to the center 

#### Collapse and expand 

* The algorithm used is simple : find the center points of each sub components of the 3D model, then use the average formula to determine the Barycenter of the model.This point called center is usefull to calculate each vectors for expension of a certain factor (times 0.2 for example).
For this app, we used mainly certain properties : (.boundingBox.max.x,.boundingBox.max.y) and (.boundingBox.min.x , .boundingBox.min.y) 
![](https://github.ibm.com/ibm-ix-france/SWIM_3D/blob/master/wiki/images/expand3.png)


```swift
 func expand (){
        var test = SCNVector3(0.6, 0.6, 0.6)
    
        var X : Float = 0.0
        var Y : Float = 0.0
        var Z : Float = 0.0
        for childNode in self.SceneChildNodes {
            X += Float((childNode.boundingBox.max.x + childNode.boundingBox.min.x) / 2 )
            Y += Float((childNode.boundingBox.max.y + childNode.boundingBox.min.y) / 2)
            Z += Float((childNode.boundingBox.max.z + childNode.boundingBox.min.z) / 2 )
           
        }
        bary.x = Float(X/Float(self.SceneChildNodes.count))
        bary.y = Float(Y/Float(self.SceneChildNodes.count))
        bary.z = Float(Z/Float(self.SceneChildNodes.count))
        for childNode in self.SceneChildNodes {
            test.x = -0.007*(((childNode.boundingBox.max.x + childNode.boundingBox.min.x) / 2) - bary.x)
            test.y = -0.007*(((childNode.boundingBox.max.y + childNode.boundingBox.min.y) / 2) - bary.y)
            test.z = -0.007*(((childNode.boundingBox.max.z + childNode.boundingBox.min.z) / 2) - bary.z)
            let action = SCNAction.move( to : test , duration : 1)
            childNode.runAction(action)
        }
    }
```
### Release
The folder Release contains the .ipa file. It is the prototyp part


