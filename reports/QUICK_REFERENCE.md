# Quick Reference: Model Comparison & Validation

## 🎯 What Was Done

### 1. **Reduced Overfitting**
Updated `new_lgbm_model.ipynb` with stronger regularization to bring test and train RMSE closer together.

### 2. **Created Rolling Window Backtesting**
New notebook: `model_comparison_and_backtesting.ipynb` that trains incrementally (Jan→Feb, Jan-Feb→Mar, etc.) to expose seasonal weaknesses.

---

## 🚀 Quick Start

### Run This First:
```bash
cd /Users/saatwik/Documents/Energy-consumption-forecasting/notebooks

# 1. Run training with reduced overfitting
# Open: new_lgbm_model.ipynb → Run All Cells

# 2. Run comparison and backtesting
# Open: model_comparison_and_backtesting.ipynb → Run All Cells
```

---

## 📊 What to Check

### After Running new_lgbm_model.ipynb:

Look for this in Cell 7 output:
```
Test/Train RMSE ratio: X.XXXX
```

**Interpretation:**
- ✅ 1.00 - 1.08: Good generalization
- ⚠️ 1.08 - 1.15: Acceptable
- ❌ > 1.15: Still overfitting

### After Running model_comparison_and_backtesting.ipynb:

**Part 1: Model Comparison**
```
Baseline:  181.63 kWh
Enhanced:  XXX.XX kWh

✅ Enhanced is better if: < 181.63
⚠️ Acceptable if: 181-190
❌ Revert if: > 190
```

**Part 2: Seasonal Stability**
```
RMSE variability across months: ± XX.XX kWh

✅ Stable: < 20 kWh
⚠️ Moderate: 20-40 kWh
❌ Unstable: > 40 kWh
```

**Part 3: Worst Month**
```
Worst forecast: [Month Name]
RMSE: XXX.XX kWh

If > 250 kWh → That month needs attention
```

---

## 🔍 Outputs to Review

| File | What It Shows |
|------|---------------|
| `reports/model_comparison.png` | Baseline vs Enhanced side-by-side |
| `reports/rolling_window_backtest.csv` | Detailed monthly forecast results |
| `reports/rolling_window_seasonal_analysis.png` | RMSE/MAE/R² trends by month |

---

## ✅ Decision Tree

```
Did test RMSE improve?
├─ YES → Is Test/Train ratio < 1.10?
│  ├─ YES → Is seasonal variability < 30 kWh?
│  │  ├─ YES → ✅ KEEP enhanced model
│  │  └─ NO → ⚠️ Keep but investigate worst month
│  └─ NO → ⚠️ Model still overfitting, consider more regularization
└─ NO → ❌ REVERT to baseline (say "REVERT BACK")
```

---

## 🔧 If You Need to Revert

Simply say: **"REVERT BACK"**

Or manually:
1. Delete latest model files in `models/`
2. Use backup from `.backup_baseline_20251109/`

---

## 📝 Key Metrics Cheat Sheet

| Metric | Good | Acceptable | Bad |
|--------|------|------------|-----|
| Test RMSE | < 175 | 175-190 | > 190 |
| Test/Train Ratio | < 1.08 | 1.08-1.15 | > 1.15 |
| Seasonal Variability | < 20 | 20-40 | > 40 |
| R² | > 0.98 | 0.97-0.98 | < 0.97 |

---

## 💡 Tips

1. **If test RMSE increases slightly:** This is OK if Test/Train ratio improves (less overfitting = more reliable)

2. **If one month is terrible:** Check that month's weather features - may need season-specific model

3. **If summer/winter imbalance:** Add more CDD (cooling) or HDD (heating) features

4. **If still overfitting:** Increase `lambda_l1` and `lambda_l2` to 0.5, reduce `max_depth` to 6

---

Files: `reports/OVERFITTING_REDUCTION.md` (full details)
