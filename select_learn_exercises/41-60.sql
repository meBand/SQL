--41. Для каждого производителя, у которого присутствуют
--    модели хотя бы в одной из таблиц PC, Laptop или Printer,
--    определить максимальную цену на его продукцию.
--    Вывод: имя производителя, если среди цен на продукцию
--    данного производителя присутствует NULL,
--    то выводить для этого производителя NULL, иначе максимальную цену.

WITH makersAndPrices AS (
	SELECT DISTINCT maker,
				    pc.price
			   FROM pc
			   JOIN product
			     ON product.model = pc.model
			   
			   UNION
			   
	SELECT DISTINCT maker,
					laptop.price
			   FROM laptop
			   JOIN product
				 ON product.model = laptop.model
				 
			  UNION

	SELECT DISTINCT maker,
					printer.price 
			   FROM printer
			   JOIN product
			     ON product.model = printer.model
)

SELECT maker, 
	   CASE
		 WHEN maker IN(SELECT DISTINCT maker FROM makersAndPrices WHERE price IS NULL)
		 THEN NULL
		 ELSE MAX(price)
	   END price
  FROM makersAndPrices
 GROUP BY maker



--42. Найдите названия кораблей, потопленных в сражениях,
--    и название сражения, в котором они были потоплены.

SELECT ship,
	   battle
  FROM outcomes
 WHERE result = 'sunk'
 


--43. Укажите сражения, которые произошли в годы,
--    не совпадающие ни с одним из годов спуска кораблей на воду.

SELECT name
  FROM battles
 WHERE YEAR(date) NOT IN(
						 SELECT launched
						   FROM ships
						  WHERE launched IS NOT NULL
						)
						
						
						
--44. Найдите названия всех кораблей в базе данных,
--    начинающихся с буквы R.

SELECT name
  FROM ships
 WHERE name LIKE 'R%'
 
 UNION
 
SELECT ship
  FROM outcomes
 WHERE ship LIKE 'R%'
 
 
 
--45. Найдите названия всех кораблей в базе данных, состоящие
--    из трех и более слов (например, King George V).
--    Считать, что слова в названиях разделяются единичными
--    пробелами, и нет концевых пробелов.

SELECT name 
  FROM ships
 WHERE name LIKE '% % %'
 
 UNION
 
SELECT ship
  FROM outcomes
 WHERE ship LIKE '% % %'
 


--46. Для каждого корабля, участвовавшего в сражении при
--    Гвадалканале (Guadalcanal), вывести название,
--    водоизмещение и число орудий.

WITH classAndShipsG AS (
	SELECT DISTINCT CASE
					  WHEN class IS NULL
					  THEN ship
					  ELSE class
					END class,
					ship,
					battle
			   FROM outcomes
		  LEFT JOIN ships
		         ON ships.name = outcomes.ship
)

SELECT DISTINCT ship,
			    displacement,
				numGuns
		   FROM classAndShipsG
	  LEFT JOIN classes
	         ON classes.class = classAndShipsG.class
		  WHERE battle = 'Guadalcanal'



--47. Определить страны, которые потеряли в сражениях все свои корабли.
--    p.s. скорее всего есть более краткий способ.. 
  
WITH AllShips AS (
	SELECT class,
		   name
	  FROM ships
	  
	 UNION

	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
			 END class,
			ship
		FROM outcomes
   LEFT JOIN ships
          ON ships.name = outcomes.ship
),
AllShipsCount AS (
	SELECT country,
		   COUNT(name) AS countShips
	  FROM classes
	  JOIN AllShips
	    ON AllShips.class = classes.class
  GROUP BY country
),
SunkShips AS (
SELECT DISTINCT CASE
				  WHEN class IS NULL
				  THEN ship
				  ELSE class
				  END class,
				  ship
			 FROM outcomes
		LEFT JOIN ships
		       ON ships.name = outcomes.ship
	        WHERE result = 'sunk'
),
countSunkShips AS (
	SELECT country,
		   COUNT(ship) AS cSunkShips
	  FROM classes
	  JOIN SunkShips
	    ON SunkShips.class = classes.class
  GROUP BY country
),
countryAndCount AS (
SELECT * FROM AllShipsCount

INTERSECT

SELECT * FROM countSunkShips
)

SELECT DISTINCT country
	       FROM countryAndCount
		   
		   
		   
--48. Найдите классы кораблей, в которых
--    хотя бы один корабль был потоплен в сражении.

WITH AllShips AS (
	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
		   END class,
		   ship
	  FROM outcomes
 LEFT JOIN ships
        ON ships.name = outcomes.ship
	 WHERE result = 'sunk'
)

SELECT class
  FROM classes

INTERSECT

SELECT class
  FROM allShips
  
  
  
--49. Найдите названия кораблей с орудиями
--    калибра 16 дюймов (учесть корабли из таблицы Outcomes).

WITH AllShips AS (
	SELECT class,
	       name as ship
	  FROM ships
	  
	  UNION
	  
	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
			 END class,
		   ship FROM outcomes
	  LEFT JOIN ships
	    ON ships.name = outcomes.ship
),
AllShipsWithBore AS (
	SELECT AllShips.class,
	       ship,
		   bore
	  FROM AllShips
	  JOIN classes
	    ON classes.class = AllShips.class
)

SELECT ship
  FROM ALLShipsWithBore
 WHERE bore = 16



--50. Найдите сражения, в которых участвовали
--    корабли класса Kongo из таблицы Ships.

WITH AllShips AS (
	SELECT class,
		   name as ship
	  FROM ships
	
	 UNION
	
	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
		   END,
		   ship
	  FROM outcomes
      LEFT JOIN ships
	    ON ships.name = outcomes.ship
)

SELECT DISTINCT battle
		   FROM AllShips
	       JOIN outcomes
		     ON outcomes.ship = AllShips.ship
		  WHERE class = 'Kongo'
		  
		  
		  
--51. Найдите названия кораблей, имеющих наибольшее число
--    орудий среди всех имеющихся кораблей такого же
--    водоизмещения (учесть корабли из таблицы Outcomes).

WITH AllShips AS (
	SELECT class,
		   name as ship
	  FROM ships
	
	 UNION
	
	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
		   END,
		   ship
	  FROM outcomes
      LEFT JOIN ships
	    ON ships.name = outcomes.ship
)

SELECT ship
  FROM AllShips
  JOIN classes AS c
    ON AllShips.class=c.class
 WHERE numGuns >= ALL (
					   SELECT classes.numGuns
					     FROM classes
						WHERE classes.displacement=c.displacement
						  AND classes.class IN (
												SELECT AllShips.class
												  FROM AllShips
											   )
					  )
					  
					  
					  
--52. Определить названия всех кораблей из таблицы Ships,
--    которые могут быть линейным японским кораблем,
--    имеющим число главных орудий не менее девяти,
--    калибр орудий менее 19 дюймов
--    и водоизмещение не более 65 тыс.тонн

SELECT name
  FROM ships
  JOIN classes
    ON classes.class = ships.class
 WHERE ( type = 'bb' OR type IS NULL )
   AND   country = 'Japan'
   AND ( numGuns >= 9 OR numGuns IS NULL )
   AND ( bore < 19 OR bore IS NULL )
   AND ( displacement <= 65000 or displacement IS NULL )
   
   
   
--53. Определите среднее число орудий для классов линейных кораблей.
--    Получить результат с точностью до 2-х десятичных знаков.

SELECT CAST(AVG(numGuns*1.0) AS NUMERIC(6,2))
  FROM classes
 WHERE type = 'bb'
 
 
 
--54. С точностью до 2-х десятичных знаков определите среднее
--    число орудий всех линейных кораблей
--    (учесть корабли из таблицы Outcomes).

WITH AllShips AS (
	SELECT class,
		   name as ship
	  FROM ships
	
	 UNION
	
	SELECT CASE
			 WHEN class IS NULL
			 THEN ship
			 ELSE class
		   END,
		   ship
	  FROM outcomes
      LEFT JOIN ships
	    ON ships.name = outcomes.ship
)

SELECT CAST(AVG(numGuns*1.0) AS NUMERIC(6,2))
  FROM AllShips
  JOIN classes
    ON classes.class = AllShips.class
 WHERE type = 'bb'
 
 
 
--55. Для каждого класса определите год, когда был спущен на воду
--    первый корабль этого класса. Если год спуска на воду головного
--    корабля неизвестен, определите минимальный год спуска
--    на воду кораблей этого класса. Вывести: класс, год. 

SELECT classes.class,
	   MIN(launched)
  FROM classes
  FULL JOIN ships
    ON ships.class = classes.class
 GROUP BY classes.class



--56. Для каждого класса определите число кораблей этого класса,
--    потопленных в сражениях.
--    Вывести: класс и число потопленных кораблей.

SELECT class,
       SUM(
	       CASE
		     WHEN result='sunk'
			 THEN 1
			 ELSE 0
		   END) AS count_sunks
  FROM (
		SELECT classes.class,
			   name
		  FROM classes
		  LEFT JOIN ships
			ON classes.class=ships.class
			
		 UNION
 
		SELECT class,
		  ship FROM classes
		  JOIN outcomes
			ON class=ship
        ) AS AllS
		
  LEFT JOIN outcomes
    ON AllS.name=outcomes.ship
 GROUP BY class
 
 

--57. Для классов, имеющих потери в виде потопленных кораблей
--    и не менее 3 кораблей в базе данных,
--    вывести имя класса и число потопленных кораблей.

SELECT class,
	   SUM(
	       CASE
		     WHEN result = 'sunk'
			 THEN 1
			 ELSE 0
		   END) as count_sunks
  FROM (
		SELECT classes.class,
		       name
		  FROM classes
	      LEFT JOIN ships
	        ON ships.class = classes.class
			
		 UNION
		 
		SELECT class,
		       ship
		  FROM classes
		  JOIN outcomes
		    ON ship = class
		) AS AllS
  LEFT JOIN outcomes
    ON AllS.name = outcomes.ship
 GROUP BY class
HAVING SUM(
		   CASE
		     WHEN result = 'sunk'
			 THEN 1
			 ELSE 0
			 END
		  ) > 0
   AND (SELECT COUNT(ship.name)
		  FROM (
				SELECT ships.name, ships.class FROM ships
            
				UNION
			
				SELECT o.ship,
				       o.ship
				  FROM outcomes o
			   ) AS ship
         WHERE ship.class = Alls.class
	     GROUP BY ship.class
       )>=3



--58. Для каждого типа продукции и каждого производителя
--    из таблицы Product c точностью до двух десятичных знаков
--    найти процентное отношение числа моделей данного типа данного
--    производителя к общему числу моделей этого производителя.
--    Вывод: maker, type, процентное отношение числа моделей
--    данного типа к общему числу моделей производителя

WITH aCount AS (
	SELECT maker,
	       COUNT(model) AS a_count
	  FROM product
     GROUP BY maker
), 
tCount AS (
	SELECT maker,
		   type,
		   COUNT(model) AS countOfTypes
	  FROM product
	 GROUP BY maker, type
),
alls AS (
	SELECT DISTINCT p1.maker,
					p2.type
		       FROM product AS p1
	     CROSS JOIN product AS p2
	       ORDER BY maker
),
ptca AS (
	SELECT alls.maker,
	       alls.type, 
		   CASE
			 WHEN countOfTypes IS NULL
			 THEN 0
			 ELSE countOfTypes
		   END,
		   a_count
	  FROM alls
	  LEFT JOIN tCount
	    ON tCount.type = alls.type
	   AND tCount.maker = alls.maker
	  JOIN aCount
	    ON aCount.maker = alls.maker
)

SELECT maker,
	   type,
       CAST((countOfTypes*1.0/a_count)*100 AS NUMERIC(6,2))
  FROM ptca



--59. Посчитать остаток денежных средств на каждом пункте приема
--    для базы данных с отчетностью не чаще одного раза в день.
--    Вывод: пункт, остаток.

WITH Tincome AS(
	SELECT point, 
	       SUM(
		       CASE
				 WHEN inc IS NULL
				 THEN 0
				 ELSE inc
			   END
			  ) AS income
	  FROM Income_o
     GROUP BY point
),
Toutcome AS (
SELECT point, 
	   SUM(
		   CASE
		     WHEN out IS NULL
		     THEN 0
		     ELSE out
	       END
		  ) AS outcome
  FROM Outcome_o
 GROUP BY point
)

SELECT Tincome.point,
	   CASE
		 WHEN outcome IS NULL
		 THEN income
		 ELSE income-outcome
	   END AS retain
  FROM Tincome
  FULL JOIN Toutcome
    ON Toutcome.point = Tincome.point
	
	

--60. Посчитать остаток денежных средств на начало дня 15/04/2001
--    на каждом пункте приема для базы данных с отчетностью
--    не чаще одного раза в день.
--    Вывод: пункт, остаток.
--    Замечание. Не учитывать пункты, информации о которых нет до указанной даты.

WITH Tincome AS(
	SELECT point, 
	       SUM(
		       CASE
				 WHEN inc IS NULL
				 THEN 0
				 ELSE inc
			   END
			  ) AS income
	  FROM Income_o
	 WHERE date < '2001-04-15' 
     GROUP BY point
),
Toutcome AS (
SELECT point, 
	   SUM(
		   CASE
		     WHEN out IS NULL
		     THEN 0
		     ELSE out
	       END
		  ) AS outcome
  FROM Outcome_o
 WHERE date < '2001-04-15' 
 GROUP BY point
)

SELECT Tincome.point,
	   CASE
		 WHEN outcome IS NULL
		 THEN income
		 ELSE income-outcome
	   END AS retain
  FROM Tincome
  FULL JOIN Toutcome
    ON Toutcome.point = Tincome.point