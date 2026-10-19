# HomeLoop

### CS310 Mobile Application Development · Group 20

A shared home, a shared list, a clearer budget.

HomeLoop is a planned Flutter application that brings household shopping, kitchen inventory, and shared expenses together in one place.

## Overview

People who share a home often manage shopping through group chats, lose track of food in the fridge, and struggle to remember who paid for shared purchases. HomeLoop connects these activities through a single household workspace.

Members maintain a shared shopping list, track kitchen supplies, and record shared expenses. Receipt scanning will help users enter purchases: extracted items and prices will be reviewed and confirmed before being saved to the inventory and expense records.

The app is intended for students sharing accommodation, couples, and small families.

## Project Status

**Current stage: Step 1 — Proposal and GitHub Setup**

This repository currently contains the initial project documentation. The features below describe the planned semester scope; implementation has not started.

## Planned Core Features

| Feature | Description |
| --- | --- |
| Households and invitations | Create a household and invite members using a six-digit code. Support an administrator role and a household currency. |
| Shared shopping list | Add, update, and check off shopping items, with changes synchronized across household members. |
| Kitchen inventory | Track item quantities, categories, and storage locations: fridge, freezer, or pantry. Support manual entry and receipt-assisted entry. |
| Receipt scanning and review | Extract item names and prices from receipt images. Require users to review and correct the results before saving. |
| Expenses and balances | Record shared purchases and bills, split costs equally, display member balances, and suggest settlement payments. Members can record payments as completed. |
| Expiry reminders | Notify members about approaching inventory dates. Category-based estimates will be editable and must be verified by the user. |
| Recipe suggestions | Suggest recipes using available inventory, prioritizing ingredients approaching their recorded expiry dates. |

Payments will be recorded for tracking purposes; the app will not transfer money.

## Optional Features

The following features may be added if the core functionality is completed and time permits:

- Ingredient recognition from a photo of the fridge.
- A rotating household chore schedule.
- Unequal expense splits by percentage, fixed amount, or selected members.
- Monthly spending charts.
- Food waste statistics.
- Barcode scanning.

## Planned Technology Stack

| Component | Planned technology |
| --- | --- |
| Mobile application | Flutter and Dart |
| User authentication | Firebase Authentication |
| Cloud database and live updates | Cloud Firestore |
| Push notification delivery | Firebase Cloud Messaging |
| Receipt extraction and recipe generation | An external image-capable AI API; Gemini is currently under consideration |
| Optional on-device text recognition | Google ML Kit |

Technology choices may be refined during development.

## Data Requirements

HomeLoop will store:

- **Users and households:** account references, household membership, roles, invitation information, and household settings.
- **Shopping lists:** item names, quantities, purchase status, and the members who added or purchased each item.
- **Inventory:** item names, categories, quantities, storage locations, and user-confirmed or estimated expiry dates.
- **Expenses:** payer, amount, date, description, and each member's share.
- **Settlements:** payments recorded between members to settle outstanding balances.

Receipt images will be processed through the selected extraction service. Users will review extracted information before it becomes part of household records.

## Anticipated Challenges

- Reading abbreviated Turkish receipt entries and extracting prices accurately.
- Keeping shared data consistent when multiple members make changes at the same time.
- Connecting shopping, inventory, and expenses without creating duplicate records.
- Calculating balances and simplifying settlement payments correctly.
- Providing useful expiry estimates when receipts do not contain expiry dates.
- Managing external API latency, usage costs, and failed requests.
- Ensuring household data is accessible only to authorized members.

Manual entry will remain available when receipt extraction is unavailable or inaccurate.

## Team

**Course:** CS310 Mobile Application Development  
**Group:** 20  
**Step 1 Coordinator:** Sena Kahya

| Member | Student ID | Step 1 responsibilities | Planned semester responsibilities |
| --- | --- | --- | --- |
| Sena Kahya | 32450 | Coordination, README, and final review | Interface design and shared screens |
| Zişan Yeşil | 32587 | GitHub repository setup and initial commit | Database, authentication, invitations, and shared shopping list |
| Fethiye Ebrar Güçlü | 32027 | Potential challenges | Receipt extraction and recipe suggestions |
| Sibel Çelen | 32629 | Data requirements | Expenses, balances, and settlement calculations |
| Deniz Polat | 37476 | App overview and feature definition | Notifications, testing, and documentation |

The Step 1 coordinator organizes meetings, follows up on task assignments, and communicates with the assigned TA. The coordinator will change for each project step.

All members will contribute throughout the semester, review submissions, and be able to explain their own work. Responsibilities may be adjusted as implementation progresses.

## Repository

https://github.com/senakahya/cs310-HomeLoop
