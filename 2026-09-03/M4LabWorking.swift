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

// 3B: Define class BankAccount
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

    var displayName: String { self.nickname ?? self.accountType.capitalized }
    var maskedAccountNumber: String { "****" + self.accountNumber.suffix(4) }
    var summary: String { "" }
    var formattedBalance: String { "$\(String(format: "%.2f", self.balance))" }

    var recentTransactions: [Transaction] { [] }

    var pendingCount: Int { 0 }

    func deposit(amount: Double) throws -> String {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard self.isActive else {throw AccountOperationsError.accountInactive}
        self.balance += amount
        return "Deposited $\(amount) | New Balance: $\(self.balance)"
    }

    func withdraw(amount: Double) throws -> String {
        guard amount > 0 else { throw AccountOperationsError.invalidAmount }
        guard amount <= self.balance else {
            throw AccountOperationsError.insufficientFunds(available: self.balance, required: amount)
        }
        guard self.isActive else {throw AccountOperationsError.accountInactive}
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

    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        if transaction.type.isExpense { balance -= transaction.amount
        } else { balance += transaction.amount }

        availableBalance = balance
    }
}

// ============================================================
// SECTION 4: Protocols
// ============================================================

// 4A: Summarizable protocol
protocol Summarizable { var summary: String { get } }
extension Summarizable { func printSummary() { print(summary) } }

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
// 5A: AnalyticsProvider protocol
protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }         // credits - debits
    var largestTransaction: Transaction? { get }
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

// 5B: AccountAnalytics struct
struct AccountAnalytics: AnalyticsProvider {
    var transactions: [Transaction] = []
    var totalCredits: Double { transactions.filter { !$0.type.isExpense }.reduce(0) { $0 + $1.amount } }
    var totalDebits: Double { transactions.filter { $0.type.isExpense }.reduce(0) { $0 + $1.amount } }
    var netFlow: Double { totalCredits - totalDebits }
    var largestTransaction: Transaction? { transactions.max(by: { $0.amount < $1.amount }) ?? nil }

    func monthlyTotal(month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        return transactions
            .filter { transaction in
                let components = calendar.dateComponents([.year, .month], from: transaction.date)
                return components.year == year && components.month == month && transaction.type.isExpense
            } .reduce(0) { $0 + $1.amount }
    }

    func transactionsByCategory() -> [String: [Transaction]] {
        Dictionary(grouping: transactions, by: { $0.resolvedCategory })
    }
}

// ============================================================
// SECTION 6: Generic Result Reporter
// ============================================================

// 6: Write a generic function
func reportResults<T: Summarizable>(_ items: [T], title: String) {
    items.forEach { item in
        print("=== [title] ===\nItems: \(items.count)")
        item.printSummary()
        print("=== End of [title] ===")
    }
}

// ============================================================
// SECTION 7: INTEGRATION TEST — Tie it all together
// ============================================================

// 7: Write a function named runlabDemo() that does the following:
func runlabDemo() {
    div("SECTION 7: Integration Test")

    // 7A: Create at least two BankAccount instances:
    let checkingAccount = BankAccount(
        id: "1",
        accountNumber: "12341234",
        accountType: "Checking",
        nickname: "Everyday Checking",
        initialBalance: 3_500.00,
    )

    let savingsAccount = BankAccount(
        id: "2",
        accountNumber: "99999999",
        accountType: "Savings",
        nickname: "Emergency Fund",
        initialBalance: 12_000.00,
    )

    // 7B: Create at least five Transaction instances across different types
    div("Adding Transactions")

    let credit = Transaction(date: Date(), amount: 1_200.00, description: "Paycheck", type: .credit)
    checkingAccount.addTransaction(credit)
    print("After credit     → \(checkingAccount.formattedBalance)")

    let debit1 = Transaction(date: Date(), amount: 85.50, description: "Groceries", type: .debit, category: "Food")
    checkingAccount.addTransaction(debit1)
    print("After debit1     → \(checkingAccount.formattedBalance)")

    let debit2 = Transaction(date: Date(), amount: 42.00, description: "Gas", type: .debit, category: "Transportation")
    checkingAccount.addTransaction(debit2)
    print("After debit2     → \(checkingAccount.formattedBalance)")

    let fee = Transaction(
        date: Date(), amount: 5.00, description: "Monthly maintenance fee",
        type: .fee, category: "Fees"
    )
    checkingAccount.addTransaction(fee)
    print("After fee        → \(checkingAccount.formattedBalance)")

    let transfer = Transaction(date: Date(), amount: 500.00, description: "Transfer to Savings", type: .transfer)
    checkingAccount.addTransaction(transfer)
    print("After transfer   → \(checkingAccount.formattedBalance)")

    // 7C: Demonstrate error handling:
    div("Error Handling")

    do { _ = try checkingAccount.withdraw(amount: 999_999)
    } catch let err as AccountOperationsError { print(err.localizedDescription) } catch { print(error) }

    do { _ = try checkingAccount.deposit(amount: -50)
    } catch let err as AccountOperationsError { print(err.localizedDescription) } catch { print(error) }

    do { _ = try savingsAccount.transfer(amount: 10, to: savingsAccount)
    } catch let err as AccountOperationsError { print(err.localizedDescription) } catch { print(error) }

    // 7D: Create an AccountAnalytics instance with the checking account's transactions.
    div("Analytics")

    let analytics = AccountAnalytics(transactions: checkingAccount.transactions)
    print("Total credits: \(analytics.totalCredits)")
    print("Total debits: \(analytics.totalDebits)")
    print("Net flow: \(analytics.netFlow)")

    if let largest = analytics.largestTransaction {
        print("Largest transaction: \(largest.description) — \(largest.formattedAmount)")
    }

    for (category, categoryTransactions) in analytics.transactionsByCategory() {
        print("\(category): \(categoryTransactions.count)")
    }

    // 7E: Call reportResults with the checking account's transactions, title: "Checking Transactions"
    div("Reports")

    reportResults(checkingAccount.transactions, title: "Checking Transactions")
    reportResults([checkingAccount, savingsAccount], title: "All Accounts")

    // 7F: Demonstrate value vs. reference semantics:
    div("Value vs. Reference Semantics")

    var transactionCopy = credit
    transactionCopy.status = .cancelled
    print("Original status: \(String(describing: credit.status))")
    print("Copy status: \(String(describing: transactionCopy.status))")

    let checkingAlias = checkingAccount
    do { _ = try checkingAlias.deposit(amount: 100)
    } catch { print(error) }
    print("checkingAccount balance: \(checkingAccount.formattedBalance)")
    print("checkingAlias balance: \(checkingAlias.formattedBalance)")
}

runlabDemo()
