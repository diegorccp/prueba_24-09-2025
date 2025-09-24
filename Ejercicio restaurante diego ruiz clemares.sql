-- ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
SELECT 
    s.customer_id, 
    SUM(m.price) AS gastado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- ¿Cuántos días ha visitado cada cliente el restaurante?
SELECT 
    customer_id, 
    COUNT(DISTINCT order_date) AS visitas
FROM sales
GROUP BY customer_id;

-- ¿Cuál fue el primer artículo del menú comprado por cada cliente?
SELECT 
    distinct s.customer_id,
    m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
WHERE s.product_id = (
    SELECT MIN(s2.product_id)
    FROM sales s2
    WHERE s2.customer_id = s.customer_id
      AND s2.order_date = (
          SELECT MIN(s3.order_date)
          FROM sales s3
          WHERE s3.customer_id = s.customer_id
      )
);


-- ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes? (aqui lo que hago esq lo ordeno de mas comprado a menos y ueog hago el limite 1 para que me de solo el mas comprado)
SELECT 
    m.product_name,
    COUNT(*) AS veces_comprado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY veces_comprado DESC
LIMIT 1;

-- ¿Qué artículo fue el más popular para cada cliente?
SELECT s.customer_id, m.product_name, count(*) as veces
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM sales s2
        WHERE s2.customer_id = s.customer_id
        GROUP BY s2.product_id
    ) sub
);


-- ¿Qué artículo compró primero el cliente después de convertirse en miembro?
SELECT 
    s.customer_id,
    m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date = (
    SELECT MIN(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = s.customer_id
      AND s2.order_date >= mem.join_date
);


-- ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro? (en a salen dos porque ha comprado los dos el mismo día)
SELECT 
    s.customer_id,
    m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date = (
    SELECT MIN(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = s.customer_id
      AND s2.order_date < mem.join_date
);


-- ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro?
SELECT 
    s.customer_id,
    COUNT(*) AS total_articulos,
    SUM(m.price) AS total_gastado
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date < mem.join_date
GROUP BY s.customer_id;

-- Si cada $1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de 2x, ¿Cuántos puntos tendría cada cliente?
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN m.product_name = 'sushi' THEN m.price * 20
            ELSE m.price * 10
        END
    ) AS puntos
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date
GROUP BY s.customer_id;

-- Puntos de clientes A y B hasta fines de enero con primera semana doble
SELECT 
    s.customer_id,
    SUM(
        CASE 
            WHEN s.order_date >= mem.join_date 
             AND s.order_date < DATE_ADD(mem.join_date, INTERVAL 7 DAY) 
            THEN m.price * 20  -- primera semana: todos los productos valen doble
            WHEN m.product_name = 'sushi' 
             AND s.order_date >= mem.join_date
            THEN m.price * 20  -- sushi después de unirse: 2x
            ELSE m.price * 10  -- otros productos después de unirse: 10 puntos por dólar
        END
    ) AS puntos
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mem ON s.customer_id = mem.customer_id
WHERE s.customer_id IN ('A','B')
  AND s.order_date >= mem.join_date  -- solo compras después de unirse
  AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id;