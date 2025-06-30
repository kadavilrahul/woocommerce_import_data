# WooCommerce Data Import Tools

A comprehensive toolkit for extracting and monitoring data from WooCommerce stores. This collection of Python scripts provides multiple methods to fetch product data, order information, and monitor WordPress activities.

## 🚀 Features

- **Product Data Extraction**: Fetch product titles or complete product information
- **Order Data Import**: Extract orders via REST API or direct database access
- **Activity Monitoring**: Monitor WordPress user activities and security events
- **Multi-Website Support**: Manage multiple WooCommerce stores from one configuration
- **AI Integration**: Google Gemini AI integration for data analysis
- **Flexible Configuration**: Support for both environment variables and JSON configuration

## 📋 Prerequisites

- Python 3.7 or higher
- MySQL access (for database-based tools)
- WooCommerce REST API credentials
- Google Gemini API key (optional, for AI features)

## ⚡ Quick Start

```bash
# Clone and setup
git clone https://github.com/kadavilrahul/woocommerce_import_data.git
cd woocommerce_import_data

# Install dependencies
python3 -m pip install -r requirements.txt

# Setup configuration
cp sample.env .env
# Edit .env with your credentials

# Run the interactive menu
bash main.sh
```

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kadavilrahul/woocommerce_import_data.git
cd woocommerce_import_data
```

### 2. Install Dependencies

```bash
# Install Python dependencies
python3 -m pip install -r requirements.txt

# Or use the built-in installer
bash main.sh
# Then select option 7 (Install Dependencies)
```

### 3. Configuration Setup

Choose one of the following configuration methods:

#### Option A: Environment Variables (.env file)
```bash
# Copy the sample environment file
cp sample.env .env

# Edit with your credentials
nano .env
```

#### Option B: JSON Configuration (Recommended for multiple websites)
```bash
# Copy the sample configuration file
cp sample_config.json config.json

# Edit with your credentials
nano config.json
```

## ⚙️ Configuration

### Environment Variables (.env)

**Note**: The `sample.env` file uses generic names (WEBSITE1_, WEBSITE2_) for template purposes. In actual usage, you can either:
1. Use the generic structure with JSON configuration, or  
2. Use specific website names (SILKROAD_, NILGIRI_) as shown below for environment variable configuration.

```bash
# WordPress Database Credentials - Domain 1
IP_1=your_database1_ip
DOMAIN_1=your_domain1.com
DATABASE_NAME_1=your_database1_name
DATABASE_USER_1=your_database1_user
DATABASE_PASSWORD_1=your_database1_password
DATABASE_TABLE_PREFIX_1=wp_

# WordPress Database Credentials - Domain 2 (optional)
IP_2=your_database2_ip
DOMAIN_2=your_domain2.com
DATABASE_NAME_2=your_database2_name
DATABASE_USER_2=your_database2_user
DATABASE_PASSWORD_2=your_database2_password
DATABASE_TABLE_PREFIX_2=wp_

# WooCommerce REST API Credentials - Website 1
WEBSITE1_CONSUMER_KEY=your_website1_consumer_key
WEBSITE1_CONSUMER_SECRET=your_website1_consumer_secret
WEBSITE1_SITE_URL=https://your-website1.com

# WooCommerce REST API Credentials - Website 2
WEBSITE2_CONSUMER_KEY=your_website2_consumer_key
WEBSITE2_CONSUMER_SECRET=your_website2_consumer_secret
WEBSITE2_SITE_URL=https://your-website2.com

# Default WooCommerce REST API Credentials (Website 1)
CONSUMER_KEY=your_website1_consumer_key
CONSUMER_SECRET=your_website1_consumer_secret
SITE_URL=https://your-website1.com

# Google Gemini API Configuration (optional)
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-2.0-flash-exp

# Optional: Debug and logging
DEBUG_MODE=false
LOG_LEVEL=INFO
```

### JSON Configuration (config.json)

```json
{
    "websites": {
        "website1": {
            "CONSUMER_KEY": "ck_your_consumer_key_here",
            "CONSUMER_SECRET": "cs_your_consumer_secret_here",
            "SITE_URL": "https://your-website1.com",
            "DOMAIN": "your-website1.com",
            "DATABASE_IP": "your_database_ip_here",
            "DATABASE_NAME": "your_database_name_here",
            "DATABASE_USER": "your_database_user_here",
            "DATABASE_PASSWORD": "your_database_password_here",
            "DATABASE_TABLE_PREFIX": "wp_"
        },
        "website2": {
            "CONSUMER_KEY": "ck_your_consumer_key_here",
            "CONSUMER_SECRET": "cs_your_consumer_secret_here",
            "SITE_URL": "https://your-website2.com",
            "DOMAIN": "your-website2.com",
            "DATABASE_IP": "your_database_ip_here",
            "DATABASE_NAME": "your_database_name_here",
            "DATABASE_USER": "your_database_user_here",
            "DATABASE_PASSWORD": "your_database_password_here",
            "DATABASE_TABLE_PREFIX": "wp_"
        }
    },
    "default_website": "website1",
    "ai_config": {
        "GEMINI_MODEL": "gemini-2.0-flash-exp",
        "DEBUG_MODE": false,
        "LOG_LEVEL": "INFO"
    }
}
```

## 🎯 Usage

### Interactive Menu (Recommended)

```bash
bash main.sh
```

This will show a clean, minimalistic menu with all available tools:

```
WooCommerce Data Import Tools
=============================
1. Product Titles - Fetch product titles only
2. Product Data - Fetch complete product information
3. Orders (API) - Fetch orders via WooCommerce API
4. Orders (DB) - Fetch orders from database
5. Activity Monitor - Monitor WordPress activities
6. AI Test - Test Gemini AI integration
7. Install Dependencies - Install required packages
8. Config Help - Show configuration helper
0. Exit
```

### Individual Tool Usage

#### Product Data Tools

```bash
# Fetch product titles only
cd fetch_product_titles
python3 main.py

# Fetch complete product data
cd fetch_product_data
python3 main.py

# With specific website (if using environment variables)
python3 main.py --website silkroad
python3 main.py --website nilgiri
```

#### Order Data Tools

```bash
# Fetch orders via REST API
python3 fetch_orders_api.py --interactive

# Fetch orders from database
python3 fetch_orders_database.py --db 1

# With date filters
python3 fetch_orders_database.py --db 1 --days 30
python3 fetch_orders_database.py --db 1 --start 2024-01-01 --end 2024-01-31
```

#### Activity Monitoring

```bash
# Monitor Domain 1 activities
python3 monitor_activity_domain1.py

# Monitor Domain 2 activities
python3 monitor_activity_domain2.py

# With filters
python3 monitor_activity_domain1.py --limit 10 --days 7 --event 9073
```

#### Configuration Helper

```bash
# Test and validate configuration
python3 tools/config_helper.py

# List available websites
python3 fetch_orders_api.py --list
```

## 📁 Project Structure

```
woocommerce_import_data/
├── main.sh                          # Interactive menu script
├── README.md                        # This file
├── requirements.txt                 # Python dependencies
├── sample.env                       # Sample environment file
├── sample_config.json               # Sample JSON configuration
├── fetch_orders_api.py              # Order fetcher (REST API)
├── fetch_orders_database.py         # Order fetcher (Database)
├── monitor_activity_domain1.py      # Activity monitor (Domain 1)
├── monitor_activity_domain2.py      # Activity monitor (Domain 2)
├── test_ai_integration.py           # AI integration test
├── fetch_product_data/              # Product data tools
│   ├── main.py                      # Complete product data fetcher
│   └── README.md                    # Product data documentation
├── fetch_product_titles/            # Product titles tools
│   ├── main.py                      # Product titles fetcher
│   └── README.md                    # Product titles documentation
├── tools/                           # Utility tools
│   └── generate_project_report.sh   # Project reporting
└── examples/                        # Example configurations and scripts
    └── version_01/                  # Version 1 examples
```

## 🔧 Tools Overview

### 1. Product Titles Importer
- **Purpose**: Lightweight extraction of product titles only
- **Output**: CSV file with product names
- **Best for**: Quick product catalog overview

### 2. Product Data Importer
- **Purpose**: Complete product information extraction
- **Output**: Detailed CSV with titles, prices, categories, images
- **Best for**: Comprehensive product analysis

### 3. Order Data Importer (REST API)
- **Purpose**: Standard WooCommerce API order extraction
- **Output**: CSV with customer and order details
- **Best for**: Standard order data needs

### 4. Order Data Importer (Database)
- **Purpose**: Direct MySQL database access for orders
- **Output**: Detailed CSV with order and product information
- **Best for**: Enhanced performance and detailed data

### 5. Activity Monitor
- **Purpose**: WordPress user activity and security monitoring
- **Output**: Activity logs and CSV exports
- **Best for**: Security auditing and user behavior analysis

### 6. AI Integration
- **Purpose**: Google Gemini AI integration for data analysis
- **Output**: AI-powered insights and analysis
- **Best for**: Advanced data interpretation

## 🔑 Getting API Credentials

### WooCommerce REST API
1. Go to your WordPress admin panel
2. Navigate to WooCommerce → Settings → Advanced → REST API
3. Click "Add Key"
4. Set permissions to "Read" or "Read/Write"
5. Copy the Consumer Key and Consumer Secret

### Google Gemini API
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the API key to your configuration

### Database Access
1. Contact your hosting provider for database credentials
2. Ensure your IP is whitelisted for remote access
3. Use the provided host, username, password, and database name

## 🚨 Troubleshooting

### Common Issues

**"No configuration found"**
```bash
# Copy and edit configuration files
cp sample.env .env
# or
cp sample_config.json config.json
```

**"Python 3 is not installed"**
```bash
# Install Python 3
sudo apt update && sudo apt install python3 python3-pip
# or on macOS
brew install python3
```

**"Module not found"**
```bash
# Install dependencies
python3 -m pip install -r requirements.txt
```

**"Connection refused" (Database)**
- Check database credentials
- Verify IP whitelisting
- Confirm database server is accessible

**"Unauthorized" (API)**
- Verify Consumer Key and Secret
- Check API permissions in WooCommerce settings
- Ensure SITE_URL is correct

## 📊 Output Files

All tools generate CSV files with timestamps:
- `products.csv` - Product data
- `order_data_*.csv` - Order information
- `woocommerce_orders_*.csv` - Database order exports
- Activity logs with custom names

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
1. Check the troubleshooting section
2. Review the examples in the `examples/` directory
3. Run the configuration helper: `python3 tools/config_helper.py`
4. Create an issue in the repository

## 🔄 Updates

To update the tools:
```bash
git pull origin main
python3 -m pip install -r requirements.txt --upgrade
```

---

**Note**: Always backup your data before running any import/export operations. Test with small datasets first.