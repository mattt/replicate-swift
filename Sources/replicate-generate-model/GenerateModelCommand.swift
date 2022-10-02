import Foundation
import ArgumentParser
import Replicate
import OpenAPIKit
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftFormat

@main
struct GenerateModelCommand: AsyncParsableCommand {
    enum Error: Swift.Error {
        case versionNotFound
    }

    @Argument(help: "The model id.")
    var modelID: Model.ID

    @Argument(help: "The version.")
    var versionID: Model.Version.ID?

    @Option
    var name: String?

    mutating func run() async throws {
        let client = Client(token: "4d6f17cca743e726710f9eba83ec9e09932a7191")

        let model = try await client.getModel(modelID)
        let version: Model.Version
        if let versionID {
            version = try await client.getModelVersion(modelID, version: versionID)
        } else {
            guard let latestVersion = model.latestVersion else {
                throw Error.versionNotFound
            }

            version = latestVersion
        }

        let document = try OpenAPI.document(for: version)
        guard let input = document.components.schemas["Input"]?.objectContext else {
            fatalError("No input found")
        }

        name = name ?? model.name.capitalized.replacingOccurrences(of: "-", with: "")

        let source = SourceFile {
            ImportDecl(path: "Foundation")
            ImportDecl(path: "Replicate")
            

            ClassDecl(classOrActorKeyword: .class.withLeadingTrivia(.docBlockComment("    Lorem ipsum dolor sit amet")),
                      identifier: "\(name!)", membersBuilder:  {
                StructDecl(identifier: "Input", membersBuilder: {
                    for (name, schema) in input.properties {
                        VariableDecl(.let.withLeadingTrivia(.newlines(1) + schema.swiftDocumentation),
                                     name: name,
                                     type: schema.swiftTypeName)

//                        print(name)
//                        dump(schema)
                    }
                })

                EnumDecl(
                    enumKeyword: .enum.withLeadingTrivia(.newlines(1)),
//                    identifier: .enum,

                     identifier: "Greeting",
                     inheritanceClause: TypeInheritanceClause {
                       InheritedType(typeName: "String")
                        
                       InheritedType(typeName: "Codable")
                       InheritedType(typeName: "Equatable")
                     }, modifiersBuilder: {
                         TokenSyntax.private
                     },
                     membersBuilder:
                    {
                        EnumCaseDecl(elementsBuilder: {
                       EnumCaseElement(
                         identifier: "goodMorning",
                         rawValue: InitializerClause(equal: .equal, value: StringLiteralExpr("Good Morning")))

                     })
                   })

//                EnumDecl(attributes: AttributeList([Attribute(attributeName: .public)]),
//                         identifier: .enum,
//                         inheritanceClause: TypeInheritanceClause {
//                                 InheritedType(typeName: "String")
//                                 InheritedType(typeName: "Codable")
//                                 InheritedType(typeName: "Equatable")
//                               },
//                         members: MemberDeclBlock (membersBuilder: {
//                    for (name, _) in input.properties {
//                        EnumCaseElement(
//                            identifier: "goodMorning",
//                            rawValue: InitializerClause(equal: .equal, value: StringLiteralExpr("Good Morning")))
//                        })
//                    })
//                }

//                }(members: input.properties.map { (name, _) in
//                    EnumCaseElement(
//                        identifier: "goodMorning",
//                        rawValue: InitializerClause(equal: .equal, value: StringLiteralExpr("Good Morning")))
//                    })
//                )

            })
        }


        let syntax = source.buildSyntax(format: .init())

        var text = ""


        let formatter = SwiftFormatter(configuration: .init())
        try formatter.format(syntax: .init(syntax)!, assumingFileURL: nil, to: &text)


//        syntax.write(to: &text)
        print(text)


    }
}

// MARK: -

private extension OpenAPI {
    static func document(for version: Replicate.Model.Version) throws -> Document {
        let encoder = JSONEncoder()
        let data = try encoder.encode(version.openAPISchema)

        let decoder = JSONDecoder()
        return try decoder.decode(Document.self, from: data)
    }
}

private extension JSONSchema {
    var swiftTypeName: String {
        switch self {
        case .boolean:
            return "Bool"
        case .number:
            return "Double"
        case .integer:
            return "Int"
        case .string:
            return "String"
        default:
            return "Any"
        }
    }

    var swiftDocumentation: Trivia {
        guard let description else {
            return .zero
        }

        return .docLineComment("    " + description)
    }
}
