# WooCommerce Order Data Fetcher

A Python script to fetch order data from a WooCommerce store via the REST API. The script collects the following order information:
- Customer Name
- Email
- Phone
- Order ID
- Order Status
- Order Amount

## Features

- Fetches order data in batches
- Saves progress in case of interruption
- Handles API rate limiting
- Exports data to CSV
- Includes error handling and progress tracking

## Setup

1. Enter the folder
   ```bash
   cd fetch_order_data
   ```

2. Create a Python virtual environment (recommended):
   ```bash
   python3 -m venv ordervenv
   source ordervenv/bin/activate
   ```

3. Install required package:
   ```bash
   pip install requests
   ```

4. Create a `config.json` file with your WooCommerce credentials:
  
   {
       "CONSUMER_KEY": "your_consumer_key",
       "CONSUMER_SECRET": "your_consumer_secret",
       "SITE_URL": "https://your-store-url.com"
   }
  

## Usage

1. Run the script:
   ```bash
   python main.py
   ```

2. To reset progress and start fresh:
   ```python
   python3 -c "from reset_script import reset_script; reset_script()"
   ```

## Output

The script creates a CSV file named `order_data.csv` with the following columns:
1. Name (Customer's full name)
2. Email
3. Phone
4. Order ID
5. Order Status
6. Order Amount

## Progress Tracking

The script maintains a `current_page.txt` file to track progress. If interrupted, it will resume from the last processed page when restarted.

## Error Handling

- Handles API connection errors
- Manages rate limiting
- Validates API responses
- Provides clear error messages
- Gracefully handles interruptions

## Limitations

- Fetches maximum 50 orders per API request (WooCommerce limitation)
- Requires appropriate WooCommerce API permissions to access order data

## Troubleshooting

1. **API Connection Issues**
   - Verify your WooCommerce REST API credentials
   - Ensure your store URL is correct
   - Check if your store is accessible

2. **Missing Data**
   - Verify API user has permission to view orders
   - Check if required fields exist in your WooCommerce setup

3. **Permission Issues**
   - Ensure the script has write permissions in the directory

## Notes

- The script includes a 1-second delay between API requests to avoid rate limiting
- Large order volumes may take some time to process
- Progress is displayed in real-time in the console
- The script can be safely interrupted and resumed
- Data is exported in UTF-8 encoding