import Foundation

let BIT_32 = 32 / 8
let BIT_64 = 64 / 8
let BIT_256 = 256 / 8
let BIT_512 = 512 / 8
let BIT_1024 = 1024 / 8

func readULE32(data: [UInt8], startPos: Int) -> UInt32 {
  let bytes = readBytes(data: data, startPos: startPos, length: BIT_32)
  let value = bytes.withUnsafeBytes { $0.load(as: UInt32.self) }
  return value
}

func readULE64(data: [UInt8], startPos: Int) -> UInt64 {
  let bytes = readBytes(data: data, startPos: startPos, length: BIT_64)
  let value = bytes.withUnsafeBytes { $0.load(as: UInt64.self) }
  return value
}

func readBytes(data: [UInt8], startPos: Int, length: Int) -> [UInt8] {
  let bytes = Array(data[startPos...startPos + length - 1])
  return bytes
}

public func readZkey(filePath: String, fileType: String, maxVersion: Int) -> [String: Any] {
  let fileURL = URL(fileURLWithPath: filePath)
  do {
    let fileData = try Data(contentsOf: fileURL)
    let bytesData = [UInt8](fileData)
    var typeString = ""
    var pointer = 0
    for i in 0...3 {
      typeString.append(String(Unicode.Scalar(bytesData[i])))
    }
    if fileType != typeString {
      throw NSError(domain: "Invalid File format", code: 0, userInfo: nil)
    }
    pointer += BIT_32

    let version = readULE32(data: bytesData, startPos: pointer)
    if version > maxVersion {
      throw NSError(domain: "Version not supported", code: 0, userInfo: nil)
    }
    pointer += BIT_32

    let nSections = readULE32(data: bytesData, startPos: pointer)
    pointer += BIT_32

    var sections: [[(p: Int, size: UInt64)]] = Array(repeating: [], count: Int(nSections) + 1)
    for _ in (0...nSections - 1) {
      let ht = readULE32(data: bytesData, startPos: pointer)
      pointer += BIT_32
      let hl = readULE64(data: bytesData, startPos: pointer)
      pointer += BIT_64
      sections[Int(ht)].append((p: pointer, size: hl))
      pointer += Int(hl)
    }

    pointer = sections[1][0].p
    let protocolId = readULE32(data: bytesData, startPos: pointer)
    pointer += BIT_32

    var zkey = [String: Any]()
    if protocolId == 1 {
      zkey["protocol"] = "groth16"

      pointer = sections[2][0].p
      let n8q = readULE32(data: bytesData, startPos: pointer)
      zkey["n8q"] = n8q
      pointer += BIT_32

      let q = readBytes(data: bytesData, startPos: pointer, length: BIT_256)
      zkey["q"] = q
      pointer += BIT_256

      let n8r = readULE32(data: bytesData, startPos: pointer)
      zkey["n8r"] = n8r
      pointer += BIT_32

      let r = readBytes(data: bytesData, startPos: pointer, length: BIT_256)
      zkey["r"] = r
      pointer += BIT_256

      // TODO: get curve

      let nVars = readULE32(data: bytesData, startPos: pointer)
      zkey["nVars"] = nVars
      pointer += BIT_32

      let nPublic = readULE32(data: bytesData, startPos: pointer)
      zkey["nPublic"] = nPublic
      pointer += BIT_32

      let domainSize = readULE32(data: bytesData, startPos: pointer)
      zkey["domainSize"] = domainSize
      pointer += BIT_32

      let power = log2(Double(domainSize))
      zkey["power"] = Int(power)

      zkey["vk_alpha_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      zkey["vk_beta_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      zkey["vk_beta_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024

      zkey["vk_gamma_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024

      zkey["vk_delta_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      zkey["vk_delta_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024
    }

    return zkey
  } catch let error {
    print("Error: \(error)")
  }
  return [String: Any]()
}
