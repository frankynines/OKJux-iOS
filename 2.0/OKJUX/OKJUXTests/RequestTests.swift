//
//  RequestTests.swift
//  OKJUX
//
//  Created by German Pereyra on 2/21/17.
//  Copyright © 2017 German Pereyra. All rights reserved.
//

import XCTest
@testable import OKJUX

class RequestTests: OKJUXTests {

    func test_registerUserPostRequest() {
        let exp = expectation(description: "")
        BaseNetworkManager.sendRequest(method: "users", requestMethodType: .post, parameters: ["user[UUID]": "F96034AC-446E-4139-949D-9F7CB4686322"]) { (error, json) in

            guard error == nil else {
                XCTAssert(false, "request faild")
                exp.fulfill()
                return
            }

            if let json = json {
                if !json.isEmpty {
                    if let user = json["user"] as? [String: Any], let _ = user["id"] as? Double, let _ = user["UUID"] as? String, let _ = user["karma"] as? Int {
                        XCTAssert(true)
                    } else {
                        XCTAssert(false, "the parameters were not able to be casted")
                    }
                } else {
                    XCTAssert(false, "json result came empty")
                }
                exp.fulfill()
            } else {
                XCTAssert(false, "request faild")
            }
        }

        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_registerUser() {
        let exp = expectation(description: "")
        self.signInUser {
            XCTAssert(true)
            exp.fulfill()
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_getNewestSnaps() {
        let exp = expectation(description: "")
        self.signInUser {

            SnapsManager.sharedInstance.getSnaps(hottest: false, completion: { (error, snapsResult) in
                if let error = error {
                    XCTAssert(false, error.description)
                } else {
                    if let snapsResult = snapsResult, !snapsResult.isEmpty {
                        if let firstSnap = snapsResult.first, let _ = firstSnap.id {
                            XCTAssert(true)
                        } else {
                            XCTAssert(false, "snaps must be not empty")
                        }
                    } else {
                        XCTAssert(false, "snaps must be not empty")
                    }
                }
                exp.fulfill()
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func test_getHottestSnaps() {
        let exp = expectation(description: "")
        self.signInUser {

            SnapsManager.sharedInstance.getSnaps(hottest: true, completion: { (error, snapsResult) in
                if let error = error {
                    XCTAssert(false, error.description)
                } else {
                    if let snapsResult = snapsResult, !snapsResult.isEmpty {
                        if let firstSnap = snapsResult.first, let snapId = firstSnap.id {
                            SnapsManager.sharedInstance.getSnaps(hottest: true, page: 2, completion: { (error2, snapsResultSecondPage) in
                                if let firstSnapSecondPage = snapsResultSecondPage?.first, let snapIdSecondPage = firstSnapSecondPage.id {
                                    if snapId != snapIdSecondPage {
                                        XCTAssert(true)
                                    } else {
                                        XCTAssert(false, "second query result contains duplicated data")
                                    }
                                } else {
                                    XCTAssert(false, "second query result was empty")
                                }
                                exp.fulfill()
                            })

                        } else {
                            XCTAssert(false, "snaps must be not empty")
                        }
                    } else {
                        XCTAssert(false, "snaps must be not empty")
                    }
                }
            })
        }
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}
