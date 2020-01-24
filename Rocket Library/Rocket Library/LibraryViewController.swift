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
        
        return ((string.isEmpty) || (Int(string)) != nil) && count <= 6
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
            book.setValue("url google", forKey: "capa")
            
            do {
                try managedContext.save()
                print("gg salvou")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            if let estanteViewController = self.parent?.presentingViewController?.children.first?.children.first as? EstanteViewController {
                
                estanteViewController.retrieveData()
                self.dismiss(animated: true, completion: nil)
            }
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
          let numPg: Int = Int(textFieldNPaginas.text!) == nil ? 0 : Int(textFieldNPaginas.text!)!
          let dataAtual: Date = Date()
          let dataPrevista: Date = previsaoTermino.date
          let distance: TimeInterval = dataPrevista.timeIntervalSince(dataAtual)
          let diasAte: Double = round(distance / (24*60*60)) == 0 ? 2 : distance / (24*60*60) + 1
          let pgPorDia: Int = numPg/Int(round(diasAte)) <= 0 ? 1 : numPg/Int((diasAte.rounded(.up)))
          paginasPorDia.text = "\(pgPorDia)"
      }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
     
     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
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

