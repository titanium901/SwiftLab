//
//  ViewController.swift
//  HitList
//
//  Created by Sergey Dunaev on 06/08/2019.
//  Copyright © 2019 SwiftLab. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var people: [Person] = []
    var imagePickerIndexPath = IndexPath(item: 0, section: 0)
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Список"
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try context.fetch(Person.fetchRequest())
        } catch {
            print(error.localizedDescription)
        }
        
        
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Новое имя", message: "Добавить новое имя", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [unowned self] action in
            guard let nameToSave = alert.textFields?[0].text,
                let age = alert.textFields?[1].text,
                let eyeColor = alert.textFields?[3].text,
                let adressToSave = alert.textFields?[2].text,
                let ageToSave = Int16(age) else {
                    return
            }
            
            let eyeColorToSave = self.eyeColorFromString(eyeColor)
            
            self.save(name: nameToSave, age: ageToSave, eyeColor: eyeColorToSave, adress: adressToSave)
            self.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .default)
        
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        alert.addTextField()
        
        alert.textFields?[0].placeholder = "Имя"
        alert.textFields?[1].placeholder = "Возраст"
        alert.textFields?[2].placeholder = "Адрес"
        alert.textFields?[3].placeholder = "Цвет глаз"
        
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func eyeColorFromString(_ eyeColor: String) -> UIColor {
        switch eyeColor {
        case "Blue":
            return UIColor.blue
        case "Purple":
            return UIColor.purple
        case "Green":
            return UIColor.green
        case "Brown":
            return UIColor.brown
        default:
            return UIColor.blue
        }
    }
    
    func save(name: String, age: Int16, eyeColor: UIColor, adress: String) {
//        //получили ссылку на таблицу
//        let entity = NSEntityDescription.entity(forEntityName: "Person", in: context)!
//        //добавить новый объект в контексте
//        let person = NSManagedObject(entity: entity, insertInto: context)
//        person.setValue(name, forKey: "name")
        
        let person = Person(entity: Person.entity(), insertInto: context)
        person.name = name
        person.age = age
        person.eyeColor = eyeColor
        person.adress = adress
        
        appDelegate.saveContext()
        people.append(person)
    }
}

// MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PersonViewCell
        
        let person = people[indexPath.row]
        
        cell.nameLabel.text = person.name
        cell.ageLabel.text = String(person.age)
        cell.eyeColorView.backgroundColor = person.eyeColor as! UIColor?
        cell.addressLabel.text = person.adress
        
        if let pictureData = person.picture {
            cell.pictureImageView.image = UIImage(data: pictureData)
        } else {
            cell.pictureImageView.image = UIImage(named: "person-placeholder")
        }
        
        
        return cell
    }
    
    
}

// MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imagePickerIndexPath = indexPath
        
        let pickerController = UIImagePickerController()
        pickerController.sourceType = .photoLibrary
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationController

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let person = people[imagePickerIndexPath.row]
        person.picture = image.pngData()!
        
        appDelegate.saveContext()
        
        collectionView.reloadItems(at: [imagePickerIndexPath])
        picker.dismiss(animated: true, completion: nil)
    }
}

