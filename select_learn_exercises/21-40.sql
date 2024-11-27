--21. Найдите максимальную цену ПК, выпускаемых каждым
--    производителем, у которого есть модели в таблице PC.
--    Вывести: maker, максимальная цена.

SELECT DISTINCT maker,
		        MAX(price)
		   FROM product
		   JOIN pc
		     ON pc.model = product.model
       GROUP BY maker
	   
	   
	   
--22. Для каждого значения скорости ПК, превышающего 600 МГц,
--    определите среднюю цену ПК с такой же скоростью.
--    Вывести: speed, средняя цена.

SELECT speed,
	   AVG(price)
  FROM pc
 WHERE speed > 600
 GROUP BY speed
 
 
 
--23. Найдите производителей, которые производили бы как ПК
--    со скоростью не менее 750 МГц, так и ПК-блокноты
--    со скоростью не менее 750 МГц.
--    Вывести: Maker 

SELECT DISTINCT maker
		   FROM product
		   JOIN pc
		     ON pc.model = product.model
          WHERE speed >= 750
		  
	  INTERSECT
	  
SELECT DISTINCT maker
           FROM product
		   JOIN laptop
		     ON laptop.model = product.model
		  WHERE speed >= 750
		  
		  
		  
--24. Перечислите номера моделей любых типов,
--    имеющих самую высокую цену по всей имеющейся
--    в базе данных продукции.

WITH AllModelPrices(model, price) AS (
	SELECT model,
		   price
	  FROM pc
	  
	  UNION
	  
	SELECT model,
		   price
	  FROM laptop
	  
	  UNION
	
	SELECT model,
		   price
	  FROM printer
)

SELECT DISTINCT model
		   FROM AllModelPrices
		  WHERE price = (
						 SELECT MAX(price)
						   FROM AllModelPrices
						)
						
						
						
--25.  Найдите производителей принтеров, которые
--	   производят ПК с наименьшим объемом RAM
--     и с самым быстрым процессором среди всех ПК,
--     имеющих наименьший объем RAM. Вывести: Maker

SELECT DISTINCT maker
	       FROM product
		  WHERE type = 'printer'

		  INTERSECT

SELECT DISTINCT maker
		   FROM product

           JOIN pc
		     ON pc.model = product.model
		  WHERE speed = (
						 SELECT MAX(speed)
						   FROM (
						         SELECT speed
								   FROM pc
								  WHERE ram = (
											   SELECT MIN(ram)
											     FROM pc
											  ) 
								) as z
			            )
			AND ram = (
					   SELECT MIN(ram)
					     FROM pc
					  )
					  
					  
					  
--26. Найдите среднюю цену ПК и ПК-блокнотов,
--    выпущенных производителем A (латинская буква).
--    Вывести: одна общая средняя цена.

WITH prices AS (
	SELECT price
	  FROM pc
	 WHERE model IN (
					 SELECT model
					   FROM product
					  WHERE maker = 'A'
					)
	 
	UNION ALL
	
	SELECT price
	  FROM laptop
	 WHERE model IN ( 
					 SELECT model
					 FROM product
					 WHERE maker = 'A'
					)
)

SELECT AVG(price)
  FROM prices
  
  
  
--27. Найдите средний размер диска ПК каждого из тех производителей,
--    которые выпускают и принтеры.
--    Вывести: maker, средний размер HD.

SELECT maker,
       AVG(hd)
  FROM product
  JOIN pc
    ON pc.model = product.model
 WHERE type = 'pc'
   AND maker IN (
				 SELECT maker
				   FROM product
				  WHERE type = 'printer'
				)
 GROUP BY maker



--28. Используя таблицу Product, определить количество
--    производителей, выпускающих по одной модели.

WITH maker_one AS (
	SELECT maker,
		   COUNT(model) AS count_models
	  FROM product
  GROUP BY maker
    HAVING COUNT(model) = 1
)

SELECT COUNT(maker)
  FROM maker_one 
  
  
  
--29. В предположении, что приход и расход денег на каждом
--    пункте приема фиксируется не чаще одного раза в день
--    [т.е. первичный ключ (пункт, дата)], написать запрос
--    с выходными данными (пункт, дата, приход, расход).
--    Использовать таблицы Income_o и Outcome_o.

SELECT Income_o.point,
	   Income_o.date,
	   inc,
	   out
  FROM Income_o
  LEFT JOIN Outcome_o
    ON Outcome_o.point = Income_o.point
   AND Outcome_o.date = Income_o.date

UNION

SELECT Outcome_o.point,
	   Outcome_o.date,
	   inc,
	   out
  FROM Outcome_o
  LEFT JOIN Income_o
    ON Outcome_o.point = Income_o.point
   AND Outcome_o.date = Income_o.date
   
   
   
--30. В предположении, что приход и расход денег на каждом
--    пункте приема фиксируется произвольное число раз
--    (первичным ключом в таблицах является столбец code),
--    требуется получить таблицу, в которой каждому пункту
--    за каждую дату выполнения операций будет соответствовать одна строка.
--    Вывод: point, date, суммарный расход пункта за день (out),
--    суммарный приход пункта за день (inc).
--    Отсутствующие значения считать неопределенными (NULL).

WITH un_inc_out AS (
	SELECT point,
		   date,
		   SUM(out) AS outcome,
		   NULL AS income
	  FROM outcome
  GROUP BY point,
		   date
		   
	 UNION
	 
	SELECT point,
		   date,
		   NULL AS outcome,
		   SUM(inc) AS income
	  FROM income
  GROUP BY point,
		   date
)

SELECT point,
	   date,
	   SUM(outcome),
	   SUM(income)
  FROM un_inc_out
 GROUP BY point,
		  date  



--31. Для классов кораблей, калибр орудий которых
--    не менее 16 дюймов, укажите класс и страну.

SELECT class,
	   country
  FROM classes
 WHERE bore >= 16
 
 

--32. Одной из характеристик корабля является половина
--    куба калибра его главных орудий (mw).
--    С точностью до 2 десятичных знаков определите
--    среднее значение mw для кораблей каждой страны,
--    у которой есть корабли в базе данных.

WITH classesAndNames AS (
	SELECT class,
		   name
	  FROM ships
	  
	  UNION

	SELECT classes.class,
		   ship as name
      FROM outcomes
	  JOIN classes
	    ON classes.class = outcomes.ship
),
countryAndClasses AS (
	SELECT classes.country,
	       classesAndNames.class,
		   classes.bore
	  FROM classes
      JOIN classesAndNames
	    ON classesAndNames.class = classes.class
)

SELECT country,
	   CAST(AVG(POWER(bore, 3)/2) AS NUMERIC(6, 2))
  FROM countryAndClasses
 GROUP BY country
 
 
 
--33. Укажите корабли, потопленные в сражениях
--    в Северной Атлантике (North Atlantic).
--    Вывод: ship.

SELECT ship
  FROM outcomes

 WHERE battle = 'North Atlantic'
   AND result = 'sunk'
   
   
   
--34. По Вашингтонскому международному договору от начала 1922 г.
--    запрещалось строить линейные корабли водоизмещением
--    более 35 тыс.тонн. Укажите корабли, нарушившие этот
--    договор (учитывать только корабли c известным годом спуска на воду).
--    Вывести названия кораблей.

SELECT name
  FROM ships,
       classes AS cl
 WHERE ships.class = cl.class
   AND launched > 1921
   AND launched IS NOT NULL
   AND displacement > 35000
   AND type = 'bb'
   
   
   
--35. В таблице Product найти модели, которые состоят
--    только из цифр или только из латинских букв (A-Z, без учета регистра).
--    Вывод: номер модели, тип модели.

SELECT model,
	   type
  FROM product
 WHERE model NOT LIKE '%[^0-9]%'
    OR model NOT LIKE '%[^a-z]%'
	
	
	
--36. Перечислите названия головных кораблей,
--    имеющихся в базе данных (учесть корабли в Outcomes).

SELECT name
  FROM ships
 WHERE name = class

 UNION

SELECT ship
  FROM outcomes,
	   classes
 WHERE ship = class
 
 
 
--37. Найдите классы, в которые входит только один корабль
--    из базы данных (учесть также корабли в Outcomes).

WITH classesAndShips AS (
	SELECT class,
	       name
	  FROM ships
	  
	  UNION
	  
	SELECT class,
		   ship 
	  FROM outcomes,
	       classes
     WHERE class = ship
)

SELECT class
  FROM classesAndShips
 GROUP BY class
HAVING COUNT(name) = 1



--38. Найдите страны, имевшие когда-либо классы обычных боевых
--    кораблей ('bb') и имевшие когда-либо классы крейсеров ('bc').

SELECT country
  FROM classes
 WHERE type = 'bb'

INTERSECT

SELECT country
  FROM classes
 WHERE type = 'bc'



--39. Найдите корабли, `сохранившиеся для будущих сражений`;
--    т.е. выведенные из строя в одной битве (damaged),
--    они участвовали в другой, произошедшей позже.

WITH shipsAndBattles AS (
	SELECT ship,
		   battle,
		   date,
		   result
	  FROM outcomes,
	       battles
	 WHERE battle = name
)

SELECT DISTINCT ship
	       FROM shipsAndBattles AS sab1
	      WHERE sab1.result = 'damaged'
		    AND EXISTS (
						SELECT ship
						  FROM shipsAndBattles AS sab2
						 WHERE sab2.ship = sab1.ship
						   AND sab2.date > sab1.date
						)
						
						
						
--40. Найти производителей, которые выпускают более одной модели,
--    при этом все выпускаемые производителем модели
--    являются продуктами одного типа.
--    Вывести: maker, type

WITH a AS (        --производитель | тип | количество моделей
	SELECT maker,
		    type,
			COUNT(model) as countOfModel
	   FROM product
   GROUP BY maker,
		    type
), 
     b AS (        --производители с 1 типом продукта
	SELECT maker
	  FROM a
  GROUP BY maker
    HAVING COUNT(type) = 1
)

SELECT DISTINCT b.maker,
			    type
		   FROM b
		   JOIN product
		     ON product.maker = b.maker
	   GROUP BY b.maker,
				type
		 HAVING COUNT(model) > 1