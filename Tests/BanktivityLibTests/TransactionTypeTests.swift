// Copyright (c) 2026 Steve Flinter. MIT License.

import Testing
@testable import BanktivityLib

@Suite("Transaction type determination")
struct TransactionTypeTests {

    @Test("explicit withdrawal overrides line item signs")
    func explicitWithdrawalOverridesLineItemSigns() {
        let result = TransactionRepository.determineTransactionType(
            lineItems: [
                .init(accountId: 1, amount: 100.0, accountClass: 1001),
                .init(accountId: 2, amount: -100.0, accountClass: 7000),
            ],
            explicitTransactionType: "withdrawal"
        )

        #expect(result == "withdrawal")
    }

    @Test("auto detects withdrawal from one negative bank-like line")
    func autoDetectsWithdrawalFromNegativeBankLine() {
        let result = TransactionRepository.determineTransactionType(
            lineItems: [
                .init(accountId: 1, amount: -100.0, accountClass: 1001),
                .init(accountId: 2, amount: 100.0, accountClass: 7000),
            ]
        )

        #expect(result == "withdrawal")
    }

    @Test("auto detects deposit from one positive bank-like line")
    func autoDetectsDepositFromPositiveBankLine() {
        let result = TransactionRepository.determineTransactionType(
            lineItems: [
                .init(accountId: 1, amount: 100.0, accountClass: 1002),
                .init(accountId: 2, amount: -100.0, accountClass: 6000),
            ]
        )

        #expect(result == "deposit")
    }

    @Test("auto detects transfer from two bank-like lines with opposite signs")
    func autoDetectsTransferFromTwoOppositeBankLines() {
        let result = TransactionRepository.determineTransactionType(
            lineItems: [
                .init(accountId: 1, amount: -50.0, accountClass: 1001),
                .init(accountId: 2, amount: 50.0, accountClass: 1002),
                .init(accountId: 3, amount: 0.0, accountClass: 7000),
            ]
        )

        #expect(result == "transfer")
    }

    @Test("auto falls back to withdrawal for category-only transaction")
    func autoFallsBackToWithdrawalForCategoryOnlyTransaction() {
        let result = TransactionRepository.determineTransactionType(
            lineItems: [
                .init(accountId: 1, amount: 25.0, accountClass: 7000),
                .init(accountId: 2, amount: -25.0, accountClass: 6000),
            ]
        )

        #expect(result == "withdrawal")
    }

    @Test("invalid explicit transaction type has no base type code")
    func invalidExplicitTransactionTypeHasNoBaseTypeCode() {
        #expect(TransactionRepository.transactionTypeBaseTypeCode("not-a-real-type") == nil)
    }

    @Test("create mapping matches update mapping for built-in transaction base types")
    func createMappingMatchesUpdateMappingForBuiltInTransactionBaseTypes() {
        let expected: [(String, Int, String)] = [
            ("deposit", 1, "deposit"),
            ("withdrawal", 2, "withdrawal"),
            ("transfer", 3, "transfer"),
            ("check", 4, "check"),
            ("charge", 5, "charge"),
            ("refund", 6, "refund"),
            ("payment", 7, "payment"),
            ("buy", 100, "buy"),
            ("sell", 101, "sell"),
            ("buy-to-open", 102, "buy-to-open"),
            ("buy-to-close", 103, "buy-to-close"),
            ("sell-to-open", 104, "sell-to-open"),
            ("sell-to-close", 105, "sell-to-close"),
            ("move-shares-in", 210, "move-shares-in"),
            ("move-shares-out", 211, "move-shares-out"),
            ("transfer-shares", 212, "transfer-shares"),
            ("split-shares", 250, "split-shares"),
            ("investment-income", 300, "investment-income"),
            ("dividend", 301, "dividend"),
            ("cap-gains-short", 302, "cap-gains-short"),
            ("cap-gains-long", 303, "cap-gains-long"),
            ("interest-income", 304, "interest-income"),
            ("return-of-capital", 310, "return-of-capital"),
        ]

        for (name, code, baseTypeName) in expected {
            #expect(TransactionRepository.transactionTypeBaseTypeCode(name) == code)
            #expect(TransactionRepository.transactionTypeBaseTypeName(code) == baseTypeName)
        }
    }
}
