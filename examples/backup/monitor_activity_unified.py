import os
import sys
import mysql.connector
from dotenv import load_dotenv
from datetime import datetime
import argparse
import csv
import json

# Load environment variables
load_dotenv()

DEFAULT_ACTIVITY_LIMIT = 5  # Default number of activities to display

# Mapping of common event IDs to descriptions
EVENT_DESCRIPTIONS = {
    9073: "User viewed a product"
}

def get_domain_config(domain_number):
    """Get configuration for specified domain"""
    config = {
        'ip': os.getenv(f"IP_{domain_number}"),
        'domain': os.getenv(f"DOMAIN_{domain_number}"),
        'database_name': os.getenv(f"DATABASE_NAME_{domain_number}"),
        'database_user': os.getenv(f"DATABASE_USER_{domain_number}"),
        'database_password': os.getenv(f"DATABASE_PASSWORD_{domain_number}"),
        'database_table_prefix': os.getenv(f"DATABASE_TABLE_PREFIX_{domain_number}", "wp_")
    }
    
    # Validate required config
    required_fields = ['ip', 'database_name', 'database_user', 'database_password']
    missing_fields = [field for field in required_fields if not config[field]]
    
    if missing_fields:
        raise ValueError(f"Missing required environment variables for domain {domain_number}: {missing_fields}")
    
    return config

def format_timestamp(timestamp):
    """Convert timestamp to readable datetime"""
    try:
        return datetime.fromtimestamp(float(timestamp)).strftime('%Y-%m-%d %H:%M:%S')
    except:
        return str(timestamp)

def extract_metadata(occurrence_id, cursor, table_prefix='wp_'):
    """Extract metadata for a specific occurrence with detailed error handling"""
    metadata_table = f"{table_prefix}wsal_metadata"
    try:
        # First, check if any metadata exists for this occurrence
        cursor.execute(f"SELECT COUNT(*) as metadata_count FROM {metadata_table} WHERE occurrence_id = %s", (occurrence_id,))
        count_result = cursor.fetchone()
        metadata_count = count_result['metadata_count'] if count_result else 0
        
        if metadata_count == 0:
            # No metadata found, but this isn't necessarily an error
            return {}
        
        # If metadata exists, retrieve it
        cursor.execute(f"""
            SELECT name, value 
            FROM {metadata_table} 
            WHERE occurrence_id = %s
        """, (occurrence_id,))
        
        metadata = {}
        for row in cursor.fetchall():
            # Ensure we're working with strings
            try:
                name = row['name'].decode('utf-8') if isinstance(row['name'], bytes) else str(row['name'])
                value = row['value'].decode('utf-8') if isinstance(row['value'], bytes) else str(row['value'])
                metadata[name] = value
            except Exception as conversion_error:
                print(f"Error converting metadata for occurrence {occurrence_id}: {conversion_error}")
                print(f"Raw data - Name: {row['name']}, Value: {row['value']}")
        
        return metadata
    except Exception as e:
        print(f"Detailed error extracting metadata for occurrence {occurrence_id}: {e}")
        return {}

def get_table_columns(cursor, table_name):
    """Retrieve the columns of a given table"""
    try:
        cursor.execute(f"DESCRIBE {table_name}")
        columns = cursor.fetchall()
        return [col['Field'] for col in columns]
    except Exception as e:
        print(f"Error retrieving columns for {table_name}: {e}")
        return []

def get_interactive_input():
    """Get user input interactively"""
    print("WordPress Activity Monitor")
    print("=" * 40)
    print()
    
    # Get domain information for display
    domain1_name = os.getenv("DOMAIN_1", "Domain 1 (not configured)")
    domain2_name = os.getenv("DOMAIN_2", "Domain 2 (not configured)")
    
    # Get domain selection
    print("Available domains:")
    print(f"  1. {domain1_name}")
    print(f"  2. {domain2_name}")
    print()
    
    while True:
        try:
            domain = input("Select domain (1 or 2): ").strip()
            if domain in ['1', '2']:
                domain = int(domain)
                selected_name = domain1_name if domain == 1 else domain2_name
                print(f"Selected: {selected_name}")
                break
            print("Invalid input. Please enter 1 or 2")
        except KeyboardInterrupt:
            print("\nExiting...")
            return None
        except EOFError:
            print("\nExiting...")
            return None
    
    # Get optional parameters
    print("\nOptional parameters (press Enter to skip):")
    
    limit_input = input(f"Number of records to retrieve (default: {DEFAULT_ACTIVITY_LIMIT}): ").strip()
    limit = int(limit_input) if limit_input else DEFAULT_ACTIVITY_LIMIT
    
    days_input = input("Show events from last X days: ").strip()
    days = int(days_input) if days_input else None
    
    event_input = input("Filter by event ID (default: 9073): ").strip()
    event = int(event_input) if event_input else 9073
    
    user = input("Filter by username or user ID: ").strip() or None
    csv_file = input("Export to CSV file (filename): ").strip() or None
    
    # Additional options
    print("\nAdditional options:")
    diagnose = input("Run diagnostic mode? (y/n): ").strip().lower() == 'y'
    prefix = input("Custom table prefix (leave empty for default): ").strip() or None
    
    return {
        'domain': domain,
        'limit': limit,
        'days': days,
        'event': event,
        'user': user,
        'csv': csv_file,
        'diagnose': diagnose,
        'prefix': prefix
    }

def main():
    # Check if running interactively (no command line arguments)
    if len(sys.argv) == 1:
        # Interactive mode
        params = get_interactive_input()
        if params is None:
            return
        
        # Create a mock args object
        class Args:
            def __init__(self, **kwargs):
                for key, value in kwargs.items():
                    setattr(self, key, value)
        
        args = Args(**params)
    else:
        # Command line mode
        parser = argparse.ArgumentParser(description='Extract detailed activity log from WordPress')
        parser.add_argument('--domain', type=int, choices=[1, 2], required=True, help='Domain number (1 or 2)')
        parser.add_argument('--limit', type=int, default=DEFAULT_ACTIVITY_LIMIT, help=f'Number of records to retrieve (default: {DEFAULT_ACTIVITY_LIMIT})')
        parser.add_argument('--days', type=int, help='Show events from the last X days')
        parser.add_argument('--event', type=int, default=9073, help='Filter by specific event ID (default: 9073 - User viewed a product)')
        parser.add_argument('--user', type=str, help='Filter by username or user ID')
        parser.add_argument('--csv', type=str, help='Export results to CSV file')
        parser.add_argument('--diagnose', action='store_true', help='Run table diagnostic information')
        parser.add_argument('--prefix', type=str, help='Database table prefix (overrides environment variable)')
        args = parser.parse_args()

    try:
        # Get domain configuration
        config = get_domain_config(args.domain)
        table_prefix = args.prefix or config['database_table_prefix']
        
        print(f"\nConnecting to: {config['domain'] or f'Domain {args.domain}'}")
        print(f"Database: {config['database_name']}")
        print(f"Host: {config['ip']}")
        print(f"Table prefix: {table_prefix}")
        print("-" * 40)
        
        # Establish database connection
        connection = mysql.connector.connect(
            host=config['ip'],
            database=config['database_name'],
            user=config['database_user'],
            password=config['database_password']
        )

        if connection.is_connected():
            cursor = connection.cursor(dictionary=True)
            
            # Run diagnostic if requested
            if args.diagnose:
                # Show all tables in the database
                cursor.execute("SHOW TABLES")
                tables = cursor.fetchall()
                print(f"Found {len(tables)} tables in database {config['database_name']}:")
                for table in tables:
                    print(f"  - {list(table.values())[0]}")
                return
            
            # Check if WP Security Audit Log tables exist
            wsal_occurrences = f"{table_prefix}wsal_occurrences"
            wsal_metadata = f"{table_prefix}wsal_metadata"
            
            # Check if the tables exist
            cursor.execute(f"SHOW TABLES LIKE '{wsal_occurrences}'")
            occurrences_exists = cursor.fetchone() is not None
            
            cursor.execute(f"SHOW TABLES LIKE '{wsal_metadata}'")
            metadata_exists = cursor.fetchone() is not None
            
            if not occurrences_exists:
                print(f"Table {wsal_occurrences} does not exist. Looking for product view data in other tables...")
                
                # Query for product views in WooCommerce tables
                posts_table = f"{table_prefix}posts"
                postmeta_table = f"{table_prefix}postmeta"
                
                # Check if these tables exist
                cursor.execute(f"SHOW TABLES LIKE '{posts_table}'")
                posts_exists = cursor.fetchone() is not None
                
                cursor.execute(f"SHOW TABLES LIKE '{postmeta_table}'")
                postmeta_exists = cursor.fetchone() is not None
                
                if posts_exists and postmeta_exists:
                    # Query for recently viewed products
                    query = f"""
                    SELECT p.ID, p.post_title, p.post_date, p.post_modified, 
                           u.user_login, u.user_email
                    FROM {posts_table} p
                    LEFT JOIN {postmeta_table} pm ON p.ID = pm.post_id
                    LEFT JOIN {table_prefix}users u ON pm.meta_value = u.ID
                    WHERE p.post_type = 'product'
                    AND pm.meta_key LIKE '%viewed%'
                    ORDER BY p.post_modified DESC
                    LIMIT %s
                    """
                    
                    try:
                        cursor.execute(query, (args.limit,))
                        products = cursor.fetchall()
                        
                        if products:
                            print(f"Found {len(products)} recently viewed products:")
                            print("-" * 100)
                            
                            for product in products:
                                print(f"Product ID: {product['ID']}")
                                print(f"Title: {product['post_title']}")
                                print(f"Last Modified: {product['post_modified']}")
                                if product['user_login']:
                                    print(f"Viewed by: {product['user_login']} ({product['user_email']})")
                                print("-" * 100)
                        else:
                            # Try a different approach - get product view count
                            query = f"""
                            SELECT p.ID, p.post_title, pm.meta_key, pm.meta_value
                            FROM {posts_table} p
                            JOIN {postmeta_table} pm ON p.ID = pm.post_id
                            WHERE p.post_type = 'product'
                            AND (
                                pm.meta_key LIKE '%view%count%' OR
                                pm.meta_key LIKE '%product_views%' OR
                                pm.meta_key LIKE '%total_sales%'
                            )
                            ORDER BY CAST(pm.meta_value AS UNSIGNED) DESC
                            LIMIT %s
                            """
                            
                            cursor.execute(query, (args.limit,))
                            products = cursor.fetchall()
                            
                            if products:
                                print(f"Found {len(products)} products with view/sales data:")
                                print("-" * 100)
                                
                                for product in products:
                                    print(f"Product ID: {product['ID']}")
                                    print(f"Title: {product['post_title']}")
                                    print(f"Metric: {product['meta_key']}")
                                    print(f"Value: {product['meta_value']}")
                                    print("-" * 100)
                            else:
                                print("No product view data found in the database.")
                    except Exception as e:
                        print(f"Error querying product view data: {e}")
                else:
                    print(f"WooCommerce tables not found. Available tables:")
                    cursor.execute("SHOW TABLES")
                    tables = cursor.fetchall()
                    for table in tables:
                        print(f"  - {list(table.values())[0]}")
                
                return
            
            # If we get here, the WSAL tables exist, so proceed with the original query
            # Get available columns in the occurrences table
            occurrence_columns = get_table_columns(cursor, wsal_occurrences)
            
            # Dynamically build the select columns
            select_columns = [
                'o.id', 
                'o.alert_id', 
                'o.created_on', 
                'o.user_id', 
                'u.user_login', 
                'u.user_email'
            ]
            
            # Add optional columns if they exist
            optional_columns = {
                'site_id': 'o.site_id',
                'blog_id': 'o.blog_id',
                'object_id': 'o.object_id',
                'severity': 'o.severity'
            }
            
            for col_name, col_ref in optional_columns.items():
                if col_name in occurrence_columns:
                    select_columns.append(col_ref)
            
            # Build the query
            query = f"""
            SELECT 
                {', '.join(select_columns)}
            FROM {wsal_occurrences} o
            LEFT JOIN {table_prefix}users u ON o.user_id = u.ID
            """
            
            # Prepare WHERE clauses and parameters
            where_clauses = []
            params = []
            
            # Filter by days
            if args.days:
                where_clauses.append("o.created_on > UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL %s DAY))")
                params.append(args.days)
            
            # Filter by event ID
            if args.event:
                where_clauses.append("o.alert_id = %s")
                params.append(args.event)
            
            # Filter by user
            if args.user:
                # Check if it's a numeric user ID or a username
                if args.user.isdigit():
                    where_clauses.append("o.user_id = %s")
                else:
                    where_clauses.append("u.user_login = %s")
                params.append(args.user)
            
            # Combine WHERE clauses
            if where_clauses:
                query += " WHERE " + " AND ".join(where_clauses)
            
            # Order and limit
            query += " ORDER BY o.created_on DESC LIMIT %s"
            params.append(args.limit)
            
            # Execute the query
            print("Executing query...")
            
            cursor.execute(query, params)
            records = cursor.fetchall()
            
            # Prepare CSV if requested
            csv_file = None
            csv_writer = None
            if args.csv:
                csv_file = open(args.csv, 'w', newline='', encoding='utf-8')
                csv_writer = csv.writer(csv_file)
                csv_writer.writerow([
                    'Domain', 'Timestamp', 'Event ID', 'Event Description', 
                    'User', 'User Email', 'Details', 
                    'Site ID', 'Blog ID', 'Object ID', 'Severity'
                ])
            
            # Process and display records
            print(f"\nFound {len(records)} activity log entries:")
            print("-" * 100)
            
            for record in records:
                # Get occurrence details
                occurrence_id = record['id']
                alert_id = record['alert_id']
                created_on = format_timestamp(record['created_on'])
                user_login = record.get('user_login', 'Unknown')
                user_email = record.get('user_email', '')
                
                # Get event description
                event_description = EVENT_DESCRIPTIONS.get(
                    alert_id, 
                    f"Unknown Event (ID: {alert_id})"
                )
                
                # Attempt to extract metadata
                metadata = {}
                if metadata_exists:
                    try:
                        metadata = extract_metadata(occurrence_id, cursor, table_prefix)
                    except Exception as meta_error:
                        print(f"Error extracting metadata for occurrence {occurrence_id}: {meta_error}")
                
                # Print detailed record information
                print(f"Domain: {config['domain'] or f'Domain {args.domain}'}")
                print(f"Occurrence ID: {occurrence_id}")
                print(f"Timestamp: {created_on}")
                print(f"Event ID: {alert_id}")
                print(f"Event: {event_description}")
                print(f"User: {user_login} ({user_email})")
                
                # Additional diagnostic information
                for col_name in ['site_id', 'blog_id', 'object_id', 'severity']:
                    if col_name in record:
                        print(f"{col_name.replace('_', ' ').title()}: {record.get(col_name, 'N/A')}")
                
                # Print metadata details
                if metadata:
                    print("Metadata:")
                    for key, value in metadata.items():
                        print(f"  - {key}: {value}")
                else:
                    print("No metadata found for this occurrence.")
                
                # Write to CSV if requested
                if csv_writer:
                    csv_writer.writerow([
                        config['domain'] or f"Domain {args.domain}",
                        created_on,
                        alert_id,
                        event_description,
                        user_login,
                        user_email,
                        json.dumps(metadata) if metadata else '',
                        record.get('site_id', ''),
                        record.get('blog_id', ''),
                        record.get('object_id', ''),
                        record.get('severity', '')
                    ])
                
                print("-" * 100)
            
            # Close CSV file if opened
            if csv_file:
                csv_file.close()
                print(f"CSV export completed: {args.csv}")

    except ValueError as e:
        print(f"Configuration Error: {e}")
    except mysql.connector.Error as e:
        print(f"MySQL Error: {e}")
    except Exception as e:
        print(f"Unexpected error: {e}")
    finally:
        if 'connection' in locals() and connection.is_connected():
            cursor.close()
            connection.close()
            print("Database connection closed")

if __name__ == "__main__":
    main()