

import UIKit
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO

class ARZoom {
    //init
    init(){
        
    }

    /*
     *  function to zoom/dezoom
     *  with the scaling option
     */
    func zoom ( node : SCNNode!, sender: UIPinchGestureRecognizer ){
        if(node.scale.x > Float(0.005) && sender.scale < CGFloat(1.0)){
            node.scale.x *= Float(0.99)
            node.scale.y *= Float(0.99)
            node.scale.z *= Float(0.99)
        }
        
        if(node.scale.x < Float(0.9) && sender.scale > CGFloat(1.0) ){
            node.scale.x *= Float(1.01)
            node.scale.y *= Float(1.01)
            node.scale.z *= Float(1.01)
            
        }
    }
    
     func zoomAudio(node :SCNNode! , boolean : Bool){
        if boolean {
            node.scale.x *= Float(0.99)
            node.scale.y *= Float(0.99)
            node.scale.z *= Float(0.99)
        }else {
            node.scale.x *= Float(1.01)
            node.scale.y *= Float(1.01)
            node.scale.z *= Float(1.01)
        }
    }
}

