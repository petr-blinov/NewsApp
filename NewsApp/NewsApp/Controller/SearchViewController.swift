//
//  SearchViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 26.06.2021.
//

import UIKit

class SearchViewController: BaseViewController {
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Init
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    lazy var searchController: UISearchController = {
        // в инициализаторе устанавливаем nil чтобы для отображения результатов поиска использовалось то же вью, в котором отображается наш контент
        let searchController = UISearchController(searchResultsController: nil)
        // присваиваем self для делегата - чтобы получателем результата поиска был наш класс
        searchController.searchResultsUpdater = self
        // говорим чтобы не затемнял результаты поиска
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        return searchController
    }()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    // MARK: - Internal Properties
    private var dataSource = [Get2ArticleDataResponse]()
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        // Свойство, котрое позволяет отпустить строку поиска при переходе на другой экран
        definesPresentationContext = true
        configureUI()
    }
    
    // MARK: - Methods
    private func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Search"
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarItem.title = "Search"
        tabBarItem.image = UIImage(systemName: "magnifyingglass")
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        view.addSubview(tableView)
    }
    
    private func loadData() {
        isLoading = true
        self.networkService.getArticles {
            self.processDataLoading($0) }
    }
    private func processDataLoading(_ response: GetAPIResponse) {
        DispatchQueue.main.async {
            switch response {
            
            case .success(let data):
                self.dataSource.append(contentsOf: data.articles)
                self.tableView.reloadData()
                
            case .failure(let error):
                self.showErrorAlert(for: error)
            }
            self.isLoading = false
        }
    }
    
    // MARK: - Error handling
    private func showErrorAlert(for error: NetworkServiceError) {
        let alert = UIAlertController(title: "Oops, something went wrong",
                                      message: setAlertMessage(for: error),
                                      preferredStyle: .alert)
        present(alert, animated: true)
    }
    private func setAlertMessage(for error: NetworkServiceError) -> String {
        switch error {
        case .network:
            return "Network error, please check your network"
        case .decodable:
            return "Parsing error"
        case .unknown:
            return "Unknown error"
        }
    }
}

// MARK: - SearchBar
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchRequest = searchController.searchBar.text else { return }
        Constants.searchRequest = searchRequest
        loadData()

    }
}

// MARK: - TableView
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath)
        // Используем DTO - чтобы ячейка конфигурировалась на стороне. Data Transfer Object (DTO) — шаблон проектирования, используется для передачи данных между подсистемами приложения. DTO в отличие от business object или data access object не должен содержать какого-либо поведения.
        (cell as? ArticleCell)?.configure(with: dataSource[indexPath.row])
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    
    // Используем willDisplay cell для того чтобы таблица загружала новый кусок данных когда мы пролистываем до последней ячейки (у нас в выдаче не больше двух страниц по 20 статей, поэтому ограничиваемся двумя страницами)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataSource.count - 1, !isLoading, Constants.page == 1 {
            Constants.page += 1
            isLoading = true
            networkService.getArticles { self.processDataLoading($0) }
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // не забываем диселектнуть ряд чтобы все было красиво
        tableView.deselectRow(at: indexPath,animated : true)
        isLoading = false
        let articleContentViewController = ArticleContentViewController(networkService: networkService, model: dataSource[indexPath.row])
        navigationController?.pushViewController(articleContentViewController, animated: true)
    }
}
