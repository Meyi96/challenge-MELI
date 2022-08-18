-- sql oralce
-- autor: Fabio Mejia
-- 10/08/22

-- Borrado de tablas previo
DROP TABLE category CASCADE CONSTRAINTS;

DROP TABLE city CASCADE CONSTRAINTS;

DROP TABLE country CASCADE CONSTRAINTS;

DROP TABLE customer CASCADE CONSTRAINTS;

DROP TABLE item CASCADE CONSTRAINTS;

DROP TABLE "ORDER" CASCADE CONSTRAINTS;

DROP TABLE state CASCADE CONSTRAINTS;


/*
    Tabla ciudad, para representar el conjunto de ciudades de un pais y estado.
 */
CREATE TABLE city (
    city_id   VARCHAR2(10) NOT NULL,
    name      VARCHAR2(50) NOT NULL,
    latitude  NUMBER(11, 6) NOT NULL,
    longitude NUMBER(11, 6) NOT NULL,
    state_id  VARCHAR2(10) NOT NULL
);

ALTER TABLE city ADD CONSTRAINT city_pk PRIMARY KEY ( city_id );


/*
    Tabla estado, para representar el conjunto de estados de un pais.
 */
CREATE TABLE state (
    state_id   VARCHAR2(10) NOT NULL,
    name       VARCHAR2(50) NOT NULL,
    latitude   NUMBER(11, 6) NOT NULL,
    longitude  NUMBER(11, 6) NOT NULL,
    country_id VARCHAR2(10) NOT NULL
);

ALTER TABLE state ADD CONSTRAINT state_pk PRIMARY KEY ( state_id );


/*
    Tabla pais, para representar los diferentes paises con sus
    estados y ciudades.
 */
CREATE TABLE country (
    country_id VARCHAR2(10) NOT NULL,
    name       VARCHAR2(50) NOT NULL,
    latitude   NUMBER(11, 6) NOT NULL,
    longitude  NUMBER(11, 6) NOT NULL
);

ALTER TABLE country ADD CONSTRAINT country_pk PRIMARY KEY ( country_id );


/*
    Tabla cliente representa a los vendedores y compradores dentro del sistema.
    Un cliente es un comprador al tener relacion directa con la orden y es un 
    vendedor cuando tiene asociados items para vender.
 */
CREATE TABLE customer (
    customer_id NUMBER(10) NOT NULL,
    name        VARCHAR2(50) NOT NULL,
    last_name   VARCHAR2(50) NOT NULL,
    nickname    VARCHAR2(50) NOT NULL,
    dni         VARCHAR2(20) NOT NULL,
    email       VARCHAR2(50) NOT NULL,
    gender      VARCHAR2(10) NOT NULL,
    phone       VARCHAR2(20) NOT NULL,
    birth_date  DATE NOT NULL,
    address     VARCHAR2(50) NOT NULL,
    city_id     VARCHAR2(10) NOT NULL
);

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( customer_id );


/*
    Tabla categoria tiene una relacion consigo misma para representar 
    todas las subcategorias que una categoria puede tener. La estrategia 
    con el path consiste en que cada vez que se cree una nueva categoria,
    el path sera la concatenacion del path de la categoria padre y el nombre
    de la categoria en creacion path_parent/name_current_category. Si la categoria
    no tiene padre su path sera su mismo nombre.
 */
CREATE TABLE category (
    category_id        VARCHAR2(20) NOT NULL,
    name               VARCHAR2(50) NOT NULL,
    category_desc      VARCHAR2(80),
    items_in_category  NUMBER(10),
    path               VARCHAR2(100),
    parent_category_id VARCHAR2(20)
);

ALTER TABLE category ADD CONSTRAINT category_pk PRIMARY KEY ( category_id );


/*
    Tabla item es la representacion de cada uno de los productos que tiene publicados
    un vendedor para la venta y puede estar asociado a varias ordenes, representado
    diferentes ventas de ese producto. Cada item cuenta con un estado para saber si esta
    activo o inactivo, tambien cuenta con una fecha de bajada, dado el caso.
 */
CREATE TABLE item (
    item_id            VARCHAR2(20) NOT NULL,
    tittle             VARCHAR2(80) NOT NULL,
    subtitle           VARCHAR2(80),
    price              NUMBER(11, 2) NOT NULL,
    available_quantity NUMBER(9) NOT NULL,
    created_date       DATE NOT NULL,
    start_date         DATE NOT NULL,
    stop_date          DATE,
    status             VARCHAR2(10) NOT NULL,
    seller_id          NUMBER(10) NOT NULL,
    category_id        VARCHAR2(20) NOT NULL
);

ALTER TABLE item ADD CONSTRAINT item_pk PRIMARY KEY ( item_id );


/*
    Tabla orden representa cada una de las transacciones de venta.
    una orden tiene un comprador y un item a comprar. La order de
    compra cuenta con un estado para saber si la transaccion fue exitosa,
    cancelada o en proceso. Tambien almacena el precio del item a comprar
    ya que este puede variar con el tiempo en futuras compras.
 */
CREATE TABLE "ORDER" (
    order_id       VARCHAR2(20) NOT NULL,
    sales_quantity NUMBER(8) NOT NULL,
    sales_price    NUMBER(11, 2) NOT NULL,
    sales_date     DATE NOT NULL,
    status         VARCHAR2(10) NOT NULL,
    buyer_id       NUMBER(10) NOT NULL,
    item_id        VARCHAR2(20) NOT NULL
);

ALTER TABLE "ORDER" ADD CONSTRAINT order_pk PRIMARY KEY ( order_id );


-- representa  la relacion del comprador en una orden
ALTER TABLE "ORDER"
    ADD CONSTRAINT buyer_id_fk FOREIGN KEY ( buyer_id )
        REFERENCES customer ( customer_id );

-- representa  la relacion del item a comprar en una orden
ALTER TABLE "ORDER"
    ADD CONSTRAINT order_item_id_fk FOREIGN KEY ( item_id )
        REFERENCES item ( item_id );

-- representa  la relacion de los items que tiene publicados un vendedor
ALTER TABLE item
    ADD CONSTRAINT seller_id_fk FOREIGN KEY ( seller_id )
        REFERENCES customer ( customer_id );

-- representa  la relacion la categoria a la cual hace parte un item
ALTER TABLE item
    ADD CONSTRAINT category_id_fk FOREIGN KEY ( category_id )
        REFERENCES category ( category_id );

-- representa  la relacion de una categoria hija con su categoria padre
ALTER TABLE category
    ADD CONSTRAINT children_categories_fk FOREIGN KEY ( parent_category_id )
        REFERENCES category ( category_id );

-- representa  la relacion de la ciudad de donde es la direccion del cliente
ALTER TABLE customer
    ADD CONSTRAINT city_id_fk FOREIGN KEY ( city_id )
        REFERENCES city ( city_id );

-- representa  la relacion del pais con sus estados
ALTER TABLE state
    ADD CONSTRAINT country_id_fk FOREIGN KEY ( country_id )
        REFERENCES country ( country_id );

-- representa  la relacion del estado con sus ciudades
ALTER TABLE city
    ADD CONSTRAINT state_id_fk FOREIGN KEY ( state_id )
        REFERENCES state ( state_id );
