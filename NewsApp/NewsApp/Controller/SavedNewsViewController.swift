//
//  SavedNewsViewController.swift
//  NewsApp
//
//  Created by Petr Blinov on 26.06.2021.
//

import UIKit

class SavedNewsViewController: BaseViewController {

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = "Saved"
        tabBarItem.image = UIImage(systemName: "book.closed")
        view.backgroundColor = .white
        navigationItem.title = "Saved articles"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Methods

}
