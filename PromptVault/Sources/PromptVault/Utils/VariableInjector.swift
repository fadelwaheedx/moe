import Foundation

struct VariableInjector {

    /// Extracts variable names from text in the format {{variableName}}
    static func extractVariables(from text: String) -> [String] {
        let pattern = #"\{\{(.*?)\}\}"#

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))

            let variables = results.compactMap { match -> String? in
                guard let range = Range(match.range(at: 1), in: text) else { return nil }
                return String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }

            // Return unique variables maintaining order
            var seen = Set<String>()
            return variables.filter { seen.insert($0).inserted }

        } catch {
            print("Regex error: \(error)")
            return []
        }
    }

    /// Replaces variables in the text with values provided in the dictionary
    static func inject(variables: [String: String], into text: String) -> String {
        var result = text
        let extracted = extractVariables(from: text)

        for varName in extracted {
            guard let value = variables[varName] else { continue }

            // Construct a regex for this specific variable to handle spacing: {{ \s*varName\s* }}
            let pattern = #"\{\{\s*"# + NSRegularExpression.escapedPattern(for: varName) + #"\s*\}\}"#

            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(result.startIndex..., in: result)
                result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: NSRegularExpression.escapedTemplate(for: value))
            } catch {
                print("Regex replacement error: \(error)")
                continue
            }
        }

        return result
    }
}
