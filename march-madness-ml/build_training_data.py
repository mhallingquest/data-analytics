"""
Builds a matchup-level training dataset from historical tournament games.

Each historical tournament game becomes TWO training rows (Team A vs Team B
labeled 1, and Team B vs Team A labeled 0) — this symmetric augmentation is
important: without it, a model could learn to just always predict "the
first-listed team wins," which is a spurious pattern, not a real signal.

Features are DIFFERENCES between the two teams' season stats (TeamA - TeamB)
plus the seed difference — this framing means the model predicts
"does Team A beat Team B" as a function of how much better Team A's stats
are, which generalizes to any hypothetical matchup, not just ones seen in
training.
"""
import pandas as pd

FEATURE_COLS = [
    "WinPct", "PointDiff", "AvgPointsFor", "AvgPointsAgainst",
    "FGPct", "FG3Pct", "FTPct", "AstToRatio", "AvgStl", "AvgBlk", "AvgTO",
    "SeedNum",
]


def build_matchup_training_data(data_dir: str, output_dir: str, prefix: str) -> pd.DataFrame:
    features = pd.read_csv(f"{output_dir}/{prefix}_team_season_features.csv")
    tourney_results = pd.read_csv(f"{data_dir}/{prefix}NCAATourneyCompactResults.csv")

    feat_lookup = features.set_index(["Season", "TeamID"])

    rows = []
    for _, game in tourney_results.iterrows():
        season = game["Season"]
        wteam, lteam = game["WTeamID"], game["LTeamID"]

        try:
            w_feats = feat_lookup.loc[(season, wteam)]
            l_feats = feat_lookup.loc[(season, lteam)]
        except KeyError:
            continue  # team missing season stats (rare, early years) -- skip

        # Row 1: winner as "Team A" -> label 1
        diff_w = {f"Diff_{c}": w_feats[c] - l_feats[c] for c in FEATURE_COLS}
        rows.append({**diff_w, "Season": season, "Label": 1})

        # Row 2: loser as "Team A" -> label 0 (mirrors the same game)
        diff_l = {f"Diff_{c}": l_feats[c] - w_feats[c] for c in FEATURE_COLS}
        rows.append({**diff_l, "Season": season, "Label": 0})

    return pd.DataFrame(rows)


if __name__ == "__main__":
    for prefix in ["M", "W"]:
        matchups = build_matchup_training_data("data", "output", prefix)
        matchups.to_csv(f"output/{prefix}_matchup_training_data.csv", index=False)
        print(f"{prefix}: {len(matchups)} training rows "
              f"({matchups['Season'].nunique()} tournament seasons), "
              f"label balance: {matchups['Label'].mean():.3f}")
