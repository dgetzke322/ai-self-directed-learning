# Blackjack Game UX Specification

---

## Layout (Desktop & Mobile)

**Game Board** (375px+ width)
```
┌────────────────────────────────────┐
│  Dealer Hand       [7♠] [🂠]       │
│  Dealer Total: 7 (hole card hidden)│
│                                    │
├────────────────────────────────────┤
│  Strategy Coach:  Optimal: Hit     │
│  Accuracy: 5/7 (71%)               │
│                                    │
├────────────────────────────────────┤
│  Your Hand         [K♣] [5♥]       │
│  Your Total: 15 (Hard)             │
│                                    │
│  [HIT]  [STAND]  [DOUBLE] [SPLIT]  │
│                                    │
├────────────────────────────────────┤
│  Last Hand: WIN (+$100)            │
│                                    │
│  [NEW GAME]                        │
└────────────────────────────────────┘
```

---

## Component Specs

### Dealer Hand Panel
- **Display:** Two card slots; one face-up, one hidden (🂠)
- **Reveal:** When player stands, show hole card with animation
- **Total:** Show calculated total after reveal
- **State:** Empty → Deal → Hidden → Revealed

### Strategy Coach Panel
- **Position:** Above game board, high visibility
- **Content:** "Optimal: [Hit | Stand | Double | Split]"
- **Style:** Green background, large text
- **Update:** Every player action decision point

### Player Hand Panel
- **Display:** Card slots (up to 2 for split)
- **Total:** Calculate and show (e.g., "15 - Hard Hand")
- **Soft indicator:** "Soft" if Ace counts as 11, "Hard" if Ace as 1
- **Split indicator:** If split possible, show "(Can Split)"

### Action Buttons
- **States:** Available, Disabled, Loading, Completed
- **Hit:** Always available until stand/bust
- **Stand:** Always available
- **Double:** Available only on first move
- **Split:** Available only if two cards same rank
- **Touch target:** 44px+ height for mobile
- **Spacing:** 8px between buttons

### Accuracy Tracker
- **Display:** "Accuracy: 5/7 (71%)"
- **Update:** After each decision
- **Reset:** On new game button
- **Visual:** Progress bar optional

### Game Status Messages
- **Your turn:** "Your move — Optimal: Hit"
- **Dealer playing:** "Dealer reveals: K♠. Dealer hits on 16..."
- **Game end:** "You Win! +$100" or "Bust — You Lose" or "Push"

---

## Interaction Flows

### Flow 1: Deal Hand
1. Player clicks [NEW GAME]
2. Dealer deals 2 cards to player, 2 to dealer (one hidden)
3. Strategy coach displays optimal first action
4. Player can Hit/Stand/Double/Split

### Flow 2: Player Action
1. Player clicks action button
2. Button disables temporarily (loading state)
3. If Hit: card dealt, new total calculated
4. If Stand: transition to dealer play
5. Strategy coach updates for next decision (if Hit)

### Flow 3: Dealer Play
1. Dealer reveals hole card
2. Dealer hits/stands automatically per rules
3. Final totals displayed
4. Outcome shown (Win/Lose/Push)
5. Accuracy updated (player's actions vs optimal)

### Flow 4: Accuracy Assessment
1. Each player action compared to optimal
2. Marker shown (✓ Correct or ✗ Incorrect)
3. Running total updated
4. Percentage calculated

---

## State Handling

### Empty State
- Before first game: "Click [NEW GAME] to start"

### Loading State
- Action buttons show spinner while processing
- Strategy coach shows spinner while lookup runs

### Game States
- **Dealing:** Cards being distributed
- **Player Turn:** Waiting for player action
- **Dealer Turn:** Showing dealer play (auto)
- **Game Over:** Showing outcome

### Error States
- Strategy lookup failed: "Coach unavailable" (fallback to basic rules)
- Invalid action: "Action not allowed" + reason

---

## Mobile Specifics

### Layout (375px width)
- Single column, cards stack vertically
- Dealer hand, strategy coach, player hand in that order
- Buttons stack vertically or 2-column grid
- No horizontal scroll

### Performance
- Card animation: <300ms
- Strategy coach lookup: <500ms
- Button response: <200ms

### Touch
- Buttons 44px+ height
- 12px+ padding inside buttons
- Tap target spacing: 8px minimum

---

## Accessibility

- **Keyboard navigation:** Tab through buttons, Enter to click
- **Screen reader:** Card descriptions (e.g., "King of Clubs"), button labels clear
- **Color contrast:** Text on backgrounds meet WCAG AA (4.5:1 minimum)
- **No flash:** Animations under 3 Hz
- **Button labels:** Explicit text, not just icons

---

## Future Enhancements (Not V1)

- Hand split display (two hands side-by-side)
- Betting interface
- Hand statistics (lifetime accuracy, hands played)
- Difficulty modes (coach always on, off, hidden)
