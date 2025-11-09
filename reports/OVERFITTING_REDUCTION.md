# Model Improvements - Overfitting Reduction & Seasonal Validation

## Summary of Changes (November 9, 2025)

### ✅ Created: Rolling Window Backtesting Notebook
**File:** `notebooks/model_comparison_and_backtesting.ipynb`

**What it does:**
1. **Compares baseline vs enhanced model** side-by-side
2. **Rolling window validation:** Train on Jan→Feb, Jan-Feb→Mar, etc.
3. **Exposes seasonal failures:** Which months are hardest to predict?
4. **Analyzes summer/winter imbalance**

### ✅ Reduced Overfitting in Main Model
**File:** `notebooks/new_lgbm_model.ipynb` (Cell 6)

**Parameter Changes:**
- `num_leaves`: 64 → **48** (simpler trees)
- `max_depth`: 10 → **8** (shallower trees)
- `min_data_in_leaf`: 20 → **50** (more data per leaf)
- `lambda_l1`: 0.1 → **0.3** (stronger L1 regularization)
- `lambda_l2`: 0.1 → **0.3** (stronger L2 regularization)
- `feature_fraction`: 0.85 → **0.80** (more sampling)
- `bagging_fraction`: 0.85 → **0.80** (more sampling)
- **Added:** `min_gain_to_split: 0.01`

**Expected Result:**
- Test/Train RMSE ratio: 1.10 → **1.05-1.08**
- More reliable predictions
- Better generalization to unseen data

---

## How to Run

### Step 1: Re-run Training with Regularization
```bash
cd notebooks
# Run new_lgbm_model.ipynb (all cells)
```

**Watch for:**
- Test/Train RMSE ratio (should be closer to 1.0)
- Test RMSE may be slightly higher but more stable

### Step 2: Run Comparison & Backtesting
```bash
# Run model_comparison_and_backtesting.ipynb (all cells)
```

**Outputs:**
- `reports/model_comparison.png` - Visual comparison
- `reports/rolling_window_backtest.csv` - Monthly results
- `reports/rolling_window_seasonal_analysis.png` - Seasonal trends

---

## Success Criteria

✅ **Keep Enhanced Model If:**
- Test RMSE < Baseline RMSE
- Test/Train ratio < 1.10
- Seasonal variability < 30 kWh
- No single month RMSE > 250 kWh

❌ **Revert to Baseline If:**
- Test RMSE worse than baseline
- Test/Train ratio > 1.15
- Extreme seasonal imbalance (>50 kWh range)

---

## Interpreting Rolling Window Results

### Good Stability Example:
```
Feb: 175 kWh | Mar: 172 kWh | Apr: 178 kWh → ±3 kWh (EXCELLENT)
```

### Poor Stability Example:
```
Feb: 150 kWh | Jun: 220 kWh | Dec: 160 kWh → ±35 kWh (PROBLEM)
→ June needs attention (add cooling features?)
```

---

## Generated Files

- ✅ `model_comparison_and_backtesting.ipynb`
- ✅ `new_lgbm_model.ipynb` (updated parameters)

**After running:**
- 📊 `reports/model_comparison.png`
- 📊 `reports/rolling_window_backtest.csv`
- 📊 `reports/rolling_window_seasonal_analysis.png`
