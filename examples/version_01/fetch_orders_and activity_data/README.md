# WP Data Fetcher

This script fetches data from the `wp_activity_log` table in a WordPress database.

## Prerequisites

-   Python 3.6+
-   `pip` (Python package installer)
-   MySQL Connector/Python
-   python-dotenv

## Installation

1.  **Create a virtual environment (recommended):**

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    ```

22.  **Install the required packages:**

    ```bash
    pip install -r requirements.txt
    ```

## Configuration

1.  **Create a `.env` file** in the same directory as the script.

2.  **Add the following environment variables** to the `.env` file:

    ```
    IP=your_database_ip
    DOMAIN=your_domain
    DATABASE_NAME=your_database_name
    DATABASE_USER=your_database_user
    DATABASE_PASSWORD=your_database_password
    ```

    Replace the placeholders with your actual database credentials.

## Usage

1.  **Run the script:**

    ```bash
    python wp_activity.py
    ```
    ```bash
    python wc_orders_fetch.py
    ```

## Troubleshooting

-   **"ModuleNotFoundError: No module named 'mysql.connector'"**: Make sure you have installed the `mysql-connector-python` package using `pip install mysql-connector-python`.
-   **"ModuleNotFoundError: No module named 'dotenv'"**: Make sure you have installed the `python-dotenv` package using `pip install python-dotenv`.
-   **"Access denied for user..."**: Double-check your

-   **"ModuleNotFoundError: No module named 'mysql.connector'"**: Make sure you have installed the `mysql-connector-python` package using `pip install mysql-connector-python`.
-   **"ModuleNotFoundError: No module named 'dotenv'"**: Make sure you have installed the `python-dotenv` package using `pip install python-dotenv`.
-   **"Access denied for user..."**: Double-check your database credentials in the `.env` file.
