//
//  Slacket.swift
//  Slacket
//
//  Created by Jakub Tomanik on 30/05/16.
//
//

import Foundation
import Kitura
import HeliumLogger
import LoggerAPI

import libc

struct ExternalServerConfig: URLType {

    let host: String = "slacket.link"
}

struct InternalServerConfig: URLType {

    let host: String = "localhost"
    let port: Int? = 8090
}

struct Slacket: ServerModuleType {

    private let router: Router

    init(using router: Router) {
        self.router = router
        self.setupRoutes()
    }

    mutating func setupRoutes() {
        router.get("/health-check", middleware: HealthCheckMiddleware())
        router.get("/", middleware: StaticFileServer(path: repoDirectory+"public/"))
        router.all("api/*", middleware: BodyParser())
        router.all("api/*", middleware: SlacketHandler())
    }
}