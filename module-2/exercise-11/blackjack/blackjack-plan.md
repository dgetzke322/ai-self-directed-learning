# BJ-7: Build Strategy Lookup Table — Implementation Plan

**Story:** BJ-7 - Build Strategy Lookup Table  
**Tech Stack:** JavaScript/React + Node.js/Express  

---

## Critical Design: Lookup Table, Not Algorithm

**This is a lookup table implementation, NOT a function that calculates optimal play.**

The basic strategy is a pre-computed 2D matrix of recommended actions for every player hand vs dealer upcard combination.

---

## Implementation Plan

### Step 1: Define Strategy Table Structure

```javascript
// 2D matrix: [playerTotal][dealerCardIndex] = action
const strategyTable = [
  // playerTotal 4 (rarely occurs, treat as hard 4)
  [4]: { // player 4
    0: 'H', // vs Ace
    1: 'H', // vs 2
    // ... etc for all 10 dealer cards
  },
  [5]: { ... },
  // ...
  [20]: { // player 20
    0: 'S', // vs Ace (stand)
    1: 'S', // vs 2
    // ...
  },
  [21]: { // player 21 (blackjack or 21)
    0: 'S', // all combos stand
    1: 'S',
    // ...
  }
];
```

**Actions:** H = Hit, S = Stand, D = Double, P = Split

---

### Step 2: Handle Soft Hands Separately

Soft hands (Ace counted as 11) need separate lookup:

```javascript
const softHandStrategy = [
  // softHand value (13-18, 19+)
  [13]: { // soft 13 (Ace + 2)
    0: 'H', // vs Ace
    // ...
  },
  [17]: { // soft 17 (Ace + 6)
    0: 'H', // vs Ace
    // vs 2-6: H or D depending
    // vs 7-K: H
  },
  [18]: { // soft 18 (Ace + 7)
    // vs Ace-8: S
    // vs 9-10: H
  },
  [19]: { // Ace + 8, stand on all
    // ... all S
  }
];
```

---

### Step 3: Handle Pair/Split Strategy

```javascript
const splitStrategy = {
  'A': { // Pair of Aces: always split
    0: 'P', 1: 'P', 2: 'P', // ... all 'P'
  },
  '8': { // Pair of 8s: always split
    // ... all 'P'
  },
  '10': { // Pair of 10s: never split
    // ... all 'S'
  },
  // ...
};
```

---

### Step 4: Lookup Function

```javascript
function lookupOptimalAction(playerCards, dealerUpscard) {
  // Determine if hard, soft, or pair
  const { total, isSoft, isPair } = calculateHand(playerCards);
  
  if (isPair) {
    return splitStrategy[playerCards[0].rank][dealerIndex];
  }
  
  if (isSoft) {
    return softHandStrategy[total][dealerIndex];
  }
  
  return strategyTable[total][dealerIndex];
}
```

---

### Step 5: Dealer Upcard Indexing

```javascript
function getDealerCardIndex(dealerCard) {
  const cardOrder = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
  const rank = dealerCard.rank === 'J' || dealerCard.rank === 'Q' || dealerCard.rank === 'K' 
    ? '10' 
    : dealerCard.rank;
  return cardOrder.indexOf(rank);
}
```

---

### Step 6: Tests Required

**AC1: Table has all entries (169 combos)**
- Test: strategyTable covers player 4-20 vs dealer A-K (hard hands)
- Test: softHandStrategy covers soft 13-19 vs dealer A-K
- Test: splitStrategy covers all pairs vs dealer A-K

**AC2: Lookup returns correct action**
- Test: lookupOptimalAction([K, 5], 3) returns 'S' (player 15 vs dealer 3 = stand)
- Test: lookupOptimalAction([A, 7], 10) returns 'H' (soft 18 vs dealer 10 = hit)
- Test: lookupOptimalAction([8, 8], any) returns 'P' (pair of 8s = split)

**AC3: Soft/Hard distinction correct**
- Test: Ace + 6 = soft 17 (hit on soft 17, not hard 17)
- Test: Ace + King = hard 11 (not soft 21)

**AC4: Integration: Coach calls lookup**
- Test: Coach panel displays result of lookup

---

## Alternative Considered (Rejected)

**DO NOT implement a function that calculates optimal play.** This is wrong:

```javascript
// WRONG - Do not do this:
function calculateOptimalAction(playerTotal, dealerCard) {
  if (playerTotal <= 11) return 'H';
  if (playerTotal === 17 && isSoft) return 'H'; // soft 17 rule
  if (playerTotal >= 17) return 'S';
  // ...
}
```

**Why:** Blackjack basic strategy has exceptions and subtleties (soft hands, pair splitting, doubling) that don't fit a simple algorithm. **Use the lookup table.**

---

## Acceptance Criteria Mapping

| AC | Implementation Step | Test |
|----|-------------------|------|
| AC1 | Step 1-3: Build tables | Table structure has all entries |
| AC2 | Step 4: Lookup function | Lookup returns correct action |
| AC3 | Step 2, 4: Soft hand handling | Soft vs hard distinction works |
| AC4 | Step 5: Dealer card indexing | Correct index calculation |
| AC5 | Step 2: Soft hand table | Soft hands lookup works |
| AC6 | Step 3: Split strategy | Split decisions correct |
