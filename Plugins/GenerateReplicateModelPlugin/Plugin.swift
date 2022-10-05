import PackagePlugin
import Foundation

@main
struct Plugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "generate-replicate-model")
        let toolUrl = URL(fileURLWithPath: tool.path.string)
//
//        guard let replicate = try context.package.products(named: ["Replicate"]).first else {
//            fatalError("cannot replicate dependency")
//        }
//
//        var targetName: String?
//
//        var arguments = arguments
//        if let flagIndex = arguments.firstIndex(of: "--target"),
//           let valueIndex = arguments.index(flagIndex, offsetBy: 1, limitedBy: arguments.endIndex)
//        {
//            targetName = arguments[valueIndex]
//            arguments.removeSubrange(flagIndex...valueIndex)
//        }
//
//        var candidates = context.package.targets.filter { target in
//            guard let target = target as? SourceModuleTarget else { return false }
//            for case .product(let product) in target.dependencies where product.id == replicate.id {
//                return true
//            }
//
//            return false
//        }
//
//        guard candidates.count > 0 else {
//            fatalError("no source module targets found with dependency on Replicate")
//        }
//
//        if let targetName {
//            candidates = candidates.filter { target in
//                target.name == targetName
//            }
//
//            guard !candidates.isEmpty else {
//                fatalError("no source module targets found with name '\(targetName)'")
//            }
//        }
//
//        guard candidates.count == 1,
//              let target = candidates.first
//        else {
//            fatalError("multiple source module targets found with dependency on Replicate")
//        }
//

//
//        let destination = target.directory.appending(subpath: "Model.swift")
//        if FileManager.default.fileExists(atPath: destination.string) {
//            fatalError("file already exists at \(destination)")
//        }

        let process = Process()
        process.executableURL = toolUrl
        process.arguments = arguments

        print(toolUrl.path, process.arguments!.joined(separator: " "))
//
//        let outPipe = Pipe()
//        let errPipe = Pipe()
//        process.standardOutput = outPipe
//        process.standardError = errPipe

        try process.run()
        process.waitUntilExit()
//
//        guard process.terminationStatus == EXIT_SUCCESS else {
//           let error = String(data: errPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)
//           fatalError(error?.trimmingCharacters(in: .newlines) ?? "unknown error")
//        }
//
//
//        guard let output = String(data: outPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?
//                            .trimmingCharacters(in: .newlines),
//              !output.isEmpty
//        else {
//           fatalError("no code generated")
//        }
//
//        let destination = context.pluginWorkDirectory.appending("GeneratedSources", "Model.swift")
//
//        FileManager.default.createFile(atPath: destination.string, contents: output.data(using: .utf8))
//
////        try output.write(toFile: destination.string, atomically: true, encoding: .utf8)
    }
}
