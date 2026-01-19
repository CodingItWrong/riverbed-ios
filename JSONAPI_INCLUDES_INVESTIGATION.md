# JSON:API `include` Parameter Investigation

## Summary

**Finding: The iOS app does NOT currently use the JSON:API `include` parameter to query nested data.**

## Current Implementation

The app makes **multiple separate HTTP requests** to fetch related resources:

### Example: Loading Board Data (BoardViewController.swift)

When loading a board, the app makes 3 separate parallel API calls:

1. **GET** `/boards/{boardId}/cards` - Fetches all cards for the board
2. **GET** `/boards/{boardId}/columns` - Fetches all columns for the board  
3. **GET** `/boards/{boardId}/elements` - Fetches all elements for the board

```swift
// From BoardViewController.loadBoardData()
cardStore.all(for: board) { ... }      // GET /boards/{id}/cards
columnStore.all(for: board) { ... }    // GET /boards/{id}/columns
elementStore.all(for: board) { ... }   // GET /boards/{id}/elements
```

These requests are made in parallel with separate completion handlers, and the UI updates once all three requests complete.

## JSON:API `include` Parameter

According to the JSON:API specification, the `include` query parameter allows fetching related resources in a single request. For example:

```
GET /boards/{id}?include=cards,columns,elements
```

This would return:
- The board resource in the `data` field
- Related cards, columns, and elements in the `included` array

### Benefits of Using `include`
- **Fewer network requests**: 1 request instead of 3
- **Better performance**: Reduced latency from multiple round trips
- **Atomic data loading**: All related data arrives together
- **Reduced server load**: Single database query can fetch related data more efficiently

### Current Code Gaps

1. **No query parameter support**: The `RiverbedAPI` URL builder doesn't support adding query parameters
2. **No `included` parsing**: The `JSONAPI.Data` class only parses the `data` field, not the `included` array
3. **No relationship support in models**: Board, Card, Column, and Element models don't have fields to parse relationships from responses

## Code Locations

### URL Construction
- `Riverbed/Data/API/RiverbedAPI.swift` - Builds API URLs (no query parameter support)

### API Calls
- `Riverbed/Data/BoardStore.swift` - Fetches boards
- `Riverbed/Data/CardStore.swift` - Fetches cards  
- `Riverbed/Data/ColumnStore.swift` - Fetches columns
- `Riverbed/Data/ElementStore.swift` - Fetches elements

### JSON:API Handling
- `Riverbed/Data/API/JSONAPI.swift` - Minimal implementation (only `data` wrapper, no `included` support)

### UI Components Using Multiple Calls
- `Riverbed/UI/Board/BoardViewController.swift:211-278` - Makes 3 parallel calls in `loadBoardData()`
- `Riverbed/UI/Card/CardViewController.swift:260-272` - Reloads elements separately

## Recommendations

To leverage the JSON:API `include` parameter, the following changes would be needed:

1. **Extend RiverbedAPI**: Add support for query parameters
2. **Update JSONAPI class**: Parse the `included` array from responses
3. **Update models**: Add optional relationships fields to handle included resources
4. **Update stores**: Modify fetch methods to use `include` parameter and parse included data
5. **Update view controllers**: Simplify to make single requests instead of multiple parallel calls

## Backend Compatibility

**Note**: This investigation does not test whether the Riverbed backend API actually supports the `include` parameter. That would need to be verified by:
- Checking backend API documentation
- Testing with actual API calls (e.g., `GET /boards/{id}?include=cards,columns,elements`)
- Confirming the backend returns data in the `included` array format

## Conclusion

The iOS app currently **does not rely on** the JSON:API `include` parameter for querying nested data. Instead, it makes multiple separate API requests to fetch related resources. This approach works but is less efficient than using the `include` parameter as specified by JSON:API.
