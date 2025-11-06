"""
Energy Consumption Forecasting - Model Deployment Script
Generated on: 2025-11-07 02:11:01
"""

import lightgbm as lgb
import pandas as pd
import numpy as np
import json

class EnergyConsumptionPredictor:
    def __init__(self, model_path="/Users/saatwik/Documents/Energy-consumption-forecasting/models/lgbm_energy_model.txt", metadata_path="/Users/saatwik/Documents/Energy-consumption-forecasting/models/model_metadata.json"):
        """Initialize the predictor with trained model and metadata"""
        self.model = lgb.Booster(model_file=model_path)

        with open(metadata_path, 'r') as f:
            self.metadata = json.load(f)

        self.feature_names = self.metadata['feature_names']
        print(f"Model loaded successfully!")
        print(f"Expected features: {len(self.feature_names)}")
        print(f"Model performance - Test RMSE: {self.metadata['performance_metrics']['test_rmse']:.2f}")

    def predict(self, X):
        """Make predictions on new data"""
        # Ensure features are in correct order
        if isinstance(X, pd.DataFrame):
            X = X[self.feature_names]

        predictions = self.model.predict(X)
        return predictions

    def get_feature_importance(self):
        """Get feature importance rankings"""
        importance = self.model.feature_importance(importance_type='gain')
        return pd.DataFrame({
            'Feature': self.feature_names,
            'Importance': importance
        }).sort_values('Importance', ascending=False)

# Example usage:
# predictor = EnergyConsumptionPredictor()
# predictions = predictor.predict(new_data)
