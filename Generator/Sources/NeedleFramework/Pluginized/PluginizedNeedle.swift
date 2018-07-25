//
//  Copyright (c) 2018. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/// The entry point to Needle, providing all the functionalities of the system.
public class PluginizedNeedle {

    /// Parse Swift source files by recurively scanning the directories starting
    /// from the specified source path, excluding files with specified suffixes.
    /// Generate the necessary dependency provider code and export to the
    /// specified destination path.
    ///
    /// - parameter sourceRootPath: The root directory of source files to parse.
    /// - parameter exclusionSuffixes: The file suffixes to exclude from parsing.
    /// - parameter additionalImports: The additional import statements to add
    /// to the ones parsed from source files.
    /// - parameter destinationPath: The path to export generated code to.
    public static func generate(from sourceRootPath: String, excludingFilesWithSuffixes exclusionSuffixes: [String], withAdditionalImports additionalImports: [String], to destinationPath: String) {
        let sourceRootUrl = URL(fileURLWithPath: sourceRootPath)
        #if DEBUG
        let executor: SequenceExecutor = ProcessInfo().environment["SINGLE_THREADED"] != nil ? SerialSequenceExecutorImpl() : SequenceExecutorImpl(name: "PluginizedNeedle.generate", qos: .userInteractive)
        #else
        let executor = SequenceExecutorImpl(name: "PluginizedNeedle.generate", qos: .userInteractive)
        #endif
        let parser = PluginizedDependencyGraphParser()
        do {
            let (components, pluginizedComponents, imports) = try parser.parse(from: sourceRootUrl, excludingFilesWithSuffixes: exclusionSuffixes, using: executor)
            let exporter = PluginizedDependencyGraphExporter()
            try exporter.export(components, pluginizedComponents, with: imports + additionalImports, to: destinationPath, using: executor)
        } catch DependencyGraphParserError.timeout(let sourcePath) {
            fatalError("Parsing Swift source file at \(sourcePath) timed out.")
        } catch DependencyGraphExporterError.timeout(let componentName) {
            fatalError("Generating dependency provider for \(componentName) timed out.")
        } catch DependencyGraphExporterError.unableToWriteFile(let outputFile) {
            fatalError("Failed to export contents to \(outputFile)")
        } catch {
            fatalError("Unknown error \(error).")
        }
    }
}