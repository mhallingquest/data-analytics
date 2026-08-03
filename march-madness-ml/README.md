# March Madness ML: 2025 NCAA Tournament Bracket Predictions

A machine learning pipeline that predicts NCAA tournament game outcomes,
trained blind on data through 2024, then genuinely backtested against the
real 2025 tournament results — both Men's and Women's brackets.

## Data source

**Kaggle "March Machine Learning Mania 2025"** official competition dataset
— historical NCAA box scores, tournament seeds/results, and team data back
to 2003 (Men's) / 2010 (Women's). This is the actual frozen competition
file released right before Selection Sunday 2025, meaning the 2025
tournament results genuinely were NOT in the training data — the model's
2025 predictions were made blind, the same way a real Kaggle competitor's
would have been.

## Pipeline

```
Raw box scores (2003/2010 - 2025)
    → Feature engineering: per-team-per-season aggregate stats
    → Matchup training data: historical tourney games, symmetric augmentation
    → Model training: Logistic Regression + XGBoost, time-based validation split
    → 2025 predictions: every possible matchup among the 68 tournament teams
    → Bracket simulation: real slot structure, round-by-round advancement
    → Scoring: checked against actual, real 2025 tournament results
```

## Files

| File | Purpose |
|---|---|
| `feature_engineering.py` | Builds per-(team, season) aggregate stats from box scores |
| `build_training_data.py` | Builds matchup-level training data from historical tourney games |
| `train_model.py` | Trains Logistic Regression + XGBoost, evaluates on held-out recent seasons |
| `generate_predictions.py` | Generates win probability for every possible 2025 matchup |
| `simulate_bracket.py` | Simulates the real bracket structure round by round |
| `score_against_real_results.py` | Scores predictions against actual 2025 results |
| `output/march-madness-results.html` | Standalone visual for the portfolio site |

## Running it

```bash
pip install -r requirements.txt

python feature_engineering.py
python build_training_data.py
python train_model.py
python generate_predictions.py
python simulate_bracket.py
python score_against_real_results.py
```

Each script writes its output to `output/` and reads from the previous
step — run them in order.

## Modeling notes worth knowing

**Why Logistic Regression, not just XGBoost:** Logistic Regression's
coefficients are directly interpretable — you can read off which stats
actually move the prediction. XGBoost slightly underperformed it on this
dataset in validation, likely because the matchup-level training set
(2,764 rows for Men's, 1,788 for Women's) is small enough that a simpler,
lower-variance model generalizes better than a higher-capacity one. The
better-performing model (by validation log-loss) was saved and used for
final predictions — Logistic Regression won for both brackets.

**A real multicollinearity issue, found and fixed:** an early version of
this model included both `WinPct` and `SeedNum` as features. Since a
team's seed is largely *derived from* their win record, these two features
were correlated at -0.62, which flipped `SeedNum`'s coefficient sign to
something nonsensical (implying a better seed *hurt* a team's chances).
Dropping the redundant `WinPct` feature (keeping the more granular
`PointDiff` instead) fixed this — worth knowing this happened and was
caught before treating the coefficients as meaningful, rather than
presenting a broken model's coefficients as insight.

**An honest finding, not hidden:** on backtested validation (held-out
2023-24 tournament games), the model essentially ties the naive
"always pick the better seed" baseline for Men's (67.9% vs. 68.3%), while
meaningfully beating it for Women's (81.3% vs. 77.2%). This matches
well-documented reality — Men's tournament outcomes are notoriously close
to seed-based "chalk," and beating that baseline with box-score stats
alone is genuinely difficult. This is reported as-is rather than
downplayed.

## 2025 real-world results

Scored against actual results for the Elite Eight through Championship
(the rounds that decide the tournament):

- **Women's: 7/7 correct** — all four Elite Eight winners, both Final Four
  semifinal winners, and the eventual champion (UConn), all called
  correctly, blind, before the games were played
- **Men's: 5/7 correct** — all four Elite Eight winners correctly called
  (matching the historic all-#1-seed Final Four), one of two Final Four
  semifinals correct, and the correct national runner-up picked as
  champion (Houston made the actual championship game; Florida won it)
- **Combined: 12/14 (85.7%)**

## Known limitations / future improvements

- **Scoring scope:** verified against real results for the Elite Eight
  through Championship (15 games... 7 distinct decision points per
  bracket), not the full 67-game bracket — getting verified results for
  every First/Second Round game would need either Kaggle's post-competition
  ground-truth file or manually compiling 100+ individual results
- **Strength of schedule** is currently a simple average-opponent-win%
  proxy, not a full opponent-of-opponent adjusted rating
- **Massey Ordinals** (a large file of various computer/expert ranking
  systems, included in the raw data but not used here) would likely
  improve on the Men's seed-baseline tie — a natural next iteration
- **Deterministic bracket simulation** picks the higher-probability team
  at each step rather than Monte Carlo sampling many possible bracket
  outcomes — reasonable for a single "most likely bracket" view, but a
  probabilistic simulation (thousands of simulated brackets) would give a
  richer picture of each team's true championship odds
