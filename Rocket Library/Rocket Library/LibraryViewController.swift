//
//  LibraryViewController.swift
//  Rocket Library
//
//  Created by Lucas Dantas on 20/01/20.
//  Copyright © 2020 Rocket Team. All rights reserved.
//

import UIKit
import CoreData

class LibraryViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var textFieldTitulo: UITextField!
    
    @IBOutlet weak var textFieldAutor: UITextField!
    
    @IBOutlet weak var textFieldNPaginas: UITextField!
    
    @IBOutlet weak var previsaoTermino: UIDatePicker!
    
    @IBOutlet weak var paginasPorDia: UILabel!
    
    @IBOutlet weak var avisoSemPaginas: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previsaoTermino.minimumDate = Date().dayAfter
        textFieldNPaginas.delegate = self
        
        self.textFieldNPaginas.addTarget(self, action: #selector(focus), for: .editingDidBegin)
        self.textFieldNPaginas.addTarget(self, action: #selector(unfocus), for: .editingDidEnd)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
        let rangeOfTextToReplace = Range(range, in: textFieldText) else {
               return false
       }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        
        return ((string.isEmpty) || (Int(string)) != nil) && count <= 4
    }
    
    @IBAction func botaoOk(_ sender: Any) {
        if Int((textFieldNPaginas.text)!) == nil || textFieldAutor.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || textFieldTitulo.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    {
            avisoSemPaginas.text = "Por favor, preencha todos os campos"
            return
        } else {
            avisoSemPaginas.text = " "
        
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let bookEntity = NSEntityDescription.entity(forEntityName: "Livro", in: managedContext)
            let book = NSManagedObject(entity: bookEntity!, insertInto: managedContext)
            book.setValue("\(textFieldAutor.text!.trimmingCharacters(in: .whitespacesAndNewlines))", forKey: "autor")
            book.setValue("\(textFieldTitulo.text!.trimmingCharacters(in: .whitespacesAndNewlines))", forKey: "titulo")
            book.setValue(Int(textFieldNPaginas.text!), forKey: "nPaginas")
            book.setValue(0, forKey: "paginaAtual")
            book.setValue(Date(), forKey: "dataIni")
            book.setValue(previsaoTermino.date, forKey: "dataPrev")
            
            googleBooks(title: textFieldTitulo.text!.trimmingCharacters(in: .whitespacesAndNewlines), completionHandler: { urlImage in
                
                print("Terminou! \(urlImage)")
                
                book.setValue(urlImage, forKey: "capa")
                
                do {
                    try managedContext.save()
                    print("gg salvou")
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
                
                DispatchQueue.main.async {
                    if let estanteViewController = self.parent?.presentingViewController?.children.first?.children.first as? EstanteViewController {
                        
                        estanteViewController.retrieveData()
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                
            })
        }

    }
    
    @objc func focus() {
        if UIScreen.main.bounds.midY < self.textFieldNPaginas.center.y {
            UIView.animate(withDuration: 0.25) {
                let newPos = CGPoint(x: self.view.center.x, y: self.view.center.y - (self.textFieldNPaginas.center.y - self.view.center.y) + 15)
                self.view.center = newPos
            }
        }
    }
       
    @objc func unfocus() {
        UIView.animate(withDuration: 0.15) {
            let originalPos = CGPoint(x: self.view.center.x, y: UIScreen.main.bounds.midY)
            self.view.center = originalPos
        }
    }
    
    func centroDaSubview(para subview: UIView, em view: UIView) -> CGPoint {
        let x = view.bounds.size.width/2 - subview.frame.size.width/2
        let y = view.bounds.size.height/2 - subview.frame.size.height/2
        return CGPoint(x: x, y: y)
    }

  
        @IBAction func attPaginas(_ sender: Any) {
            setDateFinish()
       }
    
        @IBAction func mudaPaginas(_ sender: Any) {
            setDateFinish()
        }

    func setDateFinish () {
          func diasAte (dataIni: Date, dataFim: Date) -> Double {

              let distance: TimeInterval = dataFim.timeIntervalSince(dataIni)
              let diasAte = round(distance / (24*60*60)) == 0 ? 2 : distance / (24*60*60) + 1
              return diasAte

          }
      }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    
    
    func googleBooks (title: String, completionHandler: @escaping (String) -> Void ) {
        let Newtitulo = title.replacingOccurrences(of: " ", with: "%20")
        print(Newtitulo)
            let path: String = "https://www.googleapis.com/books/v1/volumes?q=\(Newtitulo)&maxResults=1&orderBy=relevance&printType=books&key=AIzaSyDFyRuS8rcCG3qLaIky7VNo8u9hIRg5yg8"
        
        let url: URL = URL(string: path)!
            
            //GET
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let data = data else { return }
                
                do {
                    let booksResult = try JSONDecoder().decode(BooksResultJSON.self, from: data)
                    
                    if let urlImage = booksResult.items.first?.volumeInfo.imageLinks.thumbnail {
                        
                        completionHandler(urlImage)
                    }
                    
                } catch {
                    print(error.localizedDescription)
                    completionHandler("https://pbs.twimg.com/profile_images/783312363978129408/R6vKaLYH_400x400.jpg")
                }
                
                
            }.resume()
    }
}

struct BooksResultJSON: Decodable {
    let items: [ItemJSON]
}

struct ItemJSON: Decodable {
    let volumeInfo: VolumeInfoJSON
}

struct VolumeInfoJSON: Decodable {
    let imageLinks: ImageLinkJSON
}

struct ImageLinkJSON: Decodable {
    let smallThumbnail: String?
    let thumbnail: String?
    let largeThumbnail: String?
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

func diasAte (dataIni: Date, dataFim: Date) -> Double {

    let distance: TimeInterval = dataFim.timeIntervalSince(dataIni)
    let diasAte = round(distance / (24*60*60)) == 0 ? 2 : distance / (24*60*60) + 1
    return diasAte

}
