# Server-Side Card Filtering Plan (iOS)

This document describes the plan for updating the iOS app to use the new `GET /columns/:id/cards` endpoint for server-side card filtering, replacing the current client-side filtering approach.

---

## Background

**Current behavior:** `BoardViewController` loads ALL cards for a board via `GET /boards/:id/cards`, passes them to each `CollectionViewColumnCell`, and each cell filters locally using `Card.filter()` / `checkConditions()` / `Query.match()`.

**New behavior:** Each column's cards are fetched pre-filtered from the server via `GET /columns/:id/cards`. The iOS app no longer performs card filtering. Sorting and grouping remain client-side.

**API reference:** See `api/docs/server-side-filtering-plan.md` (commit `8e5629c`). The endpoint returns JSON:API format: `{ "data": [{ "type": "cards", "id": "...", "attributes": { "field-values": {...} } }] }`.

---

## Files to Create

| File | Purpose |
|---|---|
| `RiverbedTests/Data/ColumnStoreTests.swift` | Unit tests for the new `cards(for:completion:)` method |

## Files to Modify

| File | Change |
|---|---|
| `Riverbed/Data/API/RiverbedAPI.swift` | Add `columnCardsURL(for:)` URL builder |
| `Riverbed/Data/ColumnStore.swift` | Add `cards(for:completion:)` method |
| `Riverbed/UI/Board/BoardViewController.swift` | Replace board-level card loading with per-column card loading |
| `Riverbed/UI/Board/CollectionViewColumnCell.swift` | Remove client-side filtering; accept pre-filtered cards |

---

## Step 1: Add URL builder

In `RiverbedAPI.swift`, add a URL for the new endpoint:

```swift
static func columnCardsURL(for columnId: String) -> URL {
    url(columnCardsPath(columnId))
}

private static func columnCardsPath(_ columnId: String) -> String {
    joinPathSegments(columnsPath(), columnId, "cards")
}
```

This produces `/columns/{columnId}/cards`.

---

## Step 2: Add `cards(for:completion:)` to `ColumnStore`

Add a method to `ColumnStore` that fetches pre-filtered cards for a column:

```swift
func cards(for column: Column, completion: @escaping (Result<[Card], Error>) -> Void) {
    let url = RiverbedAPI.columnCardsURL(for: column.id)
    var request = URLRequest(url: url)
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

    let task = session.dataTask(with: request) { (data, response, error) in
        let result: Result<[Card], Error> = self.processResult((data, response, error))
        OperationQueue.main.addOperation {
            completion(result)
        }
    }
    task.resume()
}
```

This follows the same pattern as `CardStore.all(for:completion:)` — the response format is identical (`JSONAPI.Data<[Card]>`), so `processResult` handles decoding.

---

## Step 3: Change `BoardViewController` loading flow

### 3a. Replace `cards` with `columnCards`

Remove the board-level `cards` property and replace with a per-column dictionary:

```swift
// REMOVE
var cards = [Card]()

// ADD
var columnCards = [String: [Card]]()
```

### 3b. Rewrite `loadBoardData()`

The new loading sequence:

1. Load **columns** and **elements** in parallel (same as before).
2. Once both are loaded, load **filtered cards for each column** in parallel.
3. Once all per-column card loads complete, call `updateSnapshot()`.

```swift
@IBAction func loadBoardData(_ sender: Any? = nil) {
    guard let board = board else { return }

    let refreshControl = sender as? UIRefreshControl

    isLoadingBoard = true
    updateLoadingErrorDisplay(isError: false, refreshControl: refreshControl)

    var isError = false
    var areColumnsLoading = true
    var areElementsLoading = true

    func checkForInitialLoadDone() {
        if areColumnsLoading || areElementsLoading { return }

        if isError {
            isLoadingBoard = false
            updateLoadingErrorDisplay(isError: true, refreshControl: refreshControl)
            clearBoardData()
            return
        }

        // Phase 2: load filtered cards for each column
        loadCardsForColumns(refreshControl: refreshControl)
    }

    columnStore.all(for: board) { (result) in
        switch result {
        case let .success(columns):
            self.columns = columns
            self.updateSortedColumns()
        case let .failure(error):
            print("Error loading columns: \(error)")
            isError = true
        }
        areColumnsLoading = false
        checkForInitialLoadDone()
    }
    elementStore.all(for: board) { (result) in
        switch result {
        case let .success(elements):
            self.elements = elements
        case let .failure(error):
            print("Error loading elements: \(error)")
            isError = true
        }
        areElementsLoading = false
        checkForInitialLoadDone()
    }
}
```

### 3c. Add `loadCardsForColumns()`

```swift
private func loadCardsForColumns(refreshControl: UIRefreshControl?) {
    let columnsToLoad = sortedColumns
    if columnsToLoad.isEmpty {
        finishLoading(isError: false, refreshControl: refreshControl)
        return
    }

    var isError = false
    var remainingCount = columnsToLoad.count

    for column in columnsToLoad {
        columnStore.cards(for: column) { (result) in
            switch result {
            case let .success(cards):
                self.columnCards[column.id] = cards
            case let .failure(error):
                print("Error loading cards for column \(column.id): \(error)")
                isError = true
            }
            remainingCount -= 1
            if remainingCount == 0 {
                self.finishLoading(isError: isError, refreshControl: refreshControl)
            }
        }
    }
}

private func finishLoading(isError: Bool, refreshControl: UIRefreshControl?) {
    isLoadingBoard = false
    updateLoadingErrorDisplay(isError: isError, refreshControl: refreshControl)

    if isError {
        clearBoardData()
    } else {
        isFirstLoadingBoard = false
        updateSnapshot()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}
```

### 3d. Update `clearBoardData()`

```swift
func clearBoardData() {
    columnCards = [:]  // was: cards = []
    columns = []
    elements = []
    isFirstLoadingBoard = true

    updateSortedColumns()
    updateSnapshot()
}
```

### 3e. Update cell provider in `configureCollectionView()`

Change the cell provider to pass per-column cards instead of all cards:

```swift
// BEFORE
cell.cards = self.cards

// AFTER
cell.cards = self.columnCards[column.id] ?? []
```

---

## Step 4: Simplify `CollectionViewColumnCell`

The cell currently receives all board cards and filters them locally. With server-side filtering, it receives pre-filtered cards.

### 4a. Remove filtering from the cell

Replace `updateFilteredCards()` to skip the filtering step:

```swift
// BEFORE
var cards = [Card]() {
    didSet { updateFilteredCards() }
}
var elements = [Element]() {
    didSet { updateFilteredCards() }
}

var filteredCards = [Card]() {
    didSet {
        updateColumnTitle()
        updateCardGroups()
    }
}
private func updateFilteredCards() {
    guard let column = column else { return }
    filteredCards = Card.filter(cards: cards, for: column, with: elements)
}

// AFTER
var cards = [Card]() {
    didSet {
        updateColumnTitle()
        updateCardGroups()
    }
}
var elements = [Element]() {
    didSet {
        updateCardGroups()
    }
}
```

### 4b. Replace `filteredCards` references with `cards`

All references to `filteredCards` in the cell become `cards`:

- `calculate(summary:)` — `filteredCards.count` and `filteredCards.map` become `cards.count` and `cards.map`
- `updateCardGroups()` — `Card.group(cards: filteredCards, ...)` becomes `Card.group(cards: cards, ...)`

---

## Step 5: Clean up client-side filtering code

The following code is no longer called by the main app, but should be **kept** (not deleted) because:
- It serves as documentation of the filtering logic
- It could be useful as a fallback or for offline mode in the future
- The existing unit tests (`QueryTests`, `CardTests.test_filter_*`) validate the contract

Files with client-side filtering code to leave in place:
- `Card.filter(cards:for:with:)` in `Card.swift`
- `checkConditions()` in `Utils.swift`
- `Query.match()` in `Query.swift`

---

## Test Plan

### New: `RiverbedTests/Data/ColumnStoreTests.swift`

Test the URL construction for the new endpoint:

| Test | Expectation |
|---|---|
| `test_columnCardsURL_constructsCorrectURL` | `RiverbedAPI.columnCardsURL(for: "42")` produces a URL ending in `/columns/42/cards` |

### Updated: `RiverbedTests/Data/Models/CardTests.swift`

The existing `Card.filter` tests remain as-is (they test client-side logic that still exists in the codebase). No changes needed.

The existing `Card.group` tests remain as-is. Grouping/sorting behavior is unchanged.

### New: `RiverbedTests/UI/Board/BoardViewControllerTests.swift`

Test the new loading flow using mock stores.

**Prerequisites:** `ColumnStore` needs to be refactored into a protocol (like `BoardStore`) so it can be mocked. Currently `ColumnStore` is a concrete class extending `BaseStore`. This refactor is described below.

#### ColumnStore protocol extraction

Create a protocol and rename the concrete class:

```swift
// ColumnStore.swift (protocol)
protocol ColumnStore {
    func all(for board: Board, completion: @escaping (Result<[Column], Error>) -> Void)
    func cards(for column: Column, completion: @escaping (Result<[Card], Error>) -> Void)
    func create(on board: Board, completion: @escaping (Result<Column, Error>) -> Void)
    func update(_ column: Column,
                with updatedAttributes: Column.Attributes,
                completion: @escaping (Result<Void, Error>) -> Void)
    func updateDisplayOrders(of columns: [Column],
                             completion: @escaping (Result<[Column], Error>) -> Void)
    func delete(_ column: Column, completion: @escaping (Result<Void, Error>) -> Void)
}

// ApiColumnStore.swift (implementation)
class ApiColumnStore: BaseStore, ColumnStore { ... }
```

This follows the existing `BoardStore` / `ApiBoardStore` pattern. Update `SceneDelegate` and `BoardViewController` to use the protocol type.

#### MockColumnStore

```swift
// RiverbedTests/Doubles/MockColumnStore.swift
class MockColumnStore: ColumnStore {
    var allResult: Result<[Column], Error>?
    var cardsResults: [String: Result<[Card], Error>] = [:]  // keyed by column ID
    var createResult: Result<Column, Error>?
    var updateResult: Result<Void, Error>?
    var deleteResult: Result<Void, Error>?

    func all(for board: Board, completion: @escaping (Result<[Column], Error>) -> Void) {
        if let result = allResult { completion(result) }
    }

    func cards(for column: Column, completion: @escaping (Result<[Card], Error>) -> Void) {
        if let result = cardsResults[column.id] { completion(result) }
    }
    // ... other methods
}
```

#### BoardViewController loading flow tests

| Test | Setup | Expectation |
|---|---|---|
| `test_loadBoardData_fetchesFilteredCardsPerColumn` | Mock returns 2 columns, each with different cards | `columnCards` has entries for both column IDs with correct cards |
| `test_loadBoardData_whenColumnHasNoCards_storesEmptyArray` | Mock returns 1 column with empty card array | `columnCards[columnId]` is `[]` |
| `test_loadBoardData_whenColumnLoadFails_showsError` | Mock returns columns successfully, card load fails | Error state is displayed, board data is cleared |
| `test_loadBoardData_whenColumnsLoadFails_doesNotLoadCards` | Mock column load returns error | No card-fetch calls are made |

### New: `RiverbedTests/UI/Board/CollectionViewColumnCellTests.swift`

Test that the cell correctly uses pre-filtered cards without re-filtering:

| Test | Setup | Expectation |
|---|---|---|
| `test_settingCards_updatesCardGroups` | Set `cards` to 2 cards, column has no grouping | `cardGroups` has 1 group with 2 cards |
| `test_settingCards_calculatesSummaryCount` | Set `cards` to 3 cards, column has count summary | Title includes "(3)" |
| `test_settingCards_doesNotFilterAgainstConditions` | Set `cards` with column that has conditions cards wouldn't match | All cards are still in `cardGroups` (no re-filtering) |

---

## Data Flow Comparison

### Before (client-side filtering)
```
BoardViewController.loadBoardData()
  |-- GET /boards/:id/cards        --> self.cards (ALL cards)
  |-- GET /boards/:id/columns      --> self.columns
  |-- GET /boards/:id/elements     --> self.elements
  |
  v
updateSnapshot() --> cell provider
  |
  v
CollectionViewColumnCell
  |-- receives ALL cards
  |-- Card.filter(cards, column, elements)  --> filteredCards
  |-- Card.group(filteredCards, column, elements) --> cardGroups
```

### After (server-side filtering)
```
BoardViewController.loadBoardData()
  |-- GET /boards/:id/columns      --> self.columns
  |-- GET /boards/:id/elements     --> self.elements
  |
  v (after columns + elements loaded)
loadCardsForColumns()
  |-- GET /columns/:id1/cards      --> self.columnCards["id1"]
  |-- GET /columns/:id2/cards      --> self.columnCards["id2"]
  |-- ...                          --> (parallel, one per column)
  |
  v
updateSnapshot() --> cell provider
  |
  v
CollectionViewColumnCell
  |-- receives PRE-FILTERED cards for this column
  |-- Card.group(cards, column, elements) --> cardGroups
```

---

## Migration Considerations

### Network requests
- **Before:** 3 parallel requests per board load (cards, columns, elements)
- **After:** 2 + N requests (columns, elements in parallel; then N column card requests in parallel)
- This is more requests but each returns less data. The server applies filtering, reducing payload size.

### Sorting and grouping
- Sorting (`Card.sort`) and grouping (`Card.group`) remain **client-side** in `CollectionViewColumnCell`. The server endpoint only handles filtering.

### Card detail view
- When a user taps a card from a column, the `Card` object comes from `columnCards[columnId]`. This is the same `Card` model, so `CardViewController` works unchanged.

### Card create/update/delete
- After any card mutation, `loadBoardData()` is called, which re-fetches all column cards. This keeps the data fresh without needing the board-level card list.

### Share extension
- `RiverbedShare` does not use card filtering — it posts webhooks. No changes needed.

### CardStore.all(for:)
- The `CardStore.all(for:)` method (`GET /boards/:id/cards`) is no longer called by `BoardViewController`. It can be kept for other potential uses but is effectively unused by the main app flow.

---

## Implementation Order

1. Add `columnCardsURL` to `RiverbedAPI` + unit test
2. Extract `ColumnStore` protocol, rename class to `ApiColumnStore`, update `SceneDelegate`
3. Add `cards(for:completion:)` to `ApiColumnStore`
4. Create `MockColumnStore` test double
5. Rewrite `BoardViewController.loadBoardData()` and add `loadCardsForColumns()`
6. Simplify `CollectionViewColumnCell` (remove filtering, rename `filteredCards` to `cards`)
7. Write `BoardViewControllerTests` and `CollectionViewColumnCellTests`
8. Manual testing: verify columns load correct filtered cards, card detail still works, card CRUD still refreshes correctly
