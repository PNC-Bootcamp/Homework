// // // // // // // // // // // // // // // // // // // // // // // // // // //
// KotlinFundamentals_Starter.kt
// Module 10 — Kotlin Programming Fundamentals
// Module Exercise: PNC Mobile Kotlin Fundamentals Exercise
// // // // // // // // // // // // // // // // // // // // // // // // // // //

@file:DependsOn("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
import kotlinx.coroutines.*

// // // // // // // // // // // // // // // // // // // // // // // // // // //
// SCENARIO
// Create an Account model and a few small behaviors in idiomatic Kotlin. 
// This exercise runs entirely as a plain Kotlin file — 
// no Android Studio or Android project needed.
// // // // // // // // // // // // // // // // // // // // // // // // // // // 

// // // // // // // // // // // // // // // // // // // // // // // // // // //
// YOUR TASKS (five TODOs below)
// 1. Model Account as a Kotlin data class.
// 2. Write a sealed class TransferResult with Success and Failure cases, and
//    a function that handles both exhaustively with `when`.
// 3. Write an extension function Double.asCurrency() for formatted balance
//    display.
// 4. Write a suspend function that simulates fetching accounts with a
//    delay(), called from a coroutine in main().
// 5. Use filter, map, and sumOf to compute total balance and flag overdraft
//    accounts from a List<Account>.
// // // // // // // // // // // // // // // // // // // // // // // // // // //
    
// // // // // // // // // // // // // // // // // // // // // // // // // // //
// Run this file directly (it has a `fun main()`) once all five TODOs are
// complete.
// // // // // // // // // // // // // // // // // // // // // // // // // // //


// // // // // // // // // // // // // // // // // // // // // // // // // // //
// MARK: TODO 1 — Account data class
// Define a data class named Account with: id (String), name (String),
// balance (Double).

data class Account (
    val id: String,
    val name: String,
    val balance: Double
)

// // // // // // // // // // // // // // // // // // // // // // // // // // //
// MARK: TODO 2 — TransferResult sealed class
// Define a sealed class named TransferResult with two nested data classes:
// Success(val confirmationId: String) and Failure(val reason: String).
// Then write a function:
//   fun describe(result: TransferResult): String
// that uses `when` to handle both cases exhaustively, returning a
// human-readable message for each.

sealed class TransferResult {
    data class Success(val confirmationID: String): TransferResult()
    data class Failure(val reason: String): TransferResult()
}

fun describe(result: TransferResult): String = 
    when(result) {
        is TransferResult.Success -> result.confirmationID
        is TransferResult.Failure -> result.reason
    }


// // // // // // // // // // // // // // // // // // // // // // // // // // //
// MARK: TODO 3 — Double.asCurrency() extension function
// Write: fun Double.asCurrency(): String
// that formats a Double as a dollar amount, e.g. 4281.16 -> "$4281.16"

fun Double.asCurrency(): String = "$%.2f".format(this)

// // // // // // // // // // // // // // // // // // // // // // // // // // //
// MARK: TODO 4 — suspend function simulating a network fetch
// Write: suspend fun fetchAccounts(): List<Account>
// It should call delay(500) to simulate network latency, then return a
// hard-coded list of at least three Account values — include at least one
// with a negative balance so TODO 5 has something to find.

suspend fun fetchAccounts(): List<Account> {
    println("Fetching accounts...")
    delay(500)
    println("Fetching complete!")
    return listOf(
        Account("CA-123", "Checking", -750.0), 
        Account("SA-123", "Savings", 10000.0), 
        Account("CC-123", "Credit", 1200.0)
    )
    
}

// // // // // // // // // // // // // // // // // // // // // // // // // // //
// MARK: TODO 5 — collection operations
// Inside fun main() below, after calling fetchAccounts():
//   - use .filter { } to find accounts with a negative balance
//   - use .sumOf { } to compute the total balance across all accounts
//   - print both, using your asCurrency() extension from TODO 3

fun main() = runBlocking {
    // TODO: call fetchAccounts(), then complete TODO 5's collection
    // operations here.
    
    val accounts = fetchAccounts()
    
    val negBal = accounts
        .filter { it.balance < 0 }

    val totalBal = accounts
        .sumOf { it.balance }
    
    println("Accounts with a negative balance:")
    negBal.forEach {
        println("Account #${it.id} - ${it.name}: ${it.balance.asCurrency()}")
    }
    
    accounts.forEach {
        println("Account Type: ${it.name}\t| Account #${it.id}:\t${it.balance.asCurrency()}")
    }
    println("Total balance between accounts:\t\t\t${totalBal.asCurrency()}")
    
}


main()