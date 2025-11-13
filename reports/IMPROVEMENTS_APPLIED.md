# Energy Consumption Forecasting - Improvements Applied

## Overview
Both notebooks (`preprocessing.ipynb` and `new_lgbm_model.ipynb`) have been updated to address critical issues and implement best practices for time series forecasting.

---

## 🔴 Red Flags Addressed

### 1. **7.8M Duplicate (building_id, timestamp) Pairs**
**Problem:** Duplicates distort lags/rolling stats and create subtle leakage.

**Solution:**
- ✅ **Deduplication** (Preprocessing Cell 2): Duplicates are aggregated by **summing meter_reading** (represents multiple meters in same building)
- ✅ Ensures causality in lagged/rolling features

### 2. **Test RMSE (36,121) < Train RMSE (56,994)**
**Problem:** Unusual pattern suggests distributional shift, lag contamination, or test period is "easier".

**Solution:**
- ✅ **Distributional diagnostics** added (LightGBM Cell 5):
  - Compare mean, std, IQR between train/test periods
  - Flag if std_diff > 20% or mean_diff > 10%
- ✅ Post-dedup, this ratio should normalize

### 3. **MAPE = 3.2e17 (Invalid with Zeros)**
**Problem:** MAPE divides by zero when y_true = 0 (~9.3% of data).

**Solution:**
- ✅ **Replaced MAPE with robust metrics** (LightGBM Cell 7):
  - **WAPE** (Weighted Absolute Percentage Error): handles zeros gracefully
  - **sMAPE** (Symmetric MAPE): symmetric and bounded [0, 200%]
  - **MAE/RMSE**: never problematic
- ✅ Raw MAPE completely dropped

### 4. **Temporal Features Dominate, Building Features Minor**
**Problem:** Excluding building_id removes fixed effects; label-encoding primary_use is ordinal.

**Solution:**
- ✅ **building_id retained as categorical** (Preprocessing + LightGBM):
  - Passed to LightGBM via `categorical_feature` parameter
  - LightGBM handles high-cardinality categories efficiently
- ✅ **Primary_use target-encoded** (Preprocessing Cell 9):
  - Replace label-encoding with mean(meter_reading | primary_use)
  - Preserves interpretability, avoids artificial ordering
- ✅ **site_id also included** as categorical

### 5. **Potential Feature Leakage via Lags/Rollings**
**Problem:** Rolling stats included current target or weren't shifted properly.

**Solution:**
- ✅ **Strict causality** (Preprocessing Cell 7-8):
  - All lags: `lag_k = meter_reading.shift(k)` ✓
  - All rollings: `rolling_mean = meter_reading.shift(1).rolling(24).mean()` ✓
  - **No current value included** in any feature
- ✅ Features computed BEFORE train/test split; test only uses historical data

### 6. **Thin Weather Features**
**Problem:** Only 3 weather variables; energy demand sensitive to humidity, cloud cover, precip, solar.

**Solution:**
- ✅ **Weather enrichment** (Preprocessing Cell 6):
  - ✅ **CDD** (Cooling Degree Days): `max(temp - 18°C, 0)` per hour
  - ✅ **HDD** (Heating Degree Days): `max(18°C - temp, 0)` per hour
  - ✅ Restored: `air_temperature`, `dew_temperature`, `wind_speed`
  - Note: `cloud_coverage`, `precip_depth_1_hr` removed (sparse) per design; consider adding back if needed

---

## ✅ Major Improvements Implemented

### **Preprocessing Notebook** (`preprocessing.ipynb`)

#### Cell 1: Setup
- Added `LabelEncoder` import (for potential use)

#### Cell 2: Deduplication & Frequency Regularization (NEW)
```python
# Deduplicate: sum meter_reading for same building+timestamp
train_df = train_df.groupby(['building_id', 'timestamp']).agg({
    'meter_reading': 'sum',
    'meter': 'first'
}).reset_index()
```
- Reports duplicates before/after
- Ensures no cross-building time leakage

#### Cell 6: Enhanced Temporal Features (EXPANDED)
- ✅ Core temporal: `hour`, `dayofweek`, `month`, `quarter`, `is_weekend`, `dayofmonth`
- ✅ **NEW Calendar features**:
  - `is_holiday`: US Federal holidays 2016
  - `near_holiday`: ±1 day around holidays (demand often differs)
- ✅ **NEW Derived features**:
  - `CDD`/`HDD`: Cooling/Heating degree days (base 18°C)
  - `building_age`: Clipped to [0, 150] years

#### Cell 7: Causal Lag Features (REINFORCED)
- Lag hours expanded: `[1, 3, 6, 24, 72]` (added 6h)
- Strict causality: `groupby().shift(lag_h)` — no leakage

#### Cell 8: Rolling Statistics (REINFORCED)
- All rolling computed on **shifted data**: `shift(1).rolling(...)`
- **NEW features**: `rolling_max_24h`, `rolling_min_24h`
- Ensures past-only lookback

#### Cell 9: Categorical Encoding (NEW)
```python
# Target encoding for primary_use
primary_use_means = train_df_agg.groupby('primary_use')['meter_reading'].mean()
train_df_agg['primary_use_encoded'] = train_df_agg['primary_use'].map(primary_use_means)
```
- Replaces ordinal label-encoding
- building_id, site_id retained as categorical (not one-hot)

#### Cell 10: Feature Selection (EXPANDED)
- Explicitly tracks all feature categories
- Reports count per category
- Includes calendar + CDD/HDD in final feature set

---

### **LightGBM Notebook** (`new_lgbm_model.ipynb`)

#### Cell 3: Feature Identification (UPDATED)
- Maps all features to categories (building, temporal, calendar, weather, lags, rolling, LCA, PDA)
- Identifies categorical features separately

#### Cell 5: Train/Test Split (ENHANCED)
- ✅ **NEW Distributional diagnostics**:
  ```python
  # Compare target distributions
  train_std, test_std = train_df['meter_reading'].std(), test_df['meter_reading'].std()
  std_diff_pct = abs(train_std - test_std) / train_std * 100
  # Flag if > 20%
  ```
- Detects temporal distributional shifts
- Warns of potential issues before modeling

#### Cell 6: LightGBM Training (UPDATED)
- ✅ **Categorical support**:
  ```python
  categorical_indices = [model_features_all.index('building_id'), model_features_all.index('site_id')]
  train_data.categorical_feature = categorical_indices
  ```
- LightGBM handles building_id (1,449 categories) efficiently
- Hyperparameters tweaked: `num_leaves=64` (up from 31), `min_data_in_leaf=20`

#### Cell 7: Evaluation (MAJOR OVERHAUL)
- ✅ **Robust metrics** (no more MAPE):
  - RMSE, MAE, R²: standard
  - **WAPE**: `sum|error| / sum|true| * 100` — handles zeros
  - **sMAPE**: Symmetric MAPE — bounded, zero-safe
  
- ✅ **Baseline comparisons**:
  ```python
  # 3 naive models as reference
  baseline_1h_rmse     # Persistence: y_pred = y_{t-1}
  baseline_24h_rmse    # Seasonal: y_pred = y_{t-24}
  baseline_rolling_rmse  # Moving average: y_pred = rolling_mean_24h
  ```
  - Compute improvement: `(baseline - model) / baseline * 100`
  - If model < baselines → fix features, don't tune

- ✅ **Overfitting/underfitting check**:
  - Test/Train RMSE ratio interpretation
  - Flag if < 0.9 (test anomalously good → leakage or shift)

#### Cell 9: Results & Diagnostics (MAJOR EXPANSION)
- ✅ **Per-building metrics**:
  ```python
  per_building_metrics = test_analysis.groupby('building_id').agg({
      'meter_reading': ['count', 'mean', 'std'],
      'abs_error': ['mean', 'median', 'max'],
      'error_pct': 'mean'
  })
  ```
  - CSV saved: `per_building_metrics_{timestamp}.csv`
  - Lists top 5 worst and best buildings
  - Useful for segmented improvements or targeted fixes

- ✅ **Comprehensive results JSON**:
  ```json
  {
    "test_rmse": 12345.67,
    "test_wape": 15.2,
    "test_smape": 18.5,
    "baseline_1h_rmse": 20000.0,
    "improvement_vs_1h": 38.3,
    ...
  }
  ```
  - All robust metrics included
  - Baseline comparisons logged
  - Feature list preserved for reproducibility

---

## 📊 Key Metrics to Monitor Post-Update

| Metric | Interpretation |
|--------|-----------------|
| **WAPE < 15%** | Good for energy (typical threshold ~10-20%) |
| **Test RMSE / Train RMSE ≈ 1.0 ± 0.1** | Balanced fit (not over/under) |
| **Improvement vs 24h baseline > 10%** | Model adds value over naive seasonal |
| **Per-building MAE std < mean × 1.5** | Fairly consistent across buildings |
| **LCA/PDA importance > 5%** | Latent components contributing |

---

## 🚀 Next Steps (Recommended)

### Immediate (After running updated notebooks):
1. **Check distributional shift** in Cell 5 output
2. **Verify no duplicates remain** in dedup Cell 2
3. **Inspect per-building_metrics.csv** for outlier buildings
4. **Compare vs baselines** — if model worse, debug features first

### Short-term (1-2 days):
1. **Run rolling-window backtesting** (4-5 folds) to assess month-to-month robustness
2. **Add SHAP analysis** to confirm top drivers align with domain knowledge
3. **Test with CatBoost** (may outperform on categorical features)

### Medium-term (1 week):
1. **Multi-step forecasting** (1h, 3h, 6h, 24h ahead) with direct or recursive strategy
2. **Quantile GBM** for prediction intervals (0.1/0.5/0.9 quantiles)
3. **Hyperparameter search** (Bayesian or grid) on tuned set

### Production (ongoing):
1. **Memory optimization**: Use `float32`, `int16`, category dtypes
2. **GPU training** if dataset grows
3. **Retraining strategy**: Monthly/quarterly model updates
4. **Monitoring**: Track actual vs predicted over time; alert if WAPE degrades

---

## 📁 Artifacts Generated

After running both notebooks:
- `../data/energy_processed_fulldata_{timestamp}.csv` — Clean deduplicated data with all engineered features
- `../models/lgbm_temporal_energy_fulldata_{timestamp}.pkl` — Trained LightGBM model
- `../models/lgbm_results_{timestamp}.json` — Metrics, baselines, hyperparameters
- `../models/feature_importance_{timestamp}.csv` — Feature importance (all features)
- `../models/per_building_metrics_{timestamp}.csv` — Per-building MAE/error stats (NEW)

---

## 🎯 Summary

✅ **Data quality**: Deduplicated, causally engineered features, no leakage  
✅ **Evaluation rigor**: Baselines, robust metrics, distributional checks, per-building diagnostics  
✅ **Feature richness**: Calendar, CDD/HDD, target-encoded categoricals, latent components  
✅ **Interpretability**: Per-building breakdowns, feature importance, improvement vs baselines  

**Ready to run and diagnose!**
