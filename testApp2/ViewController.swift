import UIKit

protocol infoFromPopUp {
    func refreshData(id:Int, name:String, phoneNumber:String, eMail: String, imagePath:String)
    func addPerson(id:Int, name:String, phoneNumber:String, eMail: String, imagePath:String)
}
protocol tapOnCell {
    func getId(id:Int)
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var db:DBHelper = DBHelper()
    
    var persons:[Person] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        persons = db.read()
        persons.sort {$0.name < $1.name}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addPerson" {
            let addVC = segue.destination as! AddPersonViewController
            addVC.prevVC = self
            addVC.change = false
            addVC.personID = db.findEmpty()
        }
    }
    func refreshTable(){
        persons = db.read()
        persons.sort {$0.name < $1.name}
        tableView.reloadData()
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named+".png").path)
        }
        return nil
    }
}
extension ViewController: infoFromPopUp {
    func addPerson(id:Int, name:String, phoneNumber:String, eMail: String, imagePath:String) {
        db.insert(id: id, name: name, phoneNumber: phoneNumber, eMail: eMail,imagePath: imagePath)
        refreshTable()
    }
    
    func refreshData(id:Int, name:String, phoneNumber:String, eMail: String, imagePath:String) {
        db.reload(id: id, name: name, phoneNumber: phoneNumber, eMail: eMail, imagePath: imagePath)
        refreshTable()
    }
}
extension ViewController: tapOnCell{
    func getId(id: Int) {
        let popUpVC = storyboard?.instantiateViewController(withIdentifier: "AddPersonViewController") as! AddPersonViewController
        
        popUpVC.personID = persons[id].id
        popUpVC.personName = persons[id].name
        popUpVC.personPhoneNum = persons[id].phoneNumber
        popUpVC.personEmail = persons[id].eMail
        popUpVC.imagePath = persons[id].imagePath
        
        popUpVC.change = true
        popUpVC.prevVC = self
        present(popUpVC, animated: true, completion: nil)
        
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        persons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! tableCell
        if persons[indexPath.row].imagePath != "default"{
            cell.personImageView.image = getSavedImage(named: persons[indexPath.row].imagePath)
        } else {
            cell.personImageView.image = UIImage(systemName: "person.crop.circle")
        }
        cell.fillCell(name: persons[indexPath.row].name, phoneNum: persons[indexPath.row].phoneNumber, email: persons[indexPath.row].eMail)
        cell.cellId = indexPath.row
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "delete") { (action, view, completionHandler) in
            self.db.deleteByID(id: self.persons[indexPath.row].id)
            self.refreshTable()
            completionHandler(true)
        }
        let swipe = UISwipeActionsConfiguration(actions: [delete])
        return swipe
    }
}
