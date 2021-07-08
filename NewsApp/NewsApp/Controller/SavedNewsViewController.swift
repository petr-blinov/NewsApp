//
//  SavedNewsViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 26.06.2021.
//

import UIKit
import CoreData

class SavedNewsViewController: BaseViewController {
    
// MARK: - FetchedResultsController
    private let frc: NSFetchedResultsController<MOArticle> = {
        let request = NSFetchRequest<MOArticle>(entityName: "MOArticle")
        request.sortDescriptors = [.init(key: "articlePublishedAt", ascending: true)]
        return NSFetchedResultsController(fetchRequest: request,
                                          managedObjectContext: CoreDataStack.shared.container.viewContext,
                                          sectionNameKeyPath: nil,
                                          cacheName: nil)
    }()
    private let coreDataStack = CoreDataStack.shared
    
// MARK: - UI
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ArticleCell.self, forCellReuseIdentifier: ArticleCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy var deleteAllBarButton: UIBarButtonItem = {
        let deleteAllBarButton = UIBarButtonItem(title: "Remove all", style: .plain, target: self, action: #selector(deleteAllSavedArticles))
        return deleteAllBarButton
    }()
    
// MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = "Saved"
        tabBarItem.image = UIImage(systemName: "book.closed")
        view.backgroundColor = .white
        view.addSubview(tableView)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        try? frc.performFetch()
        tableView.reloadData()
    }
    
// MARK: - Methods
    @objc func deleteAllSavedArticles() {
        coreDataStack.deleteAll()
        try? frc.performFetch()
        tableView.reloadData()
    }
    
    private func configureUI() {
        navigationItem.title = "Saved articles"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItems = [deleteAllBarButton]
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - TableView
extension SavedNewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = frc.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let article = frc.object(at: indexPath)
        guard let articleTitle = article.articleTitle else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleCell.identifier, for: indexPath)
        (cell as? ArticleCell)?.configureFromCoreData(with: articleTitle)
        return cell
    }
    // Добавляем Swipe-to-delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            coreDataStack.deleteByIndexPath(indexPath: indexPath)
            try? frc.performFetch()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
extension SavedNewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // не забываем диселектнуть ряд чтобы все было красиво
        tableView.deselectRow(at: indexPath,animated : true)
        isLoading = false
        let article = frc.object(at: indexPath)
        let savedArticleContentViewController = SavedArticleContentViewController(modelObject: article)
        navigationController?.pushViewController(savedArticleContentViewController, animated: true)
    }
}


