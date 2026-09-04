# Blackjack with Strategy Coach — System Architecture

---

## System Overview

**Components:**
- React 18 Frontend (game UI, coach display, accuracy tracker)
- Node.js/Express Backend (game logic, strategy table, session management)
- Client-side game state or server-side state persistence

---

## Component Architecture

### Frontend (React 18)
**Responsibilities:**
- Game board display (player hand, dealer hand, cards)
- Action buttons (Hit, Stand, Double, Split)
- Strategy coach panel (display optimal move)
- Accuracy display (X/Y correct decisions)
- Hand history

**State:**
- `currentHand`: Player cards, dealer cards
- `gameState`: 'dealing', 'playing', 'dealer-playing', 'game-over'
- `strategyCoach`: Current optimal action
- `sessionStats`: `{ correctDecisions: 0, totalDecisions: 0, accuracy: 0% }`

### Backend (Node.js/Express)
**Responsibilities:**
- Game logic (deal, hit, stand, split)
- Strategy lookup table (2D matrix)
- Deck management (shuffle, draw)
- Session state management (optional)

---

## Critical Design: Basic Strategy Lookup Table

**NOT an algorithm, NOT a calculation function.**

**Is:** 2D array (or object map) with 169 entries
- Rows: Player hand (4, 5, 6, ... 20, 21)
- Columns: Dealer up-card (A, 2, 3, 4, 5, 6, 7, 8, 9, 10)
- Value: Action (Hit, Stand, Double, Split)

**Example entries:**
```
[Player: 12 vs Dealer: 2] → Stand
[Player: 12 vs Dealer: 3] → Stand
[Player: 12 vs Dealer: 4] → Stand
[Player: 12 vs Dealer: 5] → Stand
[Player: 12 vs Dealer: 6] → Stand
[Player: 12 vs Dealer: 7] → Hit
...
```

**Soft hands (Ace as 11):**
- Soft 13 (Ace + 2) vs Dealer 2 → Hit
- Soft 18 (Ace + 7) vs Dealer 9 → Hit
- Soft 18 (Ace + 7) vs Dealer 10 → Stand

**Splits:**
- Pair of 8s vs any dealer card → Always Split
- Pair of 10s vs any dealer card → Never Split

---

## Data Architecture

### Tables/State

**Deck Model:**
```
cards: [
  { suit: 'hearts', rank: 'A' },
  { suit: 'hearts', rank: '2' },
  ...
]
```

**Hand Model:**
```
{
  cards: [...],
  value: 17,  // Total points
  soft: false,  // Is hand soft (has Ace as 11)?
  canSplit: true
}
```

**Game Session:**
```
{
  playerHand: Hand,
  dealerHand: Hand,
  gameState: 'playing' | 'dealer-turn' | 'game-over',
  outcome: 'win' | 'lose' | 'push',
  decisions: [
    { playerAction: 'Hit', optimalAction: 'Hit', correct: true },
    { playerAction: 'Stand', optimalAction: 'Hit', correct: false },
    ...
  ]
}
```

---

## API Surface

**POST /api/game/start**
- Response: `{ playerHand: [...], dealerHand: [...], gameState: 'playing' }`

**POST /api/game/action**
- Body: `{ action: 'hit' | 'stand' | 'double' | 'split' }`
- Response: Updated game state

**POST /api/strategy/lookup**
- Body: `{ playerHand: [...], dealerCard: '5' }`
- Response: `{ optimalAction: 'Stand' }`

**GET /api/session/stats**
- Response: `{ correctDecisions: 5, totalDecisions: 7, accuracy: 71% }`

---

## Strategy Coach Integration

**Flow:**
1. Player receives hand → Frontend calls `/api/strategy/lookup`
2. Backend looks up (playerTotal, dealerUpcard) in strategy table
3. Response: `{ optimalAction: 'Hit' }`
4. Frontend displays: "Optimal: Hit"
5. Player acts → Frontend compares player action vs optimal
6. Increment decision counter

---

## Deployment & Operations

**Docker:**
- Single container: Node + React built app
- Environment vars: Strategy table source (if external), session persistence URL

**Monitoring:**
- Game state transitions logged
- Strategy coach lookup success rate (100% expected)
- Session duration, hands played, accuracy distribution

---

## Open Technical Decisions

1. **Session Persistence:** Store strategy coach sessions (in-memory OK for V1)?
2. **Strategy Table Storage:** Hardcoded array vs loaded from JSON?
3. **Multi-hand UI:** How to render split hands side-by-side (375px mobile)?
4. **Soft hand calculation:** Client-side or server-side validation?
