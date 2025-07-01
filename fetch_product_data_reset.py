#!/usr/bin/env python3
"""
Product Data Reset Script
Cleans up product data files and resets pagination
"""

import os
import glob

def reset_script():
    """Reset product data files and pagination"""
    print("🧹 Resetting product data...")
    
    # Remove product data CSV files
    data_files = glob.glob("data/product_data_*.csv")
    page_files = glob.glob("data/product_data_page_*.txt")
    
    removed_count = 0
    
    # Remove CSV files
    for file in data_files:
        try:
            os.remove(file)
            print(f"✓ Removed {file}")
            removed_count += 1
        except OSError as e:
            print(f"⚠️ Could not remove {file}: {e}")
    
    # Remove page tracking files
    for file in page_files:
        try:
            os.remove(file)
            print(f"✓ Removed {file}")
            removed_count += 1
        except OSError as e:
            print(f"⚠️ Could not remove {file}: {e}")
    
    # Remove generic product_data.csv if it exists
    if os.path.exists("data/product_data.csv"):
        try:
            os.remove("data/product_data.csv")
            print("✓ Removed data/product_data.csv")
            removed_count += 1
        except OSError as e:
            print(f"⚠️ Could not remove data/product_data.csv: {e}")
    
    if removed_count > 0:
        print(f"✅ Reset complete! Removed {removed_count} files.")
    else:
        print("ℹ️ No product data files found to remove.")

if __name__ == "__main__":
    reset_script()