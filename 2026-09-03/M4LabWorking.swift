import Foundation

func div(_ message: String = "", _ symbol: String = "=", _ lineLength: Int = 120) {
    let msg = message.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? "" : " \(message) "
    let msgLen = msg.count
    let halfDiv =  String(repeating: symbol, count: (lineLength-msgLen)/2)
    var div = "\(halfDiv)\(msg)\(halfDiv)"

    if div.count < lineLength {
        div = "\(div)\(symbol)"
    }

    print(div)
}

// ============================================================
// SECTION 1: Enumerations
// ============================================================

// 1A: TransactionType
enum TransactionType: String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee

    var isExpense: Bool {
        switch self {
        case .debit, .fee: return true
        default: return false
        }
    }
}

// 1B: TransactionStatus
enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
    case cancelled

    var isTerminal: Bool {
        switch self {
        case .completed, .failed, .cancelled: return true
        case .pending: return false
        }
    }
}

// ============================================================
// SECTION 2: Transaction Struct
// ============================================================

// 2: Define struct Transaction
struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {
    let date: Date
    let amount: Double // (always positive — type determines direction)
    let description: String
    let type: TransactionType
    let category: String?
    let merchantName: String?

    init(date: Date, amount: Double, description: String, type: TransactionType,
         status: TransactionStatus? = .completed, category: String? = nil, merchantName: String? = nil) {
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }

    var id: String = UUID().uuidString
    var status: TransactionStatus?
    var summary: String { "" }
    var formattedAmount: String { "\(type.isExpense ? "-" : "+")$\(String(format: "%.2f", amount))" }
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    var resolvedCategory: String { category ?? "Uncategorized" }
}

// ============================================================
// SECTION 3: Account Class
// ============================================================

// 3A: Define protocol AccountOperations

// TODO 3B: Define class BankAccount
class BankAccount: Identifiable, AccountOperations, Summarizable {
    let id: String
    let accountNumber: String
    let accountType: String          // (e.g., "CHECKING", "SAVINGS")
    let nickname: String?

    init(id: String, accountNumber: String, accountType: String, nickname: String?,
         initialBalance: Double, currency: String = "USD", isActive: Bool = true) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
    }

    var isActive: Bool
    let currency: String
    var balance: Double
    var availableBalance: Double
    var transactions: [Transaction] = []

    var displayName: String { self.nickname ?? accountType.capitalized }
    var maskedAccountNumber: String { "****" + self.accountNumber.suffix(4) }
    var summary: String { "" }
    var formattedBalance: String { "" }

    var recentTransactions: [Transaction] { [] }

    var pendingCount: Int { 0 }

    func deposit(amount: Double) throws -> String {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard isActive else {throw AccountOperationsError.accountInactive}
        self.balance += amount
        return "Deposited $\(amount) | New Balance: $\(self.balance)"
    }

    func withdraw(amount: Double) throws -> String {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard amount <= balance else { throw AccountOperationsError.insufficientFunds(available: self.balance, required: amount) }
        guard isActive else {throw AccountOperationsError.accountInactive}
        self.balance -= amount
        return "Withdrawn: $\(amount) | New Balance: $\(self.balance)"
    }

    func transfer(amount: Double, to destination: BankAccount) throws -> String {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard amount <= self.balance else {
            throw AccountOperationsError.insufficientFunds(available: self.balance, required: amount)
        }
        guard self.isActive, destination.isActive else { throw AccountOperationsError.accountInactive }
        guard self.id != destination.id else { throw AccountOperationsError.transferToSameAccount}
        self.balance -= amount
        return "Transfered $\(amount) → \(destination.maskedAccountNumber) | New Balance: $\(self.balance)"
    }
}

// ============================================================
// SECTION 4: Protocols
// ============================================================

// 4A: Summarizable protocol
protocol Summarizable { var summary: String { get } }
extension Summarizable { func printDetails() { print(summary) } }

// 4B: AccountOperations protocol
protocol AccountOperations {
    func deposit(amount: Double) throws -> String
    func withdraw(amount: Double) throws -> String
    func transfer(amount: Double, to destination: BankAccount) throws -> String
}

// 4C: AccountOperationsError enum conforming to LocalizedError
enum AccountOperationsError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)

    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "The amount must be greater than zero."
        case .insufficientFunds(available: let avail, required: let req):
            let formattedAvail = String(format: "%.2f", avail)
            let formattedReq = String(format: "%.2f", req)
            return "Insufficient funds! → Available: $\(formattedAvail) | Requested: $\(formattedReq)"
        case .accountInactive:
            return "You're account is currently inactive."
        case .transferToSameAccount:
            return "You must choose another account for the destination."
        case .dailyLimitExceeded(limit: let lim):
            return "This would exceed your daily limit of $\(String(format: "%.2f", lim))"
        }
    }
}

// ============================================================
// SECTION 5: Analytics
// ============================================================
// TODO 5A: AnalyticsProvider protocol

// TODO 5B: AccountAnalytics struct

// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

struct ErrorTest {
    let label: String
    let setup: () -> Void
    let action: () throws -> String
}

func runTests(_ tests: [ErrorTest]) {
    for test in tests {
        test.setup()
        do {
            let res = try test.action()
            print("\(test.label) → \(res)")
        } catch let err as AccountOperationsError {
            print("\(test.label) → \(err.localizedDescription)")
        } catch {
            print("\(test.label) → \(error)")
        }
    }
}

func sectionTwoTests() {
    div("Section 2 Tests")

    let test1 = Transaction(
        date: Date(),
        amount: 10.00,
        description: "cash deposit",
        type: .credit
    )

    print(test1)
    print(test1.resolvedCategory)
    print(test1.formattedAmount)
    print(test1.formattedDate)
}

func sectionThreeTests() {
    div("Section 3 Tests")

    let test2 = BankAccount(
        id: "acct-1",
        accountNumber: "String",
        accountType: "String",
        nickname: "String?",
        initialBalance: 0.0,
        currency: "String",
        isActive: true
    )
    let test3 = BankAccount(
        id: "acct-2",
        accountNumber: "String",
        accountType: "String",
        nickname: "String?",
        initialBalance: 0.0,
        currency: "String",
        isActive: true
    )

    print(test2)
    print(test2.availableBalance)
    print(test2.transactions)
    print(test2.displayName)
    print(test2.maskedAccountNumber)
    print(test2.summary)
    print(test2.formattedBalance)
    print(test2.recentTransactions)
    print(test2.pendingCount)

div("BankAccount.Deposit")
runTests([
    ErrorTest(label: "success", setup: { test2.isActive = true }) { try test2.deposit(amount: 100) },
    ErrorTest(label: "invalidAmount", setup: {}) { try test2.deposit(amount: 0) },
    ErrorTest(label: "accountInactive", setup: { test2.isActive = false }) { try test2.deposit(amount: 100) }
])

div("BankAccount.Withdraw")
runTests([
    ErrorTest(label: "success", setup: { test2.isActive = true }) { try test2.withdraw(amount: 10) },
    ErrorTest(label: "invalidAmount", setup: {}) { try test2.withdraw(amount: 0) },
    ErrorTest(label: "insufficientFunds", setup: {}) { try test2.withdraw(amount: 100) },
    ErrorTest(label: "accountInactive", setup: { test2.isActive = false }) { try test2.withdraw(amount: 10) }
])

div("BankAccount.Transfer")
runTests([
    ErrorTest(label: "success", setup: { test2.isActive = true }) { try test2.transfer(amount: 10, to: test3) },
    ErrorTest(label: "invalidAmount", setup: {}) { try test2.transfer(amount: 0, to: test3) },
    ErrorTest(label: "insufficientFunds", setup: {}) { try test2.transfer(amount: 100, to: test3) },
    ErrorTest(label: "transferToSameAccount", setup: {}) { try test2.transfer(amount: 10, to: test2) },
    ErrorTest(label: "accountInactive", setup: { test2.isActive = false }) { try test2.transfer(amount: 10, to: test3) }
])

}

func tests() {
    sectionTwoTests()
    sectionThreeTests()
}

tests()
