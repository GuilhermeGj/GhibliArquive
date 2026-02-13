//
//  Ghibli_ArchiveApp.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//
import SwiftUI

@main
struct Ghibli_ArchiveApp: App {
    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            InitialScreen()
                .environment(coordinator)
        }
    }
}

