//
//  Injector.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-09-01.
//

import Foundation

@propertyWrapper
struct Injected<T> {
    private let keyPath: WritableKeyPath<InjectedValues, T>
    var wrappedValue: T {
        get { InjectedValues[keyPath] }
        set { InjectedValues[keyPath] = newValue }
    }
    
    init(_ keyPath: WritableKeyPath<InjectedValues, T>) {
        self.keyPath = keyPath
    }
}

public protocol InjectorProtocol {
    associatedtype Value
    static var currentValue: Self.Value { get set }
}

public struct InjectedValues {
    
    private static var current = InjectedValues()
    
    static public subscript<T>(injector: T.Type) -> T.Value where T : InjectorProtocol {
        get { injector.currentValue }
        set { injector.currentValue = newValue }
    }
    
    static public subscript<T>(_ keyPath: WritableKeyPath<InjectedValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}

extension InjectedValues {
    var networkService: NetworkServiceProtocol {
        get { Self[NetworkServiceInjector.self] }
        set { Self[NetworkServiceInjector.self] = newValue }
    }

    var imageDownloader: ImageDownloadingProtocol {
        get { Self[ImageDownloaderInjector.self] }
        set { Self[ImageDownloaderInjector.self] = newValue }
    }
}

private struct NetworkServiceInjector: InjectorProtocol {
    static var currentValue: NetworkServiceProtocol = NetworkService()
}

private struct ImageDownloaderInjector: InjectorProtocol {
    static var currentValue: ImageDownloadingProtocol = ImageDownloader()
}
