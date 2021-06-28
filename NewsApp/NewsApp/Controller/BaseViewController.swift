//
//  BaseViewController.swift
//  Lesson17HomeworkNewsApp
//
//  Created by Петр Блинов on 04.06.2021.
//

import UIKit


//Создаем базовый View COntroller чтобы от него наследовались все другие VC (добавляем в него спиннер чтобы он тоже сразу был у всех VC)


class BaseViewController: UITabBarController {
    
    private let spinnerVC = SpinnerViewController()
    
    var isLoading = false {
        didSet {
            guard oldValue != isLoading else { return }
            showSpinner (isShown: isLoading)
        }
    }
    
    
    private func showSpinner(isShown: Bool) {
        
        if isShown {
//      Добавляем View Controller со спиннером как дочерний
            addChild(spinnerVC)
            spinnerVC.view.frame = view.frame
            view.addSubview(spinnerVC.view)
            spinnerVC.didMove(toParent: self)
       
        } else {
//          Удаляем дочерний VC
            spinnerVC.willMove(toParent: nil)
            spinnerVC.view.removeFromSuperview()
            spinnerVC.removeFromParent()
        }
    }
    
}
