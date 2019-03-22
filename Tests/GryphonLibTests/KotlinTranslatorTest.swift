/*
* Copyright 2018 Vinícius Jorge Vendramini
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

@testable import GryphonLib
import XCTest

class KotlinTranslatorTest: XCTestCase {
	func testTranslator() {
		let tests = TestUtils.testCasesForAllTests

		for testName in tests {
			print("- Testing \(testName)...")

			do {
				// Create the new Kotlin code from the cached Gryphon AST using the
				// KotlinTranslator
				let testFilePath = TestUtils.testFilesPath + testName
				let ast = try GryphonAST(decodeFromFile: testFilePath + .gryAST)
				_ = RecordEnumsTranspilationPass().run(on: ast)
				let createdKotlinCode = try KotlinTranslator().translateAST(ast)

				// Load the cached Kotlin code from file
				let expectedKotlinCode = try! String(contentsOfFile: testFilePath + .kt)

				// Compare the two
				XCTAssert(
					createdKotlinCode == expectedKotlinCode,
					"Test \(testName): translator failed to produce expected result. Diff:" +
						TestUtils.diff(createdKotlinCode, expectedKotlinCode))

				print("\t- Done!")
			}
			catch let error {
				XCTFail("🚨 Test failed with error:\n\(error)")
			}
		}

		XCTAssertFalse(Compiler.hasErrorsOrWarnings())
		Compiler.printErrorsAndWarnings()
	}

	static var allTests = [
		("testTranslator", testTranslator),
	]

	override static func setUp() {
		do {
			try Utilities.updateTestFiles()
		}
		catch let error {
			print(error)
			fatalError("Failed to update test files.")
		}
	}

	override func setUp() {
		Compiler.clearErrorsAndWarnings()
	}
}