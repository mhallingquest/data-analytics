"""
Trains two models per bracket (Men's/Women's):
  - Logistic Regression: interpretable baseline, coefficients show which
    stats actually matter
  - XGBoost: higher-capacity model, likely better raw accuracy

Evaluation uses a TIME-BASED split, not random shuffling — train on
earlier seasons, validate on the most recent 2 tournament seasons in the
data. This matters: a random split would let the model implicitly "see"
patterns from 2024 while training on 2023 games from the same season's
teams, which overstates real-world accuracy. A model deployed to predict
a brand-new season has never seen that season's teams before, so the
evaluation should reflect that.
"""
import pandas as pd
import numpy as np
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, log_loss, brier_score_loss
import xgboost as xgb
import pickle

FEATURE_COLS = [c for c in [
    "Diff_PointDiff", "Diff_AvgPointsFor", "Diff_AvgPointsAgainst",
    "Diff_FGPct", "Diff_FG3Pct", "Diff_FTPct", "Diff_AstToRatio",
    "Diff_AvgStl", "Diff_AvgBlk", "Diff_AvgTO", "Diff_SeedNum",
]]


def train_and_evaluate(prefix: str, val_seasons: int = 2):
    df = pd.read_csv(f"output/{prefix}_matchup_training_data.csv")
    df = df.dropna(subset=FEATURE_COLS)  # drop rows missing seed (very rare, e.g. First Four play-in oddities)

    seasons_sorted = sorted(df["Season"].unique())
    val_season_set = set(seasons_sorted[-val_seasons:])
    train_df = df[~df["Season"].isin(val_season_set)]
    val_df = df[df["Season"].isin(val_season_set)]

    X_train, y_train = train_df[FEATURE_COLS], train_df["Label"]
    X_val, y_val = val_df[FEATURE_COLS], val_df["Label"]

    results = {}

    # --- Logistic Regression baseline ---
    logreg = LogisticRegression(max_iter=1000)
    logreg.fit(X_train, y_train)
    val_probs_lr = logreg.predict_proba(X_val)[:, 1]
    results["logreg"] = {
        "model": logreg,
        "val_accuracy": accuracy_score(y_val, val_probs_lr > 0.5),
        "val_log_loss": log_loss(y_val, val_probs_lr),
        "val_brier": brier_score_loss(y_val, val_probs_lr),
    }

    # --- XGBoost ---
    xgb_model = xgb.XGBClassifier(
        n_estimators=150, max_depth=3, learning_rate=0.05,
        subsample=0.8, colsample_bytree=0.8, eval_metric="logloss",
    )
    xgb_model.fit(X_train, y_train)
    val_probs_xgb = xgb_model.predict_proba(X_val)[:, 1]
    results["xgboost"] = {
        "model": xgb_model,
        "val_accuracy": accuracy_score(y_val, val_probs_xgb > 0.5),
        "val_log_loss": log_loss(y_val, val_probs_xgb),
        "val_brier": brier_score_loss(y_val, val_probs_xgb),
    }

    print(f"\n=== {prefix} — validated on seasons {sorted(val_season_set)} "
          f"({len(val_df)} matchup rows, train on {len(train_df)} rows) ===")
    for name, r in results.items():
        print(f"  {name:10s}  accuracy={r['val_accuracy']:.3f}  "
              f"log_loss={r['val_log_loss']:.3f}  brier={r['val_brier']:.3f}")

    # Feature importance from logistic regression coefficients (interpretable)
    coef_df = pd.DataFrame({
        "feature": FEATURE_COLS,
        "coefficient": logreg.coef_[0],
    }).sort_values("coefficient", key=abs, ascending=False)
    print(f"  Top logreg coefficients (magnitude = importance):")
    for _, row in coef_df.head(5).iterrows():
        print(f"    {row['feature']:25s} {row['coefficient']:+.3f}")

    return results


if __name__ == "__main__":
    all_results = {}
    for prefix in ["M", "W"]:
        all_results[prefix] = train_and_evaluate(prefix)

        # Save the better-performing model (by log_loss) for prediction generation
        best_name = min(all_results[prefix], key=lambda k: all_results[prefix][k]["val_log_loss"])
        best_model = all_results[prefix][best_name]["model"]
        with open(f"output/{prefix}_best_model.pkl", "wb") as f:
            pickle.dump({"model": best_model, "model_type": best_name, "features": FEATURE_COLS}, f)
        print(f"  -> Saved best model: {best_name}")
