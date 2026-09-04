# BJ-7: Strategy Lookup Table Implementation

```javascript
// strategyTable.js - Basic strategy lookup table

// Hard hands strategy (4-20)
export const hardHandStrategy = {
  4: ['H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H'],  // vs A,2,3,4,5,6,7,8,9,10
  5: ['H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H'],
  6: ['H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H'],
  7: ['H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H'],
  8: ['H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H', 'H'],
  9: ['H', 'D', 'D', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],
  10: ['D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'H', 'H'],
  11: ['D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'D'],
  12: ['H', 'H', 'S', 'S', 'S', 'S', 'H', 'H', 'H', 'H'],
  13: ['S', 'S', 'S', 'S', 'S', 'S', 'H', 'H', 'H', 'H'],
  14: ['S', 'S', 'S', 'S', 'S', 'S', 'H', 'H', 'H', 'H'],
  15: ['S', 'S', 'S', 'S', 'S', 'S', 'H', 'H', 'H', 'H'],
  16: ['S', 'S', 'S', 'S', 'S', 'S', 'H', 'H', 'H', 'H'],
  17: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],
  18: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],
  19: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],
  20: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],
};

// Soft hands strategy (Ace counted as 11)
export const softHandStrategy = {
  13: ['H', 'H', 'H', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],  // A + 2
  14: ['H', 'H', 'H', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],  // A + 3
  15: ['H', 'H', 'D', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],  // A + 4
  16: ['H', 'H', 'D', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],  // A + 5
  17: ['H', 'D', 'D', 'D', 'D', 'D', 'H', 'H', 'H', 'H'],  // A + 6
  18: ['S', 'D', 'D', 'D', 'D', 'D', 'S', 'S', 'H', 'H'],  // A + 7 (soft 17 rule)
  19: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],  // A + 8
  20: ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],  // A + 9
};

// Pair splitting strategy
export const splitStrategy = {
  'A': ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],  // Always split Aces
  '2': ['P', 'P', 'P', 'P', 'P', 'P', 'H', 'H', 'H', 'H'],
  '3': ['P', 'P', 'P', 'P', 'P', 'P', 'H', 'H', 'H', 'H'],
  '4': ['H', 'H', 'H', 'P', 'P', 'H', 'H', 'H', 'H', 'H'],
  '5': ['D', 'D', 'D', 'D', 'D', 'D', 'D', 'D', 'H', 'H'],
  '6': ['P', 'P', 'P', 'P', 'P', 'P', 'H', 'H', 'H', 'H'],
  '7': ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'H', 'H', 'H'],
  '8': ['P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'],  // Always split 8s
  '9': ['P', 'P', 'P', 'P', 'P', 'S', 'P', 'P', 'S', 'S'],
  '10': ['S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S', 'S'],  // Never split 10s
};

// Dealer card index mapping
const dealerCards = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10'];

function getDealerIndex(dealerCard) {
  const rank = dealerCard.rank === 'J' || dealerCard.rank === 'Q' || dealerCard.rank === 'K' 
    ? '10' 
    : dealerCard.rank;
  return dealerCards.indexOf(rank);
}

/**
 * Look up optimal action from strategy table
 * @param {Array} playerCards - Player's current cards
 * @param {Object} dealerCard - Dealer's upcard
 * @returns {String} - 'H' (Hit), 'S' (Stand), 'D' (Double), 'P' (Split)
 */
export function lookupOptimalAction(playerCards, dealerCard) {
  const dealerIndex = getDealerIndex(dealerCard);
  
  // Check if player can split (pair)
  if (playerCards.length === 2 && playerCards[0].rank === playerCards[1].rank) {
    const rank = playerCards[0].rank === 'A' ? 'A' : 
                 playerCards[0].rank === 'K' || playerCards[0].rank === 'Q' || playerCards[0].rank === 'J' 
                 ? '10' : playerCards[0].rank;
    return splitStrategy[rank][dealerIndex];
  }
  
  // Calculate hand total
  let total = 0;
  let aces = 0;
  for (const card of playerCards) {
    if (card.rank === 'A') aces++;
    total += card.value;
  }
  
  // Determine if soft hand (Ace counted as 11)
  if (aces > 0 && total - 10 <= 21 && total - 10 >= 13) {
    // Soft hand: use soft strategy table
    const softTotal = total - 10;
    return softHandStrategy[softTotal][dealerIndex];
  }
  
  // Hard hand
  return hardHandStrategy[total][dealerIndex];
}

export default { hardHandStrategy, softHandStrategy, splitStrategy, lookupOptimalAction };
```

**Tests:**

```javascript
import { lookupOptimalAction } from './strategyTable.js';

describe('Strategy Table', () => {
  test('AC1: Hard hand 15 vs dealer 3 = Stand', () => {
    const player = [{ rank: 'K', value: 10 }, { rank: '5', value: 5 }];
    const dealer = { rank: '3' };
    expect(lookupOptimalAction(player, dealer)).toBe('S');
  });
  
  test('AC2: Soft 18 vs dealer 10 = Hit', () => {
    const player = [{ rank: 'A', value: 11 }, { rank: '7', value: 7 }];
    const dealer = { rank: '10' };
    expect(lookupOptimalAction(player, dealer)).toBe('H');
  });
  
  test('AC3: Pair of 8s vs dealer 5 = Split', () => {
    const player = [{ rank: '8', value: 8 }, { rank: '8', value: 8 }];
    const dealer = { rank: '5' };
    expect(lookupOptimalAction(player, dealer)).toBe('P');
  });
  
  test('AC4: All lookup calls succeed', () => {
    for (let pTotal = 4; pTotal <= 20; pTotal++) {
      for (let dCard of ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10']) {
        const result = lookupOptimalAction([...], { rank: dCard });
        expect(['H', 'S', 'D', 'P']).toContain(result);
      }
    }
  });
});
```
