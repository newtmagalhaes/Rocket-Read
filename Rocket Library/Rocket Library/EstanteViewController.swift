//
//  ViewController.swift
//  TableView
//
//  Created by Gabriel Marinho on 22/01/20.
//  Copyright © 2020 Gabriel Marinho. All rights reserved.
//

import UIKit
import CoreData

class HeadlineTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTitulo: UILabel!

    @IBOutlet weak var labelAutor: UILabel!

    @IBOutlet weak var progressBar: UIProgressView!

    @IBOutlet weak var labelProgress: UILabel!

    @IBOutlet weak var imageCapa: UIImageView!
    
    @IBOutlet weak var botaoLer: UIButton!
    
}


class EstanteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if livros.count == 0 {
                 self.tableView.setEmptyMessage("Cri... Cri... Cri...")
             } else {
                 self.tableView.restore()
             }
        return livros.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HeadlineTableViewCell
        cell.botaoLer.tag = indexPath.row;
        cell.botaoLer.addTarget(self, action:#selector(botaoLer), for: .touchUpInside)
        let livro = livros[indexPath.row]
        cell.labelTitulo?.text = livro.titulo
        cell.labelAutor?.text = livro.autor
        let progresso: Float = Float(livro.paginaAtual) / Float(livro.nPaginas)
        cell.progressBar?.setProgress(progresso, animated: true)
        //MARK: - TODO: tudo
        
        URLSession.shared.dataTask(with: URL(string: livro.capa!)!) {data, response, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                cell.imageCapa.image = UIImage(data: data!)
            }
            print("gg wp")
        }.resume()
            
         ///
        cell.labelProgress?.text = "pg. \(livro.paginaAtual) / \(livro.nPaginas)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            
            print("")
            // handle delete (by removing the data from your array and updating the tableview)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Livro")
            
            
            do {
                _ = try managedContext.fetch(fetchRequest)
                let objectToDelete = self.livros.remove(at: indexPath.row)
                managedContext.delete((objectToDelete))
                
                do{
                    try managedContext.save()
                } catch {
                    print(error)
                }
                
            } catch {
                print(error)
            }
        
        }
    }
    
    let cellIdentifier = "cellIdentifier"
    var livros: [Livro] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retrieveData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func botaoLer(_ sender: Any) {
        let alertBox = UIAlertController(title: "", message: "Em que página você está?", preferredStyle: .alert)
        alertBox.addTextField { (textField) in
            textField.text = ""
            textField.keyboardType = .numberPad
        }
        
        alertBox.addAction(UIAlertAction(title: "Cancelar", style: .default, handler: { [weak alertBox] (_) in
            let textField = alertBox?.textFields![0]
            print("Text field: \(String(describing: textField?.text))")
        }))

        alertBox.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alertBox] (_) in
            let textField = alertBox?.textFields?[0]
            self.livros[(sender as! UIButton).tag].paginaAtual =  (Int16(textField!.text!) ?? self.livros[(sender as! UIButton).tag].paginaAtual)
            print(self.livros[(sender as! UIButton).tag].paginaAtual)
            let livro = self.livros[(sender as! UIButton).tag]
            if Int(textField!.text!)! > Int(livro.nPaginas) {
                livro.setValue(livro.nPaginas, forKey: "paginaAtual")
            } else {
                livro.setValue(Int(textField!.text!), forKey: "paginaAtual")
            }
            livro.setValue(dateFinish(Int(livro.nPaginas), Int((Double(livro.nPaginas) / diasAte(dataIni: livro.dataIni!, dataFim: livro.dataPrev!)))), forKey: "dataPrev")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                try managedContext.save()
                self.retrieveData()
            } catch {
                print(error)
            }
        }))
        self.present(alertBox, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func cadastrarLivros(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "cadastrarLivrosSegue", sender: Any?.self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let infoViewController = segue.destination as? InfoViewController,
            let indice = self.tableView.indexPathForSelectedRow?.row
            else {
                return
        }
        infoViewController.livro = livros[indice]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "descricaoLivroSegue", sender: Any?.self)
    }
    
    func retrieveData () {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Livro")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            livros.removeAll()
            for data in result as! [NSManagedObject] {
                livros.append(data as! Livro)
            }
        } catch {
            print("Don'T WORK")
        }
    }
}

extension UITableView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

func dateFinish (_ numPg: Int, _ pagPDia: Int) -> Date {
    let hoje: Date = Date()
    let intervalo: TimeInterval = TimeInterval((pagPDia/numPg) * 24 * 60 * 60)
    let datefinish: Date = hoje.addingTimeInterval(intervalo)
    return datefinish
}
