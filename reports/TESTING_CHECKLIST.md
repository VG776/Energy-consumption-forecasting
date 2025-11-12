# Testing Checklist - Model Enhancements

## Pre-Testing (Baseline)
- [x] Baseline RMSE: 181.63 kWh
- [x] Baseline MAE: 47.02 kWh
- [x] Baseline R²: 0.9826
- [x] Baseline features: 20
- [x] Backup created: `.backup_baseline_20251109/`

---

## During Testing

### Preprocessing Phase (preprocessing.ipynb)
Run all cells and check:

- [ ] **Cell 5 (Outlier Removal)**: No errors, shows std reduction
- [ ] **Cell 6 (Weather Features)**: 
  - [ ] `relative_humidity` calculated successfully
  - [ ] Values between 0-100%
  - [ ] No NaN warnings
- [ ] **Cell 8 (Rolling Features)**: Completes without errors
- [ ] **Cell 8.5 (Trend Features)**: ⭐ NEW CELL
  - [ ] `slope_6h` created
  - [ ] `slope_12h` created
  - [ ] `delta_24h` created
  - [ ] `acceleration_6h` created
  - [ ] No excessive NaNs (only at series start)
- [ ] **Cell 10 (Feature Selection)**:
  - [ ] Shows ~31 total features (up from 20)
  - [ ] Lists trend_features correctly
  - [ ] Lists enhanced weather features
- [ ] **Cell 11 (Save Data)**:
  - [ ] Creates new `energy_processed_fulldata_{timestamp}.csv`
  - [ ] File size reasonable (~1-2GB)
  - [ ] No errors saving

**Expected Output:**
```
✓ Trend features: 4
✓ Enhanced weather: 8 (air_temp, CDD, HDD, RH, cloud, precip, has_precip, pressure)
✓ Total features: ~31
```

### Training Phase (new_lgbm_model.ipynb)
Run all cells and check:

- [ ] **Cell 1 (Load Data)**: Loads new preprocessed file
- [ ] **Cell 3 (Feature Identification)**: Shows ~31 features
- [ ] **Cell 6 (Training)**: 
  - [ ] Training completes in reasonable time (<30 min)
  - [ ] Early stopping triggers (not hitting 1000 rounds)
  - [ ] No memory errors
- [ ] **Cell 7 (Evaluation)**:
  - [ ] ⭐ **NEW RMSE < 181.63 kWh** (improvement)
  - [ ] ⭐ **NEW MAE < 47.02 kWh** (improvement)
  - [ ] R² > 0.98 (maintained)
  - [ ] WAPE reasonable (<10%)
- [ ] **Cell 8 (Feature Importance)**:
  - [ ] Trend features appear in top 20
  - [ ] Weather features show importance
  - [ ] No single feature dominates (>50%)
- [ ] **Cell 9 (Save Model)**:
  - [ ] Model saves to `../models/lgbm_temporal_energy_fulldata_{timestamp}.pkl`
  - [ ] Results save to `../models/lgbm_results_{timestamp}.json`
  - [ ] Temporal metrics save to `../reports/temporal_metrics_{timestamp}.csv`
- [ ] **Cell 10 (Temporal Viz)**:
  - [ ] `temporal_analysis_{timestamp}.png` created in reports/
  - [ ] `weekly_analysis_{timestamp}.png` created in reports/
  - [ ] Plots show good actual vs predicted alignment
- [ ] **Cell 11 (Comprehensive Viz)**: ⭐ NEW CELL
  - [ ] `comprehensive_analysis_{timestamp}.png` created in reports/
  - [ ] All 7 subplots render correctly
  - [ ] Residual distribution looks normal
  - [ ] Actual vs Predicted scatter tight around diagonal
  - [ ] Hourly/weekly box plots show patterns

---

## Post-Testing Evaluation

### Performance Comparison
Open `lgbm_results_{timestamp}.json` and compare:

| Metric | Baseline | New Model | Change | Status |
|--------|----------|-----------|--------|--------|
| RMSE | 181.63 | _______ | ______% | [ ] Better / [ ] Worse |
| MAE | 47.02 | _______ | ______% | [ ] Better / [ ] Worse |
| R² | 0.9826 | _______ | _______ | [ ] Better / [ ] Worse |
| WAPE | 8.05% | _______ | ______% | [ ] Better / [ ] Worse |

### Feature Analysis
Check `feature_importance_{timestamp}.csv`:

- [ ] **Trend features in top 20?**
  - [ ] `slope_6h` rank: _____
  - [ ] `slope_12h` rank: _____
  - [ ] `delta_24h` rank: _____
  - [ ] `acceleration_6h` rank: _____

- [ ] **Weather features important?**
  - [ ] `relative_humidity` rank: _____
  - [ ] `cloud_coverage` rank: _____
  - [ ] `CDD` rank: _____
  - [ ] `HDD` rank: _____

### Visualization Insights
Open `comprehensive_analysis_{timestamp}.png`:

- [ ] **Residual distribution**: Centered at 0? Bell-shaped?
- [ ] **Actual vs Predicted**: Points tight around diagonal?
- [ ] **Hourly box plots**: Consistent errors or spikes at certain hours?
- [ ] **Monthly trends**: Performance stable across months?
- [ ] **Day-of-week**: Weekend vs weekday differences reasonable?

---

## Decision Point

### ✅ KEEP ENHANCEMENTS IF:
- [ ] RMSE improved by ≥5% (< 172.5 kWh)
- [ ] MAE improved by ≥3% (< 45.6 kWh)
- [ ] R² maintained (≥0.980)
- [ ] Trend/weather features appear important
- [ ] Visualizations show good predictions
- [ ] No training errors or excessive time

**→ Document success in ENHANCEMENT_CHANGELOG.md**

### ❌ REVERT IF:
- [ ] RMSE same or worse (≥181.63 kWh)
- [ ] MAE same or worse (≥47.02 kWh)
- [ ] R² dropped (<0.980)
- [ ] Training errors or excessive NaNs
- [ ] Model takes >2x longer to train
- [ ] Visualizations show systematic bias

**→ Say "REVERT BACK" to restore baseline**

---

## Final Notes

**Actual Results:**
```
Test RMSE: _______ kWh (Baseline: 181.63 kWh)
Test MAE:  _______ kWh (Baseline: 47.02 kWh)
Test R²:   _______ (Baseline: 0.9826)

Improvement: _____% RMSE reduction

Decision: [ ] KEEP  [ ] REVERT
Reason: _________________________________________________
```

**Signature:**
- Date tested: _________________
- Tester: _________________
- Final decision: _________________

---

## Quick Reference

**Baseline Model Location:**
`.backup_baseline_20251109/lgbm_temporal_energy_fulldata_20251109_171901.pkl`

**Revert Command:**
Simply say: **"REVERT BACK"**

**Success Threshold:**
Minimum 5% RMSE improvement = 172.5 kWh or better
