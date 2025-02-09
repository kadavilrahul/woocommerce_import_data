const fs = require('fs');
const WooCommerceRestApi = require("@woocommerce/woocommerce-rest-api").default;

// Load configuration from config.json
let config;
try {
    config = JSON.parse(fs.readFileSync('config.json', 'utf8'));
    console.log('✓ Loaded configuration from config.json');
} catch (error) {
    console.error('✗ Error loading config.json:', error.message);
    process.exit(1);
}

// Initialize WooCommerce API
const api = new WooCommerceRestApi({
    url: config.SITE_URL,
    consumerKey: config.CONSUMER_KEY,
    consumerSecret: config.CONSUMER_SECRET,
    version: "wc/v3"
});
console.log(`✓ Connected to WooCommerce API at ${config.SITE_URL}`);

// Create CSV write stream
const csvStream = fs.createWriteStream('products.csv');
csvStream.write('Product Title\n'); // CSV header

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
        console.log(`📁 Results saved to products.csv`);

    } catch (error) {
        console.error("\n❌ Fatal Error:", error.response?.data?.message || error.message);
    }
}

// Run the function
console.log('🚀 Starting product title import...\n');
fetchAllProductTitles();
