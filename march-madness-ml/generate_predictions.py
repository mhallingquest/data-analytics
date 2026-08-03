"""
Generates win probability predictions for every possible pairing among the
2025 tournament teams, using the trained model and each team's 2024-25
regular season features. This matches the actual Kaggle competition
submission format (every possible matchup, not just the ones that
actually happened in the real bracket) — necessary because we don't know
in advance which teams will face each other until earlier rounds play out.
"""
import pandas as pd
import pickle
from itertools import combinations

TARGET_SEASON = 2025


def generate_2025_predictions(prefix: str) -> pd.DataFrame:
    features = pd.read_csv(f"output/{prefix}_team_season_features.csv")
    season_feats = features[features["Season"] == TARGET_SEASON].copy()
    season_feats = season_feats[season_feats["SeedNum"].notna()]  # only tournament teams

    with open(f"output/{prefix}_best_model.pkl", "rb") as f:
        saved = pickle.load(f)
    model = saved["model"]
    feature_cols = saved["features"]

    feat_lookup = season_feats.set_index("TeamID")
    team_ids = sorted(season_feats["TeamID"].unique())

    rows = []
    for team_a, team_b in combinations(team_ids, 2):
        a_feats = feat_lookup.loc[team_a]
        b_feats = feat_lookup.loc[team_b]

        # Build the diff feature vector, mapping "Diff_X" -> a_feats[X] - b_feats[X]
        diffs = {}
        for col in feature_cols:
            base_col = col.replace("Diff_", "")
            diffs[col] = a_feats[base_col] - b_feats[base_col]

        X = pd.DataFrame([diffs])[feature_cols]
        prob_a_wins = model.predict_proba(X)[0, 1]

        rows.append({
            "Season": TARGET_SEASON,
            "TeamA": team_a,
            "TeamB": team_b,
            "ProbAWins": prob_a_wins,
        })

    return pd.DataFrame(rows)


if __name__ == "__main__":
    for prefix in ["M", "W"]:
        preds = generate_2025_predictions(prefix)
        preds.to_csv(f"output/{prefix}_2025_matchup_predictions.csv", index=False)
        print(f"{prefix}: {len(preds)} pairwise predictions generated for 2025")
