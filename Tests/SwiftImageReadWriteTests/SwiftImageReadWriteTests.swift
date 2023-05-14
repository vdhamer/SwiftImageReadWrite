import XCTest
@testable import SwiftImageReadWrite

let output = TestOutputContainer(name: "SwiftImageReadWrite")

final class SwiftImageReadWriteTests: XCTestCase {
	func testExample1() throws {
		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)

		let image = try CGImage.load(imageData: data)

		let pdfData = try image.pdfRepresentation(size: CGSize(width: 600, height: 600))
		try output.writeFile(titled: "wombles-e1.pdf", data: pdfData)
	}

	func testPlatformImage() throws {
		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)
		let image = try XCTUnwrap(PlatformImage(data: data))

		let pngData = try image.representation.png(scale: 2)
		let jpgData = try image.representation.jpeg(compression: 0.65)
		let pdfData = try image.representation.pdf(size: CGSize(width: 200, height: 200))

	}

	func testExample2() throws {
		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)

		let image = try CGImage.load(imageData: data)

		let jpg2 = try image.representation.jpeg()

		let jpegData = try image.representation.jpeg(scale: 3, compression: 0.65, excludeGPSData: true)
		try output.writeFile(titled: "wombles-e2.jpg", data: jpegData)
	}

	func testLoad() throws {

		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)

		let image = try CGImage.load(imageData: data)
		XCTAssertEqual(image.width, 512)
		XCTAssertEqual(image.height, 512)
	}

	func testExportScale() throws {
		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)
		let image = try CGImage.load(imageData: data)

		let platformImage2 = image.platformImage(scale: 2)
		assert(platformImage2 != nil)

		let platformImage3 = image.platformImage(dpi: 214.0)
		assert(platformImage3 != nil)
	}

	func testExportGIF() throws {
		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)
		let image = try CGImage.load(imageData: data)
		let gif = try image.imageData(for: .gif)

		try output.writeFile(titled: "wombles-export-gif.gif", data: gif)
	}

	func testCodable() throws {

		struct MyStruct: Codable {
			let name: String
			let image: PlatformImageCodable
		}

		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)
		let image = try XCTUnwrap(PlatformImage(data: data))

		let s = MyStruct(name: "Fishy", image: PlatformImageCodable(image))
		let d = try JSONEncoder().encode(s)

		let recon = try JSONDecoder().decode(MyStruct.self, from: d)
		XCTAssertEqual(recon.name, "Fishy")
		XCTAssertEqual(recon.image.image.size, image.size)
	}

	func testCGCodable() throws {

		struct MyStruct: Codable {
			let name: String
			let image: CGImageCodable
		}

		let url = Bundle.module.url(forResource: "wombles", withExtension: "jpeg")!
		let data = try Data(contentsOf: url)
		let image = try CGImage.load(imageData: data)

		let s = MyStruct(name: "Fishy", image: CGImageCodable(image))
		let d = try JSONEncoder().encode(s)

		let recon = try JSONDecoder().decode(MyStruct.self, from: d)
		XCTAssertEqual(recon.name, "Fishy")
		XCTAssertEqual(recon.image.image.width, image.width)
		XCTAssertEqual(recon.image.image.height, image.height)
	}
}
