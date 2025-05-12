-- Updating Schema from PS2
CREATE TABLE address_type (
    address_type_id      VARCHAR2(32) NOT NULL,
    address_type_desc    VARCHAR2(10) NOT NULL,
    address_type_crtd_id VARCHAR2(40) NOT NULL,
    address_type_crtd_dt DATE NOT NULL,
    address_type_updt_id VARCHAR2(40) NOT NULL,
    address_type_updt_dt DATE NOT NULL,
    CONSTRAINT address_type_pk PRIMARY KEY ( address_type_id ) ENABLE
);

CREATE TABLE address (
    address_id      VARCHAR2(32) NOT NULL,
    address_line1   VARCHAR2(50) NOT NULL,
    address_line2   VARCHAR2(50),
    address_line3   VARCHAR2(50),
    address_city    VARCHAR2(40) NOT NULL,
    address_state   CHAR(2) NOT NULL,
    address_zip     VARCHAR2(20) NOT NULL,
    address_crtd_id VARCHAR2(20) NOT NULL,
    address_crtd_dt DATE NOT NULL,
    address_updt_id VARCHAR2(20) NOT NULL,
    address_updt_dt DATE NOT NULL,
    CONSTRAINT address_pk PRIMARY KEY ( address_id ) ENABLE
);

CREATE TABLE customer_address (
    customer_address_id              VARCHAR2(32) NOT NULL,
    customer_address_customer_id     VARCHAR2(32) NOT NULL,
    customer_address_address_id      VARCHAR2(32) NOT NULL,
    customer_address_address_type_id VARCHAR2(32) NOT NULL,
    customer_address_actv_ind        NUMBER(1) NOT NULL,
    customer_address_default_ind     NUMBER(1) NOT NULL,
    customer_address_crtd_id         VARCHAR2(40) NOT NULL,
    customer_address_crtd_dt         DATE NOT NULL,
    customer_address_updt_id         VARCHAR2(40) NOT NULL,
    customer_address_updt_dt         DATE NOT NULL,
    CONSTRAINT customer_address_pk PRIMARY KEY ( customer_address_id ) ENABLE
);

ALTER TABLE customer_address
    ADD CONSTRAINT customer_address_fk1
        FOREIGN KEY ( customer_address_customer_id )
            REFERENCES customer ( customer_id )
        ENABLE;

ALTER TABLE customer_address
    ADD CONSTRAINT customer_address_fk2
        FOREIGN KEY ( customer_address_address_id )
            REFERENCES address ( address_id )
        ENABLE;

ALTER TABLE customer_address
    ADD CONSTRAINT customer_address_fk3
        FOREIGN KEY ( customer_address_address_type_id )
            REFERENCES address_type ( address_type_id )
        ENABLE;

CREATE TABLE order_status (
    order_status_id                   VARCHAR2(32) NOT NULL,
    order_status_desc                 VARCHAR2(20) NOT NULL,
    order_status_next_order_status_id VARCHAR2(32),
    order_status_crtd_id              VARCHAR2(40) NOT NULL,
    order_status_crtd_dt              DATE NOT NULL,
    order_status_updt_id              VARCHAR2(40) NOT NULL,
    order_status_updt_dt              DATE NOT NULL,
    CONSTRAINT order_status_pk PRIMARY KEY ( order_status_id ) ENABLE
);

CREATE TABLE order_state (
    order_state_id              VARCHAR2(32) NOT NULL,
    order_state_orders_id       VARCHAR2(32) NOT NULL,
    order_state_order_status_id VARCHAR2(32) NOT NULL,
    order_state_eff_date        DATE NOT NULL,
    order_state_crtd_id         VARCHAR2(40) NOT NULL,
    order_state_crtd_dt         DATE NOT NULL,
    order_state_updt_id         VARCHAR2(40) NOT NULL,
    order_state_updt_dt         DATE NOT NULL,
    CONSTRAINT order_state_pk PRIMARY KEY ( order_state_id ) ENABLE
);

ALTER TABLE order_status
    ADD CONSTRAINT order_status_fk1
        FOREIGN KEY ( order_status_next_order_status_id )
            REFERENCES order_status ( order_status_id )
        ENABLE;

ALTER TABLE order_state
    ADD CONSTRAINT order_state_fk1
        FOREIGN KEY ( order_state_orders_id )
            REFERENCES orders ( orders_id )
        ENABLE;

ALTER TABLE order_state
    ADD CONSTRAINT order_state_fk2
        FOREIGN KEY ( order_state_order_status_id )
            REFERENCES order_status ( order_status_id )
        ENABLE;

-- Run the Triggers procedure
BEGIN
    prc_create_triggers();
END;
/

-- Insert records into order_status with next status
INSERT INTO order_status ( order_status_desc ) VALUES ( 'New' );

INSERT INTO order_status ( order_status_desc ) VALUES ( 'Picking' );

INSERT INTO order_status ( order_status_desc ) VALUES ( 'Picked' );

INSERT INTO order_status ( order_status_desc ) VALUES ( 'Shipping' );

INSERT INTO order_status ( order_status_desc ) VALUES ( 'Shipped' );

UPDATE order_status
SET
    order_status_next_order_status_id = (
        SELECT
            order_status_id
        FROM
            order_status
        WHERE
            order_status_desc = 'Picking'
    )
WHERE
    order_status_desc = 'New';

UPDATE order_status
SET
    order_status_next_order_status_id = (
        SELECT
            order_status_id
        FROM
            order_status
        WHERE
            order_status_desc = 'Picked'
    )
WHERE
    order_status_desc = 'Picking';

UPDATE order_status
SET
    order_status_next_order_status_id = (
        SELECT
            order_status_id
        FROM
            order_status
        WHERE
            order_status_desc = 'Shipping'
    )
WHERE
    order_status_desc = 'Picked';

UPDATE order_status
SET
    order_status_next_order_status_id = (
        SELECT
            order_status_id
        FROM
            order_status
        WHERE
            order_status_desc = 'Shipped'
    )
WHERE
    order_status_desc = 'Shipping';

CREATE OR REPLACE PACKAGE pkg_order AS
    FUNCTION fn_find_current_order_status_id (
        orders_id_in VARCHAR2
    ) RETURN VARCHAR2;
    
    FUNCTION fn_find_next_order_status_id (
        order_status_id_in VARCHAR2
    ) RETURN VARCHAR2;

    FUNCTION fn_find_status_id_by_desc (
        order_status_desc_in VARCHAR2
    ) RETURN VARCHAR2;
    
    PROCEDURE set_order_status (
        order_state_orders_id_in       orders.orders_id%TYPE,
        order_state_order_status_id_in order_state.order_state_order_status_id%TYPE,
        order_state_eff_date_in        order_state.order_state_eff_date%TYPE
    );

    PROCEDURE advance_order_status (
        orders_id_in            orders.orders_id%TYPE,
        order_state_eff_date_in order_state.order_state_eff_date%TYPE
    );

END pkg_order;
/

CREATE OR REPLACE PACKAGE BODY pkg_order AS

    FUNCTION fn_find_current_order_status_id (
        orders_id_in VARCHAR2
    ) RETURN VARCHAR2 AS
        v_current_order_status_id VARCHAR2(38);
    BEGIN
        SELECT
            order_state_order_status_id
        INTO v_current_order_status_id
        FROM
            order_state
        WHERE
                order_state_orders_id = orders_id_in
            AND order_state_updt_dt = (
                SELECT
                    MAX(order_state_updt_dt)
                FROM
                    order_state
                WHERE
                    order_state_orders_id = orders_id_in
            );

        RETURN v_current_order_status_id;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN NULL;
    END;

    FUNCTION fn_find_status_id_by_desc (
        order_status_desc_in VARCHAR2
    ) RETURN VARCHAR2 AS
        v_order_status_id VARCHAR2(38);
    BEGIN
        SELECT
            order_status_id
        INTO v_order_status_id
        FROM
            order_status
        WHERE
            order_status_desc = order_status_desc_in;

        RETURN v_order_status_id;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN NULL;
    END;
    
    FUNCTION fn_find_next_order_status_id (
        order_status_id_in VARCHAR2
    ) RETURN VARCHAR2 AS
        v_next_order_status_id VARCHAR2(38);
    BEGIN
        SELECT
            order_status_next_order_status_id
        INTO v_next_order_status_id
        FROM
            order_status
        WHERE
            order_status_id = order_status_id_in;  -- FIXED condition

        RETURN v_next_order_status_id;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN NULL;
    END;

    PROCEDURE set_order_status (
        order_state_orders_id_in       orders.orders_id%TYPE,
        order_state_order_status_id_in order_state.order_state_order_status_id%TYPE,
        order_state_eff_date_in        order_state.order_state_eff_date%TYPE
    ) AS
    BEGIN
        INSERT INTO order_state (
            order_state_id,
            order_state_orders_id,
            order_state_order_status_id,
            order_state_eff_date
        ) VALUES ( sys_guid(),
                   order_state_orders_id_in,
                   order_state_order_status_id_in,
                   order_state_eff_date_in );

    END set_order_status;

    PROCEDURE advance_order_status (
        orders_id_in            orders.orders_id%TYPE,
        order_state_eff_date_in order_state.order_state_eff_date%TYPE
    ) AS
        v_current_order_status_id VARCHAR2(38);
        v_next_order_status_id    VARCHAR2(38);
    BEGIN
        -- Find current order status id
        v_current_order_status_id := fn_find_current_order_status_id(orders_id_in);
        IF v_current_order_status_id IS NULL THEN
            v_next_order_status_id := fn_find_status_id_by_desc('New');
        ELSE
        -- Find next order status id
            v_next_order_status_id := fn_find_next_order_status_id(v_current_order_status_id);
        END IF;

    -- Insert new order state record if a valid next status exists
        IF v_next_order_status_id IS NOT NULL THEN
            set_order_status(orders_id_in, v_next_order_status_id, order_state_eff_date_in);
        END IF;

    END advance_order_status;

END pkg_order;
/

    
-- Test out the functions
select pkg_order.fn_find_current_order_status_id('0024FD0DDF7E4078A44EA7377B234280');  -- Current Status
select pkg_order.fn_find_next_order_status_id('76E5DA206BB6458481B7EF6CE8E78090');  -- Shipping
select pkg_order.fn_find_status_id_by_desc('Shipping');  -- 28567296F28E43BAA161714706DBD079
