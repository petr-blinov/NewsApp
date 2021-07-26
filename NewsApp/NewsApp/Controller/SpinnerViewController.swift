//
//  SpinnerViewController.swift
//  NewsApp
//
//  Created by Петр Блинов on 04.06.2021.
//

import UIKit

final class SpinnerViewController: UIViewController {
    
    private let spinner = UIActivityIndicatorView(style: .large)
    
    override func loadView() {
        view = UIView()        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
