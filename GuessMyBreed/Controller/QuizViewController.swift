//
//  QuizViewController.swift
//  GuessMyBreed
//
//  Created by Huong Tran on 6/2/20.
//  Copyright © 2020 RiRiStudio. All rights reserved.
//

import UIKit
import CoreData

class QuizViewController: UIViewController, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
//    @IBOutlet weak var optionStackView: UIStackView!
    @IBOutlet weak var answerView: UIView!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var optionStackView: UIStackView!
    
    
    var breed = ""
    var breeds: [String]! {
        let object = UIApplication.shared.delegate
        let delegate = object as! AppDelegate
        return delegate.breeds
    }
    
    var image: UIImage?
    var options = [-1, -1, -1, -1] // breed position
    var answerPos = -1
    
    var fetchedResultsController: NSFetchedResultsController<Dog>!
    var dataController: DataController!
//    let rightAnswerMessage = "Well done, buddy!"
//    let wrongAnswerMessage = "Opps, I'm !"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        overrideUserInterfaceStyle = .light
        
        let tabBar = self.tabBarController as! TabBarViewController
        dataController = tabBar.dataController
        
//        getBreedList()
        generateQuiz()
        if dataController == nil {
            print("dataController is NIL")
        }
//        dataController = tabBarController.data
//        dataController = 
        setUpFetchedResultsController()
    }
    
    func generateQuiz() {
        answerPos = Int.random(in: 0...3)
        options = [-1, -1, -1, -1]
        for i in 0...3 {
            var randomX = -1
            while options.contains(randomX) {
                randomX = Int.random(in: 0...(breeds.count-1))
            }
            options[i] = randomX
        }
        option1Button.setTitle(breeds[options[0]].localizedCapitalized, for: .normal)
        option2Button.setTitle(breeds[options[1]].localizedCapitalized, for: .normal)
        option3Button.setTitle(breeds[options[2]].localizedCapitalized, for: .normal)
        option4Button.setTitle(breeds[options[3]].localizedCapitalized, for: .normal)
        getDogWithBreed(breed: breeds[options[answerPos]])
        
        
    }
    
    func getDogWithBreed(breed: String) {
        Client.requestRandomImage(breed: breed, completionHandler: handleRandomImageResponse(imageData:error:))
    }
    
    func handleRandomImageResponse(imageData: DogResponse?, error: Error?) {
        guard let url = URL(string: imageData?.message ?? "") else {
                print("cannot create URL")
                return
        }
        Client.requestImageFile(url: url, completionHandler: self.handleImageFileResonse(image:error:))
    }
    
    func handleImageFileResonse(image: UIImage?, error: Error?) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
//    func getBreedList() {
//        Client.requestBreedsList(completionHandler: handleBreedsListResponse(breedsListData:error:))
//    }
//
//    func handleBreedsListResponse(breedsListData: [String]?, error: Error?) {
//           if let breedsListData = breedsListData {
//               breeds = breedsListData
//                print(breeds)
////               DispatchQueue.main.async {
////                   self.pickerView.reloadAllComponents()
////               }
//           } else {
//               print("cannot get the breed list")
//           }
//
//       }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func showAnswer(tappedButtonPostition: Int) {
        optionStackView.isHidden = true
        answerButton.isHidden = false
        if answerPos == tappedButtonPostition {
            answerButton.setTitle("Yes! I'm \(breeds[options[answerPos]])", for: .normal)
        } else {
            answerButton.setTitle("Opps, I'm \(breeds[options[answerPos]])", for: .normal)
        }
        print("answer: \(answerPos)")
        print("tapped: \(tappedButtonPostition)")
        print(options)
        for i in 0...3 {
            print(breeds[options[i]])
        }
        
    }
    
    func saveAnswer() {
        let dogToSave = Dog(context: dataController.viewContext)
        dogToSave.breed = breeds[options[answerPos]]
        dogToSave.date = NSDate() as Date
        dogToSave.image = imageView.image?.pngData()
        try? dataController.viewContext.save()
        setUpFetchedResultsController()
    }
    
    func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Dog> = Dog.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func option1ButtonTapped(_ sender: Any) {
        showAnswer(tappedButtonPostition: 0)
        saveAnswer()
    }
    @IBAction func option2ButtonTapped(_ sender: Any) {
        showAnswer(tappedButtonPostition: 1)
        saveAnswer()
    }
    @IBAction func option3ButtonTapped(_ sender: Any) {
        showAnswer(tappedButtonPostition: 2)
        saveAnswer()
    }
    @IBAction func option4ButtonTapped(_ sender: Any) {
        showAnswer(tappedButtonPostition: 3)
        saveAnswer()
    }
    @IBAction func resetButtonTapped(_ sender: Any) {
        optionStackView.isHidden = false
        answerButton.isHidden = true
        generateQuiz()
    }
    
}