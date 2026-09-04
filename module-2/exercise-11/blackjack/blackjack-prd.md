# Blackjack with Strategy Coach — Product Requirements Document

**Product:** Blackjack Card Game with Basic Strategy Coaching  
**Status:** V1 Specification  
**Audience:** Card game enthusiasts learning optimal play  

---

## Problem Statement

Players learning Blackjack struggle to memorize optimal strategy (basic strategy charts). Manual lookups distract from gameplay, and performance metrics are unavailable. Players need real-time coaching and accuracy tracking to improve decision-making.

---

## Solution

A web-based Blackjack game with:
1. Interactive single-player gameplay vs dealer
2. Basic strategy lookup table for every decision point
3. Real-time strategy coach showing optimal move
4. Decision accuracy tracking (% correct decisions per session)

---

## Key Features

### 1. Game Engine
- Standard casino Blackjack rules (hit soft 16, stand soft 17)
- Card deck: 52 cards, shuffled before each round
- Player hand: Hit/Stand/Double/Split options
- Dealer hand: Hit/Stand logic built-in
- Blackjack: 21 on deal pays 3:2, insurance not available
- Bust: >21 loses immediately

### 2. Basic Strategy Coach
- 2D lookup table: Player hand (4-20) × Dealer upcard (A-K) → Optimal action
- Display optimal move for every player decision
- Distinguish soft hands (Ace as 11) vs hard hands (Ace as 1)
- Support split decisions (if player hand can split, lookup includes split option)

### 3. Decision Tracking
- Track each player decision: Player choice vs Optimal choice
- Calculate accuracy: % decisions matching optimal strategy
- Display per-session (reset on new game)
- Show accuracy improvement across hands

### 4. UI Flow
- Deal button (start new hand)
- Player hand display (cards, total, soft/hard indicator)
- Action buttons (Hit, Stand, Double, Split) — available based on rules
- Strategy coach panel (show "Optimal: [Action]")
- Dealer hand display (hole card hidden until player stands)
- Outcome display (Win/Lose/Push)
- Accuracy indicator (X/Y decisions correct this session)

---

## Acceptance Criteria

### PRD-Level Requirements
- ✅ Gameplay loop: Deal → Player acts → Dealer acts → Outcome
- ✅ All standard Blackjack rules enforced
- ✅ Basic strategy table correctly implemented (lookup, not calculated)
- ✅ Strategy coach displays every decision point
- ✅ Accuracy tracking works across multiple hands in session
- ✅ Mobile responsive (375px viewport minimum)
- ✅ Performance: Hand resolution <1s, UI responsive

---

## Technical Context

**Tech Stack:**
- Frontend: React 18, TypeScript
- Backend: Node.js/Express (or Python/FastAPI alternative)
- Game State: Client-side or server-side persistence optional
- Strategy Table: Hardcoded or loaded from data file

**Scope V1:** Single-player, basic strategy, no splits-beyond-basic, no insurance

**Out of Scope V1:**
- Multiplayer
- Betting/money (cosmetic only)
- Card counting strategies
- Surrender
- Insurance
- Hand statistics persistence (session-only)

---

## Rules Engine Specification

### Player Actions
- **Hit:** Take another card (stay under 21)
- **Stand:** Keep current hand, let dealer play
- **Double:** Double bet, take exactly 1 more card
- **Split:** If two cards same rank, split into two hands (limit 2 hands for V1)

### Dealer Strategy (Auto)
- Hit on hand value ≤ 16
- Stand on hand value ≥ 17
- Soft 17 rule: Hit on soft 17 (Ace + 6), stand on hard 17+

### Hand Valuation
- Number cards: Face value
- Face cards (J, Q, K): 10
- Ace: 11 or 1 (whichever doesn't bust; if both bust, use 1)

### Outcomes
- **Blackjack (21 on deal):** Pays 1.5x (if dealer doesn't also have blackjack, then push)
- **Bust (>21):** Immediate loss
- **Dealer busts:** Player wins (1x payout)
- **Higher hand:** Player wins (1x payout)
- **Same total:** Push (bet returned, no win/loss)
- **Lower hand:** Dealer wins

---

## Non-Functional Requirements

- **Performance:** Hand resolution <1s, dealer AI response <500ms
- **Accessibility:** WCAG 2.1 AA (keyboard navigation, high contrast, accessible buttons)
- **Responsiveness:** Works on mobile (375px), tablet (768px), desktop (1024px+)
- **Reliability:** Game state consistent across refreshes (session state preserved)

---

## Success Metrics

- Game plays correctly per rules
- Strategy coach shows correct optimal move (100% accuracy vs basic strategy table)
- Accuracy tracking increments correctly
- UI responsive on mobile under 4G network
- No crashes or logic errors after 20+ hands
