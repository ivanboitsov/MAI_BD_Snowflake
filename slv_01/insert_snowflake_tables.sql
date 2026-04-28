-- 1. dim_location
INSERT INTO dim_location (country, state, city, postal_code, location)
SELECT DISTINCT country, state, city, postal_code, location
FROM (
    SELECT customer_country, NULL, NULL, customer_postal_code, NUll FROM mock_data
    UNION

    SELECT seller_country, NULL, NULL, seller_postal_code, NULL FROM mock_data
    UNION

    SELECT store_country, store_state, store_city, NULL, store_location FROM mock_data
    UNION

    SELECT supplier_country, NULL, NULL, NULL, NULL FROM mock_data
) loc
WHERE country IS NOT NULL OR city IS NOT NULL OR state IS NOT NULL OR postal_code IS NOT NULL OR location IS NOT NULL;


-- 2. dim_pet
INSERT INTO dim_pet (pet_type, pet_name, pet_breed)
SELECT DISTINCT customer_pet_type, customer_pet_name, customer_pet_breed
FROM mock_data
WHERE customer_pet_type IS NOT NULL
ON CONFLICT (pet_type, pet_name, pet_breed) DO NOTHING;
 
 
-- 3. dim_customer
INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, location_id, pet_id)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    l.location_id,
    p.pet_id
FROM mock_data md
LEFT JOIN dim_location l
    ON l.country IS NOT DISTINCT FROM md.customer_country
    AND l.city IS NULL
    AND l.state IS NULL
    AND l.postal_code IS NOT DISTINCT FROM md.customer_postal_code
LEFT JOIN dim_pet p
    ON p.pet_type IS NOT DISTINCT FROM md.customer_pet_type
    AND p.pet_name IS NOT DISTINCT FROM md.customer_pet_name
    AND p.pet_breed IS NOT DISTINCT FROM md.customer_pet_breed
ON CONFLICT (customer_id) DO NOTHING;
 
 
-- 4. dim_seller
INSERT INTO dim_seller (seller_id, first_name, last_name, email, location_id)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    l.location_id
FROM mock_data md
LEFT JOIN dim_location l
    ON l.country IS NOT DISTINCT FROM md.seller_country
    AND l.city IS NULL
    AND l.state IS NULL
    AND l.postal_code IS NOT DISTINCT FROM md.seller_postal_code
ON CONFLICT (seller_id) DO NOTHING;
 
 
-- 5. dim_supplier
INSERT INTO dim_supplier (supplier_name, contact_name, email, phone, address, location_id)
SELECT DISTINCT ON (supplier_name)
    md.supplier_name,
    md.supplier_contact,
    md.supplier_email,
    md.supplier_phone,
    md.supplier_address,
    l.location_id
FROM mock_data md
LEFT JOIN dim_location l
    ON l.country IS NOT DISTINCT FROM md.supplier_country
    AND l.city IS NOT DISTINCT FROM md.supplier_city
    AND l.state IS NULL
    AND l.postal_code IS NULL
WHERE md.supplier_name IS NOT NULL
ON CONFLICT (supplier_name) DO NOTHING;
 
 
-- 6. dim_store
INSERT INTO dim_store (store_name, store_location, phone, email, location_id)
SELECT DISTINCT ON (store_name, store_location)
    md.store_name,
    md.store_location,
    md.store_phone,
    md.store_email,
    l.location_id
FROM mock_data md
LEFT JOIN dim_location l
    ON l.country IS NOT DISTINCT FROM md.store_country
    AND l.city IS NOT DISTINCT FROM md.store_city
    AND l.state IS NOT DISTINCT FROM md.store_state
    AND l.postal_code IS NULL
WHERE md.store_name IS NOT NULL
ON CONFLICT (store_name, store_location) DO NOTHING;
 
 
-- 7. dim_product
INSERT INTO dim_product (
    product_id, product_name, category, pet_category,
    price, quantity, weight, color, size, brand, material,
    description, rating, reviews, release_date, expiry_date, supplier_id
)
SELECT DISTINCT ON (sale_product_id)
    md.sale_product_id,
    md.product_name,
    md.product_category,
    md.pet_category,
    md.product_price,
    md.product_quantity,
    md.product_weight,
    md.product_color,
    md.product_size,
    md.product_brand,
    md.product_material,
    md.product_description,
    md.product_rating,
    md.product_reviews,
    TO_DATE(md.product_release_date, 'MM/DD/YYYY'),
    TO_DATE(md.product_expiry_date, 'MM/DD/YYYY'),
    s.supplier_id
FROM mock_data md
LEFT JOIN dim_supplier s ON s.supplier_name = md.supplier_name
ON CONFLICT (product_id) DO NOTHING;
 
 
-- 8. fact_sales
INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, sale_date, sale_quantity, sale_total_price, product_price)
SELECT
    md.sale_customer_id,
    md.sale_seller_id,
    md.sale_product_id,
    st.store_id,
    TO_DATE(md.sale_date, 'MM/DD/YYYY'),
    md.sale_quantity,
    md.sale_total_price,
    md.product_price
FROM mock_data md
LEFT JOIN dim_store st
    ON st.store_name = md.store_name
    AND st.store_location IS NOT DISTINCT FROM md.store_location;
