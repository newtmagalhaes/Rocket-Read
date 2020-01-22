//
//  LibraryViewController.swift
//  Rocket Library
//
//  Created by Lucas Dantas on 20/01/20.
//  Copyright © 2020 Rocket Team. All rights reserved.
//

import UIKit

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
        
        // Do any additional setup after loading the view.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((string.isEmpty) || (Int(string) != nil)) {
          return true
       } else {
          return false
       }
    }
    
    @IBAction func botaoOk(_ sender: Any) {
        if Int((textFieldNPaginas.text)!) == nil || textFieldAutor.text == nil || textFieldTitulo == nil {
            avisoSemPaginas.text = "Por favor, preencha todos os campos"
            return
        } else {
            avisoSemPaginas.text = " "
        }
        var livro = Livro(titulo: textFieldTitulo.text!, autores: textFieldAutor.text!, imagem: "", nPaginas: 0, dataIni: Date(), dataFim: previsaoTermino.date, paginasPorDia: 0, genero: "")
        livro.nPaginas = Int((textFieldNPaginas.text)!)!
        livro.paginasPorDia = Int((paginasPorDia.text)!)!
        print(livro)
    }
    
    @IBAction func mudaPaginas(_ sender: Any) {
        let numPg: Int = Int(textFieldNPaginas.text!) == nil ? 0 : Int(textFieldNPaginas.text!)!
        let dataAtual: Date = Date()
        let dataPrevista: Date = previsaoTermino.date
        let distance: TimeInterval = dataPrevista.timeIntervalSince(dataAtual)
        let diasAte: Double = round(distance / (24*60*60)) == 0 ? 2 : distance / (24*60*60) + 1
        let pgPorDia: Int = numPg/Int(round(diasAte)) <= 0 ? 1 : numPg/Int((diasAte.rounded(.up)))
        paginasPorDia.text = "\(pgPorDia)"
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

struct Livro {
    var titulo: String
    var autores: String
    var imagem: String
    var nPaginas: Int
    var dataIni: Date
    var dataFim: Date
    var paginasPorDia: Int
    var genero: String
    
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
