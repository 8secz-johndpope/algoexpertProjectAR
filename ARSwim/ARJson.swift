
import UIKit
import Foundation
import SceneKit
import ARKit
import ModelIO
import SceneKit.ModelIO

public class ARJson {
    var iden : String
    var scene : ARSCNView!
    var model : ARModel!
    
    //Listing of variables needed in the json file
    private var Equipment : String
    private var Id: String
    private var Temperature : String
    private var Workorder : String
    private var model3D : String!
    
       
    
    var IoT : String
    var liste = [Container]()
    // var gitData : Decodable
    init(identi : String){
        //Be carefull to the adjustement
      /*  let mySubstring = value.prefix(7)
        if mySubstring == "http://" {
            let value2 = value.suffix(8)
            self.iden = String(value2)
        }else{
            self.iden = String(value)
        }*/
        self.iden = String(10000027) //tempory
      // self.gitData = JSONDecoder() as! Decodable
      //  self.scene = scene
        self.Equipment = ""
        self.Id = ""
        self.Temperature = ""
        self.Workorder = ""
        self.model3D = ""
        
        self.IoT = ""
    }
    
    
   
    
    func getModel() -> String { 
        return self.model3D 
    }
    
    func setModel(value : String) {
        self.model3D = value
    }
    
    func getEquipment() -> String {
        return self.Equipment
    }
    func setEquipment(value : String){
        self.Equipment = value
    }
    
    func getId() -> String {
        return self.Id
    }
    func setId(value : String){
        self.Id = value
    }
    
    func getTemperature() -> String {
        return self.Temperature
    }
    func setTemperature(value : String){
        self.Temperature = value
    }
    func getWorkorder() -> String {
        return self.Workorder
    }
    func setWorkorder(value : String){
        self.Workorder = value
    }
}

