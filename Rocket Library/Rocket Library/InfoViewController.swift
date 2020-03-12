
//
//  InfoViewController.swift
//  Rocket Library
//
//  Created by Gabriel Marinho on 24/01/20.
//  Copyright © 2020 Rocket Team. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var imageCapa: UIImageView!
    
    @IBOutlet weak var labelTitulo: UILabel!
    
    @IBOutlet weak var labelAutor: UILabel!
    
    @IBOutlet weak var fieldPagAtual: UITextField!
    
    @IBOutlet weak var labelNPaginas: UILabel!
    
    @IBOutlet weak var labelPaginasDiarias: UILabel!
    
    @IBOutlet weak var pickerPrevisao: UIDatePicker!
    
    var livro: Livro = Livro()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelTitulo.text = livro.titulo
        labelAutor.text = livro.autor
        fieldPagAtual.text = String(livro.paginaAtual)
        labelNPaginas.text = "/" + String(livro.nPaginas)
        labelPaginasDiarias.text = String("falta")
        pickerPrevisao.date = livro.dataPrev!
        let _: TimeInterval = livro.dataPrev!.timeIntervalSince(livro.dataIni!)
        let diasAt = diasAte(dataIni: livro.dataIni!, dataFim: livro.dataPrev!)
        labelPaginasDiarias.text = String(Int(livro.nPaginas)/Int(round(diasAt)) <= 0 ? 1 : Int(livro.nPaginas)/Int((diasAt.rounded(.up))))
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
