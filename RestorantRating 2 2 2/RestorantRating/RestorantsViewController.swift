//
//  RestorantsViewController.swift
//  RestorantRating
//
//  Created by Yury Popov on 02/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit

class RestorantsViewController: UITableViewController {
    
    
    var restorants = [Restarant]()
    
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        loadRestorantItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationController?.navigationBar.barTintColor = UIColor(displayP3Red: 21/255,
                                                                   green: 101/255,
                                                                   blue: 192/255,
                                                                   alpha: 1)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewRestarant))
        navigationItem.rightBarButtonItem?.tintColor = .black
        tableView.allowsSelectionDuringEditing = true
        

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restorants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Restarant", for: indexPath) as? RestarantTableViewCell else {
            fatalError("Dont get custom cell")
        }
        let restarant = restorants[indexPath.row]
        cell.name.text = restarant.name.capitalizingFirstLetter()
        cell.imageName.image = UIImage(named: restarant.image)
        cell.staff.text = restarant.staff
        

        return cell
    }
    
  
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print(#function)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        print(#function)
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            restorants.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveRestorantItem()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if  let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.restarant = restorants[indexPath.row]
            vc.buttonStatus = true
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    func documentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //возвращает папку с названием файла куда будем сохранять
    func dataFilePath() -> URL {
        return documentDirectory().appendingPathComponent("Restorants.plist")
    }
    
    func loadRestorantItems() {
        let path = dataFilePath()
        print("Rest path")
        print(path)
        if FileManager.default.fileExists(atPath: path.path) {
            do {
                restorants = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(Data(contentsOf: path)) as! [Restarant]
            } catch {
                print("Error загрузки \(error.localizedDescription)")
            }
        }
    }
    
    func saveRestorantItem() {
        let path = dataFilePath()
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: restorants, requiringSecureCoding: false)
            try data.write(to: path)
        } catch {
            print("Error сохранения \(error.localizedDescription)")
        }
    }
 

    @objc func addNewRestarant () {
        if  let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            navigationController?.pushViewController(vc, animated: true)
            vc.title = "Rating"
        }
    }
    
    @IBAction func unwing(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveSegue" else { return }
        guard let detailVC = segue.source as? DetailViewController else { return }
        let restarant = detailVC.restarant
        print(restarant.image)
        print("-----------------", restarant.image)
        if let path = tableView.indexPathForSelectedRow {
            restorants[path.row] = restarant
            tableView.deselectRow(at: path, animated: false)
        } else {
            restorants.append(restarant)
        }
        saveRestorantItem()
        tableView.reloadData()
        
        
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
