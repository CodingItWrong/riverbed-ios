# Server-Side Filtering Implementation Checklist

## Step 1: Add URL builder (`RiverbedAPI.swift`)
- [ ] Add `columnCardsPath(_:)` private static method
- [ ] Add `columnCardsURL(for:)` static method

## Step 2: Extract `ColumnStore` protocol
- [ ] Create `ColumnStore` protocol with all existing methods plus `cards(for:completion:)`
- [ ] Rename `ColumnStore` class to `ApiColumnStore` (extends `BaseStore`, conforms to `ColumnStore`)
- [ ] Update `SceneDelegate` to use `ColumnStore` protocol type and instantiate `ApiColumnStore`
- [ ] Update `BoardViewController` property type from `ColumnStore` class to `ColumnStore` protocol

## Step 3: Add `cards(for:completion:)` to `ApiColumnStore`
- [ ] Implement method using `RiverbedAPI.columnCardsURL(for:)` and `processResult`

## Step 4: Create `MockColumnStore` test double (`RiverbedTests/Doubles/MockColumnStore.swift`)
- [ ] Add `allResult`, `cardsResults`, `createResult`, `updateResult`, `deleteResult` properties
- [ ] Implement all `ColumnStore` protocol methods

## Step 5: Rewrite `BoardViewController` loading flow
- [ ] Replace `var cards = [Card]()` with `var columnCards = [String: [Card]]()`
- [ ] Rewrite `loadBoardData()` — remove card-loading phase, call `loadCardsForColumns()` after columns + elements load
- [ ] Add `loadCardsForColumns(refreshControl:)` private method
- [ ] Add `finishLoading(isError:refreshControl:)` private method
- [ ] Update `clearBoardData()` to use `columnCards = [:]` instead of `cards = []`
- [ ] Update cell provider in `configureCollectionView()`: `cell.cards = self.columnCards[column.id] ?? []`

## Step 6: Simplify `CollectionViewColumnCell`
- [ ] Remove `filteredCards` property
- [ ] Remove `updateFilteredCards()` method
- [ ] Change `cards` didSet to call `updateColumnTitle()` and `updateCardGroups()` directly
- [ ] Change `elements` didSet to call `updateCardGroups()` directly
- [ ] Replace `filteredCards` with `cards` in `calculate(summary:)`
- [ ] Replace `filteredCards` with `cards` in `updateCardGroups()`

## Step 7: Write unit tests

### `RiverbedTests/Data/ColumnStoreTests.swift` (new file)
- [ ] `test_columnCardsURL_constructsCorrectURL` — verify URL ends in `/columns/42/cards`

### `RiverbedTests/UI/Board/BoardViewControllerTests.swift` (new file)
- [ ] `test_loadBoardData_fetchesFilteredCardsPerColumn`
- [ ] `test_loadBoardData_whenColumnHasNoCards_storesEmptyArray`
- [ ] `test_loadBoardData_whenColumnLoadFails_showsError`
- [ ] `test_loadBoardData_whenColumnsLoadFails_doesNotLoadCards`

### `RiverbedTests/UI/Board/CollectionViewColumnCellTests.swift` (new file)
- [ ] `test_settingCards_updatesCardGroups`
- [ ] `test_settingCards_calculatesSummaryCount`
- [ ] `test_settingCards_doesNotFilterAgainstConditions`

## Step 8: Set up side-by-side testing (temporary — revert before release)
- [ ] In `Riverbed.xcodeproj/project.pbxproj`, change the `Debug` config bundle ID for the main target to `com.codingitwrong.riverbed.uikit.dev`
- [ ] Log in to both the App Store build and the local Debug build

## Step 9: Manual testing
- [ ] Columns load with correct filtered cards
- [ ] Card detail view still opens and displays correctly
- [ ] Card create/update/delete refreshes correctly
- [ ] Pull-to-refresh works
- [ ] Error state displays when network fails

## Step 10: Revert temporary changes
- [ ] Restore `Debug` bundle ID to `com.codingitwrong.riverbed.uikit` in `project.pbxproj`
