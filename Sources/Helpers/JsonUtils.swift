import Foundation

public func getJsonStringFromKV(_ tuples: [(String, String)]) throws -> String {
  func removeOccurrences(substring: String, text: String, with: String) -> String {
    return text.replacingOccurrences(of: substring, with: with)
  }

  var jsonArray: [[String: String]] = []
  for tuple in tuples {
    let jsonDict: [String: String] = [
      tuple.0: tuple.1
    ]
    jsonArray.append(jsonDict)
  }

  let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
  var jsonString = String(data: jsonData, encoding: .utf8)!
  jsonString = removeOccurrences(substring: "},{", text: jsonString, with: ",")
  jsonString = removeOccurrences(substring: "}]", text: jsonString, with: "}")
  jsonString = removeOccurrences(substring: "[{", text: jsonString, with: "{")
  jsonString = removeOccurrences(substring: "\"null\"", text: jsonString, with: "null")
  jsonString = removeOccurrences(substring: "\\/", text: jsonString, with: "/")
  // jsonString = removeOccurrences(substring: "/", text: jsonString, with: "\\n")
  return jsonString
}
