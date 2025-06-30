# WooCommerce Product Data Fetcher

A set of scripts to fetch product data from a WooCommerce store via the REST API. The scripts collect the following product information:
- Title
- Price
- Product Link
- Category
- Image URL

## Features

- Fetches product data in batches to handle large catalogs
- Saves progress in case of interruption
- Provides both Python and Node.js implementations
- Includes error handling and progress tracking
- Exports data to CSV in a consistent format
- Handles API rate limiting with built-in delays

## Prerequisites

For Python implementation:
- Python 3.x
- `requests` library

For Node.js implementation:
- Node.js
- `@woocommerce/woocommerce-rest-api` package

## Setup

1. Clone or download this repository

   ```bash
   git clone https://github.com/kadavilrahul/woocommerce_import_product_data.git && cd woocommerce_import_product_data
   ```

2. Create python environment if you plan to run python script:
   ```bash
   cd fetch_product_data
   ```
   ```bash
   python3 -m venv fetchvenv
   ```
   ```bash
   source fetchvenv/bin/activate
   ```
3. Run the setup script:
   ```bash
   bash main.sh
   ```
4. Follow the prompts to enter your WooCommerce credentials:
   - Consumer Key (from WooCommerce REST API settings)
   - Consumer Secret (from WooCommerce REST API settings)
   - Site URL (your WooCommerce store URL)

## Configuration

Create a `config.json` file in the same directory with the following structure:
```json
{
    "CONSUMER_KEY": "your_consumer_key",
    "CONSUMER_SECRET": "your_consumer_secret",
    "SITE_URL": "https://your-store-url.com"
}
```

The setup script will create this file for you automatically.

## Usage

### Using the Shell Script (Recommended)
1. Run the shell script:
   ```bash
   ./main.sh
   ```
2. Choose your preferred implementation (Python or Node.js)
3. The script will handle dependency installation and run the chosen implementation

### Manual Running

Python implementation:
```bash
python3 main.py
```

Node.js implementation:
```bash
node main.js
```

## Output

The script creates a CSV file named `product_data.csv` with the following columns:
1. title
2. price
3. product_link
4. category
5. image_url

## Progress Tracking

The script maintains a `current_page.txt` file to track progress. If the script is interrupted, it will resume from the last processed page when restarted.

## Error Handling

- Handles API connection errors
- Manages rate limiting
- Validates API responses
- Provides clear error messages
- Gracefully handles interruptions

## Limitations

- Fetches only the first category if a product has multiple categories
- Uses the first image if multiple product images exist
- Maximum of 50 products per API request (WooCommerce limitation)

## Troubleshooting

1. **API Connection Issues**
   - Verify your WooCommerce REST API credentials
   - Ensure your store URL is correct
   - Check if your store is accessible

2. **Missing Dependencies**
   - For Python: Run `pip install requests`
   - For Node.js: Run `npm install @woocommerce/woocommerce-rest-api`

3. **Permission Issues**
   - Ensure the script has write permissions in the directory
   - Make sure the shell script is executable

## Reset Progress

To start fresh:
1. Delete `current_page.txt` if it exists
2. Delete `product_data.csv` if it exists
3. Run the script again

## Notes

- The script includes a 1-second delay between API requests to avoid rate limiting
- Large catalogs may take some time to process
- Progress is displayed in real-time in the console
- The script can be safely interrupted and resumed