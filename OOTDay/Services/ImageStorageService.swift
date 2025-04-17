import Foundation
import UIKit

enum ImageStorageError: Error {
    case failedToSaveImage
    case failedToLoadImage
}

class ImageStorageService {
    static let shared = ImageStorageService()
    
    private init() {}
    
    private let fileManager = FileManager.default
    
    private var imagesDirectory: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagesDirectory = documentsDirectory.appendingPathComponent("Images")
        
        if !fileManager.fileExists(atPath: imagesDirectory.path) {
            try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        }
        
        return imagesDirectory
    }
    
    func saveImage(_ image: UIImage, withName name: String) throws {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let imageUrl = imagesDirectory.appendingPathComponent("\(name).jpg")
        try data.write(to: imageUrl)
    }
    
    func loadImage(withName name: String) -> UIImage? {
        let imageUrl = imagesDirectory.appendingPathComponent("\(name).jpg")
        guard let data = try? Data(contentsOf: imageUrl) else { return nil }
        return UIImage(data: data)
    }
    
    func deleteImage(withName name: String) throws {
        let imageUrl = imagesDirectory.appendingPathComponent("\(name).jpg")
        if fileManager.fileExists(atPath: imageUrl.path) {
            try fileManager.removeItem(at: imageUrl)
        }
    }
} 