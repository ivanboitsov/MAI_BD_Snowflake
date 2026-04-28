CREATE TABLE dim_location (
    location_id: SERIAL PRIMARY KEY,
    country VARCHAR (100),
    state VARCHAR (100),
    city VARCHAR (100),
    postal_code VARCHAR (20),
    location VARCHAR (200)
);


CREATE TABLE dim_pet (
    pet_id SERIAL PRIMARY KEY,
    pet_name VARCHAR (100),
    pet_type VARCHAR (100),
    pet_breed VARCHAR (100)
);


CREATE TABLE dim_customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR (100),
    last_name VARCHAR (100),
    age INT,
    email VARCHAR (200),
    pet_id INT REFERENCES dim_pet(pet_id),
    location_id INT REFERENCES dim_location(location_id)
);

CREATE TABLE dim_seller (
    seller_id INT PRIMARY KEY,
    first_name VARCHAR (100),
    last_name VARCHAR (100),
    email VARCHAR (200),
    location_id INT REFERENCES dim_location(location_id)
);

CREATE TABLE dim_supplier (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    contact VARCHAR(200),
    email VARCHAR(200),
    phone VARCHAR(50),
    address VARCHAR(200),
    location_id INT REFERENCES dim_location(location_id)
);

CREATE TABLE dim_store (
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    phone VARCHAR(50),
    email VARCHAR(200),
    pet_category VARCHAR(100),
    location_id INT REFERENCES dim_location(location_id)
);

CREATE TABLE dim_product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(200),
    category VARCHAR(100),
    quantity INT,
    price DECIMAL(10, 2),
    weight DECIMAL(10, 1),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating DECIMAL(3, 2),
    reviews INT,
    release_date DATE,
    expiry_date DATE,
    supplier_id INT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE fact_sales (
    sale_id INT PRIMARY KEY,
    customer_id INT REFERENCES dim_customer(customer_id),
    seller_id INT REFERENCES dim_seller(seller_id),
    prduct_id INT REFERENCES dim_product(product_id),
    store_id INT REFERENCES dim_store(store_id),
    sale_date DATE,
    sale_quantity INT,
    sale_total_price DECIMAL(10, 2),
    product_price DECIMAL(10, 2)
)