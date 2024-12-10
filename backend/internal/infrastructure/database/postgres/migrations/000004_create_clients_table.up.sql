CREATE TABLE IF NOT EXISTS clients (
    id SERIAL PRIMARY KEY,
    company_id INT NOT NULL,
    address_street VARCHAR(255) NOT NULL,
    address_city VARCHAR(255) NOT NULL,
    address_zipcode VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(255) NOT NULL,
    registration_number VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    FOREIGN KEY (company_id) REFERENCES companies(id),
    UNIQUE (company_id, email),
    UNIQUE (company_id, registration_number)
);

