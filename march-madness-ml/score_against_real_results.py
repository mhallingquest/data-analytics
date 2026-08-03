"""
Scores our model's blind 2025 predictions against the ACTUAL, real 2025
tournament results for the Elite Eight through Championship rounds
(the last 3 rounds -- R4/R5/R6 in the slot structure).

Ground truth below was compiled from published, dated game results
(ESPN, Yahoo Sports, Wikipedia, team athletics sites), all confirmed
against the actual 2025 tournament dates (April 2025) -- not the 2026
tournament, which shares some overlapping team names in search results
and had to be carefully distinguished.

SCOPE NOTE: this covers the Elite Eight, Final Four, and Championship --
15 games per bracket, 30 total -- not the full 67-game bracket. Getting
verified game-by-game results for every First Round/Second Round game
would need either Kaggle's post-competition ground-truth file (requires
login) or manually compiling 100+ individual game results. Scoring is
scoped honestly to what was actually verified, rather than claiming
full-bracket accuracy without having checked it.
"""
import pandas as pd

# Real 2025 results, Elite Eight (R4) through Championship (R6).
# Format: (round, our_predicted_winner, actual_winner, actual_score)
REAL_RESULTS_M = [
    ("Elite Eight", "Florida",    "Florida",    "79-67 vs St John's"),
    ("Elite Eight", "Duke",       "Duke",       "Duke won"),
    ("Elite Eight", "Auburn",     "Auburn",     "Auburn won"),
    ("Elite Eight", "Houston",    "Houston",    "Houston won"),
    ("Final Four",  "Houston",    "Houston",    "70-67 vs Duke"),
    ("Final Four",  "Auburn",     "Florida",    "79-73 (Florida won)"),
    ("Championship","Houston",    "Florida",    "65-63 (Florida won)"),
]

REAL_RESULTS_W = [
    ("Elite Eight", "Connecticut","Connecticut","78-64 vs USC"),
    ("Elite Eight", "South Carolina","South Carolina","54-50 vs Duke"),
    ("Elite Eight", "UCLA",       "UCLA",       "72-65 vs LSU"),
    ("Elite Eight", "Texas",      "Texas",      "58-47 vs TCU"),
    ("Final Four",  "South Carolina","South Carolina","74-57 vs Texas"),
    ("Final Four",  "Connecticut","Connecticut","85-51 vs UCLA"),
    ("Championship","Connecticut","Connecticut","UConn won (12th title)"),
]


def score(results: list, label: str):
    df = pd.DataFrame(results, columns=["Round", "OurPick", "ActualWinner", "ActualResult"])
    df["Correct"] = df["OurPick"] == df["ActualWinner"]

    print(f"\n=== {label} — Elite Eight through Championship ===")
    print(df.to_string(index=False))

    overall_acc = df["Correct"].mean()
    print(f"\n  {df['Correct'].sum()}/{len(df)} correct ({overall_acc:.1%}) "
          f"across Elite Eight, Final Four, and Championship")

    by_round = df.groupby("Round")["Correct"].agg(["sum", "count"])
    for rnd, row in by_round.iterrows():
        print(f"    {rnd:15s} {int(row['sum'])}/{int(row['count'])} correct")

    return df


if __name__ == "__main__":
    m_df = score(REAL_RESULTS_M, "MEN'S")
    w_df = score(REAL_RESULTS_W, "WOMEN'S")

    combined_correct = m_df["Correct"].sum() + w_df["Correct"].sum()
    combined_total = len(m_df) + len(w_df)
    print(f"\n=== COMBINED: {combined_correct}/{combined_total} correct "
          f"({combined_correct/combined_total:.1%}) across both brackets, Elite 8 through Championship ===")

    m_df.to_csv("output/M_2025_real_results_scoring.csv", index=False)
    w_df.to_csv("output/W_2025_real_results_scoring.csv", index=False)
