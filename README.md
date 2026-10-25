# HomeLoop

### CS310 Mobile Application Development — Group 20

HomeLoop is a Flutter application that brings shared shopping lists, kitchen inventory and household expenses together.

Developed as a course project at Sabancı University, the app is designed for students living together, couples and small families.

## Overview

People sharing a home often manage shopping, food and shared expenses in separate places. This can lead to duplicate purchases, forgotten food and confusion about who paid for what.

HomeLoop connects these tasks through a shared household workspace. Members will be able to manage a synchronised shopping list, track kitchen inventory and record shared expenses.

Once the core workflow works reliably, we plan to add receipt scanning, expiry reminders and recipe suggestions.

## Planned Features

### Core Features

- **Households and accounts**
  - Sign in, create a household or join using a 6-digit invitation code.
  - Let the household creator manage membership and select the household currency.

- **Shared shopping list**
  - Add, edit and check off items.
  - Synchronise changes across household members’ devices.
  - Record who purchased each item.

- **Kitchen inventory**
  - Manually enter item names, quantities, storage locations and expiry dates.
  - Mark items as consumed or discarded.
  - Add items back to the shopping list.
  - Track purchases with different expiry dates as separate batches.

- **Expenses and balances**
  - Record purchases and household bills.
  - Split expenses equally among household members.
  - Calculate balances and suggest transfers to reduce the number of payments.
  - Record completed settlements.

### Features Planned After the Core Workflow

- **Receipt scanning and review:** Extract item names and prices from receipt photos, then require users to review and confirm the results before saving.
- **Expiry reminders:** Notify members about inventory items approaching their recorded expiry dates.
- **Recipe suggestions:** Suggest recipes using available ingredients, prioritising items approaching expiry.

### Optional Extensions

- Fridge-photo recognition
- Chore management
- Uneven expense splits
- Spending charts
- Food-waste statistics
- Barcode scanning

## Planned Technology Stack

| Technology | Planned Purpose |
|------------|-----------------|
| Flutter and Dart | Mobile interface and application logic |
| Firebase Authentication | User accounts and sign-in |
| Cloud Firestore | Household data storage and live synchronisation |
| Firebase Cloud Functions | Scheduled inventory checks |
| Firebase Cloud Messaging | Expiry notifications |
| Gemini API — under consideration | Receipt extraction and recipe generation |
| Google ML Kit — under consideration | On-device text recognition |

## Data and Main Workflows

### Household Data

Cloud Firestore will store household membership, shopping lists, inventory, expenses and settlements. Firestore listeners will provide live updates, and access rules will restrict household data to its members.

### Receipt Processing

1. The user photographs a receipt.
2. The app extracts item names and prices.
3. Extracted names are normalised using common product abbreviations and compared with unchecked shopping-list items.
4. The user reviews, corrects and confirms the extracted information and suggested matches.
5. The confirmed checkout updates the shopping list and inventory and creates one linked expense record.

Unmatched products can be added as new items. Existing inventory matches will offer a quantity update, while purchases with different expiry dates will remain separate batches.

Each checkout will use a unique identifier linking its inventory updates and expense record. Atomic database operations and identifier checks will prevent partial saves and repeated submissions from creating additional records.

A receipt matching an existing purchase’s merchant, date and total will trigger a duplicate warning for review.

### Expiry Dates and Reminders

Inventory items will use predefined categories such as dairy, produce, meat, frozen food and dry goods.

Users will enter the expiry date printed on the product packaging. Dates can be left blank for products without one and edited when needed.

A scheduled Firebase Cloud Function will check inventory dates daily and send notifications through Firebase Cloud Messaging for items within the reminder window. Stored reminder status will prevent repeated alerts for the same item and threshold.

## Development Priorities

1. Establish authentication, households and shared navigation.
2. Implement the shared shopping list and manual inventory.
3. Implement expenses, balances and settlements.
4. Integrate and test the core workflow.
5. Add receipt scanning and mandatory review.
6. Add expiry reminders and recipe suggestions.
7. Consider optional extensions if time permits.

## Potential Challenges

- **Receipt accuracy:** Abbreviations, poor image quality and inconsistent layouts may cause extraction errors. Mandatory review and an abbreviation list will help address these issues.
- **API availability:** Manual entry will remain available when scanning fails or API access is unavailable.
- **Concurrent updates:** Firestore transactions and linked checkout records will help keep purchases, inventory and expenses consistent.
- **Expiry data quality:** Missing or incorrectly entered dates may affect reminders. Users will be able to review and edit recorded dates.
- **Settlement calculations:** The app will use a straightforward approach to reduce transfers without claiming an absolute minimum.

## Team

| Member | Student ID | Responsibilities |
|--------|------------|------------------|
| Sena Kahya | 32450 | Step 1 coordination, README and final review; household creation, membership/settings screens and shared navigation |
| Zişan Yeşil | 32587 | Step 1 Firebase and database planning; authentication, shared shopping-list screens, synchronisation and purchase updates |
| Fethiye Ebrar Güçlü | 32027 | Step 1 challenges; receipt capture/review, recipe screens, extraction and matching logic |
| Sibel Çelen | 32629 | Step 1 data requirements; expense, balance and settlement screens and calculation logic |
| Deniz Polat | 37476 | Step 1 overview and features; inventory and expiry screens, stock updates and reminder integration |

Each member will own their module’s screens and application logic, including database integration and testing.

All members will contribute to integration testing, code review and documentation.

**Step 1 Coordinator:** Sena Kahya

## Repository

[github.com/senakahya/cs310-HomeLoop](https://github.com/senakahya/cs310-HomeLoop)
