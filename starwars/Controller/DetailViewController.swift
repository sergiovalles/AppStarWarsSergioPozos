//
//  DetailViewController.swift
//  starwars
//
//

import UIKit

class DetailViewController: UIViewController{
    var user: User
    
    var films: [Film] = []
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var createdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: self, action: #selector(onLogout))
        
        self.table.register(UINib(nibName: "FilmTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.table.delegate = self
        self.table.dataSource = self
        
        createdLabel.text = self.user.created.convertToDate().convertToFormat()
        
        loadUserFilms()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: "DetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func loadUserFilms() {
        films = []
        
        NetworkManager.shared.getFilms(urls: self.user.films) { result in
            switch result {
            case .success(let films):
                self.films = films
                
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc func onLogout() {
        navigationController?.popToRootViewController(animated: true)
    }
    
}

// MARK: Tableview delegate and datasource

extension DetailViewController: UITableViewDataSource, UITableViewDelegate  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return films.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FilmTableViewCell {
            cell.titleLabel.text = self.films[indexPath.row].title
            cell.directoLabel.text = self.films[indexPath.row].director
            cell.bodyLabel.text = self.films[indexPath.row].openingCrawl
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String? {
      return "Films"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let film = films[indexPath.item]
        let destVC = FilmDetailViewController(film: film)
//        destVC.director = film.director
//        destVC.producer = film.producer
//        destVC.overview = film.openingCrawl
//        destVC.characters = film.characters
        destVC.title = film.title
        self.present(UINavigationController(rootViewController: destVC), animated: true)
    }
}
