//
//  FilmDetailViewController.swift
//  starwars
//
//

import UIKit

class FilmDetailViewController: UIViewController {
    var film: Film
    var director: String = ""
    var producer: String = ""
    var overview: String = ""
    var characters: [MovieCharacter] = []
    
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var producerLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var charactersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.directorLabel.text = self.film.director
        self.producerLabel.text = self.film.producer
        self.overviewLabel.text = self.film.openingCrawl
        
        self.charactersTable.register(UINib(nibName: "CharacterTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.charactersTable.rowHeight = 90
        self.charactersTable.delegate = self
        self.charactersTable.dataSource = self
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(onDismiss))
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadCharacters()
    }
    
    init(film: Film) {
        self.film = film
        super.init(nibName: "FilmDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onDismiss() {
        self.dismiss(animated: true)
    }
    
    private func loadCharacters() {
        NetworkManager.shared.getMovieCharacters(urls: self.film.characters) { result in
            switch result {
            case .success(let movieCharacters):
                self.characters = movieCharacters
                DispatchQueue.main.async {
                    self.charactersTable.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension FilmDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = charactersTable.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CharacterTableViewCell {
            cell.nameLabel.text = self.characters[indexPath.row].name
            cell.homeworldLabel.text = self.characters[indexPath.row].homeworldName ?? "Unavailable"
            cell.hairLabel.text = "Hair: \(self.characters[indexPath.row].hairColor)"
            cell.heightLabel.text = "Height: \(self.characters[indexPath.row].height) cm"
            return cell
        }
        return UITableViewCell()
    }
    
    
}
