A Clarity smart contract to track stacking activity per user across stacking cycles and assign scores based on verified participation.

This contract includes admin utilities for managing scores, cycle logs, and contract ownership — useful for reward programs, gamification, or leaderboard tracking on Stacks-based apps.

---

## 🧠 Overview

- **Tracks** whether a user has stacked in a specific cycle.
- **Assigns scores** to users based on how many cycles they’ve stacked in.
- **Admin-controlled verification** ensures scores are trusted.
- **Extensible** design with utilities for future leaderboard or reward system integration.

---

## ⚙️ Features

- ✅ **Verify Stacking:** Admin can verify a user’s stacking activity for a given cycle.
- 📈 **User Scoring:** Each verified cycle adds +1 to a user's stacking score.
- 🧹 **Score Reset:** Admin can reset a user’s stacking score.
- 🔄 **Cycle Log Removal:** Admin can remove a cycle entry and auto-decrease the score.
- 🧑‍💼 **Admin Management:** Transfer contract ownership.
- 🔍 **Read-only Views:**
  - User score
  - Stacking status in a cycle
  - Contract owner
  - Total cycle count per user
  - Highest score from a given list of users
- 📝 **Event Logging:** Key actions are printed on-chain for off-chain indexing.

---

## 🛠️ Functions

### 🔐 Admin-Only Functions

| Function | Description |
|---------|-------------|
| `verify-stacker(user, cycle)` | Logs a stacking cycle for a user and increments their score. |
| `set-admin(new-admin)` | Transfers ownership of the contract. |
| `reset-user-score(user)` | Resets a user's stacking score to zero. |
| `remove-cycle-log(user, cycle)` | Deletes a stacking log and decreases score (if above zero). |

### 👀 Read-Only Functions

| Function | Description |
|---------|-------------|
| `get-stacker-score(user)` | Returns current score for a user. |
| `did-stack(user, cycle)` | Checks if the user stacked in the specified cycle. |
| `get-owner()` | Returns the current admin address. |
| `get-user-cycle-count(user)` | Returns number of cycles a user has stacked. |
| `get-top-stacker-score(users)` | Returns the highest score among a provided list of users. |
| `get-total-stacked-cycles()` | Placeholder function (currently returns `u0`). |

---

## ⚠️ Error Codes

| Constant | Code | Description |
|----------|------|-------------|
| `ERR-NOT-ADMIN` | `err u100` | Caller is not the contract owner. |
| `ERR-CYCLE-ALREADY-LOGGED` | `err u101` | Cycle has already been verified for the user. |
| `ERR-NOT-STACKED` | `err u102` | User has not stacked in the specified cycle. |
| `ERR-CYCLE-NOT_FOUND` | `err u103` | No cycle entry found for the user. |

---

## 🔧 Storage

### Variables

- `contract-owner`: Stores the principal address of the admin.
  
### Maps

- `stacked-cycles`: `{ cycle, user } => bool`
- `stacker-scores`: `user => uint`

---

## 🧪 Usage Example (Clarity REPL)

```
;; Set a new admin
(set-admin 'SP...')

;; Verify a stacking cycle for a user
(verify-stacker 'SP...user' u25)

;; Check if the user stacked in cycle 25
(did-stack 'SP...user' u25)

;; Get user's stacking score
(get-stacker-score 'SP...user')
📦 Deployment
Make sure to deploy using a Clarity-compatible development environment such as Clarinet.

Suggested contract file name
contracts/stacker-score-tracker.clar
📌 Future Enhancements
Implement total stacked cycles counter on-chain (currently placeholder).

Add time-based score decay or bonuses.

Integration hooks for leaderboard frontends.

Batch verification support.

