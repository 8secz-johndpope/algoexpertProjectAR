

import UIKit
import SceneKit
import ARKit

import ModelIO
import SceneKit.ModelIO

class ARGestureUtils {
    
    var angleX : Float
    var angleY : Float = 0.1
    var transformX : SCNMatrix4
    var transformY : SCNMatrix4
    var firstRotation : Bool = false
    
    init(){
        self.angleX = 0.1
        self.angleY = 0.1
        self.transformX =  SCNMatrix4.init(float4x4(0.0))
        self.transformY = SCNMatrix4.init(float4x4(0.0))
    }
    
    func turnAway(translation : Float , style : String) -> Bool {
        translation < 0.0 ? (style == "X" ? (self.angleX+=Float(0.1)) :(self.angleY+=Float(0.1))  ) : (style == "X" ?     (self.angleX-=Float(0.1)) : (self.angleY-=Float(0.1)))
        return translation < 0.0
    }
    
    func doAction(mode : Bool , node : SCNNode! , translationX : Float , translationY : Float){
        if mode {
            self.turnAway(translation: Float(translationX) , style : "X") == true ? (node.pivot = SCNMatrix4MakeRotation(0,self.angleX, 0, 1)) : ( node.pivot = SCNMatrix4MakeRotation(0, self.angleX, 0, 1))
        }else{
            self.turnAway(translation: Float(translationY), style: "Y")
        }
        self.doRotate(mode : mode)
        self.firstRotate()
    }
    
    func firstRotate()  {
        if(self.firstRotation == false){
            self.firstRotation = true
            self.transformY = SCNMatrix4(float4x4(1.0))
        }
    }
    
    func doRotate (mode : Bool) {
        mode == true ? (self.transformX =  SCNMatrix4MakeRotation(self.angleX, 0, 0, 1)) :  (self.transformY = SCNMatrix4MakeRotation(self.angleY, 1, 0, 0))
    }
}

