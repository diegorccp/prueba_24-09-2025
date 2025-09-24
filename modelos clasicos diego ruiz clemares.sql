-- 1
SELECT officeCode, phone
FROM offices;

-- 2
Select firstName, lastName, email
from employees
where email LIKE '%.es';

-- 3
SELECT customerNumber, customerName, state
FROM customers
WHERE state IS NULL;

-- 4 busquemos pagos que superen los $20.000.
select checkNumber
from payments 
where amount>20000;

-- 5 Ahora, acote la lista aún más y busque los pagos mayores a $20,000 que se realizaron en el año 2005.
select checkNumber
from payments 
where amount>20000 and 2005 = year(paymentDate);

-- 6 busque y muestre solo las filas únicas de la tabla “orderdetails” en función de la columna “productcode”.
SELECT DISTINCT productCode
FROM orderdetails;

-- 7 por último, cree una tabla que muestre el recuento de compras realizadas por país.
SELECT c.country, COUNT(o.orderNumber) AS total_compras
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country;

-- 8 descubramos qué línea de producto tiene la descripción de texto más larga.
SELECT productLine, LENGTH(textDescription) AS longitud
FROM productlines
ORDER BY longitud DESC
LIMIT 1;

-- 9 ¿Puede determinar el número de clientes asociados a cada oficina?
SELECT o.officeCode, COUNT(c.customerNumber) AS total_clientes
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
GROUP BY o.officeCode;

-- 10 descubra qué día de la semana se registra el mayor número de ventas de automóviles.
SELECT DAYNAME(o.orderDate) AS dia, COUNT(od.orderNumber) AS ventas
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN products p ON od.productCode = p.productCode
WHERE p.productLine LIKE '%Cars%'
GROUP BY dia
ORDER BY ventas DESC
LIMIT 1;

-- 11 Corregir valores NA en offices.territory

UPDATE offices
SET territory = 'USA'
WHERE territory IS NULL OR territory = 'NA';



-- 12 Estadísticas familia Patterson (2004-2005)

SELECT YEAR(o.orderDate) AS anio, MONTH(o.orderDate) AS mes,
       AVG(od.quantityOrdered * od.priceEach) AS promedio_carrito,
       SUM(od.quantityOrdered) AS total_items
FROM employees e
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
JOIN orders o ON c.customerNumber = o.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE (e.lastName = 'Patterson')
  AND YEAR(o.orderDate) IN (2004, 2005)
GROUP BY anio, mes;

-- 13 Análisis de compras anuales (2004-2005, clientes de Patterson)

SELECT anio, mes,
       AVG(total_carrito) AS promedio_carrito,
       AVG(total_items) AS promedio_items
FROM (
    SELECT YEAR(o.orderDate) AS anio, MONTH(o.orderDate) AS mes,
           (od.quantityOrdered * od.priceEach) AS total_carrito,
           od.quantityOrdered AS total_items
    FROM employees e
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
    JOIN orders o ON c.customerNumber = o.customerNumber
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    WHERE e.lastName = 'Patterson'
      AND YEAR(o.orderDate) IN (2004, 2005)
) AS sub
GROUP BY anio, mes;


-- 14 Oficinas con empleados que atienden clientes sin estado

SELECT DISTINCT o.officeCode, o.city
FROM offices o
JOIN employees e ON o.officeCode = e.officeCode
JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE c.state IS NULL;


