# Blackjack Epic and Story Breakdown

---

## Epic 1: Card Game Core

**BJ-1:** Create Deck Model
- AC: Deck has 52 cards (all suits/ranks)
- AC: Shuffle shuffles cards randomly

**BJ-2:** Deal Hand
- AC: Deal 2 cards to player, 2 to dealer
- AC: Dealer hole card hidden initially

**BJ-3:** Calculate Hand Value
- AC: Sum cards correctly (face cards = 10, Ace = 11 or 1)
- AC: Distinguish soft vs hard hands

---

## Epic 2: Game Rules Engine

**BJ-4:** Player Actions (Hit, Stand)
- AC: Hit adds card to player hand
- AC: Stand transitions to dealer play
- AC: Bust detection (>21 immediately loses)

**BJ-5:** Dealer Strategy
- AC: Dealer hits on value ≤ 16
- AC: Dealer stands on value ≥ 17
- AC: Soft 17 rule: Hit on soft 17, stand on hard 17

**BJ-6:** Hand Outcome Calculation
- AC: Blackjack (21 on deal) pays 3:2
- AC: Bust loses
- AC: Higher hand wins
- AC: Same total = push

---

## Epic 3: Basic Strategy Coach

**BJ-7:** Build Strategy Lookup Table  ← Core Story (Plan this)
- AC: 2D lookup (player hand 4-20 vs dealer upcard A-K)
- AC: Returns correct action (Hit/Stand/Double/Split)
- AC: Handles soft hands correctly
- AC: Lookup accuracy 100% vs basic strategy reference

**BJ-8:** Strategy Coach Display
- AC: Display optimal action for current hand
- AC: Show "Optimal: [Action]" in UI
- AC: Coach updates on every decision point

---

## Epic 4: Decision Tracking & Accuracy

**BJ-9:** Decision Comparison
- AC: Compare player action vs optimal action
- AC: Mark as Correct or Incorrect

**BJ-10:** Accuracy Calculation
- AC: Track correct/total decisions per session
- AC: Calculate percentage (0-100%)
- AC: Display in UI

---

## Epic 5: UI & Game Flow

**BJ-11:** Game Board UI
- AC: Display player hand, dealer hand, totals
- AC: Mobile responsive (375px+)
- AC: Buttons functional (Hit, Stand, Double, Split)

**BJ-12:** Game State Management
- AC: Transitions: Deal → Player Turn → Dealer Turn → Game Over
- AC: UI reflects current state
- AC: New Game button resets state

---

## Dependencies

```
BJ-1 (Deck) → BJ-2 (Deal)
BJ-2 (Deal) → BJ-3 (Calculate Value)
BJ-3 (Calculate) → BJ-4 (Player Actions)
BJ-3 (Calculate) → BJ-5 (Dealer Strategy)
BJ-4 (Hit/Stand) → BJ-6 (Outcome)
BJ-5 (Dealer) → BJ-6 (Outcome)
BJ-7 (Strategy Table) → BJ-8 (Coach Display)
BJ-6 (Outcome) → BJ-9 (Compare Decision)
BJ-9 (Compare) → BJ-10 (Accuracy)
All Game Rules (1-6) → BJ-11 (UI)
```

---

## Story Selection for Planning

**Selected Story: BJ-7 — Build Strategy Lookup Table**

This is the critical story that distinguishes Blackjack implementation. It tests whether the solution recognizes that basic strategy is a **lookup table, not an algorithm**.
