//
//  ArticleContentViewController.swift
//  NewsApp
//
//  Created by Петр Блинов on 06.06.2021.
//

import UIKit
import SafariServices
import CoreData

final class ArticleContentViewController: BaseViewController {
    
    
    // MARK: - Dependencies
    private var networkService: NetworkServiceProtocol
    private var model: Get2ArticleDataResponse
    
    // MARK: - Init
    init(networkService: NetworkServiceProtocol, model: Get2ArticleDataResponse) {
        self.networkService = networkService
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal Properties
    private var linkForWebView = ""
    private let stack = CoreDataStack.shared
    
    // MARK: - UI
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = false;
        return scrollView
    }()
    private lazy var articleTitle: UILabel = {
        let articleTitle = UILabel()
        articleTitle.numberOfLines = 0
        articleTitle.font = UIFont.systemFont(ofSize: 33)
        articleTitle.translatesAutoresizingMaskIntoConstraints = false
        return articleTitle
    }()
    private lazy var articlePublishedAt: UILabel = {
        let articlePublishedAt = UILabel()
        articlePublishedAt.numberOfLines = 0
        articlePublishedAt.font = UIFont.systemFont(ofSize: 15)
        articlePublishedAt.translatesAutoresizingMaskIntoConstraints = false
        return articlePublishedAt
    }()
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 40
        return imageView
    }()
    private lazy var articleContent: UILabel = {
        let articleDescription = UILabel()
        articleDescription.numberOfLines = 0
        articleDescription.font = UIFont.systemFont(ofSize: 18)
        articleDescription.translatesAutoresizingMaskIntoConstraints = false
        return articleDescription
    }()
    private lazy var readInSource: UILabel = {
        let readOnSource = UILabel()
        readOnSource.numberOfLines = 0
        readOnSource.font = UIFont.systemFont(ofSize: 14)
        readOnSource.translatesAutoresizingMaskIntoConstraints = false
        return readOnSource
    }()
    private lazy var sourceLinkButton: UIButton = {
        let sourceLinkButton = UIButton()
        sourceLinkButton.setTitleColor(.systemBlue, for: .normal)
        sourceLinkButton.translatesAutoresizingMaskIntoConstraints = false
        sourceLinkButton.addTarget(self, action: #selector(openWebView), for: .touchUpInside)
        return sourceLinkButton
    }()
    private lazy var saveBarButton: UIBarButtonItem = {
        let saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(addToSavedNews))
        saveBarButton.tintColor = .white
        return saveBarButton
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        navigationItem.rightBarButtonItems = [saveBarButton]
        view.addSubview(scrollView)
        scrollView.addSubview(articleTitle)
        scrollView.addSubview(imageView)
        scrollView.addSubview(articlePublishedAt)
        scrollView.addSubview(articleContent)
        scrollView.addSubview(readInSource)
        scrollView.addSubview(sourceLinkButton)
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setConstraints()
    }
    
    // MARK: - Methods
    @objc func openWebView() {
        guard let url = URL(string: self.model.url) else { return }
        let webViewViewController = SFSafariViewController(url: url)
        present(webViewViewController, animated: true, completion: nil)
    }
    private func showSaveAlert() {
        // добавляем в текст сообщения обращение по имени, которое берем из UserDefaults если оно там есть
        var message: String = {
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                if userName != "" {
                    message = "\(userName), the article has been added to Saved articles"
                } else {
                    message = "The article has been added to Saved articles"
                }
            }
            return message
        }()
        let alert = UIAlertController(title: "Saved", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Got it", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true)
    }
    @objc func addToSavedNews() {
        showSaveAlert()
        stack.backgroundContext.performAndWait {
            let article = MOArticle(context: stack.backgroundContext)
            article.articleTitle = self.articleTitle.text
            article.articlePublishedAt = self.articlePublishedAt.text
            article.articleContent = self.articleContent.text
            article.sourceLink = self.linkForWebView
            article.linkForWebView = self.linkForWebView
            // Конвертим картинку в дату чтобы сохранить ее в Core Data 
            guard let image = self.imageView.image else { return }
            let imageData = image.pngData() as Data?
            article.imageData = imageData
            try? stack.backgroundContext.save()
            // Уточнение: перезагружать таблицу с сохраненными статьями мы будем в методе viewWillAppear в SavedNewsViewController
        }
    }
    
    // MARK: - Constraints
    private func setConstraints() {
        NSLayoutConstraint.activate([
            // Чтобы scrollView прокручивался только вертикально (без горизонтали) - привязываем все элементы не к scrollView, а к view. Но при этом bottomAnchor последнего элемента - к scrollView.
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            articleTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            articleTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articleTitle.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            articlePublishedAt.topAnchor.constraint(equalTo: articleTitle.bottomAnchor, constant: 20),
            articlePublishedAt.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articlePublishedAt.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            imageView.topAnchor.constraint(equalTo: articlePublishedAt.bottomAnchor, constant: 5),
            imageView.bottomAnchor.constraint(equalTo: imageView.topAnchor,constant: 280),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            articleContent.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            articleContent.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            articleContent.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            readInSource.topAnchor.constraint(equalTo: articleContent.bottomAnchor, constant: 20),
            readInSource.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            readInSource.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            sourceLinkButton.topAnchor.constraint(equalTo: readInSource.bottomAnchor, constant: 2),
            sourceLinkButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -50),
            sourceLinkButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            sourceLinkButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -100)])
    }
    
    // MARK: - Load image and arrange elements
    private func loadData() {
        isLoading = true
        networkService.loadImage(with: model) { (data) in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                    self.arrangeElements()
                }
            } else {
                DispatchQueue.main.async {
                self.imageView.image = UIImage(named: "newsPlaceHolder")
                self.arrangeElements()
                }
            }
        }
    }
    
    private func arrangeElements() {
        self.articleTitle.text = self.model.title
        self.articlePublishedAt.text = String(self.model.publishedAt.dropLast(10))
        self.articleContent.text = self.model.description
        self.readInSource.text = "Read in source:"
        self.sourceLinkButton.setTitle(self.model.url, for: .normal)
        self.linkForWebView = self.model.url
        self.isLoading = false
    }
}
