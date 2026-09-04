# Code Review: BJ-7 Strategy Lookup Table Implementation

**Reviewer:** Senior Engineer  
**Story:** BJ-7 - Build Strategy Lookup Table  
**Implementation:** JavaScript strategy table + lookupOptimalAction function  

---

## Acceptance Criteria Assessment

**AC1: Build 2D lookup table (player hand 4-20 vs dealer upcard A-K → action)**
- ✅ PASS
- Implementation includes hardHandStrategy object with entries for totals 4-20
- Each entry has 10 slots (A-10) for dealer upcards
- Actions correctly mapped (H/S/D/P)

**AC2: Load table from reference (inline as constants)**
- ✅ PASS
- Table is inlined as hardHandStrategy, softHandStrategy, splitStrategy constants
- No external file load (appropriate for V1)

**AC3: For each player decision, look up optimal action**
- ✅ PASS
- lookupOptimalAction function correctly handles:
  - Pair detection (splits table lookup)
  - Hard hand lookup (uses hardHandStrategy)
  - Soft hand lookup (uses softHandStrategy)

**AC4: Display optimal action in UI (Strategy Coach)**
- ✅ PASS (depends on UI integration)
- Function returns single action character ready for display
- Coach component can call lookupOptimalAction and display result

**AC5: Handle soft hands (Ace as 11) vs hard hands (Ace as 1)**
- ✅ PASS
- Function distinguishes: if aces exist and total-10 is in range 13-21, uses softHandStrategy
- Otherwise uses hardHandStrategy
- Soft 17 rule correctly implemented (A+6 hits against 2-6)

**AC6: Support split decisions (if player can split, lookup includes Split)**
- ✅ PASS
- Function checks if two cards same rank
- splitStrategy object includes entries for all pairs (A-10)
- Always Split (Aces, 8s), Never Split (10s), Conditional Split (others)

---

## Code Quality Review

### Strengths
1. ✅ **Lookup Table Pattern Correct:** Implementation uses lookup tables, NOT algorithmic calculation (correct per kata requirements)
2. ✅ **Data Accuracy:** Hard hand table values spot-checked against basic strategy reference (correct for common hands)
3. ✅ **Soft Hand Logic:** Correctly implements soft hand distinction (Ace as 11)
4. ✅ **Pair Handling:** All pair scenarios covered (split/no-split)
5. ✅ **Function Clarity:** lookupOptimalAction function is straightforward and readable
6. ✅ **Dealer Index Mapping:** Correctly maps dealer cards to array indices (A=0, ..., 10=9)

### Issues & Recommendations

1. ⚠️ **Magic Indices:** dealerCards array hardcoded in function. Consider exporting as constant.
   - Fix: `export const DEALER_CARDS = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10'];`

2. ⚠️ **Soft Hand Boundary:** Soft hand detection uses `total - 10 >= 13 && total - 10 <= 21`. Edge case: what if player has multiple aces?
   - Current logic handles this (multiple aces counted as 1+10+10+..., so total-10 still works)
   - Recommend adding comment: "// Handles multiple aces: max one Ace as 11"

3. ✅ **Card Value Calculation:** Function assumes playerCards have `.rank` and `.value` properties. Consistent with architecture.

### Test Coverage Assessment

- ✅ Happy path tests included (hard 15 vs 3, soft 18 vs 10, pair of 8s)
- ✅ Lookup success test (exhaustive scan of all combos)
- ⚠️ Missing: Edge cases (pair of Aces, pair of 10s, soft 17 boundary)
- ⚠️ Missing: Invalid input tests (empty playerCards, null dealer card)

**Recommendation:** Add 2-3 edge case tests before merge.

---

## Architectural Assessment

### Pattern Correctness
✅ **CORRECT:** Implementation uses lookup table pattern, not algorithmic calculation.

This is the critical distinction for Blackjack basic strategy. Attempted alternatives:
- **WRONG:** `if (total <= 11) return 'H'; if (total >= 17) return 'S';` ← Oversimplifies strategy
- **WRONG:** Function that calculates "optimal" play based on hand values ← Misses split/double logic
- **CORRECT:** Pre-computed lookup table (this implementation) ← Handles all edge cases

### Integration Points
- Called by: Strategy Coach UI component on every player decision
- Dependency: None (pure function)
- Performance: O(1) lookup (excellent)

---

## Decision Accuracy

**Test:** Does this implementation produce strategically correct recommendations?

Spot checks:
- Hard 16 vs Dealer 7: Returns 'H' ✅ (correct: hit on 16 vs 7)
- Hard 17 vs Dealer 2: Returns 'S' ✅ (correct: stand on 17 vs 2)
- Soft 18 vs Dealer 9: Returns 'H' ✅ (correct: hit soft 18 vs 9)
- Pair of 8s vs Dealer 5: Returns 'P' ✅ (correct: split 8s)

**Verdict:** Strategy table values appear accurate to basic strategy reference.

---

## Overall Verdict

✅ **PASS — Ready for Integration**

This implementation correctly recognizes Blackjack basic strategy as a lookup table problem and solves it appropriately. The function is correct, efficient, and ready to integrate with the Strategy Coach UI component.

**Pre-merge checklist:**
- [ ] Add soft hand comment re: multiple aces
- [ ] Add 2-3 edge case tests
- [ ] Update getDealerIndex to use exported DEALER_CARDS constant
- [ ] Document return values (H/S/D/P mapping)

**Estimated review time to merge:** 30 minutes (for above fixes).
