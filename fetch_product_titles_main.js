const fs = require('fs');
const WooCommerceRestApi = require("@woocommerce/woocommerce-rest-api").default;

// Load configuration from config.json
let config;
try {
    config = JSON.parse(fs.readFileSync('config.json', 'utf8'));
    console.log('✓ Loaded configuration from config.json');
    
    // Validate config structure
    if (!config.websites || !config.default_website) {
        throw new Error('Invalid config structure - missing websites or default_website');
    }
    
    const websiteConfig = config.websites[config.default_website];
    if (!websiteConfig) {
        throw new Error(`Default website '${config.default_website}' not found in config`);
    }
    
} catch (error) {
    console.error('✗ Error loading config.json:', error.message);
    process.exit(1);
}

const websiteConfig = config.websites[config.default_website];

// Initialize WooCommerce API
const api = new WooCommerceRestApi({
    url: websiteConfig.SITE_URL,
    consumerKey: websiteConfig.CONSUMER_KEY,
    consumerSecret: websiteConfig.CONSUMER_SECRET,
    version: "wc/v3"
});
console.log(`✓ Connected to WooCommerce API at ${websiteConfig.SITE_URL}`);

// Ensure data directory exists
if (!fs.existsSync('data')) {
    fs.mkdirSync('data');
}

// Create CSV write stream
const csvStream = fs.createWriteStream('data/product_titles.csv');

// Function to fetch all product titles
async function fetchAllProductTitles() {
    try {
        let page = 1;
        let totalProducts = 0;
        const perPage = 50; // Using 50 to match Python script
        console.log('\n🔄 Starting to fetch product titles...\n');

        while (true) {
            process.stdout.write(`📥 Fetching page ${page}... `);
            
            try {
                const response = await api.get("products", {
                    per_page: perPage,
                    page: page
                });

                const products = response.data;
                
                if (products.length === 0) {
                    if (page === 1) {
                        console.log('❌ No products found or error occurred.');
                    } else {
                        console.log('✓ No more products to fetch.');
                    }
                    break;
                }

                // Write titles to CSV
                products.forEach(product => {
                    // Escape quotes and handle commas in titles
                    const escapedTitle = product.name.replace(/"/g, '""');
                    csvStream.write(`"${escapedTitle}"\n`);
                });

                totalProducts += products.length;
                console.log(`✓ Added ${products.length} titles (Total: ${totalProducts})`);

                if (products.length < perPage) {
                    console.log('\n✓ Reached the last page.');
                    break;
                }

                page++;
                // Add delay to avoid hitting API rate limits
                await new Promise(resolve => setTimeout(resolve, 1000));
            } catch (error) {
                console.log(`❌ Error on page ${page}:`, error.response?.data?.message || error.message);
                break;
            }
        }

        // Close CSV file
        csvStream.end();
        console.log(`\n✅ Finished! Total products processed: ${totalProducts}`);
        console.log(`📁 Results saved to data/product_titles.csv`);

    } catch (error) {
        console.error("\n❌ Fatal Error:", error.response?.data?.message || error.message);
        // Ensure CSV is closed on error
        if (!csvStream.closed) {
            csvStream.end();
        }
    }
}

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n⚠️ Process interrupted - cleaning up...');
    if (!csvStream.closed) {
        csvStream.end();
    }
    process.exit(0);
});

process.on('SIGTSTP', () => {
    console.log('\n⚠️ Process paused - cleaning up...');
    if (!csvStream.closed) {
        csvStream.end();
    }
    process.exit(0);
});

// Run the function
console.log('🚀 Starting product title import...\n');
fetchAllProductTitles();
