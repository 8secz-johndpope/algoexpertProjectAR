
import UIKit

class Container {

    var _id : String
    var _rev : String
    var id : String
    var temp : String
    var humidity : String
    var pressure : String
    var accelY : String
    var status : String
    
    
    init (id : String, rev : String , id2 : String , temp : String , humidity:String, pressure: String,acc : String ,status : String){
        self._id = id
        self._rev = rev
        self.id = id2
        self.temp = temp
        self.humidity = humidity
        self.pressure = pressure
        self.accelY = acc
        self.status = status
    }
    
}
