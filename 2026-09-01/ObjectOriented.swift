// ============================================================
// EXERCISE: Structs — Value Types
// Estimated time: 20 minutes
//
// Structs in Swift are MUCH more powerful than in C.
// They can have methods, computed properties, and protocol conformance.
// The key rule: assignment COPIES a struct. Two variables never
// share the same struct instance.
// ============================================================

import Foundation

let maxLineLen = 120

func div() {
    print(String(repeating: "-", count: maxLineLen))
}

let myName = "Tyler Swindell"
let headerBuffer = String(repeating: "=", count: 10)

let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .short

var components = DateComponents()
components.year = 2026
components.month = 09
components.day = 02
components.hour = 9
let dueDate = Calendar.current.date(from: components)!
let formattedDueDate = "Due Date: \(formatter.string(from: dueDate))"

let headerFill = String(repeating: "=", count: maxLineLen-myName.count-(headerBuffer.count*2)-formattedDueDate.count-4)

div()
print("\(headerBuffer) \(myName) \(headerBuffer) \(formattedDueDate) \(headerFill)")
div()

// 3a: Define a struct named Transaction with these stored properties:
//   id: String
//   date: Date
//   amount: Double
//   description: String
//   isDebit: Bool
//
// Add these computed properties:
//   formattedAmount: String
//     → returns "-$250.00" if isDebit, "+$250.00" if credit
//     → use String(format: "%.2f", abs(amount))
//
//   formattedDate: String
//     → use DateFormatter with dateStyle: .medium, timeStyle: .none
//
// Add a memberwise initializer (Swift gives you this FREE for structs —
// you do not need to write init() unless you want custom behavior).
struct Transaction {
    let id: String
    let date: Date
    let amount: Double
    var description: String
    let isDebit: Bool
    var isPending: Bool = false
    var formattedAmount: String {
        return "\(isDebit ? "-" : "+")$\(String(format: "%.2f", abs(amount)))"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    mutating func markAsPending() {
        isPending = true
    }
}

// 3b: Create two Transaction instances:
//   t1: a credit of $2,500.00 described as "Direct Deposit"
//   t2: a debit of $45.67 described as "Starbucks"
// Print their formattedAmount and description.
let t1 = Transaction(
    id: "1",
    date: Date(),
    amount: 2500.00,
    description: "Direct Deposit",
    isDebit: false
)

var t2 = Transaction(
    id: "2",
    date: Date(),
    amount: 45.67,
    description: "Starbucks",
    isDebit: true
)

print("\(t1.formattedAmount) \(t1.description)")
print("\(t2.formattedAmount) \(t2.description)")

div()

// 3c: Prove value semantics
// Assign t1 to a new variable t3.
// Try to change t3.description to "Modified".
// What happens? Why?
// Fix it by declaring t3 with var instead of let.
// Then change t3.description and print both t1.description and t3.description.
// Observe that t1 is unchanged. This is the key difference from classes.
var t3 = t1
t3.description = "Modified"
print("T1 Desc: \(t1.description) | T3 Desc: \(t3.description)")

// 3d: Add a mutating method to Transaction named markAsPending
// that sets a new stored property isPending: Bool = false to true.
// Call it on t2 and verify.

t2.markAsPending()
print("Is pending?: \(String(t2.isPending).capitalized)")

div()

// ============================================================
// EXERCISE: Classes — Reference Types
// Estimated time: 20 minutes
//
// Classes add: inheritance, reference semantics (assignment shares
// the same object), and deinitializers.
// Use classes for: managers, services, view controllers — things
// that have IDENTITY and LIFECYCLE, not just data.
// ============================================================

// TODO 4a: Define a class named BankAccount with:
//   Stored properties:
//     id: String
//     accountNumber: String
//     balance: Double
//     owner: String
//
//   A designated initializer: init(id:accountNumber:owner:initialBalance:)
//   where initialBalance has a default of 0.0
//
//   Methods:
//     deposit(amount: Double) — adds to balance if amount > 0
//     withdraw(amount: Double) -> Bool — subtracts if amount > 0 and <= balance; returns success
//     printSummary() — prints "Account [accountNumber] | Owner: [owner] | Balance: $X.XX"

class BankAccount {
    let id: String
    let accountNumber: String
    var balance: Double
    let owner: String

    init(id: String, accountNumber: String, initialBalance: Double = 0.0, owner: String) {
        self.id = id
        self.accountNumber = accountNumber
        self.balance = initialBalance
        self.owner = owner
    }

    func deposit(amount: Double) {
        guard amount > 0 else {
            return
        }
        balance += amount

    }

    func withdraw(amount: Double) -> Bool {
        guard amount > 0, amount <= balance else {
            return false
        }

        balance -= amount

        return true
    }

    func printSummary() {
        print("Account \(accountNumber) | Owner: \(owner) | Balance: $\(balance)")
    }

}

// TODO 4b: Create two BankAccount instances:
//   checking: id "`acc_001`", accountNumber "1234567890", owner "Jane Smith", balance 1_000.00
//   savings:  id "acc_002", accountNumber "0987654321", owner "Jane Smith", balance 5_000.00
// Call deposit and withdraw on checking. Print summaries for both.
let checking = BankAccount(id: "acc_001", accountNumber: "1234567890", initialBalance: 1_000.00, owner: "Jane Smith")
let savings = BankAccount(id: "acc_002", accountNumber: "0987654321", initialBalance: 5_000.00, owner: "Jane Smith")

let isWithdrawn = checking.withdraw(amount: 487.12)
checking.deposit(amount: 2_500.00)

checking.printSummary()
savings.printSummary()

div()

// TODO 4c: Prove reference semantics
// Assign checking to a new variable checkingRef.
// Call checkingRef.deposit(amount: 500)
// Print checking.balance and checkingRef.balance.
// Observe they are THE SAME object — both show the updated balance.
// Write a comment explaining why this is different from the struct in 3c.
let checkingRef = checking
checkingRef.deposit(amount: 500)
print("Checking: \(checking.balance) | Ref: \(checkingRef.balance)")

div()

// BankAccount is a Class which is passed by reference, meaning checking and checkingRef are pointing to the same 
// location in memory
// --
// Transaction in exercise 3 is a Struct which is passed by value, meaning the a copy of the data in memory is created 
// in the new variable/constant

// TODO 4d: Inheritance
// Define a class PremiumBankAccount that inherits from BankAccount.
// Add a stored property overdraftLimit: Double
// Override withdraw(amount:) so that withdrawal succeeds if
// amount <= balance + overdraftLimit (draws from overdraft if needed).
// Add a convenience initializer that takes the same params as BankAccount
// plus overdraftLimit.
//
// Test it: create a premium account with balance 100 and overdraftLimit 500.
// Withdraw 400 — should succeed (draws on overdraft).
// Withdraw 800 — should fail (exceeds balance + overdraftLimit).

class PremiumBankAccount: BankAccount {
    let overdraftLimit: Double

    init(id: String, accountNumber: String, initialBalance: Double = 0.0, owner: String, overdraftLimit: Double) {
        self.overdraftLimit = overdraftLimit
        super.init(id: id, accountNumber: accountNumber, initialBalance: initialBalance, owner: owner)
    }

    convenience override init(id: String, accountNumber: String, initialBalance: Double = 0.0, owner: String) {
        self.init(
            id: id,
            accountNumber: accountNumber,
            initialBalance: initialBalance,
            owner: owner,
            overdraftLimit: 0.0
        )
    }

    override func withdraw(amount: Double) -> Bool {
        guard amount > 0, amount <= balance + overdraftLimit else {
            return false
        }
        balance -= amount
        return true
    }
}

let pba1 = PremiumBankAccount(
    id: "pba1",
    accountNumber: "123456",
    initialBalance: 100,
    owner: "Tyler",
    overdraftLimit: 500
)

print("Withdraw 1: \(pba1.withdraw(amount: 400) ? "Succeeded" : "Failed")")
print("Withdraw 2: \(pba1.withdraw(amount: 800) ? "Succeeded" : "Failed")")

div()

// ============================================================
// EXERCISE: Enumerations
// Estimated time: 15 minutes
//
// Swift enums are the richest in any mainstream language.
// They can carry associated values — meaning each case can
// store different data. This replaces many patterns where
// Python/JS developers would use a dict or tuple.
// ============================================================

// 5a: Define an enum TransactionType with cases:
//   credit, debit, transfer, fee
// Make it conform to String and CaseIterable:
//   enum TransactionType: String, CaseIterable
enum TransactionType: String, CaseIterable {
    case credit
    case debit
    case transfer
    case fee

// 5b: Add a computed property displayName: String to TransactionType
// using a switch that returns:
//   credit   → "Credit"
//   debit    → "Debit"
//   transfer → "Transfer"
//   fee      → "Fee"

    var displayName: String {
        switch self {
        case .credit: return "Credit"
        case .debit: return "Debit"
        case .transfer: return "Transfer"
        case .fee: return "Fee"
        }
    }

}

// 5c: Enum with associated values
// Define an enum AccountError with these cases:
//   insufficientFunds(available: Double, requested: Double)
//   accountInactive
//   dailyLimitExceeded(limit: Double)
//   invalidAmount
//
// Write a function describeError(_ error: AccountError) -> String
// that uses a switch with associated value binding to return
// a user-friendly message for each case.
// Test it with all four cases.

enum AccountError {
    case insufficientFunds(available: Double, requested: Double)
    case accountInactive
    case dailyLimitExceeded(limit: Double)
    case invalidAmount
}

func describeError(_ error: AccountError) -> String {
    switch error {
    case .insufficientFunds(let available, let requested):
        return "Insufficient funds: you requested $\(requested) but only $\(available) is available."
    case .accountInactive:
        return "This account is inactive."
    case .dailyLimitExceeded(let limit):
        return "Daily limit exceeded: the maximum is $\(limit)."
    case .invalidAmount:
        return "Invalid amount. Please enter a positive value."
    }
}

// TODO 5d: Iterate over all cases
// Using CaseIterable on TransactionType, print all transaction types
// and their raw values:
// for type in TransactionType.allCases { print(...) }
// Expected:
//   credit → "credit"
//   debit → "debit"
//   etc.
print(describeError(.insufficientFunds(available: 100, requested: 250)))
print(describeError(.accountInactive))
print(describeError(.dailyLimitExceeded(limit: 1000)))
print(describeError(.invalidAmount))
