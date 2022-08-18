-- sql oralce
-- autor: Fabio Mejia
-- 10/08/22


/*
    1) Esta query lista los vendedores que esten cumpliento anios en la fecha 
    actual y que tengan cantidad de ventas mayores a 1500 en el mes de enero del 2020.
 */
SELECT c.customer_id, c.name||' '|| c.last_name as full_name            -- id del vendedor y nombre completo
FROM customer c 
    JOIN item i on c.customer_id=i.seller_id
    JOIN "ORDER" o on i.item_id=o.item_id                               -- Trae todos los vendedores que tengan transacciones de compras 
WHERE  TO_CHAR(c.birth_date , 'DD/MM')=TO_CHAR(current_date , 'DD/MM')  -- Condicion: los vendedores cumplen anios el dia de hoy
    AND TO_CHAR(o.sales_date , 'MM/YYYY')='01/2020'                     -- Condicion: traer las ventas del mes de enero del anio 2020
    AND o.status ='success'                                             -- Condicion extra: Tener en cuenta solo las ventas efectivas y no las canceladas
GROUP BY c.customer_id, c.name||' '|| c.last_name
HAVING COUNT(c.customer_id)>1500;                                       -- Condicion: los venderores que tienen ventas mayores a 1500 


/*
    2) Esta query lista el top 5 venderes con mayor ventas brutas hayan tenido
    por cada mes del anio 2020. Tabien se puede realizar con informacion de varios anios.
 */
WITH sales_summary AS 
(
    SELECT RANK() OVER(
                PARTITION BY TO_DATE(TO_CHAR(o.sales_date , 'MON YYYY'),'MON YYYY')     -- posiciona a cada uno de los venderes segun sus ventas brutas por mes
                ORDER BY SUM(o.sales_quantity * o.sales_price) DESC) AS top,            -- si dos vendedores tienen las mismas ventas en el mes, comparten el puesto
            c.name, c.last_name,
            TO_CHAR(o.sales_date , 'MON YYYY') AS sales_date,
            COUNT(o.order_id)AS sales_quantity ,
            SUM(o.sales_quantity) AS products_quantity ,
            SUM(o.sales_quantity * o.sales_price) AS sales
    FROM customer c 
        JOIN item i on c.customer_id=i.seller_id
        JOIN "ORDER" o on i.item_id=o.item_id 
        JOIN category ca on i.category_id = ca.category_id                              -- Trae todos los vendedores que tengan transacciones de compras 
    WHERE ca.path like '%Celulares%'                                                    -- Condicion: Filtra por las ventas que sean de la categoria Celulares o subcategorias de esta
        AND o.status ='success'                                                         -- Condicion extra: Tener en cuenta solo las ventas efectivas y no las canceladas
        AND TO_CHAR(o.sales_date , 'YYYY')='2020'                                       -- Condicion: traer las ventas del anio 2020
    GROUP BY  c.name, c.last_name,TO_CHAR(o.sales_date , 'MON YYYY')
)
SELECT *
FROM sales_summary
WHERE top<5;                                                                            -- Condicion: los primeros 5 de cada mes
        

/*
    3) Esta query crea un procedimiento para cargar la lista de precios de los items 
    creados en un dia especifico. si no se especifica un dia de cargue, se  realiza
    con la fecha actual.
 */
CREATE OR REPLACE PROCEDURE SP_ITEMS_PRICE_LOAD(specific_date VARCHAR := NULL)   -- Se puede pasar por parametro una fecha diferente a la de hoy si se quiere.
IS
BEGIN
    INSERT INTO price_list
    (
        SELECT item_id,price, status
        FROM item
        WHERE  created_date = TO_DATE(NVL(specific_date,SYSDATE),'DD/MM/YY')                    -- Si existe un parametro de fecha se trae los items creados ese dia, de lo contrario seran los del dia actual.
    );
    COMMIT;
END;

-- Ejecucion de stored procedure ejemplos:
EXEC SP_ITEMS_PRICE_LOAD('10/03/22');   -- Ejecucion con parametro de una fecha especifca para el cargue.
EXEC SP_ITEMS_PRICE_LOAD();             -- Ejecucion cargando los items del dia actual.

-- Estrucutra de la tabla usada para cargue de la lista de precios
CREATE TABLE PRICE_LIST
(	
    "ITEM_ID" VARCHAR2(20 BYTE), 
    "PRICE" NUMBER(11,2), 
	"STATUS" VARCHAR2(10 BYTE)
);

