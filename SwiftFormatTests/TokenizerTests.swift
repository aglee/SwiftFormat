//
//  TokenizerTests.swift
//  SwiftFormat
//
//  Created by Nick Lockwood on 12/08/2016.
//  Copyright 2016 Nick Lockwood
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/SwiftFormat
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import XCTest
import SwiftFormat

class TokenizerTests: XCTestCase {

    // MARK: Invalid input

    func testInvalidToken() {
        let input = "let `foo = bar"
        let output: [Token] = [
            .keyword("let"),
            .space(" "),
            .error("`foo = bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnclosedBraces() {
        let input = "func foo() {"
        let output: [Token] = [
            .keyword("func"),
            .space(" "),
            .identifier("foo"),
            .startOfScope("("),
            .endOfScope(")"),
            .space(" "),
            .startOfScope("{"),
            .error(""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnclosedSingleLineComment() {
        let input = "// comment"
        let output: [Token] = [
            .startOfScope("//"),
            .space(" "),
            .commentBody("comment"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnclosedMultilineComment() {
        let input = "/* comment"
        let output: [Token] = [
            .startOfScope("/*"),
            .space(" "),
            .commentBody("comment"),
            .error(""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnclosedString() {
        let input = "\"Hello World"
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("Hello World"),
            .error(""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnbalancedScopes() {
        let input = "array.map({ return $0 )"
        let output: [Token] = [
            .identifier("array"),
            .symbol("."),
            .identifier("map"),
            .startOfScope("("),
            .startOfScope("{"),
            .space(" "),
            .keyword("return"),
            .space(" "),
            .identifier("$0"),
            .space(" "),
            .error(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Space

    func testSpaces() {
        let input = "    "
        let output: [Token] = [
            .space("    "),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSpacesAndTabs() {
        let input = "  \t  \t"
        let output: [Token] = [
            .space("  \t  \t"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Strings

    func testEmptyString() {
        let input = "\"\""
        let output: [Token] = [
            .startOfScope("\""),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSimpleString() {
        let input = "\"foo\""
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("foo"),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testStringWithEscape() {
        let input = "\"hello\\tworld\""
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("hello\\tworld"),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testStringWithEscapedQuotes() {
        let input = "\"\\\"nice\\\" to meet you\""
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("\\\"nice\\\" to meet you"),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testStringWithEscapedLogic() {
        let input = "\"hello \\(name)\""
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("hello \\"),
            .startOfScope("("),
            .identifier("name"),
            .endOfScope(")"),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testStringWithEscapedBackslash() {
        let input = "\"\\\\\""
        let output: [Token] = [
            .startOfScope("\""),
            .stringBody("\\\\"),
            .endOfScope("\""),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Single-line comments

    func testSingleLineComment() {
        let input = "//foo"
        let output: [Token] = [
            .startOfScope("//"),
            .commentBody("foo"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSingleLineCommentWithSpace() {
        let input = "// foo "
        let output: [Token] = [
            .startOfScope("//"),
            .space(" "),
            .commentBody("foo"),
            .space(" "),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSingleLineCommentWithLinebreak() {
        let input = "//foo\nbar"
        let output: [Token] = [
            .startOfScope("//"),
            .commentBody("foo"),
            .linebreak("\n"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Multiline comments

    func testSingleLineMultilineComment() {
        let input = "/*foo*/"
        let output: [Token] = [
            .startOfScope("/*"),
            .commentBody("foo"),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSingleLineMultilineCommentWithSpace() {
        let input = "/* foo */"
        let output: [Token] = [
            .startOfScope("/*"),
            .space(" "),
            .commentBody("foo"),
            .space(" "),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testMultilineComment() {
        let input = "/*foo\nbar*/"
        let output: [Token] = [
            .startOfScope("/*"),
            .commentBody("foo"),
            .linebreak("\n"),
            .commentBody("bar"),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testMultilineCommentWithSpace() {
        let input = "/*foo\n  bar*/"
        let output: [Token] = [
            .startOfScope("/*"),
            .commentBody("foo"),
            .linebreak("\n"),
            .space("  "),
            .commentBody("bar"),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNestedComments() {
        let input = "/*foo/*bar*/baz*/"
        let output: [Token] = [
            .startOfScope("/*"),
            .commentBody("foo"),
            .startOfScope("/*"),
            .commentBody("bar"),
            .endOfScope("*/"),
            .commentBody("baz"),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNestedCommentsWithSpace() {
        let input = "/* foo /* bar */ baz */"
        let output: [Token] = [
            .startOfScope("/*"),
            .space(" "),
            .commentBody("foo"),
            .space(" "),
            .startOfScope("/*"),
            .space(" "),
            .commentBody("bar"),
            .space(" "),
            .endOfScope("*/"),
            .space(" "),
            .commentBody("baz"),
            .space(" "),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Numbers

    func testZero() {
        let input = "0"
        let output: [Token] = [.number("0")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSmallInteger() {
        let input = "5"
        let output: [Token] = [.number("5")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testLargeInteger() {
        let input = "12345678901234567890"
        let output: [Token] = [.number("12345678901234567890")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNegativeInteger() {
        let input = "-7"
        let output: [Token] = [
            .symbol("-"),
            .number("7"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSmallFloat() {
        let input = "0.2"
        let output: [Token] = [.number("0.2")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testLargeFloat() {
        let input = "1234.567890"
        let output: [Token] = [.number("1234.567890")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNegativeFloat() {
        let input = "-0.34"
        let output: [Token] = [
            .symbol("-"),
            .number("0.34"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testExponential() {
        let input = "1234e5"
        let output: [Token] = [.number("1234e5")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testPositiveExponential() {
        let input = "0.123e+4"
        let output: [Token] = [.number("0.123e+4")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNegativeExponential() {
        let input = "0.123e-4"
        let output: [Token] = [.number("0.123e-4")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCapitalExponential() {
        let input = "0.123E-4"
        let output: [Token] = [.number("0.123E-4")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testLeadingZeros() {
        let input = "0005"
        let output: [Token] = [.number("0005")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testBinary() {
        let input = "0b101010"
        let output: [Token] = [.number("0b101010")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOctal() {
        let input = "0o52"
        let output: [Token] = [.number("0o52")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testHex() {
        let input = "0x2A"
        let output: [Token] = [.number("0x2A")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testHexadecimalPower() {
        let input = "0xC3p0"
        let output: [Token] = [.number("0xC3p0")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInInteger() {
        let input = "1_23_4_"
        let output: [Token] = [.number("1_23_4_")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInFloat() {
        let input = "0_.1_2_"
        let output: [Token] = [.number("0_.1_2_")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInExponential() {
        let input = "0.1_2_e-3"
        let output: [Token] = [.number("0.1_2_e-3")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInBinary() {
        let input = "0b0000_0000_0001"
        let output: [Token] = [.number("0b0000_0000_0001")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInOctal() {
        let input = "0o123_456"
        let output: [Token] = [.number("0o123_456")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnderscoresInHex() {
        let input = "0xabc_def"
        let output: [Token] = [.number("0xabc_def")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNoLeadingUnderscoreInInteger() {
        let input = "_12345"
        let output: [Token] = [.identifier("_12345")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNoLeadingUnderscoreInHex() {
        let input = "0x_12345"
        let output: [Token] = [.error("0x_12345")]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Identifiers

    func testFoo() {
        let input = "foo"
        let output: [Token] = [.identifier("foo")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testDollar0() {
        let input = "$0"
        let output: [Token] = [.identifier("$0")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testDollar() {
        // Note: support for this is deprecated in Swift 3
        let input = "$"
        let output: [Token] = [.identifier("$")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testFooDollar() {
        let input = "foo$"
        let output: [Token] = [.identifier("foo$")]
        XCTAssertEqual(tokenize(input), output)
    }

    func test_() {
        let input = "_"
        let output: [Token] = [.identifier("_")]
        XCTAssertEqual(tokenize(input), output)
    }

    func test_foo() {
        let input = "_foo"
        let output: [Token] = [.identifier("_foo")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testFoo_bar() {
        let input = "foo_bar"
        let output: [Token] = [.identifier("foo_bar")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testAtFoo() {
        let input = "@foo"
        let output: [Token] = [.keyword("@foo")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testHashFoo() {
        let input = "#foo"
        let output: [Token] = [.keyword("#foo")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnicode() {
        let input = "µsec"
        let output: [Token] = [.identifier("µsec")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testEmoji() {
        let input = "💩"
        let output: [Token] = [.identifier("💩")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testBacktickEscapedClass() {
        let input = "`class`"
        let output: [Token] = [.identifier("`class`")]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: Operators

    func testBasicOperator() {
        let input = "+="
        let output: [Token] = [.symbol("+=")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testDivide() {
        let input = "a / b"
        let output: [Token] = [
            .identifier("a"),
            .space(" "),
            .symbol("/"),
            .space(" "),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCustomOperator() {
        let input = "~="
        let output: [Token] = [.symbol("~=")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSequentialOperators() {
        let input = "a *= -b"
        let output: [Token] = [
            .identifier("a"),
            .space(" "),
            .symbol("*="),
            .space(" "),
            .symbol("-"),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testDotPrefixedOperator() {
        let input = "..."
        let output: [Token] = [.symbol("...")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testUnicodeOperator() {
        let input = "≥"
        let output: [Token] = [.symbol("≥")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOperatorFollowedByComment() {
        let input = "a +/* b */"
        let output: [Token] = [
            .identifier("a"),
            .space(" "),
            .symbol("+"),
            .startOfScope("/*"),
            .space(" "),
            .commentBody("b"),
            .space(" "),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOperatorPrecededByComment() {
        let input = "/* a */-b"
        let output: [Token] = [
            .startOfScope("/*"),
            .space(" "),
            .commentBody("a"),
            .space(" "),
            .endOfScope("*/"),
            .symbol("-"),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOperatorMayContainDotIfStartsWithDot() {
        let input = ".*.."
        let output: [Token] = [.symbol(".*..")]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOperatorMayNotContainDotUnlessStartsWithDot() {
        let input = "*.."
        let output: [Token] = [
            .symbol("*"),
            .symbol(".."),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNullCoalescingOperator() {
        let input = "foo ?? bar"
        let output: [Token] = [
            .identifier("foo"),
            .space(" "),
            .symbol("??"),
            .space(" "),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: chevrons (might be operators or generics)

    func testLessThanGreaterThan() {
        let input = "a<b == a>c"
        let output: [Token] = [
            .identifier("a"),
            .symbol("<"),
            .identifier("b"),
            .space(" "),
            .symbol("=="),
            .space(" "),
            .identifier("a"),
            .symbol(">"),
            .identifier("c"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testBitshift() {
        let input = "a>>b"
        let output: [Token] = [
            .identifier("a"),
            .symbol(">>"),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testTripleShift() {
        let input = "a>>>b"
        let output: [Token] = [
            .identifier("a"),
            .symbol(">>>"),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testTripleShiftEquals() {
        let input = "a>>=b"
        let output: [Token] = [
            .identifier("a"),
            .symbol(">>="),
            .identifier("b"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testBitshiftThatLooksLikeAGeneric() {
        let input = "a<b, b<c, d>>e"
        let output: [Token] = [
            .identifier("a"),
            .symbol("<"),
            .identifier("b"),
            .symbol(","),
            .space(" "),
            .identifier("b"),
            .symbol("<"),
            .identifier("c"),
            .symbol(","),
            .space(" "),
            .identifier("d"),
            .symbol(">>"),
            .identifier("e"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testBasicGeneric() {
        let input = "Foo<Bar, Baz>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .symbol(","),
            .space(" "),
            .identifier("Baz"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNestedGenerics() {
        let input = "Foo<Bar<Baz>>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .startOfScope("<"),
            .identifier("Baz"),
            .endOfScope(">"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testFunctionThatLooksLikeGenericType() {
        let input = "y<CGRectGetMaxY(r)"
        let output: [Token] = [
            .identifier("y"),
            .symbol("<"),
            .identifier("CGRectGetMaxY"),
            .startOfScope("("),
            .identifier("r"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericClassDeclaration() {
        let input = "class Foo<T,U> {}"
        let output: [Token] = [
            .keyword("class"),
            .space(" "),
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol(","),
            .identifier("U"),
            .endOfScope(">"),
            .space(" "),
            .startOfScope("{"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericSubclassDeclaration() {
        let input = "class Foo<T,U>: Bar"
        let output: [Token] = [
            .keyword("class"),
            .space(" "),
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol(","),
            .identifier("U"),
            .endOfScope(">"),
            .symbol(":"),
            .space(" "),
            .identifier("Bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFunctionDeclaration() {
        let input = "func foo<T>(bar:T)"
        let output: [Token] = [
            .keyword("func"),
            .space(" "),
            .identifier("foo"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .startOfScope("("),
            .identifier("bar"),
            .symbol(":"),
            .identifier("T"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericClassInit() {
        let input = "foo = Foo<Int,String>()"
        let output: [Token] = [
            .identifier("foo"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Int"),
            .symbol(","),
            .identifier("String"),
            .endOfScope(">"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFollowedByDot() {
        let input = "Foo<Bar>.baz()"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .endOfScope(">"),
            .symbol("."),
            .identifier("baz"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testConstantThatLooksLikeGenericType() {
        let input = "(y<Pi)"
        let output: [Token] = [
            .startOfScope("("),
            .identifier("y"),
            .symbol("<"),
            .identifier("Pi"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testTupleOfBoolsThatLooksLikeGeneric() {
        let input = "(Foo<T,U>V)"
        let output: [Token] = [
            .startOfScope("("),
            .identifier("Foo"),
            .symbol("<"),
            .identifier("T"),
            .symbol(","),
            .identifier("U"),
            .symbol(">"),
            .identifier("V"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericClassInitThatLooksLikeTuple() {
        let input = "(Foo<String,Int>(Bar))"
        let output: [Token] = [
            .startOfScope("("),
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("String"),
            .symbol(","),
            .identifier("Int"),
            .endOfScope(">"),
            .startOfScope("("),
            .identifier("Bar"),
            .endOfScope(")"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCustomChevronOperatorThatLooksLikeGeneric() {
        let input = "Foo<Bar,Baz>>>5"
        let output: [Token] = [
            .identifier("Foo"),
            .symbol("<"),
            .identifier("Bar"),
            .symbol(","),
            .identifier("Baz"),
            .symbol(">>>"),
            .number("5"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericAsFunctionType() {
        let input = "Foo<Bar,Baz>->Void"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .symbol(","),
            .identifier("Baz"),
            .endOfScope(">"),
            .symbol("->"),
            .identifier("Void"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericContainingArrayType() {
        let input = "Foo<[Bar],Baz>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .startOfScope("["),
            .identifier("Bar"),
            .endOfScope("]"),
            .symbol(","),
            .identifier("Baz"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericContainingTupleType() {
        let input = "Foo<(Bar,Baz)>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .startOfScope("("),
            .identifier("Bar"),
            .symbol(","),
            .identifier("Baz"),
            .endOfScope(")"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericContainingArrayAndTupleType() {
        let input = "Foo<[Bar],(Baz)>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .startOfScope("["),
            .identifier("Bar"),
            .endOfScope("]"),
            .symbol(","),
            .startOfScope("("),
            .identifier("Baz"),
            .endOfScope(")"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFollowedByIn() {
        let input = "Foo<Bar,Baz> in"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .symbol(","),
            .identifier("Baz"),
            .endOfScope(">"),
            .space(" "),
            .keyword("in"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testOptionalGenericType() {
        let input = "Foo<T?,U>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol("?"),
            .symbol(","),
            .identifier("U"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testTrailingOptionalGenericType() {
        let input = "Foo<T?>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol("?"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testNestedOptionalGenericType() {
        let input = "Foo<Bar<T?>>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol("?"),
            .endOfScope(">"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testDeeplyNestedGenericType() {
        let input = "Foo<Bar<Baz<Quux>>>"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("Bar"),
            .startOfScope("<"),
            .identifier("Baz"),
            .startOfScope("<"),
            .identifier("Quux"),
            .endOfScope(">"),
            .endOfScope(">"),
            .endOfScope(">"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFollowedByGreaterThan() {
        let input = "Foo<T>\na=b>c"
        let output: [Token] = [
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .linebreak("\n"),
            .identifier("a"),
            .symbol("="),
            .identifier("b"),
            .symbol(">"),
            .identifier("c"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFollowedByElipsis() {
        let input = "foo<T>(bar: Baz<T>...)"
        let output: [Token] = [
            .identifier("foo"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .startOfScope("("),
            .identifier("bar"),
            .symbol(":"),
            .space(" "),
            .identifier("Baz"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .symbol("..."),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericOperatorFunction() {
        let input = "func ==<T>()"
        let output: [Token] = [
            .keyword("func"),
            .space(" "),
            .symbol("=="),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericCustomOperatorFunction() {
        let input = "func ∘<T,U>()"
        let output: [Token] = [
            .keyword("func"),
            .space(" "),
            .symbol("∘"),
            .startOfScope("<"),
            .identifier("T"),
            .symbol(","),
            .identifier("U"),
            .endOfScope(">"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCustomOperatorStartingWithOpenChevron() {
        let input = "foo<--bar"
        let output: [Token] = [
            .identifier("foo"),
            .symbol("<--"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCustomOperatorEndingWithCloseChevron() {
        let input = "foo-->bar"
        let output: [Token] = [
            .identifier("foo"),
            .symbol("-->"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGreaterThanLessThanOperator() {
        let input = "foo><bar"
        let output: [Token] = [
            .identifier("foo"),
            .symbol("><"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testLessThanGreaterThanOperator() {
        let input = "foo<>bar"
        let output: [Token] = [
            .identifier("foo"),
            .symbol("<>"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericFollowedByAssign() {
        let input = "let foo: Bar<Baz> = 5"
        let output: [Token] = [
            .keyword("let"),
            .space(" "),
            .identifier("foo"),
            .symbol(":"),
            .space(" "),
            .identifier("Bar"),
            .startOfScope("<"),
            .identifier("Baz"),
            .endOfScope(">"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .number("5"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testGenericInFailableInit() {
        let input = "init?<T>()"
        let output: [Token] = [
            .keyword("init"),
            .symbol("?"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testInfixQuestionMarkChevronOperator() {
        let input = "operator ?< {}"
        let output: [Token] = [
            .keyword("operator"),
            .space(" "),
            .symbol("?<"),
            .space(" "),
            .startOfScope("{"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testInfixEqualsDoubleChevronOperator() {
        let input = "infix operator =<<"
        let output: [Token] = [
            .identifier("infix"),
            .space(" "),
            .keyword("operator"),
            .space(" "),
            .symbol("=<<"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testInfixEqualsDoubleChevronGenericFunction() {
        let input = "func =<<<T>()"
        let output: [Token] = [
            .keyword("func"),
            .space(" "),
            .symbol("=<<"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .startOfScope("("),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testHalfOpenRangeFollowedByComment() {
        let input = "1..<5\n//comment"
        let output: [Token] = [
            .number("1"),
            .symbol("..<"),
            .number("5"),
            .linebreak("\n"),
            .startOfScope("//"),
            .commentBody("comment"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSortAscending() {
        let input = "sort(by: <)"
        let output: [Token] = [
            .identifier("sort"),
            .startOfScope("("),
            .identifier("by"),
            .symbol(":"),
            .space(" "),
            .symbol("<"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSortDescending() {
        let input = "sort(by: >)"
        let output: [Token] = [
            .identifier("sort"),
            .startOfScope("("),
            .identifier("by"),
            .symbol(":"),
            .space(" "),
            .symbol(">"),
            .endOfScope(")"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: optionals

    func testAssignOptional() {
        let input = "Int?=nil"
        let output: [Token] = [
            .identifier("Int"),
            .symbol("?"),
            .symbol("="),
            .identifier("nil"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testQuestionMarkEqualOperator() {
        let input = "foo ?= bar"
        let output: [Token] = [
            .identifier("foo"),
            .space(" "),
            .symbol("?="),
            .space(" "),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: case statements

    func testSingleLineEnum() {
        let input = "enum Foo {case Bar, Baz}"
        let output: [Token] = [
            .keyword("enum"),
            .space(" "),
            .identifier("Foo"),
            .space(" "),
            .startOfScope("{"),
            .keyword("case"),
            .space(" "),
            .identifier("Bar"),
            .symbol(","),
            .space(" "),
            .identifier("Baz"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSingleLineGenericEnum() {
        let input = "enum Foo<T> {case Bar, Baz}"
        let output: [Token] = [
            .keyword("enum"),
            .space(" "),
            .identifier("Foo"),
            .startOfScope("<"),
            .identifier("T"),
            .endOfScope(">"),
            .space(" "),
            .startOfScope("{"),
            .keyword("case"),
            .space(" "),
            .identifier("Bar"),
            .symbol(","),
            .space(" "),
            .identifier("Baz"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testMultilineLineEnum() {
        let input = "enum Foo {\ncase Bar\ncase Baz\n}"
        let output: [Token] = [
            .keyword("enum"),
            .space(" "),
            .identifier("Foo"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .keyword("case"),
            .space(" "),
            .identifier("Bar"),
            .linebreak("\n"),
            .keyword("case"),
            .space(" "),
            .identifier("Baz"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchStatement() {
        let input = "switch x {\ncase 1:\nbreak\ncase 2:\nbreak\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("2"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchStatementWithEnumCases() {
        let input = "switch x {\ncase .foo,\n.bar:\nbreak\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .symbol("."),
            .identifier("foo"),
            .symbol(","),
            .linebreak("\n"),
            .symbol("."),
            .identifier("bar"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseIsDictionaryStatement() {
        let input = "switch x {\ncase foo is [Key: Value]:\nbreak\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .identifier("foo"),
            .space(" "),
            .keyword("is"),
            .space(" "),
            .startOfScope("["),
            .identifier("Key"),
            .symbol(":"),
            .space(" "),
            .identifier("Value"),
            .endOfScope("]"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingCaseIdentifier() {
        let input = "switch x {\ncase 1:\nfoo.case\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .identifier("foo"),
            .symbol("."),
            .identifier("case"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingDefaultIdentifier() {
        let input = "switch x {\ncase 1:\nfoo.default\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .identifier("foo"),
            .symbol("."),
            .identifier("default"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingIfCase() {
        let input = "switch x {\ncase 1:\nif case x = y {}\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("if"),
            .space(" "),
            .keyword("case"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .identifier("y"),
            .space(" "),
            .startOfScope("{"),
            .endOfScope("}"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingIfCaseCommaCase() {
        let input = "switch x {\ncase 1:\nif case w = x, case y = z {}\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("if"),
            .space(" "),
            .keyword("case"),
            .space(" "),
            .identifier("w"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .identifier("x"),
            .symbol(","),
            .space(" "),
            .keyword("case"),
            .space(" "),
            .identifier("y"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .identifier("z"),
            .space(" "),
            .startOfScope("{"),
            .endOfScope("}"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingGuardCase() {
        let input = "switch x {\ncase 1:\nguard case x = y else {}\ndefault:\nbreak\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("guard"),
            .space(" "),
            .keyword("case"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .symbol("="),
            .space(" "),
            .identifier("y"),
            .space(" "),
            .keyword("else"),
            .space(" "),
            .startOfScope("{"),
            .endOfScope("}"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchFollowedByEnum() {
        let input = "switch x {\ncase y: break\ndefault: break\n}\nenum Foo {\ncase z\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .identifier("y"),
            .startOfScope(":"),
            .space(" "),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .space(" "),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
            .linebreak("\n"),
            .keyword("enum"),
            .space(" "),
            .identifier("Foo"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .keyword("case"),
            .space(" "),
            .identifier("z"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testSwitchCaseContainingSwitchIdentifierFollowedByEnum() {
        let input = "switch x {\ncase 1:\nfoo.switch\ndefault:\nbreak\n}\nenum Foo {\ncase z\n}"
        let output: [Token] = [
            .keyword("switch"),
            .space(" "),
            .identifier("x"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .endOfScope("case"),
            .space(" "),
            .number("1"),
            .startOfScope(":"),
            .linebreak("\n"),
            .identifier("foo"),
            .symbol("."),
            .identifier("switch"),
            .linebreak("\n"),
            .endOfScope("default"),
            .startOfScope(":"),
            .linebreak("\n"),
            .keyword("break"),
            .linebreak("\n"),
            .endOfScope("}"),
            .linebreak("\n"),
            .keyword("enum"),
            .space(" "),
            .identifier("Foo"),
            .space(" "),
            .startOfScope("{"),
            .linebreak("\n"),
            .keyword("case"),
            .space(" "),
            .identifier("z"),
            .linebreak("\n"),
            .endOfScope("}"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    // MARK: linebreaks

    func testLF() {
        let input = "foo\nbar"
        let output: [Token] = [
            .identifier("foo"),
            .linebreak("\n"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCR() {
        let input = "foo\rbar"
        let output: [Token] = [
            .identifier("foo"),
            .linebreak("\r"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCRLF() {
        let input = "foo\r\nbar"
        let output: [Token] = [
            .identifier("foo"),
            .linebreak("\r\n"),
            .identifier("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCRLFAfterComment() {
        let input = "//foo\r\n//bar"
        let output: [Token] = [
            .startOfScope("//"),
            .commentBody("foo"),
            .linebreak("\r\n"),
            .startOfScope("//"),
            .commentBody("bar"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }

    func testCRLFInMultilineComment() {
        let input = "/*foo\r\nbar*/"
        let output: [Token] = [
            .startOfScope("/*"),
            .commentBody("foo"),
            .linebreak("\r\n"),
            .commentBody("bar"),
            .endOfScope("*/"),
        ]
        XCTAssertEqual(tokenize(input), output)
    }
}
