import os
import config


def reset_script():
    # Clear the Excel file if it exists
    if os.path.exists(config.EXCEL_FILE):
        os.remove(config.EXCEL_FILE)
        print("Excel file has been reset.")
    else:
        print("No Excel file found to reset.")
