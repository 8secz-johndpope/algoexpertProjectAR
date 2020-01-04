

import UIKit
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO

class ARModel {
    
    public var position : SCNVector3
    public var name : String = ""
    public var scene : ARSCNView!
    
    public var node : SCNNode!
    public var ModelScene : SCNScene!
    public var SceneChildNodes : [SCNNode]
    public var bary : SCNVector3
    public let SENSIBILITY : Int = 60
    
    init (v : SCNVector3, n : String ) {
        self.position = v
        self.name = n
        self.scene = ARSCNView()
        self.node = SCNNode()
        self.SceneChildNodes = []
        self.bary = SCNVector3(0.0,0.0,0.0)
        self.documents = ""
    }
    
    init( v : SCNVector3, n : String , s : ARSCNView! , doc : String){
        self.position = v
        self.name = n
        self.scene = s
        self.node = SCNNode()
        self.SceneChildNodes = []
        self.bary = SCNVector3(0.0,0.0,0.0)
        self.documents = doc 
        
    }
    
    
    /*
     * Support DAE and OBJ files.Think a method to convert FBX -> DAE
     */
    func loadModel(scale : SCNVector3) -> SCNNode{
        
      //  self.ModelScene = try SCNScene(url :URL (string : self.name )! ,options : nil )
        
        let url = URL(string: self.name)!
        self.ModelScene = try! SCNScene(url: url, options: nil)
        let Node = SCNNode()
        self.SceneChildNodes = ModelScene.rootNode.childNodes
      
        for childNode in SceneChildNodes {
            Node.addChildNode(childNode as SCNNode)
        }
        Node.position = self.position
        Node.scale = scale //SCNVector3(0.6, 0.6, 0.6)
        scene.scene.rootNode.addChildNode(Node)
        self.node = Node
        return Node

    }
    
     var documents:String
    
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

    
     func loading(scale : SCNVector3) -> SCNNode{
        do{
            
            self.ModelScene =  try SCNScene(url: URL(fileURLWithPath: self.documents ), options: nil)
            
            self.SceneChildNodes = self.ModelScene.rootNode.childNodes
            for childNode in self.SceneChildNodes {
                self.node.addChildNode(childNode as SCNNode)
            }
           
            self.node.position = self.position
            self.node.scale = scale
            
            //adjusting the pivot of the node
             let bound2 = SCNVector3(
                x: self.node.boundingBox.max.x - self.node.boundingBox.min.x,
                y: self.node.boundingBox.max.y - self.node.boundingBox.min.y,
                z: self.node.boundingBox.max.z - self.node.boundingBox.min.z)
            
             self.node.pivot = SCNMatrix4MakeTranslation(bound2.x / 8, bound2.y / 8, bound2.z / 8)
             
             
            self.scene.scene.rootNode.addChildNode(self.node)
            // self.node = node
            
            
        }catch {}
        return self.node
     }
    
    /*
     * We take the center of the object then we apply a vector of force for each objects
     */
    func expend (){
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
    
    /*
     *revserse of the function expend() 
     */
    
    func collapse (){
        var aray : [SCNAction]
        var test = SCNVector3(0.6, 0.6, 0.6)
        
        for childNode in self.SceneChildNodes {
            test.x = 0.007*(((childNode.boundingBox.max.x + childNode.boundingBox.min.x) / 2) - bary.x)/60
            test.y = 0.007*(((childNode.boundingBox.max.y + childNode.boundingBox.min.y) / 2) - bary.y)/60
            test.z = 0.007*(((childNode.boundingBox.max.z + childNode.boundingBox.min.z) / 2) - bary.z)/60
            let action = SCNAction.move( to : test , duration : 1)
            childNode.runAction(action)
        }
    
    }
   
   
    
    func animation (tab : [SCNAction] ){
        if tab.count == 0 {
            //example
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
            let repAction = SCNAction.repeatForever(action)
            let action3 = SCNAction.move( to : SCNVector3(0, -1, -1) , duration : 4)
            let action4 = SCNAction.scale(by:CGFloat(1.3) , duration : 6)
            var actions: [SCNAction] = [action4 , repAction]
            actions.append(SCNAction.removeFromParentNode())
            let sequence = SCNAction.sequence(actions)
            self.node.runAction(sequence)
            
        }else{
            
            let sequence = SCNAction.sequence(tab)
            self.node.runAction(sequence)
        }
    }
}


