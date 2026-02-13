//
//  AppCoordinator.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import SwiftUI

@Observable
class AppCoordinator {
    var path = NavigationPath()
    
    enum Destination: Hashable {
        case filmCatalog
        case filmDetail(String)
    }
    
    func navigateToFilmCatalog() {
        path.append(Destination.filmCatalog)
    }
    
    func navigateToFilmDetail(_ apiID: String) {
        path.append(Destination.filmDetail(apiID))
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
