-- New Tables
CREATE TABLE inventory (
    inventory_id            VARCHAR2(38 BYTE) NOT NULL,
    inventory_product_id    VARCHAR2(38 BYTE) NOT NULL,
    inventory_order_line_id VARCHAR2(38 BYTE) NOT NULL,
    inventory_serial_nbr    VARCHAR2(50 BYTE),
    inventory_crtd_id       VARCHAR2(40 BYTE) NOT NULL,
    inventory_crtd_dt       DATE NOT NULL,
    inventory_updt_id       VARCHAR2(40 BYTE) NOT NULL,
    inventory_updt_dt       DATE NOT NULL,
    CONSTRAINT inventory_pk PRIMARY KEY ( inventory_id ) ENABLE
);

CREATE TABLE inventory_state (
    inventory_state_id                  VARCHAR2(38) NOT NULL,
    inventory_state_ts                  TIMESTAMP NOT NULL,
    inventory_state_inventory_status_id VARCHAR2(38) NOT NULL,
    inventory_state_inventory_id        VARCHAR2(38) NOT NULL,
    inventory_state_crtd_id             VARCHAR2(40) NOT NULL,
    inventory_state_crtd_dt             DATE NOT NULL,
    inventory_state_updt_id             VARCHAR2(40) NOT NULL,
    inventory_state_updt_dt             DATE NOT NULL,
    CONSTRAINT inventory_state_pk PRIMARY KEY ( inventory_state_id ) ENABLE
);

CREATE TABLE inventory_status (
    inventory_status_id      VARCHAR2(38) NOT NULL,
    inventory_status_desc    VARCHAR2(20) NOT NULL,
    inventory_status_crtd_id VARCHAR2(40) NOT NULL,
    inventory_status_crtd_dt DATE NOT NULL,
    inventory_status_updt_id VARCHAR2(40) NOT NULL,
    inventory_status_updt_dt DATE NOT NULL,
    CONSTRAINT inventory_status_pk PRIMARY KEY ( inventory_status_id ) ENABLE
);

-- Foreign Constraints
ALTER TABLE inventory
    ADD CONSTRAINT inventory_fk1
        FOREIGN KEY ( inventory_order_line_id )
            REFERENCES orders_line ( orders_line_id )
        ENABLE;

ALTER TABLE inventory
    ADD CONSTRAINT inventory_fk2
        FOREIGN KEY ( inventory_product_id )
            REFERENCES product ( product_id )
        ENABLE;

ALTER TABLE inventory_state
    ADD CONSTRAINT inventory_state_fk1
        FOREIGN KEY ( inventory_state_inventory_id )
            REFERENCES inventory ( inventory_id )
        ENABLE;

ALTER TABLE inventory_state
    ADD CONSTRAINT inventory_state_fk2
        FOREIGN KEY ( inventory_state_inventory_status_id )
            REFERENCES inventory_status ( inventory_status_id )
        ENABLE;
        
-- Ordersline to Product ID link is no longer needed since we already have inventory
ALTER TABLE ORDERS_LINE 
DROP CONSTRAINT ORDERS_LINE_FK2;

ALTER TABLE ORDERS_LINE 
DROP COLUMN ORDERS_LINE_PRODUCT_ID;
        
-- Triggers
BEGIN
    prc_create_triggers();
END;
/

-- Check Me
BEGIN
    check_me(5);
END;
