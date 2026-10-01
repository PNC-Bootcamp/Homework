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

import android.R
import android.annotation.SuppressLint
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.selection.toggleable
import kotlinx.coroutines.delay
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.tylerswindell.jetpackcomposedemos.ui.theme.KazooTheme
import kotlinx.coroutines.delay
import kotlin.time.Duration.Companion.milliseconds

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

@OptIn(ExperimentalMaterial3Api::class)
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

    LaunchedEffect(refreshed) {
        if (refreshed) delay(2000.milliseconds)
        refreshed = false
    }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = {
            TopAppBar(
                title = {
                    Text("Accounts", style = MaterialTheme.typography.titleLarge)
                }
            )
        },
    ) { innerPadding ->

        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            Column(
                modifier = Modifier.fillMaxSize(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                LazyColumn(
                    modifier = Modifier.weight(1f),
                    contentPadding = PaddingValues(horizontal = 12.dp, vertical = 8.dp)
                ) {
                    items(items = accounts, key = { it.id }) { account ->
                        AccountRow(account = account, onClick = { onAccountClick(account.id) })
                    }
                }

                Button(
                    onClick = { refreshed = true },
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text("Refresh")
                }
            }

            // the banner
            AnimatedVisibility(
                visible = refreshed,
                enter = fadeIn() + slideInVertically { -it },
                exit = fadeOut() + slideOutVertically { -it },
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .padding(12.dp)
            ) {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer
                    ),
                    elevation = CardDefaults.cardElevation(defaultElevation = 6.dp)
                ) {
                    Text(
                        text = "Refreshed!",
                        style = MaterialTheme.typography.titleMedium,
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(25.dp),
                        textAlign = TextAlign.Center
                    )
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

    val description = "Account name ${account.name}, account ${account.maskedNumber}, balance ${account.balance}"
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