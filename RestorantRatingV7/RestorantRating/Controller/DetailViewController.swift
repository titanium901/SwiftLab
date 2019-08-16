//
//  DetailViewController.swift
//  RestorantRating
//
//  Created by Yury Popov on 02/07/2019.
//  Copyright © 2019 Yury Popov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class DetailViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var auxImageView: UIImageView!
    @IBOutlet var button: UIBarButtonItem!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ratingPicker: UIPickerView!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var starsButtons: [UIButton]!
    
    @IBOutlet var starsImage: [UIImageView]!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var setLocationButton: UIButton!
    @IBOutlet var editLocationButton: UIButton!
    
    
    @IBOutlet var navBar: UINavigationBar!
    
    
    
    var ratings = ["0 stars", "1 star", "2 star", "3 star", "4 star", "5 star"]
    var staffRating = ["Good", "Bad", "Great", "Awful", "Awesome"]
    var selectedStar: String?
    var restarant = Restarant(name: "", note: "", image: "", staff: "", foto: "", location: ["" : ""])
    var index = 0
    var buttonStatus = false
    var imageStatus = false
    var newImageStatus = false
    let ratingImage = UIImage(named: "full_star")
    let nulRatingImage = UIImage(named: "star2")
    
    let isCamer = UIImagePickerController.isSourceTypeAvailable(.camera)
    
    var geocoder: CLGeocoder!
    let locationManager = CLLocationManager()
    var latitude = ""
    var longitude = ""
    var imageName = UUID().uuidString
    
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(#function)
        geocoder = CLGeocoder()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        ratingPicker.delegate = self
        ratingPicker.dataSource = self
        nameTextField.delegate = self
        noteTextView.delegate = self
        
        button.isEnabled = buttonStatus
        
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.isNavigationBarHidden = true
        navigationController?.toolbar.isHidden = false
        
        
        
        
        nameTextField.text = restarant.name
        noteTextView.text = restarant.note
        selectedStar = restarant.image
        
//        DispatchQueue.global().async { [weak self] in
//            self?.path = self?.getDocumentsDirectory().appendingPathComponent((self?.restarant.foto)!)
//            DispatchQueue.main.async {
//                self?.imageView.image = UIImage(contentsOfFile: (self?.path.path)!)
//            }
//        }
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let path = self?.getDocumentsDirectory().appendingPathComponent((self?.restarant.foto)!) else { return }
            DispatchQueue.main.async {
                self?.imageView.image = UIImage(contentsOfFile: (path.path))
            }
        }
        
       
        
        
        
        
        
        if restarant.name != "" {
            let annotation = MKPointAnnotation()
            annotation.title = restarant.name
            annotation.subtitle = "Restarant location"
//            latitude = restarant.location["latitude"]!
//            let doubleLat = Double(latitude)
//            longitude = restarant.location["longitude"]!
//            let doubleLon = Double(longitude)
            annotation.coordinate = CLLocationCoordinate2D(latitude: restarant.latitude, longitude: restarant.longitude)
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            delay(seconds: 0.2) {
                UIView.transition(with: self.imageView, duration: 1, options: [.curveEaseIn, .transitionFlipFromLeft], animations: {
                    
                }, completion: nil)
            }
        } else {
            customLocation()
            
        }
        
        
        
        
        setupUI()
        
        ratingPicker.selectRow(index, inComponent: 0, animated: false)
        if buttonStatus {
            navBar.topItem?.title = "Update"
        } else {
            navBar.topItem?.title = "Rating"
        }
       // print(navBar.topItem?.title)
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        nameTextField.becomeFirstResponder()
        print(#function, restarant.image)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "saveSegue" else {
            print("Not save segue")
            return
        }
        let selectedRow = ratingPicker.selectedRow(inComponent: 0)
        
        restarant.name = nameTextField.text ?? ""
        restarant.image = selectedStar ?? "0 star"
        restarant.note = noteTextView.text ?? ""
        restarant.staff = staffRating[selectedRow]
//        restarant.location["latitude"] = latitude
//        restarant.location["longitude"] = longitude
        restarant.latitude = Double(latitude) ?? 0
        restarant.longitude = Double(longitude) ?? 0
        restarant.foto = imageName
        
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func textFieldChanged() {
        if (nameTextField.text?.isEmpty ?? false) {
            button.isEnabled = false
            setLocationButton.isEnabled = false
            editLocationButton.isEnabled = false
        } else {
            button.isEnabled = true
            setLocationButton.isEnabled = true
            editLocationButton.isEnabled = true
        }
    }

    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        
       
        dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonAction(_ sender: UIButton) {
//        imageStatus.toggle()
        switchTags(button: sender)
    }
    
    func switchTags(button: UIButton) {
        var indexSwitch = 0
        switch button.tag {
        case 0:
            imageStatus.toggle()
            if imageStatus {
                for _ in 0..<starsButtons!.count {
                    starsButtons[indexSwitch].setImage(nulRatingImage, for: .normal)
                    indexSwitch += 1
                    selectedStar = ratings[0]
                }
            } else {
                setImagesToBtn(tag: 0, index: &indexSwitch)
            }
        case 1:
            setImagesToBtn(tag: 1, index: &indexSwitch)
        case 2:
            setImagesToBtn(tag: 2, index: &indexSwitch)
        case 3:
            setImagesToBtn(tag: 3, index: &indexSwitch)
        case 4:
            setImagesToBtn(tag: 4, index: &indexSwitch)
        default:
            break
        }
    }
    
    func setImagesToBtn(tag: Int, index: inout Int) {
        index = 0
            for _ in 0..<starsButtons!.count {
                if index <= tag {
                    starsButtons[index].setImage(ratingImage, for: .normal)
                } else {
                    starsButtons[index].setImage(nulRatingImage, for: .normal)
                }
                index += 1
            }
        selectedStar = ratings[tag + 1]
    }
    
    func setupUI() {
        switch restarant.image {
        case "0 stars":
            var i = 0
            for _ in 0..<starsImage!.count {
                starsButtons[i].setImage(nulRatingImage, for: .normal)
                starsImage[i].image = nulRatingImage
                i += 1
                
            }
        case "1 star":
            starsButtons[0].setImage(ratingImage, for: .normal)
            starsImage[0].image = ratingImage
        case "2 star":
            starsButtons[0].setImage(ratingImage, for: .normal)
            starsButtons[1].setImage(ratingImage, for: .normal)
            
            starsImage[0].image = ratingImage
            starsImage[1].image = ratingImage
        case "3 star":
            starsButtons[0].setImage(ratingImage, for: .normal)
            starsButtons[1].setImage(ratingImage, for: .normal)
            starsButtons[2].setImage(ratingImage, for: .normal)
            
            starsImage[0].image = ratingImage
            starsImage[1].image = ratingImage
            starsImage[2].image = ratingImage
        case "4 star":
            starsButtons[0].setImage(ratingImage, for: .normal)
            starsButtons[1].setImage(ratingImage, for: .normal)
            starsButtons[2].setImage(ratingImage, for: .normal)
            starsButtons[3].setImage(ratingImage, for: .normal)
            
            starsImage[0].image = ratingImage
            starsImage[1].image = ratingImage
            starsImage[2].image = ratingImage
            starsImage[3].image = ratingImage
            
        case "5 star":
            starsButtons[0].setImage(ratingImage, for: .normal)
            starsButtons[1].setImage(ratingImage, for: .normal)
            starsButtons[2].setImage(ratingImage, for: .normal)
            starsButtons[3].setImage(ratingImage, for: .normal)
            starsButtons[4].setImage(ratingImage, for: .normal)
            
            starsImage[0].image = ratingImage
            starsImage[1].image = ratingImage
            starsImage[2].image = ratingImage
            starsImage[3].image = ratingImage
            starsImage[4].image = ratingImage
        default:
            break
        }
        
        switch restarant.staff {
        case "Good":
            index = 0
        case "Bad":
            index = 1
        case "Great":
            index = 2
        case "Awful":
            index = 3
        case "Awesome":
            index = 4
        default:
            break
        }
    }
    
    func customLocation() {
        print(#function)
        if let location = locationManager.location {
            print("1")
            let annotation = MKPointAnnotation()
            annotation.title = restarant.name
            annotation.subtitle = "Restarant location"
            annotation.coordinate = location.coordinate
            
            latitude = location.coordinate.latitude.description
            longitude = location.coordinate.longitude.description
            restarant.location["latitude"] = latitude
            restarant.location["longitude"] = longitude
            print(restarant.location)
            
            
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
            
        }
    }
    
    
    @IBAction func setLocation(_ sender: UIButton) {
        customLocation()
    }
    
    
    
    @IBAction func editLocation(_ sender: UIButton) {
        let ac = UIAlertController(title: "Edit Location", message: "Set the correct coordinates", preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default) { (_) in
            guard let location = ac.textFields?[0].text, location != "" else { return }
            
            self.geocoder.geocodeAddressString(location) { (placemarks: [CLPlacemark]?, error: Error?) in
                if let addrError = error {
                    print("MapKit Error \(addrError.localizedDescription)")
                }
                
                if let pmList = placemarks {
                    if let placemark = pmList.first {
                        let annotation = MKPointAnnotation()
                        annotation.title = self.restarant.name
                        annotation.subtitle = location
                        annotation.coordinate = placemark.location!.coordinate
                        
                        self.latitude = annotation.coordinate.latitude.description
                        self.longitude = annotation.coordinate.longitude.description
                        self.restarant.location["latitude"] = self.latitude
                        self.restarant.location["longitude"] = self.longitude
                        
                        
                        self.mapView.showAnnotations([annotation], animated: true)
                        self.mapView.selectAnnotation(annotation, animated: true)
                    }
                }
            }
        }
        ac.addAction(ok)
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        ac.addAction(cancel)
        ac.addTextField { (textField) in
            textField.placeholder = "Restarant adress"
        }
        
        present(ac, animated: true)
        
    }
    
    
    @IBAction func tapOnImage(_ sender: UITapGestureRecognizer) {
        guard let recognizerView = sender.view else { return }
        let tag = recognizerView.tag
        selectedStar = ratings[tag + 1]
        
        for index in 0..<starsImage!.count {
            let image = starsImage[index]
            UIView.animate(withDuration: 0.5, animations: {
                image.alpha = 0
                
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    
                    if tag < index {
                        image.alpha = 1
                        image.image = self.nulRatingImage
                    } else {
                        image.alpha = 1
                        image.image = self.ratingImage
                    }
                })
            }
            //код ниже работал без анимации
            
//            if tag < index {
//                image.image = nulRatingImage
//            }
        }
  
    }
    
    @IBAction func takeFoto(_ sender: UIBarButtonItem) {
        
        let ac = UIAlertController(title: "Take Foto", message: "Where do you want to take a photo?", preferredStyle: .actionSheet)
        
        if !isCamer {
            let camera = UIAlertAction(title: "Camera not available", style: .default)
            camera.isEnabled = false
            ac.addAction(camera)
        } else {
            let cameraAv = UIAlertAction(title: "Camera", style: .default) { _ in
                let picker = UIImagePickerController()
                self.pickerChouse(picker: picker, isCamera: true)
            }
            ac.addAction(cameraAv)
        }
        
        let libary = UIAlertAction(title: "Photo Libary", style: .default) { _ in
            let picker = UIImagePickerController()
            self.pickerChouse(picker: picker, isCamera: false)
        }
        ac.addAction(libary)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func pickerChouse(picker: UIImagePickerController, isCamera: Bool ) {
        if isCamera {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        auxImageView.image = imageView.image
        imageView.image = image
        imageView.alpha = 0
        
        auxImageView.alpha = 1
        
        
        imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        print("Image Path")
        print(imagePath)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
            
        }
//        restarant.foto = imageName
        picker.dismiss(animated: true) {
            delay(seconds: 0.25) {
                UIView.animate(withDuration: 2) {
                    self.imageView.alpha = 1
                    self.auxImageView.alpha = 0
                    
                    
                }
            }
        }
        
        
        
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
   
    
}



extension DetailViewController: UIPickerViewDelegate {
    
}

extension DetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return staffRating.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return staffRating[row]
    }
    
    
}

extension UITableViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

extension UITableViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        textView.resignFirstResponder()
        return true
    }
}
