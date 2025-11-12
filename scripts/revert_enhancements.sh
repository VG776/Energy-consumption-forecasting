#!/bin/bash

# REVERSION SCRIPT - Restores notebooks to baseline state
# Run this if enhancements do not improve performance

echo "🔄 REVERTING TO BASELINE STATE..."
echo "=================================="

# Check if backup exists
if [ ! -d "../.backup_20251109" ]; then
    echo "❌ No backup found. Cannot revert safely."
    echo "Please manually restore from git or previous version."
    exit 1
fi

# Restore notebooks from backup
echo "📁 Restoring notebooks from backup..."
cp ../.backup_20251109/preprocessing.ipynb ../notebooks/preprocessing.ipynb
cp ../.backup_20251109/new_lgbm_model.ipynb ../notebooks/new_lgbm_model.ipynb

# Clean up enhanced output files
echo "🗑️  Cleaning up enhancement outputs..."
rm -f ../reports/comprehensive_analysis_*.png
rm -f ../reports/ENHANCEMENT_CHANGELOG.md

echo ""
echo "✅ REVERSION COMPLETE"
echo "=================================="
echo "Restored to baseline with 20 features:"
echo "  • Temporal: hour, dayofweek, month, is_weekend"
echo "  • Weather: air_temperature, CDD, HDD"
echo "  • Lag: 1h, 3h, 6h, 24h, 72h"
echo "  • Rolling: mean_24h, mean_168h, std_24h, max_24h, min_24h"
echo "  • Categorical: building_id, site_id"
echo ""
echo "Baseline performance:"
echo "  • RMSE: 181.63 kWh"
echo "  • MAE: 47.02 kWh"
echo "  • R²: 0.9826"
echo ""
echo "Re-run preprocessing.ipynb and new_lgbm_model.ipynb to restore baseline results."
