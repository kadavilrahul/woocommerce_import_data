# WooCommerce Data Import Tools

Extract product data and orders from WooCommerce stores with multi-website support.

## 🚀 Quick Start

# Clone and run

```bash
git clone https://github.com/kadavilrahul/woocommerce_import_data.git
```
```bash
cd woocommerce_import_data
```
```bash
bash main.sh
```

*Dependencies are installed automatically via the menu*

## 📋 Features

- **Product Data**: Titles and complete product information
- **Orders**: API and database extraction methods  
- **Multi-Website**: Manage multiple stores from one config
- **Languages**: Python and Node.js implementations
- **Reset**: Clean data and restart imports

## 🛠️ Interactive Menu

```
1. Product Titles - Choose Python or Node.js
2. Product Data - Choose Python or Node.js  
3. Orders - Choose API or Database
4. Activity Monitor - Monitor WordPress activities
5. Install Dependencies - Install required packages
6. Config Test - Test configuration settings
7. Cleanup - Clean environment and data files
8. Generate Report
```

## ⚙️ Configuration

Setup is guided through the menu. Sample configuration files are provided:
- `sample_config.json` - Multi-website configuration
- `sample.env` - Single website configuration

## 📊 Output

Data saved to `data/` directory:
- `product_titles_[website].csv`
- `product_data_[website].csv` 
- `order_data_[website].csv`

## 📁 Key Files

```
main.sh                                  # Interactive menu system
fetch_product_titles_main_generic.py     # Product titles (Python)
fetch_product_data_main_generic.py       # Product data (Python)  
fetch_product_titles_main_enhanced.js    # Product titles (Node.js)
fetch_product_data_main_enhanced.js      # Product data (Node.js)
fetch_orders_api_generic.py              # Orders via WooCommerce API
fetch_orders_database.py                 # Orders via database access
monitor_activity_domain*.py              # WordPress activity monitoring
data/                                     # Output directory
```

## 🔧 Direct Usage

```bash
# Python with multi-website support
python3 fetch_product_titles_main_generic.py --website mystore
python3 fetch_orders_api_generic.py --interactive

# Node.js with multi-website support  
node fetch_product_titles_main_enhanced.js --website mystore
node fetch_product_data_main_enhanced.js --website mystore
```

## 📋 Requirements

- Python 3.7+
- Node.js (optional, for JavaScript versions)
- WooCommerce REST API credentials
- MySQL access (for database extraction)

## 🎯 What You Get

- **11 Python scripts** for comprehensive data extraction
- **3 JavaScript scripts** for Node.js compatibility  
- **Multi-website management** from single configuration
- **Reset functionality** to clean data and restart
- **Interactive menu** for easy operation
- **Rate limiting** to respect API constraints

## ⚠️ Important

- Test with small datasets first
- Backup before database operations
- API credentials required for WooCommerce access