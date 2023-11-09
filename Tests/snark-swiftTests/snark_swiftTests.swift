import XCTest

@testable import snark_swift

final class snark_swiftTests: XCTestCase {
  func testExample() throws {
    let fileType = "zkey"
    let filePath =
      "Tests/zkey/multiplier2_final.zkey"  // Replace with the actual file path
    let zkey = readZkey(filePath: filePath, fileType: fileType, maxVersion: 2)
    let vk_alpha_1: [UInt8] = [
      23, 14, 17, 42, 185, 164, 205, 1, 195, 107, 171, 71,
      64, 46, 252, 207, 233, 238, 75, 26, 225, 17, 222, 60,
      207, 94, 92, 15, 152, 2, 235, 6, 30, 139, 14, 214,
      223, 44, 75, 49, 54, 176, 41, 90, 23, 66, 228, 60,
      120, 2, 126, 203, 170, 53, 127, 17, 146, 101, 59, 78,
      218, 81, 70, 6,
    ]
    let vk_beta_1: [UInt8] = [
      152, 64, 249, 69, 208, 4, 30, 157, 106, 160, 58,
      151, 154, 79, 204, 163, 133, 120, 197, 150, 223, 183,
      154, 46, 54, 212, 93, 207, 131, 241, 44, 24, 42,
      162, 90, 167, 62, 183, 252, 205, 159, 181, 21, 6,
      70, 106, 242, 84, 113, 200, 6, 37, 49, 124, 107,
      225, 133, 195, 91, 134, 238, 176, 19, 4,
    ]
    let vk_delta_1: [UInt8] = [
      159, 220, 251, 92, 1, 68, 73, 127, 240, 11, 238,
      255, 145, 25, 146, 53, 100, 110, 229, 151, 127, 156,
      71, 25, 211, 125, 78, 66, 208, 32, 232, 38, 128,
      181, 124, 14, 221, 231, 143, 141, 142, 26, 136, 66,
      161, 141, 247, 9, 98, 34, 251, 38, 245, 76, 14,
      93, 177, 216, 70, 21, 174, 34, 150, 9,
    ]
    XCTAssertEqual(zkey["vk_alpha_1"] as! [UInt8], vk_alpha_1)
    XCTAssertEqual(zkey["vk_beta_1"] as! [UInt8], vk_beta_1)
    XCTAssertEqual(zkey["vk_delta_1"] as! [UInt8], vk_delta_1)
  }
}
