@testable import Capture
import Photos
import SwiftData
import XCTest

final class PhotoTests: XCTestCase {
    private var container: ModelContainer!
    
    override func setUp() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Camera.self, Lens.self, Photo.self,
            configurations: config
        )
    }
    
    override func tearDown() {
        container = nil
        super.tearDown()
    }
    
    @MainActor
    func testMetadata() throws {
        let camera = Camera(make: "Yashica", model: "FX-D Quartz")
        let lens = Lens(make: "Carl Zeiss", model: "Planar 1,7/50")
        let location = Location(name: "Greenwich Observatory", latitude: 51.4769, longitude: 0)
        
        let photo = Photo(timestamp: Date(), 
                          location: location,
                          camera: camera, lens: lens,
                          filmSpeed: .fourHundred)
        
        container.mainContext.insert(camera)
        container.mainContext.insert(lens)
        container.mainContext.insert(photo)
        
        XCTAssertEqual(
            photo.metadata,
            [
                kCGImagePropertyTIFFDictionary as String: [
                    kCGImagePropertyTIFFMake: camera.make,
                    kCGImagePropertyTIFFModel: camera.model
                ],
                kCGImagePropertyExifDictionary as String: [
                    kCGImagePropertyExifLensMake: lens.make,
                    kCGImagePropertyExifLensModel: lens.model,
                ]
            ] as CFDictionary
        )
    }
}
