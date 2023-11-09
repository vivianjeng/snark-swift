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

func readSection(data: [UInt8], sections: [[(p: Int, size: UInt64)]], idSection: Int) throws
  -> [UInt8]
{
  let offset = 0
  let length = Int(sections[idSection][0].size) - offset
  if (offset + length) > sections[idSection][0].size {
    throw NSError(domain: "Reading out of the range of the section", code: 0, userInfo: nil)
  }

  let pointer = sections[idSection][0].p
  let buff = Array(data[pointer...pointer + Int(length) - 1])
  return buff
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

    var header = [String: Any]()
    if protocolId == 1 {
      header["protocol"] = "groth16"

      pointer = sections[2][0].p
      let n8q = readULE32(data: bytesData, startPos: pointer)
      header["n8q"] = n8q
      pointer += BIT_32

      let q = readBytes(data: bytesData, startPos: pointer, length: BIT_256)
      header["q"] = q
      pointer += BIT_256

      let n8r = readULE32(data: bytesData, startPos: pointer)
      header["n8r"] = n8r
      pointer += BIT_32

      let r = readBytes(data: bytesData, startPos: pointer, length: BIT_256)
      header["r"] = r
      pointer += BIT_256

      // TODO: get curve

      let nVars = readULE32(data: bytesData, startPos: pointer)
      header["nVars"] = nVars
      pointer += BIT_32

      let nPublic = readULE32(data: bytesData, startPos: pointer)
      header["nPublic"] = nPublic
      pointer += BIT_32

      let domainSize = readULE32(data: bytesData, startPos: pointer)
      header["domainSize"] = domainSize
      pointer += BIT_32

      let power = log2(Double(domainSize))
      header["power"] = Int(power)

      header["vk_alpha_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      header["vk_beta_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      header["vk_beta_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024

      header["vk_gamma_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024

      header["vk_delta_1"] = readBytes(data: bytesData, startPos: pointer, length: BIT_512)
      pointer += BIT_512

      header["vk_delta_2"] = readBytes(data: bytesData, startPos: pointer, length: BIT_1024)
      pointer += BIT_1024
    }

    // TODO: fix length
    let ic = try readSection(data: bytesData, sections: sections, idSection: 3)
    let buffCoeffs = try readSection(data: bytesData, sections: sections, idSection: 4)
    let buffBasesA = try readSection(data: bytesData, sections: sections, idSection: 5)
    let buffBasesB1 = try readSection(data: bytesData, sections: sections, idSection: 6)
    let buffBasesB2 = try readSection(data: bytesData, sections: sections, idSection: 7)
    let buffBasesC = try readSection(data: bytesData, sections: sections, idSection: 8)
    let buffBasesH = try readSection(data: bytesData, sections: sections, idSection: 9)

    var vk = [String: Any]()
    vk["alpha_g1"] = header["vk_alpha_1"]
    vk["beta_g2"] = header["vk_beta_2"]
    vk["gamma_g2"] = header["vk_gamma_2"]
    vk["delta_g2"] = header["vk_delta_2"]
    vk["gamma_abc_g1"] = ic

    var pk = [String: Any]()
    pk["vk"] = vk
    pk["beta_g1"] = header["vk_beta_1"]
    pk["delta_g1"] = header["vk_delta_1"]
    pk["a_query"] = buffBasesA
    pk["b_g1_query"] = buffBasesB1
    pk["b_g2_query"] = buffBasesB2
    pk["l_query"] = buffBasesC
    pk["h_query"] = buffBasesH

    return pk
  } catch let error {
    print("Error: \(error)")
  }
  return [String: Any]()
}
