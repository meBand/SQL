--61. Посчитать остаток денежных средств на всех пунктах
--    приема для базы данных с отчетностью не чаще одного раза в день. 

SELECT DISTINCT SUM(coalesce(inc,0))-SUM(coalesce(out,0)) AS remain
		   FROM Income_o AS income
      FULL JOIN Outcome_o AS outcome
	         ON outcome.point=income.point
			AND outcome.date=income.date
			
			
			
--62. Посчитать остаток денежных средств на всех пунктах
--    приема на начало дня 15/04/2001 для базы данных
--    с отчетностью не чаще одного раза в день.

SELECT DISTINCT SUM(coalesce(inc,0))
				-
				SUM(coalesce(out,0)) AS remain
           FROM Income_o AS income
	  FULL JOIN Outcome_o AS outcome
	         ON outcome.point=income.point
			AND outcome.date=income.date
          WHERE coalesce(income.date, outcome.date) < '2001-04-15'



--63. Определить имена разных пассажиров,
--    когда-либо летевших на одном и том же месте
--    более одного раза.

SELECT name
  FROM Passenger
 WHERE ID_psg IN (
				  SELECT ID_psg
				    FROM Pass_in_trip AS pit
				   GROUP BY id_psg, place
				  HAVING COUNT(*)>1
				 )
				 
				 
				 
--64. Используя таблицы Income и Outcome, для каждого пункта приема
--    определить дни, когда был приход, но не было расхода и наоборот.
--    Вывод: пункт, дата, тип операции (inc/out), денежная сумма за день.

SELECT COALESCE(income.point, outcome.point) AS point,
	   COALESCE(income.date, outcome.date) AS date, 
	   CASE
	     WHEN SUM(inc) IS NULL AND SUM(out) IS NOT NULL
	     THEN 'out'
	     WHEN SUM(out) IS NULL AND SUM(inc) IS NOT NULL
	     THEN 'inc'
	   END AS inc_out,
	   CASE
		 WHEN SUM(inc) IS NULL AND SUM(out) IS NOT NULL
		 THEN SUM(out)
		 WHEN SUM(out) IS NULL AND SUM(inc) IS NOT NULL
		 THEN SUM(inc)
	   END AS money_day
  FROM income
  FULL JOIN outcome
    ON outcome.point = income.point
   AND income.date = outcome.date
 GROUP BY COALESCE(income.point, outcome.point),
          COALESCE(income.date, outcome.date)
HAVING SUM(inc) IS NULL
    OR SUM(out) IS NULL
 ORDER BY point



--65. Пронумеровать уникальные пары {maker, type} из Product,
--    упорядочив их следующим образом:
--    - имя производителя (maker) по возрастанию;
--    - тип продукта (type) в порядке PC, Laptop, Printer.
--    Если некий производитель выпускает несколько типов продукции,
--    то выводить его имя только в первой строке;
--    остальные строки для ЭТОГО производителя должны содержать пустую строку символов ('').

SELECT row_number() over(ORDER BY maker) AS num,
	   CASE
	     WHEN number = 1
	     THEN maker
	     ELSE ''
	   END AS maker,
	   type
  FROM (
        SELECT row_number()
			   over(
					PARTITION BY maker ORDER BY maker,
												type_sort
				   ) AS number,
						maker,
						type
		  FROM (SELECT DISTINCT maker,
								type, 
							    CASE
								  WHEN UPPER(type) = 'PC'
							      THEN 1
							      WHEN UPPER(type) = 'LAPTOP'
							      THEN 2
							      ELSE 3
							    END AS type_sort
						   FROM product
			   ) AS z  											-- Если не сделать alias -> error
) AS x



--66. Для всех дней в интервале с 01/04/2003 по 07/04/2003
--    определить число рейсов из Rostov с пассажирами на борту.
--    Вывод: дата, количество рейсов.

WITH rostov AS (
	SELECT DISTINCT trip.trip_no,
					time_out,
					town_from,
					date
			   FROM trip
			   JOIN pass_in_trip AS pit
			     ON pit.trip_no = trip.trip_no
		      WHERE LOWER(town_from) = 'rostov'
			    AND trip.trip_no IN (
									 SELECT trip_no
									   FROM pass_in_trip
									)
				AND (DATE(date) between '2003-04-01' AND '2003-04-07')
		   ORDER BY date
),
date AS (                            -- Генерация последовательности (работает на postgresql)
	SELECT generate_series(
						   '01/04/2003'::timestamp,
						   '07/04/2003'::timestamp,
						   '1 day'
						  ) AS date
)

SELECT date.date,
	   COUNT(DISTINCT time_out)
  FROM date
  LEFT JOIN rostov
    ON rostov.date = date.date
 GROUP BY date.date
 
 
 
--67. Найти количество маршрутов, которые обслуживаются наибольшим числом рейсов.
--    Замечания.
--    1) A - B и B - A считать РАЗНЫМИ маршрутами.
--    2) Использовать только таблицу Trip

WITH max_trip AS (
	SELECT COUNT(trip_no),
		   town_from,
		   town_to
	  FROM trip
	 GROUP BY town_from,
			  town_to
	HAVING COUNT(trip_no) >= ALL (
								  SELECT COUNT(trip_no)
									FROM trip
								   GROUP BY town_from,
									        town_to
								 ) 
)

SELECT COUNT(*) AS qty
  FROM max_trip



--68. Найти количество маршрутов, которые обслуживаются наибольшим числом рейсов.
--	  Замечания.
--    1) A - B и B - A считать ОДНИМ И ТЕМ ЖЕ маршрутом.
--    2) Использовать только таблицу Trip

WITH max_trip AS (
	SELECT COUNT(*)
	  FROM trip
     GROUP BY CASE
				WHEN town_from > town_to
				THEN town_from
				ELSE town_to
			  END,
		      CASE
				WHEN town_from < town_to
				THEN town_from
				ELSE town_to
			  END
	HAVING COUNT(trip_no) >= ALL (
								  SELECT COUNT(trip_no)
									FROM trip
								   GROUP BY CASE
											  WHEN town_from > town_to
											  THEN town_from
											  ELSE town_to
											END,
										    CASE
											  WHEN town_from < town_to
											  THEN town_from
											  ELSE town_to
											END) 
								 )
								 
SELECT COUNT(*) AS qty
  FROM max_trip
  
  
  
--69. По таблицам Income и Outcome для каждого пункта приема
--    найти остатки денежных средств на конец каждого дня,
--    в который выполнялись операции по приходу и/или расходу на данном пункте.
--    Учесть при этом, что деньги не изымаются, а остатки/задолженность переходят на следующий день.
--    Вывод: пункт приема, день в формате "dd/mm/yyyy", остатки/задолженность на конец этого дня.

SELECT DISTINCT point,
				CONVERT(varchar, date, 103) AS day,
				SUM(inc) OVER(
							  PARTITION BY point
							      ORDER BY date
								     RANGE UNBOUNDED PRECEDING
						     ) AS remote
		   FROM (
			     SELECT point,
					    date,
						inc
				   FROM income
    
				  UNION ALL
				  
				 SELECT point,
					    date,
						-out
				   FROM outcome
			    ) AS z
	   ORDER BY point,
				day



--70. Укажите сражения, в которых участвовало
--    по меньшей мере три корабля одной и той же страны.

SELECT DISTINCT battle
		   FROM (
			     SELECT class,
				        name
				   FROM ships
				  
				  UNION
				  
				 SELECT ship,
					    ship
				   FROM outcomes
				) AS aShips
		   JOIN classes
		     ON classes.class = aShips.class
		   JOIN outcomes
		     ON outcomes.ship = aShips.name
	   GROUP BY battle,country
         HAVING COUNT(name) > 2



--71. Найти тех производителей ПК,
--    все модели ПК которых имеются в таблице PC.

SELECT DISTINCT maker
		   FROM product p1
	      WHERE type = 'PC'
		    AND NOT EXISTS(
						   SELECT model
						     FROM product p2
							WHERE p1.maker=p2.maker
							  AND p2.type='PC'
							  AND NOT EXISTS(
											 SELECT model
											   FROM pc
											  WHERE p2.model=pc.model
											)
						  )
						  
						  
						
--72. Среди тех, кто пользуется услугами
--    только какой-нибудь одной компании,
--    определить имена разных пассажиров,
--    летавших чаще других.
--    Вывести: имя пассажира и число полетов.

WITH allp AS (
	SELECT DISTINCT ID_psg,
				    ID_comp
			   FROM pass_in_trip as pit
	           JOIN trip
			     ON trip.trip_no = pit.trip_no
),
ids AS (
	SELECT DISTINCT id_psg
			   FROM allp
		   GROUP BY id_psg
		     HAVING COUNT(id_comp) = 1
),
final AS (
	SELECT name,
	       COUNT(date) AS flight
	  FROM pass_in_trip as pit
	  JOIN passenger
		ON passenger.id_psg = pit.id_psg
	 WHERE pit.id_psg IN(SELECT id_psg
						   FROM ids)
  -- Группировка по id необходима
  -- для исключения "одноименных однофамильцев"
  GROUP BY name, pit.id_psg
)

SELECT DISTINCT name,
		        flight
		   FROM final
          WHERE flight = (SELECT MAX(flight)
	                        FROM final)
							
							
							
--73. Для каждой страны определить сражения,
--    в которых не участвовали корабли данной страны.
--    Вывод: страна, сражение

WITH allShips AS (
	SELECT class,
		   name
	  FROM ships AS s
	  
	 UNION
	  
	SELECT ship,
		   ship
	  FROM outcomes AS o
)

SELECT country,
	   name
  FROM classes
 CROSS JOIN battles
	 
EXCEPT
	
SELECT DISTINCT country,
				battle
		   FROM allShips AS a
		   JOIN classes AS c
			 ON c.class = a.class
		   JOIN outcomes AS o
			 ON o.ship = a.name



--74. Вывести все классы кораблей России (Russia).
--    Если в базе данных нет классов кораблей России,
--    вывести классы для всех имеющихся в БД стран.
--    Вывод: страна, класс

SELECT country,
       class
  FROM classes c
 WHERE country =
          CASE 
		    WHEN EXISTS (
				 SELECT class
				   FROM classes
				  WHERE country = 'Russia'
				 )
		    THEN 'Russia'
			ELSE country
		  END
		  
		  
		  
--75. Для тех производителей, у которых есть продукты с
--    известной ценой хотя бы в одной из таблиц Laptop, PC, Printer
--    найти максимальные цены на каждый из типов продукции.
--    Вывод: maker, максимальная цена на ноутбуки, максимальная цена на ПК,
--    максимальная цена на принтеры.
--    Для отсутствующих продуктов/цен использовать NULL. 

SELECT maker,
	   MAX(laptop.price) laptop,
       MAX(pc.price) pc,
       MAX(printer.price) printer
  FROM product
  LEFT JOIN pc ON pc.model = product.model
  LEFT JOIN laptop ON laptop.model = product.model
  LEFT JOIN printer ON printer.model = product.model
 WHERE maker IN(SELECT maker
				  FROM product
				  LEFT JOIN laptop ON laptop.model = product.model
				  LEFT JOIN pc ON pc.model = product.model
				  LEFT JOIN printer ON printer.model = product.model
				 GROUP BY maker
				HAVING MAX(pc.price) IS NOT NULL
				    OR MAX(laptop.price) IS NOT NULL
					OR MAX(printer.price) IS NOT NULL)
GROUP BY maker



--76. Определить время, проведенное в полетах, для пассажиров,
--    летавших всегда на разных местах.
--    Вывод: имя пассажира, время в минутах.

WITH pp AS (
	SELECT DISTINCT pit.id_psg,
	       place
	  FROM pass_in_trip pit
	  JOIN passenger pass
		ON pass.id_psg = pit.id_psg
),
rp AS (
	SELECT id_psg
	  FROM pp
	 GROUP BY id_psg
	HAVING COUNT(id_psg) = (SELECT COUNT(id_psg)
	                          FROM pass_in_trip AS pit2
						     WHERE pp.id_psg = pit2.id_psg)
),
fs AS (
	SELECT pass.id_psg,
		   name,
		   CASE
			 WHEN time_in >= time_out
			 THEN DATEDIFF(minute, time_out, time_in)
			 -- В случае отрицательного времени
			 -- добавляем сутки в минутах
			 ELSE DATEDIFF(minute, time_out, time_in)+1440
		   END minutes
	  FROM passenger pass
	  JOIN pass_in_trip pit
		ON pit.id_psg = pass.id_psg
	  JOIN trip
		ON trip.trip_no = pit.trip_no
      JOIN rp
		ON rp.id_psg = pass.id_psg
)

SELECT name, 
	   SUM(minutes)
  FROM fs
 GROUP BY name, id_psg
 
 

--77. Определить дни, когда было выполнено
--    максимальное число рейсов из Ростова ('Rostov').
--    Вывод: число рейсов, дата.

WITH allDate AS (
	SELECT DISTINCT date, time_out, town_from
		   FROM pass_in_trip AS pit
		   JOIN trip
			 ON trip.trip_no = pit.trip_no
		  WHERE town_from = 'rostov'
		  GROUP BY date, time_out, town_from
),
cd AS (
	SELECT COUNT(date) AS ct,
		   date
	  FROM allDate
	 GROUP BY date
)

SELECT ct,
       date
  FROM cd
 WHERE ct = (SELECT MAX(ct) FROM cd)



--78. Для каждого сражения определить первый и последний день
--    месяца, в котором оно состоялось.
--    Вывод: сражение, первый день месяца, последний день месяца.
--    Замечание: даты представить без времени в формате "yyyy-mm-dd".

SELECT name,
	   DATEFROMPARTS(YEAR(date), MONTH(date), 1)
	   EOMONTH(date),
  FROM battles
  


--79. Определить пассажиров, которые больше других времени провели в полетах.
--    Вывод: имя пассажира, общее время в минутах, проведенное в полетах  

WITH pp AS (
	SELECT pass.id_psg,
		   name,
		   CASE
			 WHEN time_in >= time_out
			 THEN DATEDIFF(minute, time_out, time_in)
			 -- В случае отрицательного времени
			 -- добавляем сутки в минутах
			 ELSE DATEDIFF(minute, time_out, time_in)+1440
		   END minutes
	  FROM passenger AS pass
	  JOIN pass_in_trip AS pit
		ON pass.id_psg = pit.id_psg
	  JOIN trip ON trip.trip_no = pit.trip_no
),
pt AS (
	SELECT name,
		   SUM(minutes) AS minutes
	  FROM pp
     GROUP BY name, id_psg 
)

SELECT name,
	   minutes
  FROM pt
 WHERE minutes = (SELECT MAX(minutes) FROM pt)



--80. Найти производителей любой компьютерной техники,
--    у которых нет моделей ПК, не представленных в таблице PC.

SELECT DISTINCT maker FROM product

EXCEPT

SELECT DISTINCT maker
  FROM product
 WHERE type = 'PC'
   AND model NOT IN(SELECT model
                      FROM pc)