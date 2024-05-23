//
//  AuthTests.swift
//  Hidden ClientTests
//
//  Created by Hideo Den on 2018/07/11.
//  Copyright © 2018 Hidden Talent Solutions Ltd. All rights reserved.
//

import XCTest
import RxSwift
@testable import Hidden_Client

class AuthTests: XCTestCase {
    var vm: LoginVM!
    
    override func setUp() {
        super.setUp()
        vm = LoginVM()
        vm.bind()
    }
    
    func testEmptyInputs() {
        vm.email.value = ""
        vm.password.value = ""
        XCTAssert(vm.validInput.value == false, "Empty inputs")
    }
    
    func testEmptyPassword() {
        vm.email.value = "test@test.com"
        vm.password.value = ""
        XCTAssert(vm.validInput.value == false, "Password is empty")
    }
    
    func testShortPasswordLengthLessThan4() {
        vm.email.value = "test@test.com"
        vm.password.value = "abc"
        XCTAssert(vm.validInput.value == false, "Short password")
    }
    
    func testEmail() {
        vm.email.value = "test-test.com"
        vm.password.value = "abcd"
        XCTAssert(vm.validInput.value == false, "Invalid Email")
    }
    
    func testEmailPassword() {
        vm.email.value = "test@test.com"
        vm.password.value = "abcd"
        XCTAssert(vm.validInput.value, "Valid Input")
    }
    
}
