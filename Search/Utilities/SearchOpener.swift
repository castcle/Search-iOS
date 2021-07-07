//
//  SearchOpener.swift
//  Search
//
//  Created by Tanakorn Phoochaliaw on 6/7/2564 BE.
//

import UIKit
import Core

public enum SearchScene {
    case search
}

public struct SearchOpener {
    
    public static func open(_ searchScene: SearchScene) -> UIViewController {
        switch searchScene {
        case .search:
            let storyboard: UIStoryboard = UIStoryboard(name: SearchNibVars.Storyboard.search, bundle: ConfigBundle.search)
            let vc = storyboard.instantiateViewController(withIdentifier: SearchNibVars.ViewController.search)
            return vc
        }
    }
}
