
import UIKit

class UtilViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //view.backgroundColor = UIColor.clear
       // view.isOpaque = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentModal() {
        let modalController = UtilViewController()
        modalController.modalPresentationStyle = .overCurrentContext
        present(modalController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func but(_ sender: Any) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let finalView  = segue.destination as? ViewController else { return }
    
    }
}
