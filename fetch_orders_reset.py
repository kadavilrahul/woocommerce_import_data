#!/usr/bin/env python3
"""
Orders Reset Script
Cleans up order data files and resets pagination
"""

import os
import glob

def reset_script():
    """Reset order data files and pagination"""
    print("🧹 Resetting order data...")
    
    # Remove order data CSV files
    data_files = glob.glob("data/order_data_*.csv")
    page_files = glob.glob("data/current_page_*.txt")
    
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
    
    # Remove generic files if they exist
    generic_files = ["data/orders.csv", "data/order_data.csv", "current_page.txt"]
    for file in generic_files:
        if os.path.exists(file):
            try:
                os.remove(file)
                print(f"✓ Removed {file}")
                removed_count += 1
            except OSError as e:
                print(f"⚠️ Could not remove {file}: {e}")
    
    if removed_count > 0:
        print(f"✅ Reset complete! Removed {removed_count} files.")
    else:
        print("ℹ️ No order data files found to remove.")

if __name__ == "__main__":
    reset_script()