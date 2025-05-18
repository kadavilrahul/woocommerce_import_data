# WooCommerce Data Import Tools

A collection of tools to import data from WooCommerce stores via the REST API. This repository contains three main components:

1. **Product Titles Importer** (`fetch_product_titles/`) - Fetches only product titles
2. **Full Product Data Importer** (`fetch_product_data/`) - Fetches comprehensive product information including:
   - Title
   - Price
   - Product Link
   - Category
   - Image URL
3. **Order Data Importer** (`fetch_order_data/`) - Fetches order information including:
   - Customer Name
   - Email
   - Phone
   - Order ID
   - Order Status
   - Order Amount

## Features

### Common Features
- Multiple implementation options (Python and Node.js for product importers)
- Batch processing for large datasets
- Progress tracking and resume capability
- Built-in error handling
- Rate limiting protection
- Interactive setup script

### Specific Features
- **Product Titles Importer**: Lightweight, focused on title extraction
- **Full Product Data Importer**: Comprehensive product data extraction with structured CSV output
- **Order Data Importer**: Detailed order information extraction with customer details

## Prerequisites

- Python 3.x (for Python implementation)
  - `requests` library
- Node.js (for Node.js implementation)
  - `@woocommerce/woocommerce-rest-api` package

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/kadavilrahul/woocommerce_import_data.git
   cd woocommerce_import_data
   ```

2. Choose your desired tool:
   ```bash
   # For product titles only
   cd fetch_product_titles
   
   # For full product data
   cd fetch_product_data
   
   # For order data
   cd fetch_order_data
   ```

3. Create Python environment (optional, recommended):
   ```bash
   python3 -m venv fetchvenv
   source fetchvenv/bin/activate
   ```

4. Run the setup script:
   ```bash
   bash main.sh
   ```

## Configuration

Create a `config.json` file with your WooCommerce credentials:
```json
{
    "CONSUMER_KEY": "your_consumer_key",
    "CONSUMER_SECRET": "your_consumer_secret",
    "SITE_URL": "https://your-store-url.com"
}
```

The setup script will create this file automatically.

## Manual Setup and Usage

### Python Implementation

1. Install dependencies:
   ```bash
   pip install requests
   ```

2. Run the script:
   ```bash
   python main.py
   ```

### Node.js Implementation

1. Install dependencies:
   ```bash
   npm init -y
   npm install @woocommerce/woocommerce-rest-api
   ```

2. Run the script:
   ```bash
   node main.js
   ```

## Output Files

### Product Titles Importer
- `products.csv`: Contains product titles
- `current_page.txt`: Tracks import progress

### Full Product Data Importer
- `product_data.csv`: Contains all product data fields
- `current_page.txt`: Tracks import progress

### Order Data Importer
- `order_data.csv`: Contains all order data fields
- `current_page.txt`: Tracks import progress

## Reset Progress

### For Product Titles Importer
```bash
python3 -c "from reset_script import reset_script; reset_script()"
```
or
```bash
rm products.csv current_page.txt
```

### For Full Product Data Importer
```bash
rm product_data.csv current_page.txt
```

### For Order Data Importer
```bash
python3 -c "from reset_script import reset_script; reset_script()"
```
or
```bash
rm order_data.csv current_page.txt
```

## Troubleshooting

1. **API Connection Issues**
   - Verify your WooCommerce REST API credentials
   - Ensure your store URL is correct and accessible
   - Check your internet connection

2. **Missing Dependencies**
   - For Python: `pip install requests`
   - For Node.js: `npm install @woocommerce/woocommerce-rest-api`

3. **Permission Issues**
   - Ensure script files are executable: `chmod +x main.sh`
   - Check write permissions in the directory

## Limitations

- Fetches maximum 50 items per request (WooCommerce API limitation)
- Full Product Data Importer:
  - Uses first category for products with multiple categories
  - Uses first image for products with multiple images
- Order Data Importer:
  - Combines billing first and last name for customer name
  - Requires appropriate API permissions to access order data

## Best Practices

1. Use the Python virtual environment for isolation
2. Allow the script to complete its run when possible
3. Monitor the console output for progress and errors
4. Keep your API credentials secure
5. Regular backups of important data

## Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a new branch for your feature or bugfix
3. Commit your changes with descriptive messages
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Notes

- The scripts include a 1-second delay between API requests to avoid rate limiting
- Large catalogs may take significant time to process
- Progress is displayed in real-time in the console
- Scripts can be safely interrupted and resumed
- Data is exported in UTF-8 encoding
