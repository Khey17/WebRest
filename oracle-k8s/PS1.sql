CREATE TABLE customer (
    customer_id            VARCHAR2(38) NOT NULL,
    customer_first_name    VARCHAR2(30) NOT NULL,
    customer_middle_name   VARCHAR2(30),
    customer_last_name     VARCHAR2(30) NOT NULL,
    customer_date_of_birth DATE,
    customer_gender        VARCHAR2(10),
    customer_crtd_id       VARCHAR2(40) NOT NULL,
    customer_crtd_dt       DATE NOT NULL,
    customer_updt_id       VARCHAR2(40) NOT NULL,
    customer_updt_dt       DATE NOT NULL,
    CONSTRAINT customers_pk PRIMARY KEY ( customer_id ) ENABLE
);

CREATE TABLE product_status (
    product_status_id      VARCHAR2(38) NOT NULL,
    product_status_desc    VARCHAR2(32) NOT NULL,
    product_status_crtd_id VARCHAR2(40) NOT NULL,
    product_status_crtd_dt DATE NOT NULL,
    product_status_updt_id VARCHAR2(40) NOT NULL,
    product_status_updt_dt DATE NOT NULL,
    CONSTRAINT product_status_pk PRIMARY KEY ( product_status_id ) ENABLE
);

CREATE TABLE orders (
    orders_id          VARCHAR2(38) NOT NULL,
    orders_date        TIMESTAMP NOT NULL,
    orders_customer_id VARCHAR2(38) NOT NULL,
    orders_crtd_id     VARCHAR2(40) NOT NULL,
    orders_crtd_dt     DATE NOT NULL,
    orders_updt_id     VARCHAR2(40) NOT NULL,
    orders_updt_dt     DATE NOT NULL,
    CONSTRAINT orders_pk PRIMARY KEY ( orders_id ) ENABLE
);

ALTER TABLE orders
    ADD CONSTRAINT orders_fk1
        FOREIGN KEY ( orders_customer_id )
            REFERENCES customer ( customer_id )
        ENABLE;

CREATE TABLE product (
    product_id                VARCHAR2(38) NOT NULL,
    product_name              VARCHAR2(200) NOT NULL,
    product_desc              VARCHAR2(2000) NOT NULL,
    product_product_status_id VARCHAR2(38) NOT NULL,
    product_crtd_id           VARCHAR2(40) NOT NULL,
    product_crtd_dt           DATE NOT NULL,
    product_updt_id           VARCHAR2(40) NOT NULL,
    product_updt_dt           DATE NOT NULL,
    CONSTRAINT product_pk PRIMARY KEY ( product_id ) ENABLE
);

ALTER TABLE product
    ADD CONSTRAINT product_fk1
        FOREIGN KEY ( product_product_status_id )
            REFERENCES product_status ( product_status_id )
        ENABLE;

CREATE TABLE orders_line (
    orders_line_id         VARCHAR2(38) NOT NULL,
    orders_line_orders_id  VARCHAR2(38) NOT NULL,
    orders_line_product_id VARCHAR2(38) NOT NULL,
    orders_line_qty        NUMBER(4) NOT NULL,
    orders_line_price      NUMBER(9, 2) NOT NULL,
    orders_line_crtd_id    VARCHAR2(40) NOT NULL,
    orders_line_crtd_dt    DATE NOT NULL,
    orders_line_updt_id    VARCHAR2(40) NOT NULL,
    orders_line_updt_dt    DATE NOT NULL,
    CONSTRAINT orders_line_pk PRIMARY KEY ( orders_line_id ) ENABLE
);

ALTER TABLE orders_line
    ADD CONSTRAINT orders_line_fk1
        FOREIGN KEY ( orders_line_orders_id )
            REFERENCES orders ( orders_id )
        ENABLE;

ALTER TABLE orders_line
    ADD CONSTRAINT orders_line_fk2
        FOREIGN KEY ( orders_line_product_id )
            REFERENCES product ( product_id )
        ENABLE;