"""
Simulates the real 2025 tournament bracket, round by round, using the
trained model's win probabilities to pick a winner at each slot.

The slot structure is inherently sequential: First Four games resolve
first (producing a seed like "W16" from "W16a" vs "W16b"), then Round 1
uses actual seeds, then each subsequent round references the WINNER of
specific earlier slots rather than a fixed team. We process slots in
round order so every dependency is already resolved by the time we need it.

Picks the higher-probability team at each step (deterministic "most likely
bracket," the standard way these Kaggle-style bracket challenges are
typically visualized) rather than randomly sampling from the probability.
"""
import pandas as pd
import pickle

TARGET_SEASON = 2025

ROUND_ORDER = ["First4", "R1", "R2", "R3", "R4", "R5", "R6"]


def slot_round(slot_name: str) -> str:
    if slot_name[0] in ("W", "X", "Y", "Z") and len(slot_name) <= 3:
        return "First4"  # e.g. "W16", "X11" -- the First Four slot names themselves
    return slot_name[:2]  # "R1", "R2", etc.


def simulate_bracket(prefix: str) -> pd.DataFrame:
    slots = pd.read_csv(f"data/{prefix}NCAATourneySlots.csv")
    slots = slots[slots["Season"] == TARGET_SEASON].copy()
    slots["Round"] = slots["Slot"].apply(slot_round)
    slots["RoundIdx"] = slots["Round"].apply(lambda r: ROUND_ORDER.index(r))
    slots = slots.sort_values("RoundIdx")

    seeds = pd.read_csv(f"data/{prefix}NCAATourneySeeds.csv")
    seeds_2025 = seeds[seeds["Season"] == TARGET_SEASON]
    seed_to_team = dict(zip(seeds_2025["Seed"], seeds_2025["TeamID"]))

    teams = pd.read_csv(f"data/{prefix}Teams.csv")
    team_name = dict(zip(teams["TeamID"], teams["TeamName"]))

    features = pd.read_csv(f"output/{prefix}_team_season_features.csv")
    feat_lookup = features[features["Season"] == TARGET_SEASON].set_index("TeamID")

    with open(f"output/{prefix}_best_model.pkl", "rb") as f:
        saved = pickle.load(f)
    model, feature_cols = saved["model"], saved["features"]

    def predict_prob(team_a: int, team_b: int) -> float:
        a, b = feat_lookup.loc[team_a], feat_lookup.loc[team_b]
        diffs = {col: a[col.replace("Diff_", "")] - b[col.replace("Diff_", "")] for col in feature_cols}
        X = pd.DataFrame([diffs])[feature_cols]
        return model.predict_proba(X)[0, 1]

    # slot_winner maps a resolved slot name -> the winning TeamID
    slot_winner = {}

    def resolve(seed_or_slot: str) -> int:
        """Resolves either a direct seed code (e.g. 'W01') or a previously
        decided slot (e.g. 'R1W1') into an actual TeamID."""
        if seed_or_slot in seed_to_team:
            return seed_to_team[seed_or_slot]
        if seed_or_slot in slot_winner:
            return slot_winner[seed_or_slot]
        raise KeyError(f"Could not resolve '{seed_or_slot}' -- dependency not yet processed")

    results = []
    for _, row in slots.iterrows():
        team_a = resolve(row["StrongSeed"])
        team_b = resolve(row["WeakSeed"])

        prob_a = predict_prob(team_a, team_b)
        winner = team_a if prob_a >= 0.5 else team_b
        winner_prob = prob_a if winner == team_a else 1 - prob_a

        slot_winner[row["Slot"]] = winner

        results.append({
            "Round": row["Round"],
            "Slot": row["Slot"],
            "TeamA": team_name.get(team_a, team_a),
            "TeamB": team_name.get(team_b, team_b),
            "PredictedWinner": team_name.get(winner, winner),
            "WinnerTeamID": winner,
            "Confidence": round(winner_prob, 3),
        })

    return pd.DataFrame(results)


if __name__ == "__main__":
    for prefix in ["M", "W"]:
        bracket = simulate_bracket(prefix)
        bracket.to_csv(f"output/{prefix}_2025_predicted_bracket.csv", index=False)
        champ_row = bracket[bracket["Slot"] == "R6CH"].iloc[0]
        print(f"{prefix}: {len(bracket)} games simulated. "
              f"Predicted champion: {champ_row['PredictedWinner']} "
              f"({champ_row['Confidence']:.1%} confidence in final)")
