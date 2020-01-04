

import UIKit
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO
import Speech

class ScanViewController: UIViewController, ARSCNViewDelegate, AVCaptureMetadataOutputObjectsDelegate, SFSpeechRecognizerDelegate{
   
  
    
    @IBOutlet weak var information: UILabel!
    
    @IBOutlet weak var inf1: UILabel!
    @IBOutlet weak var inf2: UILabel!
    @IBOutlet weak var inf3: UILabel!
    
    
    @IBOutlet weak var modeXY: UILabel!
    @IBOutlet var sceneView: ARSCNView!
    
    var node : SCNNode!
    var utils = ARGestureUtils()
    var model : ARModel!
    //parameters for buttons
    var tapping : Bool = false
    var rotation : Bool = false
    var animate : Bool = false
    var parseJson : ARJson!
    
    //Value of the content in the QRCode.
    var Identity : String!
    var doc : String!
    
    
    //begin audio stuffs actions
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var isRecording = false
     
    var voiceToUse: AVSpeechSynthesisVoice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
        information.text = "the object file is loaded "
        
        //Voice init begining
        for voice in AVSpeechSynthesisVoice.speechVoices() {
            if #available(iOS 9.0, *) {
                if voice.name == "Daniel" {
                    voiceToUse = voice
                }
            }
        }
        
         talk(bla : "Welcome in Swim, sir.Type the button to use vocals commands.")
        
      /*  if Identity != "http://smp1.ls.lagaude.ibm.com/c222.scn" {
            Identity = "http://smp1.ls.lagaude.ibm.com/c222.scn"
        }*/
        model = ARModel(v : SCNVector3(0.0 , 0.0 , -3.0),n : /*"http://smp1.ls.lagaude.ibm.com/c222.scn"*/parseJson.getModel() , s : self.sceneView , doc : self.doc)
        
      //  self.node = self.model.DownloadModel(scale : SCNVector3(0.4,0.4,0.4))
        self.node = self.model.loading(scale : SCNVector3(0.4,0.4,0.4))
        self.analysisStart()
        self.applyGesture()
        self.model.node.runAction(SCNAction.playAudio(SCNAudioSource(named : "art.scnassets/first1.mp3")!, waitForCompletion: false))
        
        self.inf1.text = "humidity :"
        self.inf2.text = "Temperature :"
        self.inf3.text = "status :"
        
        
        //Identity is just the ID of the object
       // parseJson = ARJson(value : Identity, scene : self.sceneView)
        
       
        //parseJson.loadparse() // Stocking files in structs
  
    }
   
       @IBAction func vocal(_ sender: Any) {
        if isRecording == true {
            audioEngine.stop()
            recognitionTask?.cancel()
            isRecording = false
          
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
           
        }
        
    }
    
    /*
     *Apply all gesture recognition to the screen
     */
    func applyGesture(){
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(rotationAll(sender:)))
        dragGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(dragGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:  #selector(pinchAction(sender:)))
        view.addGestureRecognizer(pinchGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
        //Tests Hits
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(ScanViewController.handleTap(rec:)))
        view.addGestureRecognizer(tapRec)
       
    }
  /*Tests */
   @IBAction func Top(_ sender: Any) {
        let action = SCNAction.move(to:SCNVector3(node.position.x, node.position.y + 0.1 , node.position.z), duration: 1)
        node.runAction(action)
    }
    
    @IBAction func left(_ sender: Any) {
        let action = SCNAction.move(to:SCNVector3(node.position.x-0.1, node.position.y  , node.position.z), duration: 1)
        node.runAction(action)
    }
    
    @IBAction func bot(_ sender: Any) {
        let action = SCNAction.move(to:SCNVector3(node.position.x, node.position.y - 0.1 , node.position.z), duration: 1)
        node.runAction(action)
    }
    
    @IBAction func right(_ sender: Any) {
        let action = SCNAction.move(to:SCNVector3(node.position.x+0.1, node.position.y  , node.position.z), duration: 1)
        node.runAction(action)
    }
    
    /*
     * At the beginning rotate the model.
     */
    func analysisStart(){
       
      
        let  action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        node.runAction(repAction , forKey: "myrotate")
    }
    
    @IBAction func anim(_ sender: UIButton) {
        if !animate {
            node.removeAction(forKey: "myrotate")
            animate = true
        }else{
            analysisStart()
            animate = false
        }
    }
    
    func animation (){
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        let action3 = SCNAction.move( to : SCNVector3(0, -1, -1) , duration : 4)
        
        let action4 = SCNAction.scale(by:CGFloat(1.3) , duration : 6)
        //carNode.runAction(action3 , forKey: "myrotate")
        
        //sacNode.runAction(SCNAction.playAudio(SCNAudioSource(named : "art.scnassets/I.mp3")!, waitForCompletion: false))
        var actions: [SCNAction] = [action4 , repAction]
        actions.append(SCNAction.removeFromParentNode())
        let sequence = SCNAction.sequence(actions)
        node.runAction(sequence)
    }
    
    @IBAction func rot(_ sender: UIButton) {
        if !rotation {
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction(sender:)))
            dragGesture.maximumNumberOfTouches = 1
            view.addGestureRecognizer(dragGesture)
            rotation = true
            modeXY.text = "rotation XY"
        }else{
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(rotationAll(sender:)))
            dragGesture.maximumNumberOfTouches = 1
            view.addGestureRecognizer(dragGesture)
            rotation = false
            modeXY.text = "rotation ALL"
        }
    }
    
    @objc func doubleTapped() {
       
        if tapping == false {
            model.expend()
            tapping = true
        }else{
            model.collapse()
            tapping = false
        }
    }
    
    /*
     *Implementing the raycasting by the function hitTest().
     * test all test without bounding box
     */
    @objc
    func handleTap(rec: UITapGestureRecognizer){
        
     //   if rec.state == .ended {
            
            let location: CGPoint = rec.location(in: sceneView)
            let hits = self.sceneView.hitTest(location, options: nil)
        if let tappednode = hits.first?.node  {
                //do something with tapped object
                print("Eh i can see you in the ground")
          
            
          /* let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
            let repAction = SCNAction.repeatForever(action)
            tappednode.runAction(repAction)*/
           
             var id : Int = 0
             
              for childNode in model.SceneChildNodes {
                 if childNode == tappednode {
                      print("Eh i can see you in the ground")
                    for i in 0..<parseJson.liste.count {
                        
                        if id == Int(parseJson.liste[i].id) {
                            self.inf1.text = "humidity :" + parseJson.liste[i].humidity
                            self.inf2.text = "Temperature :" + parseJson.liste[i].temp
                            self.inf3.text = "status :" + parseJson.liste[i].status
                        }
                    }
                  
                }
                
                id += 1
                childNode.opacity = 0.6
              }
              id = 0 
            tappednode.opacity = 5.0
            }
       // }
    }
    
    
    @objc
    func dragAction(sender:UIPanGestureRecognizer){
        node.removeAction(forKey: "myrotate")
        let translation = sender.translation(in: sceneView!)
        if sender.state == .changed{
            abs(translation.x) > abs(translation.y) ? (utils.doAction(mode: true, node: node, translationX : Float (translation.x), translationY: Float(translation.y)))  : (utils.doAction(mode: false, node: node, translationX : Float(translation.x), translationY: Float(translation.y)))
            node.pivot = SCNMatrix4Mult(utils.transformX, utils.transformY)
        }
    }
    
    @objc
    func rotationAll(sender:UIPanGestureRecognizer){
        node.removeAction(forKey: "myrotate")
        let translation = sender.translation(in: self.sceneView!)
        var newAngleX = (Float)(translation.y)*(Float)(Double.pi)/180.0
        newAngleX += utils.angleX
        var newAngleY = (Float)(translation.x)*(Float)(Double.pi)/180.0
        newAngleY += utils.angleY
        node.eulerAngles.x = newAngleX
        node.eulerAngles.y = newAngleY
        
        if(sender.state == UIGestureRecognizerState.ended) {
            utils.angleX = newAngleX
            utils.angleY = newAngleY
        }
    }
    
    @IBAction func pinchAction( sender: UIPinchGestureRecognizer) {
        if sender.state == .changed{
            let zoom = ARZoom()
            zoom.zoom(node: node, sender: sender)
        }
        if sender.state == .ended{
            sender.scale = 1
        }
    }
    
    
    func recordAndRecognizeSpeech() {
     configureAudioSession()
        let node = audioEngine.inputNode
        
        //let recordingFormat = node.outputFormat(forBus: 0)
         let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
           
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
               self.whatAction(dot : lastString)
            } else if let error = error {
                self.sendAlert(message: "There has been a speech recognition error.")
             //   print(error)
            }
        })
    }
    
       private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { }
    }
    
     func talk(bla : String) {
        let utterance = AVSpeechUtterance(string: bla)
        utterance.voice = voiceToUse
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
      func whatAction (dot : String){
     
        
        switch dot {
        case "zoom":
            let zoom = ARZoom()
            zoom.zoomAudio(node: node, boolean: true)
        case "unzoom" :
            let zoom = ARZoom()
            zoom.zoomAudio(node: node, boolean: false)
        case "expand" :
    
            model.expend()
             talk(bla : "yes sir.")
        case "collapse" :
            model.collapse()
             talk(bla : "yes sir.")
            
        case  "rotation" :
            analysisStart()
             talk(bla : "Yes sir.Let's rotate the model.")
         case "stop" :
            node.removeAction(forKey: "myrotate")
             talk(bla : "stoping process")
        default: break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
      func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    print("Good to go!")
                } else {
                    print("Transcription permission was declined.")
                }
            }
        }
    }
    
     func sendAlert(message: String) {
        let alert = UIAlertController(title: "Speech Recognizer Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}


