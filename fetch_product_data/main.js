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

// Create CSV write stream with headers
const csvStream = fs.createWriteStream('product_data.csv');
csvStream.write('"title","price","product_link","category","image_url"\n');

// Function to escape and format CSV fields
function formatCSVField(field) {
    if (field === null || field === undefined) {
        return '""';
    }
    return `"${String(field).replace(/"/g, '""')}"`;
}

// Function to extract product data
function extractProductData(product) {
    try {
        return {
            title: product.name || '',
            price: product.price || '',
            product_link: product.permalink || '',
            category: product.categories && product.categories[0] ? product.categories[0].name : '',
            image_url: product.images && product.images[0] ? product.images[0].src : ''
        };
    } catch (error) {
        console.log(`⚠️ Warning: Could not extract all fields from product: ${error.message}`);
        return null;
    }
}

// Function to fetch all product data
async function fetchAllProductData() {
    try {
        let page = 1;
        let totalProducts = 0;
        const perPage = 50;
        console.log('\n🔄 Starting to fetch product data...\n');

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

                // Process and write product data to CSV
                products.forEach(product => {
                    const data = extractProductData(product);
                    if (data) {
                        const csvLine = [
                            formatCSVField(data.title),
                            formatCSVField(data.price),
                            formatCSVField(data.product_link),
                            formatCSVField(data.category),
                            formatCSVField(data.image_url)
                        ].join(',') + '\n';
                        csvStream.write(csvLine);
                    }
                });

                totalProducts += products.length;
                console.log(`✓ Added ${products.length} products (Total: ${totalProducts})`);

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
        console.log(`📁 Results saved to product_data.csv`);

    } catch (error) {
        console.error("\n❌ Fatal Error:", error.response?.data?.message || error.message);
    }
}

// Run the function
console.log('🚀 Starting product data import...\n');
fetchAllProductData();