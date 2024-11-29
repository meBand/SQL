--1. Добавить в таблицу PC следующую модель:
--   code: 20
--	 model: 2111
--   speed: 950
--   ram: 512
--   hd: 60
--   cd: 52x
--   price: 1100

INSERT INTO PC
     VALUES (20, 2111, 950, 512, 60, '52x', 1100)
	 
	 
	 
--2. Добавить в таблицу Product следующие продукты производителя Z:
--   принтер модели 4003,
--   ПК модели 4001
--   и блокнот модели 4002

INSERT INTO product
	 VALUES ('Z', 4003, 'Printer'),
		    ('Z', 4001, 'PC'),
			('Z', 4002, 'Laptop')
			
			
			
--3. Добавить в таблицу PC модель 4444 с кодом 22,
--   имеющую скорость процессора 1200 и цену 1350.
--   Отсутствующие характеристики должны быть
--   восполнены значениями по умолчанию,
--   принятыми для соответствующих столбцов.

INSERT INTO pc (code, model, speed, price)
     VALUES (22, 4444, 1200, 1350)
	 
	 
	 
--4. Для каждой группы блокнотов с одинаковым номером модели
--   добавить запись в таблицу PC со следующими характеристиками:
--   код: минимальный код блокнота в группе +20;
--   модель: номер модели блокнота +1000;
--   скорость: максимальная скорость блокнота в группе;
--   ram: максимальный объем ram блокнота в группе *2;
--   hd: максимальный объем hd блокнота в группе *2;
--   cd: значение по умолчанию;
--   цена: максимальная цена блокнота в группе, уменьшенная в 1,5 раза.
--   Замечание. Считать номер модели числом.

INSERT INTO pc (code, model, speed, ram, hd, price)
     SELECT MIN(code)+20,
			model+1000,
			MAX(speed),
			MAX(ram)*2,
			MAX(hd)*2,
			MAX(price)/1.5
	   FROM laptop
      GROUP BY model



--5. Удалить из таблицы PC компьютеры, имеющие
--   минимальный объем диска или памяти.

DELETE FROM pc
      WHERE hd  = (SELECT MIN(hd) FROM pc)
	     OR ram = (SELECT MIN(ram) FROM pc)
		 
		 
		 
--6. Удалить все блокноты, выпускаемые производителями,
--   которые не выпускают принтеры.

DELETE FROM laptop
       FROM laptop
	   JOIN product
	     ON product.model = laptop.model
      WHERE maker NOT IN (
	                      SELECT maker
						    FROM product
						   WHERE type = 'Printer'
						 )
						 
						 
						 
--7. Производство принтеров производитель A
--   передал производителю Z.
--   Выполнить соответствующее изменение.		

UPDATE product
   SET maker = 'Z'
 WHERE maker = 'A'
   AND type = 'Printer' 
   


--8. Удалите из таблицы Ships все корабли,
--   потопленные в сражениях.

DELETE ships
 WHERE name IN(
			   SELECT DISTINCT ship
			              FROM outcomes
						 WHERE result = 'sunk'
			  )



--9. Измените данные в таблице Classes так,
--   чтобы калибры орудий измерялись в
--   сантиметрах (1 дюйм=2,5см), а водоизмещение
--   в метрических тоннах (1 метрическая тонна = 1,1 тонны).
--   Водоизмещение вычислить с точностью до целых.

UPDATE classes
   SET bore = bore*2.5,
       displacement = ROUND(displacement/1.1, 0)



--10. Добавить в таблицу PC те модели ПК из Product,
--    которые отсутствуют в таблице PC.
--    При этом модели должны иметь следующие характеристики:
--    1. Код равен номеру модели плюс максимальный код, который был до вставки.
--    2. Скорость, объем памяти и диска, а также скорость CD должны иметь максимальные
--       характеристики среди всех имеющихся в таблице PC.
--    3. Цена должна быть средней среди всех ПК, имевшихся в таблице PC до вставки.

INSERT INTO pc (code, model, speed, ram, hd, cd, price)
     SELECT model + (SELECT MAX(code)
					   FROM pc
					),
					
            model,
			
			(SELECT MAX(speed)
			   FROM pc),
			   
            (SELECT MAX(ram)
		       FROM pc),
			   
			(SELECT MAX(hd)
			   FROM pc),
			
			--Откидываем 'x' -> каст в int -> вычисляем max -> каст в varchar -> добавляем 'x' 
			CAST((SELECT MAX(CAST(SUBSTRING(cd,1,LEN(cd) - 1) AS int))
			        FROM PC) AS VARCHAR) + 'x' AS cd,
					
			(SELECT AVG(price) FROM pc)
       FROM product
	  WHERE type = 'pc'
	    AND model NOT IN(SELECT model
		                   FROM pc)
						   
						   
						   
--11. Для каждой группы блокнотов с одинаковым номером модели
--    добавить запись в таблицу PC со следующими характеристиками:
--    код: минимальный код блокнота в группе +20;
--    модель: номер модели блокнота +1000;
--    скорость: максимальная скорость блокнота в группе;
--    ram: максимальный объем ram блокнота в группе *2;
--    hd: максимальный объем hd блокнота в группе *2;
--    cd: cd c максимальной скоростью среди всех ПК;
--    цена: максимальная цена блокнота в группе, уменьшенная в 1,5 раза

INSERT INTO pc (code, model, speed, ram, hd, cd, price)
	 SELECT MIN(code)+20,
			model+1000, 
		    MAX(speed),
		    MAX(ram)*2,
		    MAX(hd)*2,
			--Откидываем 'x' -> каст в int -> вычисляем max -> каст в varchar -> добавляем 'x'
		    CAST((SELECT MAX(CAST (SUBSTRING(cd,1,LEN(cd) - 1) AS int)) FROM PC) AS VARCHAR) + 'x' AS cd,
		    MAX(price)/1.5
       FROM laptop
      GROUP BY model



--12. Добавить отсутствующие в таблице Ships головные корабли
--    из Outcomes. Годом спуска на воду считать средний
--    округленный до целого числа год по кораблям страны
--    добавляемого корабля.
--    Если средний год неизвестен, запись не вносить.

INSERT INTO Ships (name, class, launched)
SELECT DISTINCT class,
				ship,
				year
		   FROM (SELECT C.class, 
						ROUND(AVG(launched*1.0)
						OVER(PARTITION BY country),0) AS year 
				   FROM Classes C 
      LEFT JOIN ships S
	         ON c.class=S.class
                ) AS d
		   JOIN Outcomes
		     ON class=ship
          WHERE ship NOT IN (SELECT name
						       FROM ships)
	        AND year IS NOT NULL
			
			

--13. Ввести в базу данных информацию о том, что корабль Rodney
--    был потоплен в битве, произошедшей 25/10/1944,
--    а корабль Nelson поврежден - 28/01/1945.
--    Замечание: считать, что дата битвы уникальна в таблице Battles.

INSERT INTO outcomes
     VALUES ('Rodney',
	        (SELECT name
			   FROM battles
			  WHERE date = '1944-10-25'),
			 'sunk'),
			
			('Nelson',
			(SELECT name
			   FROM battles
			  WHERE date = '1945-01-28'),
			 'damaged')
			 
			 
			 
--14. Удалите классы, имеющие в базе данных
--    менее трех кораблей (учесть корабли из Outcomes).

WITH allShips AS(              -- Более лаконичное объединение ships и outcomes
SELECT DISTINCT ship as name,
				ship as class 
		   FROM outcomes
  
          UNION
		  
		  SELECT name,
		         class
		    FROM ships
				)
DELETE FROM classes
      WHERE class IN(SELECT class
				       FROM allShips
                      GROUP BY class
                     HAVING COUNT(name) < 3)
					     OR class NOT IN (SELECT class
											FROM allShips)

--15. Для каждого пассажира удалить из таблицы
--    pass_in_trip все записи о его полетах, кроме первого и последнего.
--    P.S. скорее всего есть более красивое решение, но придумал как придумал :)

WITH all_num_first AS (
					   SELECT ROW_NUMBER()
					          OVER(
							  PARTITION BY id_psg
								  --В партиции нумеруем по возрастанию даты (#1 первый полет)
							      ORDER BY date,
										   -- ВАЖНО учесть время вылета, иначе могут быть дубли
										   -- и неверный результат
										   trip.time_out) AS num,
							  pass_in_trip.trip_no,
							  date,
							  id_psg,
							  place
					     FROM pass_in_trip
                         JOIN trip
						   ON trip.trip_no = pass_in_trip.trip_no
					  ),
all_num_last AS (
				 SELECT ROW_NUMBER()
						OVER(
						PARTITION BY id_psg
							--В партиции нумеруем по убыванию даты (#1 последний полет)
						    ORDER BY date DESC,
									 -- ВАЖНО учесть время вылета, иначе могут быть дубли
									 -- и неверный результат
							         trip.time_out DESC) AS num,
						pass_in_trip.trip_no,
						date,
						id_psg, 
						place
			       FROM pass_in_trip
				   JOIN trip
				     ON trip.trip_no = pass_in_trip.trip_no
				),
--Объединим только первые номера из двух CTE для читабельности
firstAndLast AS (
				 SELECT trip_no,
				        date, 
						id_psg,
						place
				   FROM all_num_first
				  WHERE num = 1

				  UNION ALL
				  
				 SELECT trip_no,
				        date,
						id_psg,
						place
				   FROM all_num_last
				  WHERE num = 1
				)

DELETE FROM pass_in_trip
  WHERE NOT EXISTS(
				   SELECT 1
				     FROM firstAndLast as fal
                    WHERE fal.trip_no = pass_in_trip.trip_no
                      AND fal.date = pass_in_trip.date
                      AND fal.id_psg = pass_in_trip.id_psg
                      AND fal.place = pass_in_trip.place)
					  
					  
					  
--16. Отчислить из команды игроков, ни разу не попадавших
--    в заявку на матч в текущем сезоне.

DELETE FROM players
      WHERE player_id NOT IN(SELECT player_id
	                           FROM lineups)



--17. Удалить из таблицы PC компьютеры, у которых
--    величина hd попадает в тройку наименьших значений.

WITH sortByHd AS (
	SELECT ROW_NUMBER()
		   OVER(ORDER BY hd) AS num,
		   hd
	  FROM pc
	 GROUP BY hd
)

DELETE FROM pc
      WHERE hd IN(SELECT hd
					FROM sortByHd
				   WHERE num <= 3
				 )
				 
				 
				 
--18. Перенести все концевые пробелы, имеющиеся
--    в названии каждого сражения в таблице Battles,
--    в начало названия.

UPDATE battles
   SET name = CONCAT(
				--Взять символы справа в количестве разности между
				--длиной строки и длиной строки с убранными пробелами справа.
				--Добавить к ним строку с убранными пробелами справа
				--P.S. DATALENGTH используется т.к.
				--     в отличие от LEN учитывает начальные и конечные пробелы
				RIGHT(name, DATALENGTH(name)-DATALENGTH(RTRIM(name))), RTRIM(name))
				
				
				
--19. Потопить в следующем сражении суда, которые в первой своей битве
--    были повреждены и больше не участвовали ни в каких сражениях.
--    Если следующего сражения для такого судна не существует
--    в базе данных, не вносить его в таблицу Outcomes.
--    Замечание: в базе данных нет двух сражений, которые состоялись

WITH numBattle AS (
	SELECT ROW_NUMBER() OVER(
     ORDER BY date) AS bN,
		   *
      FROM battles
),
numBattleAndOutcomes AS (
	SELECT *
	  FROM numBattle AS nB
      JOIN outcomes o
	    ON o.battle = nB.name
)
INSERT INTO outcomes (ship, battle, result)
SELECT ship,
       name,
       'sunk'
  --Из следующей строки CTE numBattleAndOutcomes
  --при условии что корабль один в списке(1 битва)
  --и результат 'damaged'
  --MIN используется для сравнения значения в HAVING
  FROM (SELECT ship,
               MIN(bN)+1 AS bN
          FROM numBattleAndOutcomes
         GROUP BY ship
        HAVING COUNT(*)=1
           AND MIN(result)='damaged'
	   ) AS nextR
  JOIN numBattle ON numBattle.bN = nextR.bN
  
  
  
--20. Для кораблей, которые принимали участие всего в двух
--    сражениях, поменять результаты (result) этих сражений.
--    Например, если в битве 1 результат был "ok",
--    а в битве 2 - "sunk", то должно стать "ok" для битвы 2
--    и "sunk" - для битвы 1.
--    p.s. перемудрил чутка, но работает
WITH numBattleAndOutcomes AS (
	SELECT ROW_NUMBER()
	       OVER(
	            PARTITION BY ship
                ORDER BY ship) AS sN,
		   *
      FROM outcomes
),
toUpdt AS (
	SELECT sN,
		   ship,
		   battle,
		   CASE
			 WHEN sN = 1
			 THEN LEAD(result) OVER(ORDER BY ship, sN)
			 WHEN sN = 2
			 THEN LAG(result) OVER(ORDER BY ship, sN) 
		   END AS result
	  FROM numBattleAndOutcomes
	  WHERE ship IN(SELECT ship
	                  FROM outcomes
					 GROUP BY ship
					HAVING count(ship) = 2)
)
UPDATE Outcomes
   set result = toUpdt.result
  FROM Outcomes o
  JOIN toUpdt
    ON o.ship = toUpdt.ship
   AND o.battle = toUpdt.battle
   AND o.result <> toUpdt.result