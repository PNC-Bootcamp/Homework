//
// AccountListScreen_Starter.kt
// Module 12 — Android UI Development
// Lab Exercise: PNC Mobile — Accounts List Screen (Jetpack Compose)
//
// SCENARIO
// Build the accounts list screen for PNC Mobile Android — the final screen
// for Module 12. This exercise pulls together state (Block 1), navigation
// (Block 3), LazyColumn (Block 4), accessibility (Block 6), and animation
// (Block 7).
//
// REQUIREMENTS
// 1. Build AccountListScreen using LazyColumn and Material 3 components.
// 2. Each row shows account name, masked account number, and balance.
// 3. Tapping a row calls onAccountClick(accountId) — wiring this to actual
//    Navigation Compose is assumed to happen in a NavHost elsewhere (not
//    part of this file).
// 4. Every row must be fully readable by TalkBack as ONE combined element,
//    not three separate announcements.
// 5. Add an AnimatedVisibility confirmation banner that appears briefly
//    after a simulated refresh (a button that toggles a "Refreshed!"
//    message is sufficient to demonstrate this).
//
// The Account model below is complete. Implement the two TODOs.
//

package com.tylerswindell.jetpackcomposedemos.homework

import android.annotation.SuppressLint
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tylerswindell.jetpackcomposedemos.ui.theme.KazooTheme

// MARK: - Model (complete — no changes needed)

data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

val sampleAccounts = listOf(
    Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
    Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
    Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
)

// MARK: - TODO 1: AccountListScreen

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun AccountListScreen(accounts: List<Account>, onAccountClick: (String) -> Unit) {
    // TODO: Show a "Refresh" button. When tapped, set a boolean state to
    // true, then use AnimatedVisibility to show a "Refreshed!" confirmation
    // banner (fadeIn/fadeOut) above the list.
    //
    // Below the banner, use a LazyColumn with items(accounts, key = { it.id })
    // to render an AccountRow for each account.

    var refreshed by remember { mutableStateOf(false) }

    Scaffold() { paddingValues ->


        Column( modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 8.dp) ) {
            Button(onClick = { refreshed = true }) { Text("Refresh") }

            AnimatedVisibility(
                visible = refreshed,
                enter = fadeIn() + expandVertically(expandFrom = Alignment.Top),
                exit = fadeOut() + shrinkVertically(shrinkTowards = Alignment.Top)
            ) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(bottom = 8.dp)
                        .align(Alignment.CenterHorizontally),

                ) { Text("Refreshed!", modifier = Modifier.padding(16.dp)) }
            }

            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
            ) {
                items( items = accounts, key = { it.id }) {
                    AccountRow(account = it, onClick = { onAccountClick(it.id) } )
                }
            }
        }
    }
}

// MARK: - TODO 2: AccountRow

@Composable
fun AccountRow(account: Account, onClick: () -> Unit) {
    // TODO: Lay out account.name, account.maskedNumber, and account.balance
    // in a Row/Column combination. Use MaterialTheme.typography styles only
    // — no hard-coded font sizes. Add
    // Modifier.semantics(mergeDescendants = true) {} and a single,
    // readable contentDescription for the whole row.

    val description = "${account.name}, account ${account.maskedNumber}, balance ${account.balance}"
    Card (
        modifier = Modifier
            .padding(4.dp)
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .semantics(mergeDescendants = true) { contentDescription = description }
    ) {

        Column( modifier = Modifier
            .padding(16.dp)
            .fillMaxWidth() ) {
            Text( text = account.name,  style = MaterialTheme.typography.titleMedium)
            Text("$${account.balance}", modifier = Modifier.align(Alignment.End))
            Text(account.maskedNumber)
        }
        }
}
@Preview(showBackground = true)
@Composable
fun AccountListScreenPreview() {
    KazooTheme() {
        AccountListScreen(
            accounts = sampleAccounts,
            onAccountClick = {}
        )
    }
}