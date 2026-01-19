# Backend API Migration Checklist

Use this checklist to track the migration of backend routes to the new implementation. For detailed information about each endpoint, see [API_ENDPOINTS.md](./API_ENDPOINTS.md).

## Authentication
- [ ] `POST /oauth/token` - Create OAuth token (sign in)

## Users
- [ ] `POST /users` - Create user (sign up)
- [ ] `GET /users/{userId}` - Get user by ID
- [ ] `PATCH /users/{userId}` - Update user
- [ ] `DELETE /users/{userId}` - Delete user

## Boards
- [ ] `GET /boards` - List all boards
- [ ] `POST /boards` - Create board
- [ ] `PATCH /boards/{boardId}` - Update board
- [ ] `DELETE /boards/{boardId}` - Delete board

## Columns
- [ ] `GET /boards/{boardId}/columns` - List columns for board
- [ ] `POST /columns` - Create column
- [ ] `PATCH /columns/{columnId}` - Update column (including display order)
- [ ] `DELETE /columns/{columnId}` - Delete column

## Elements
- [ ] `GET /boards/{boardId}/elements` - List elements for board
- [ ] `POST /elements` - Create element
- [ ] `PATCH /elements/{elementId}` - Update element (including display order)
- [ ] `DELETE /elements/{elementId}` - Delete element

## Cards
- [ ] `GET /boards/{boardId}/cards` - List cards for board
- [ ] `GET /cards/{cardId}` - Get card by ID
- [ ] `POST /cards` - Create card
- [ ] `PATCH /cards/{cardId}` - Update card
- [ ] `DELETE /cards/{cardId}` - Delete card

## Webhooks/Shares
- [ ] `POST /shares` - Post webhook/share

---

## Migration Progress Summary
- Total Endpoints: 23
- Completed: 0
- Remaining: 23

## Notes for Migration
1. All endpoints (except `/oauth/token` and user signup) require Bearer token authentication
2. Most endpoints use JSON:API format (`application/vnd.api+json`)
3. OAuth token and webhook endpoints use standard `application/json`
4. No query string parameters are currently used
5. Date fields use a custom server date-time format
6. Base URL: `https://api.riverbed.app/` (production) or `http://localhost:3000/` (development)
