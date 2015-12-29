//
//  NoCreditDataReason
//  LeistungUZH
//
//  Created by Jonny Burger on 11.11.15.
//  Copyright © 2015 jonnyburger. All rights reserved.
//

import Foundation

enum NoCreditDataReason : String {
    case USERNAME_PW_WRONG = "USERNAME_PW_WRONG"
    case SCRAPE_TIMEOUT = "SCRAPE_TIMEOUT"
    case SCRAPE_ERROR = "SCRAPE_ERROR"
    case SCRAPE_PARSE_ERROR = "SCRAPE_PARSE_ERROR"
    case NO_USERNAME = "NO_USERNAME"
    case NO_PASSWORD = "NO_PASSWORD"
    case LOGIN_PAGE_LOAD_FAIL = "LOGIN_PAGE_LOAD_FAIL"
    case OFFLINE = "OFFLINE"
    case NOT_TRIED = "NOT_TRIED"
    case REQUEST_FAILED = "REQUEST_FAILED"
    case NO_CREDENTIALS_SUPPLIED = "NO_CREDENTIALS_SUPPLIED"
    case USERNAME_UNKNOWN = "USERNAME_UNKNOWN"
    case OTHER_REASON
}