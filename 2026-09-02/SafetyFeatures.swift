// swiftlint:disable large_tuple
// ============================================================
// MODULE 4: Swift Programming Fundamentals
// Day 3 Exercises — Protocols, ARC, Optionals, Error Handling
// Enterprise Mobile Application Development Bootcamp
// ============================================================
//
// Day 3 covers Swift's safety features — the ones that make
// iOS code reliable at enterprise scale. These concepts also
// directly underpin everything you will build in Modules 7–9.
//
// Part A: Protocols and Protocol-Oriented Programming
// Part B: Automatic Reference Counting (ARC) and memory safety
// Part C: Optionals — deep dive beyond the Day 1 preview
// Part D: Typed error handling
// Part E: Generics introduction
// ============================================================

import Foundation

let maxLineLen = 120
func div(_ message: String = "", _ symbol: String = "=") {
    let msg = message.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "" : " \(message) "
    let msgLen = msg.count
    let halfDiv =  String(repeating: symbol, count: (maxLineLen-msgLen)/2)
    var div = "\(halfDiv)\(msg)\(halfDiv)"
    if div.count < 120 {
        div = "\(div)-"
    }
    print(div)
}

// ============================================================
// PART A: PROTOCOLS
// ============================================================

// ============================================================
// EXERCISE 1: Defining and Adopting Protocols
// Estimated time: 20 minutes
//
// A protocol is a contract. Any type that says it conforms to
// a protocol MUST implement everything the protocol requires.
// This is Swift's primary mechanism for polymorphism —
// preferred over inheritance for most use cases.
//
// Python equivalent: Abstract Base Classes (abc.ABC)
// JS equivalent: TypeScript interfaces (but enforced at compile time)
// ============================================================

div("EXERCISE 1")

// 1a: Define a protocol named Displayable with:
div("1a", "-")
//   - A computed property: displayDescription: String  (get only)
//   - A method: printDetails()

protocol Displayable {
    var displayDescription: String { get }
    func printDetails() -> Void
}

// 1b: Add a default implementation of printDetails() via a
div("1b", "-")
// protocol extension. The default should just print displayDescription.
// This means conforming types do NOT need to implement printDetails()
// unless they want custom behavior.

extension Displayable {
    func printDetails() {
        print(displayDescription)
    }
}

// 1c: Make Transaction (from ObjectOriented.swift) conform to Displayable.
div("1c", "-")
// Paste your Transaction struct below and add ": Displayable".
// Implement displayDescription to return:
//   "[date] [description]: [formattedAmount]"
// e.g. "Jan 15, 2024 Direct Deposit: +$2500.00"
//
// Test it: create a transaction and call printDetails().

struct Transaction: Displayable {
    let id: String
    let date: Date
    let amount: Double
    var description: String
    let isDebit: Bool
    var isPending: Bool = false
    var formattedAmount: String {
        return "\(isDebit ? "-" : "+")$\(String(format: "%.2f", abs(amount)))"
    }
    var displayDescription: String {
        return "\(date) \(description): \(formattedAmount)"
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

let t1 = Transaction(
    id: "1",
    date: Date(),
    amount: 2500.00,
    description: "Direct Deposit",
    isDebit: false
)

t1.printDetails()

// 1d: Protocol as a type
div("1d", "-")
// Write a function named printAll(items: [Displayable]) that iterates
// the array and calls printDetails() on each item.
// Create an array containing at least two Transaction instances and
// pass it to printAll().
//
// The power: printAll doesn't know or care that the items are Transactions.
// Any future type that conforms to Displayable works automatically.

func printAll(_ items: [Displayable]) {
    items.forEach { item in
        item.printDetails()
    }
}

printAll([t1, Transaction(
    id: "2",
    date: Date(),
    amount: 45.67,
    description: "Starbucks",
    isDebit: true
)])

// ============================================================
// EXERCISE 2: Protocol-Oriented Design with Dependency Injection
// Estimated time: 20 minutes
//
// This pattern will appear in EVERY module from here forward.
// A protocol defines what a dependency does.
// Concrete types implement how it does it.
// The caller only knows about the protocol — never the concrete type.
// This is how we make code testable without a network.
// ============================================================

div("EXERCISE 2")

// 2a: Define a protocol named AccountDataSource with:
div("2a", "-")
//   func fetchBalance(for accountId: String) -> Double
//   func fetchTransactionCount(for accountId: String) -> Int

protocol AccountDataSource {
    func fetchBalance(for accountId: String) -> Double
    func fetchTransactionCount(for accountId: String) -> Int
}

// 2b: Create a struct MockAccountDataSource that conforms to
div("2b", "-")
// AccountDataSource and returns hardcoded values:
//   fetchBalance: always returns 4_250.75
//   fetchTransactionCount: always returns 47

struct MockAccountDataSource: AccountDataSource {
    func fetchBalance(for accountId: String) -> Double { return 4_250.75 }
    func fetchTransactionCount(for accountId: String) -> Int { return 47 }
}

// 2c: Create a struct LiveAccountDataSource that conforms to
div("2c", "-")
// AccountDataSource and simulates real behavior:
//   fetchBalance: returns a random Double between 100 and 50_000
//   fetchTransactionCount: returns a random Int between 1 and 500
//   Hint: Double.random(in: 100...50_000)

struct LiveAccountDataSource: AccountDataSource {
     func fetchBalance(for accountId: String) -> Double { return Double.random(in: 100...50_000) }
     func fetchTransactionCount(for accountId: String) -> Int { return Int.random(in: 1...500) }
}

// 2d: Write a class AccountDashboard that:
div("2d", "-")
//   - Has a stored property dataSource: AccountDataSource (the PROTOCOL — not a concrete type)
//   - Has an init(dataSource: AccountDataSource)
//   - Has a method showSummary(for accountId: String) that prints:
//       "Account [accountId]: Balance $X.XX | Transactions: N"
//
// Create two AccountDashboard instances — one with MockAccountDataSource,
// one with LiveAccountDataSource. Call showSummary on both.
// The showSummary method is IDENTICAL for both — only the data source differs.
// This is the dependency injection pattern you'll use throughout the bootcamp.

class AccountDashboard {
    let dataSource: AccountDataSource

    init (dataSource: AccountDataSource) {
        self.dataSource = dataSource
    }

    func showSummary(for accountId: String) {
        print("Account \(accountId): Balance $X.XX | Transactions: N")
    }
}

let ad1: AccountDashboard = AccountDashboard(dataSource: MockAccountDataSource())
let ad2: AccountDashboard = AccountDashboard(dataSource: LiveAccountDataSource())

ad1.showSummary(for: "1nt13")
ad2.showSummary(for: "2fdsdfaf33")

// ============================================================
// PART B: AUTOMATIC REFERENCE COUNTING
// ============================================================

// ============================================================
// EXERCISE 3: Retain Cycles and weak References
// Estimated time: 20 minutes
//
// ARC tracks how many things are pointing to each object.
// When the count reaches 0, Swift deallocates the memory.
// A retain cycle occurs when two objects hold STRONG references
// to each other — neither ever reaches 0, so neither is freed.
// This is a memory leak.
// ============================================================

div("EXERCISE 3")

// 3a: Create a retain cycle, then fix it.
div("3a", "-")
// Define two classes:

  class Customer {
      let name: String
      var account: Account?    // optional — set after initialization
      init(name: String) {
        self.name = name
      }
      deinit { print("Customer \(name) deallocated") }
  }

  class Account {
      let number: String
      weak var owner: Customer?     // THIS CREATES THE CYCLE
      init(number: String) {
        self.number = number
      }
      deinit { print("Account \(number) deallocated") }
  }

// Create instances in a do {} block (so they go out of scope):
  do {
      let customer = Customer(name: "Jane")
      let account = Account(number: "ACC-001")
      customer.account = account
      account.owner = customer
  }
// Run this. Do you see the deinit messages? You should NOT —
// because neither object is ever deallocated (retain cycle).
//
// Fix the cycle by making Account.owner a WEAK reference:
//   weak var owner: Customer?
// Run again. Now you should see both deinit messages.

// 3b: Capture lists in closures
div("3b", "-")
// Closures can also create retain cycles when they capture self strongly.
// Complete this class:

class TransactionProcessor {
    let accountId: String
    var onComplete: (() -> Void)?

    init(accountId: String) {
        self.accountId = accountId
    }

    deinit {
        print("TransactionProcessor \(accountId) deallocated")
    }

    func startProcessing() {
        // Assign a closure to onComplete that captures self WEAKLY.
        // The closure should print "Processing complete for [accountId]"
        // Use [weak self] capture list and guard let self = self inside.
        //
        // Syntax:
        onComplete = { [weak self] in
            guard let self = self else { return }
            print("Processing complete for \(self.accountId)")
        }
    }

    func complete() {
        onComplete?()
    }
}

// Test in a do {} block:
  do {
      let processor = TransactionProcessor(accountId: "ACC-001")
      processor.startProcessing()
      processor.complete()
  }
// You should see "Processing complete for ACC-001" followed by the deinit message.

// ============================================================
// PART C: OPTIONALS — DEEP DIVE
// ============================================================

// ============================================================
// EXERCISE 4: Safe Unwrapping Patterns
// Estimated time: 20 minutes
//
// Day 1 introduced optionals briefly. Now we go deep.
// Optional<T> is an enum: either .some(value) or .none
// Every unwrapping pattern is just sugar over this enum.
// ============================================================

div("EXERCISE 4")

// 4a: Optional chaining
div("4a", "-")
// You have this nested optional structure:
struct Address {
    let street: String
    let city: String
    let zip: String?    // zip can be absent
}

struct UserProfile {
    let name: String
    var address: Address?   // address can be absent
}

let user = UserProfile(name: "Jane Smith", address: Address(
    street: "123 Main St", city: "Columbus", zip: "43001"))
let userNoAddress = UserProfile(name: "Bob", address: nil)

// Use optional chaining to safely access the zip code.
// If the zip exists, print "ZIP: [zip]"
// If any step in the chain is nil, print "No ZIP available"
// Use nil coalescing ?? for the fallback.
//
// Hint: user.address?.zip ?? "No ZIP available"

print(user.address?.zip ?? "No ZIP available")
print(userNoAddress.address?.zip ?? "No ZIP available")

// 4b: if let with multiple bindings
div("4b", "-")
// Write a function named transfer(from sourceId: String?, to destId: String?, amount: Double?)
// Use a SINGLE if let to unwrap all three optionals at once.
// (Swift lets you chain multiple bindings with commas in one if let)
// If all are present and amount > 0, print:
//   "Transfer $X.XX from [sourceId] to [destId] approved"
// Otherwise print: "Transfer failed: missing required fields"

func transfer(from sourceId: String?, to destId: String?, amount: Double?) {
    if let sourceId = sourceId, let destId = destId, let amount = amount, amount > 0 {
        print("Transfer $X.XX from \(sourceId) to \(destId)] approved")
    } else {
        print("Transfer failed: missing required fields")
    }
}

transfer(from: "ACC-001", to: "ACC-002", amount: 500.0)     // approved
transfer(from: nil, to: "ACC-002", amount: 500.0)           // failed
transfer(from: "ACC-001", to: "ACC-002", amount: nil)       // failed

// 4c: Optional map and flatMap
div("4c", "-")
// Optionals have .map and .flatMap just like arrays.
// They apply a transformation only if the optional has a value.
let rawBalanceString: String? = "4250.75"
let rawInvalidString: String? = "abc"
let nilString: String? = nil

// Use optional .map to convert rawBalanceString to a formatted
// currency string IF it is non-nil AND parseable as a Double.
// Chain: rawBalanceString → Double? → formatted String?
// Hint: rawBalanceString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
// Print the result for all three strings.
// Expected:
//   rawBalanceString → Optional("$4250.75")
//   rawInvalidString → nil
//   nilString → nil

let formattedRawBalanceString = rawBalanceString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
print("rawBalanceString → \(formattedRawBalanceString ?? "nil")")
let formattedRawInvalidString = rawInvalidString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
print("rawInvalidString → \(formattedRawInvalidString ?? "nil")")
let formattedNilString = nilString.flatMap { Double($0) }.map { String(format: "$%.2f", $0) }
print("nilString → \(formattedNilString ?? "nil")")

// 4d: Force unwrap — when and ONLY when it's safe
div("4d", "-")
// There are exactly two situations where ! is acceptable:
//   1. URL literals you typed yourself (you KNOW they're valid)
//   2. IBOutlets (the storyboard guarantees they exist)
//
// Demonstrate the first:
let apiURL = URL(string: "https://api.pnc.com/v1")!
// This is safe because you WROTE the string. If it were user input, use if let.

// Write a comment explaining why you would NEVER write:
//   let userURL = URL(string: userInputString)!
// and what you would do instead.

print("Force unwrapping can cause a runtime error if the user inputs an invalid string")
print("Allowing a user unchecked input can lead to malicous activity from a bad actor")
print("Instead I would use an if-let to validate input and check for and handle nil input")

// Force unwrapping can cause a runtime error if the user inputs an invalid string
// Allowing a user unchecked input can lead to malicous activity from a bad actor
// Instead I would use an if-let to validate input and check for and handle nil input

// ============================================================
// PART D: TYPED ERROR HANDLING
// ============================================================

// ============================================================
// EXERCISE 5: Throwing Functions and Error Types
// Estimated time: 20 minutes
//
// Swift does NOT use exceptions like Python/Java.
// Instead: functions that can fail are marked throws.
// Callers MUST handle errors with do-catch or propagate with try?.
// The error types are DEFINED BY YOU — not the framework.
// This forces you to think about every failure mode up front.
// ============================================================

div("EXERCISE 5")

// 5a: Define a comprehensive error enum for a transfer operation.
div("5a", "-")
// Name it TransferError and conform to LocalizedError.
// Cases (with associated values where noted):
//   invalidAmount                    — amount <= 0
//   insufficientFunds(available: Double)
//   accountNotFound(id: String)
//   dailyLimitExceeded(limit: Double, attempted: Double)
//   networkUnavailable
//
// Implement var errorDescription: String? using a switch to return
// a user-facing message for each case.
enum TransferError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double)
    case accountNotFound(id: String)
    case dailyLimitExceeded(limit: Double, attempted: Double)
    case networkUnavailable

    // property getter method
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "The amount must be greater than zero."
        case .accountNotFound(id: let id):
            return "Account #\(id) not found."
        case .insufficientFunds(available: let avail):
            return "Insufficient funds. Available: $\(String(format: "%.2f", avail))"
        case .dailyLimitExceeded(limit: let lim, attempted: let attempted): 
            let fLim = String(format: "%.2f", lim)
            let fAttempted = String(format: "%.2f", attempted)
            return ("Daily transfer limit exceeded. Limit: $\(fLim), Attempted: $\(fAttempted)")
        case .networkUnavailable:
            return "Network unavailable. Please try again later."
        }
    }
}

// 5b: Write a throwing function:
div("5b", "-")
// func executeTransfer(amount: Double, fromBalance: Double, toAccountId: String,
//                      dailyUsed: Double, dailyLimit: Double) throws -> String
//
// Throw the appropriate TransferError for each condition:
//   amount <= 0                           → .invalidAmount
//   toAccountId.isEmpty                   → .accountNotFound(id: toAccountId)
//   amount > fromBalance                  → .insufficientFunds(available: fromBalance)
//   dailyUsed + amount > dailyLimit       → .dailyLimitExceeded(limit: dailyLimit, attempted: dailyUsed + amount)
//   (simulate network issue for a specific account id "ERR_NET") → .networkUnavailable
//
// On success, return: "Transfer of $X.XX to account [id] complete"
func executeTransfer(amount: Double, fromBalance: Double, toAccountId: String,
                     dailyUsed: Double, dailyLimit: Double) throws -> String {
    guard amount > 0 else {
        throw TransferError.invalidAmount
    }
    guard !toAccountId.isEmpty else {
        throw TransferError.accountNotFound(id: toAccountId)
    }
    guard amount <= fromBalance else {
        throw TransferError.insufficientFunds(available: fromBalance)
    }
    guard dailyUsed + amount < dailyLimit else {
        throw TransferError.dailyLimitExceeded(limit: dailyLimit, attempted: dailyUsed + amount)
    }
    guard toAccountId != "ERR_NET" else {
        throw TransferError.networkUnavailable
    }
    return "Transfer of $X.XX to account \(toAccountId) complete"
}

// 5c: Handle all error cases
div("5c", "-")
// Call executeTransfer five times — once for each error case and once for success.
// Use a do-catch block that handles each specific TransferError case.
// For each case, print the localized error description.

// let testCases: [(Double, Double, String, Double, Double)] = [
//     (amount: 0, fromBalance: 1_000, toAccountId: "1", dailyUsed: 0, dailyLimit: 10_000),            // invalidAmount
//     (amount: 1_500, fromBalance: 1_500, toAccountId: "", dailyUsed: 0, dailyLimit: 10_000),         // accountNotFound
//     (amount: 1_500, fromBalance: 1_000, toAccountId: "3", dailyUsed: 0, dailyLimit: 10_000),        // insufficientFunds
//     (amount: 1_500, fromBalance: 1_500, toAccountId: "4", dailyUsed: 9_000, dailyLimit: 10_000),    // dailyLimitExceeded
//     (amount: 1_500, fromBalance: 1_500, toAccountId: "ERR_NET", dailyUsed: 0, dailyLimit: 10_000),  // networkUnavailable
//     (amount: 1_500, fromBalance: 1_500, toAccountId: "6", dailyUsed: 0, dailyLimit: 10_000)         // success
// ]

for test in testCases {
    do { // invalidAmount
        print(test)
        // let result = try executeTransfer(test)
        // print(result)
    } catch let err as TransferError { print(err.localizedDescription) } catch { print(error) }
}

do { // invalidAmount
    let result1 = try executeTransfer(amount: 0, fromBalance: 1_000, toAccountId: "1",
                                      dailyUsed: 0, dailyLimit: 10_000)
    print(result1)
} catch let err as TransferError { print(err.localizedDescription) } catch { print(error) }

do {
    let result2 = try executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "",
                                      dailyUsed: 0, dailyLimit: 10_000)
    print(result2)
} catch let err as TransferError { print(err.localizedDescription) } catch { print(error) }

do {
    let result3 = try executeTransfer(amount: 1_500, fromBalance: 1_000, toAccountId: "3",
                                      dailyUsed: 0, dailyLimit: 10_000)
    print(result3)

} catch let err as TransferError { print(err.localizedDescription) } catch { print(error) }

do {
    let result4 = try executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "4",
                                      dailyUsed: 9_000, dailyLimit: 10_000)
    print(result4)
} catch let err as TransferError { print(err.localizedDescription) } catch { print(error) }

do {
    let result5 = try executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "ERR_NET",
                                      dailyUsed: 0, dailyLimit: 10_000)
    print(result5)
} catch let err as TransferError { print(err.localizedDescription) }

do {
    let result6 = try executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "6",
                                      dailyUsed: 0, dailyLimit: 10_000)
    print(result6)
} catch let err as TransferError { print(err.localizedDescription) }

// 5d: try? — silently converting failure to nil
div("5d", "-")
// Sometimes you don't need to know WHY something failed.
// Convert a throwing call to an optional with try?
//
// let result = try? executeTransfer(amount: -100, ...)
// result will be nil if it threw, or the String value if it succeeded.
// Print result using nil coalescing: result ?? "Transfer failed"
//
// Demonstrate both outcomes (success and failure).

let res1 = try? executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "ERR_NET",
                                dailyUsed: 0, dailyLimit: 10_000)

print(res1 ?? "Transfer Failed")

let res2 = try? executeTransfer(amount: 1_500, fromBalance: 1_500, toAccountId: "1",
                                dailyUsed: 0, dailyLimit: 10_000)
print(res2 ?? "Transfer Failed")

// ============================================================
// PART E: GENERICS — INTRODUCTION
// ============================================================

// ============================================================
// EXERCISE 6: Writing Generic Functions and Types
// Estimated time: 15 minutes
//
// Generics let you write one function or type that works with
// ANY type satisfying certain requirements. The alternative —
// writing separate versions for Int, Double, String, etc. —
// violates the DRY principle at the language level.
// ============================================================
div("EXERCISE 6")

// 6a: Write a generic function named printFirst<T>
div("6a", "-")
// that takes an array of any type T and prints the first element,
// or "Array is empty" if it has no elements.
// Test with: [Int], [String], [Double]
let ints = [3, 1, 7, 2]
let words = ["banana", "watermelon", "apple"]
let decimals = [1.123, 534.43, 2.7187]

func printFirst<T>(_ arr: [T]) {
    if let val = arr.first {
        print(val)
    }
}

printFirst(ints)
printFirst(words)
printFirst(decimals)

// 6b: Generic Stack
div("6b", "-")
// Implement a generic value type Stack<Element>:
//   - Private stored property: items: [Element] = []
//   - mutating func push(_ item: Element)
//   - mutating func pop() -> Element?   (returns nil if empty)
//   - var top: Element?                  (returns last element without removing)
//   - var isEmpty: Bool
//   - var count: Int
//
// Test with a Stack<Double> (a transaction amount history):
//   Push: 250.00, 45.67, 1200.00
//   Pop one off: should return 1200.00
//   Print top: should be 45.67
//   Print count: should be 2
struct Stack<T> {
    // arr of T type
    private var items: [T] = []

    mutating func push(_ item: T) {
        items.append(item)
    }

    mutating func pop() -> T? {
        return items.popLast()
    }

    var top: T? {
        return items.last
    }

    var isEmpty: Bool {
        return items.isEmpty
    }

    var count: Int {
        return items.count
    }
}

var tasks = Stack<Double>()

tasks.push(250.00)
tasks.push(45.67)
tasks.push(1200.00)
print(tasks.pop() ?? "Empty Stack")
print(tasks.top ?? "Empty Stack")
print(tasks.count)

// TODO 6c: Generic function with constraint
div("6c", "-")
// Write a function named findLargest<T: Comparable>
// that takes [T] and returns the largest element, or nil if empty.
// Test with: [Int], [Double], [String]
// Hint: collection.max()

// Generic Contraint, restrict the number of data types the generic will work with
func findLargest<T: Comparable>(_ arr: [T]) -> T? {
    return arr.max() ?? nil
}

print(findLargest(ints) ?? "Empty")
print(findLargest(decimals) ?? "Empty")
print(findLargest(words) ?? "Empty")
