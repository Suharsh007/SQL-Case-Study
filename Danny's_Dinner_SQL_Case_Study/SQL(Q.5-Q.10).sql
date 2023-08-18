-- Q.5 Which item was the most popular for each customer?
WITH cte AS(
SELECT s.customer_id, m.product_name,
  COUNT(m.product_id) AS order_count,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.customer_id) DESC) AS rank
FROM sales s 
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id,m.product_name)

SELECT customer_id,product_name,order_count
FROM cte
WHERE rank=1

--Q.6 Which item was purchased first by the customer after they became a member?
WITH cte AS(SELECT s.customer_id, s.product_id,
DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rank
FROM sales s
INNER JOIN members m
ON s.customer_id = m.customer_id
AND s.order_date > m.join_date)
SELECT c.customer_id, m.product_name
FROM cte c
INNER JOIN menu m
ON c.product_id=m.product_id
WHERE rank=1

--Q.7 Which item was purchased just before the customer became a member?

WITH cte AS(SELECT s.customer_id, s.product_id,
ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rno
FROM sales s
INNER JOIN members m
ON s.customer_id = m.customer_id
AND s.order_date < m.join_date)
SELECT c.customer_id, m.product_name
FROM cte c
INNER JOIN menu m
ON c.product_id=m.product_id
WHERE rno=1


-- Q.8 What is the total items and amount spent for each member before they became a member?

WITH cte AS(SELECT s.customer_id, s.product_id
FROM sales s
INNER JOIN members m
ON s.customer_id = m.customer_id
AND s.order_date < m.join_date)
SELECT c.customer_id, COUNT(c.product_id) AS total_items, SUM(m.price) AS total_sales
FROM cte c
INNER JOIN menu m
ON c.product_id=m.product_id
GROUP BY c.customer_id

--Q.9 If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?
SELECT s.customer_id,
SUM(CASE WHEN m.product_name='sushi' THEN 20*m.price ELSE 10*m.price END) as total_points
FROM sales s 
INNER JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id

--Q.10 In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

WITH points_calc AS (
  SELECT s.customer_id,
    (
      CASE
        WHEN DATEDIFF(day,s.order_date, m.join_date) >= 0 AND DATEDIFF(day,s.order_date, m.join_date) <= 6 THEN price * 10 * 2
        WHEN product_name ='sushi' THEN price * 10 * 2
        ELSE price * 10
      END
    ) as points
  FROM sales s
  INNER JOIN menu mu
  ON s.product_id=mu.product_id
  INNER JOIN members m
  ON s.customer_id = m.customer_id
  WHERE MONTH(order_date) = 1 AND YEAR(order_date) = 2021
)
SELECT customer_id, SUM(points) AS points_total
FROM points_calc
GROUP BY customer_id;








