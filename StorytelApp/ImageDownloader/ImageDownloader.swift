//
//  ImageDownloader.swift
//  StorytelApp
//
//  Created by Tim Gunnarsson on 2023-08-31.
//

import Foundation
import UIKit

protocol ImageDownloadingProtocol {
    func downloadImage(for url: String) async throws -> UIImage?
    func cachedImage(for url: String) -> UIImage?
    func clearImageCache()
}

final class ImageDownloader: ImageDownloadingProtocol {

    @Injected(\.networkService) private var networkService: NetworkServiceProtocol
    private let imageCache: ImageCache
    
    init(imageCache: ImageCache = .shared) {
        self.imageCache = imageCache
    }
    
    func downloadImage(for url: String) async throws -> UIImage? {
        if let image = cachedImage(for: url) {
            return image
        } else {
            let imageRequest = ImageRequest(endpoint: url)
            let data = try await networkService.perform(request: imageRequest)
            guard let image = UIImage(data: data) else {
                return nil
            }
            ImageCache.shared.setImage(image, for: url)
            return image
        }
    }
    
    func cachedImage(for url: String) -> UIImage? {
        return imageCache.getImage(for: url)
    }
    
    func clearImageCache() {
        imageCache.removeAllImages()
    }
}


extension ImageDownloader {
    final class ImageCache {
        static let shared = ImageCache()
        
        private let cache = NSCache<NSString, UIImage>()
        
        private init() {
            cache.totalCostLimit = 50 * 1024 * 1024
        }
        
        func getImage(for key: String) -> UIImage? {
            return cache.object(forKey: key as NSString)
        }
        
        func setImage(_ image: UIImage, for key: String) {
            cache.setObject(image, forKey: key as NSString)
        }
        
        func removeImage(for key: String) {
            cache.removeObject(forKey: key as NSString)
        }
        
        func removeAllImages() {
            cache.removeAllObjects()
        }
    }
}
