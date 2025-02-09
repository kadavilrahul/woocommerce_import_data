import os

EXCEL_FILE = "products.xlsx"
PAGE_PROPERTY_FILE = "current_page.txt"

def reset_script():
    """Reset the script by removing the Excel file and page tracking file."""
    files_to_reset = [EXCEL_FILE, PAGE_PROPERTY_FILE]
    
    for file in files_to_reset:
        if os.path.exists(file):
            try:
                os.remove(file)
                print(f"{file} has been reset.")
            except OSError as e:
                print(f"Error removing {file}: {e}")
        else:
            print(f"No {file} found to reset.")
