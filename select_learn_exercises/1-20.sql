--1. Найдите номер модели, скорость и размер жесткого диска
--   для всех ПК стоимостью менее 500 дол.
--   Вывести: model, speed и hd

SELECT model,
       speed,
	   hd
  FROM pc
 WHERE price < 500


 
--2. Найдите производителей принтеров.
--    Вывести: maker

SELECT DISTINCT maker
  FROM Product
 WHERE type = 'Printer'


 
--3. Найдите номер модели, объем памяти
--   и размеры экранов ПК-блокнотов, цена которых превышает 1000 дол.

SELECT DISTINCT maker
  FROM Product
 WHERE type = 'Printer'


 
--4. Найдите все записи таблицы Printer
--   для цветных принтеров.

SELECT *
  FROM printer
 WHERE color = 'y'
 
 
 
--5. Найдите номер модели, скорость и размер жесткого диска ПК,
--   имеющих 12x или 24x CD и цену менее 600 дол.

SELECT model,
       speed,
	   hd
  FROM pc
 WHERE (
       cd = '12x'
    OR cd = '24x'
	   )
   AND price < 600
   
   
   
--6. Для каждого производителя, выпускающего ПК-блокноты
--   c объёмом жесткого диска не менее 10 Гбайт,
--   найти скорости таких ПК-блокнотов.
--   Вывод: производитель, скорость.

SELECT DISTINCT maker,
                laptop.speed
           FROM product
		   JOIN laptop
		     ON laptop.model = product.model
          WHERE hd >= 10



--7. Найдите номера моделей и цены всех имеющихся
--   в продаже продуктов (любого типа)
--   производителя B (латинская буква).

SELECT product.model,
       price
  FROM product
  JOIN pc
    ON pc.model = product.model
 WHERE maker = 'B'

UNION

SELECT product.model,
       price
  FROM product
  JOIN laptop
    ON laptop.model = product.model
 WHERE maker = 'B'

UNION

SELECT product.model,
       price
  FROM product
  JOIN printer
    ON printer.model = product.model
 WHERE maker = 'B'



--8. Найдите производителя, выпускающего ПК, но не ПК-блокноты.

SELECT DISTINCT maker
           FROM product
          WHERE type = 'pc'
EXCEPT
SELECT DISTINCT maker
           FROM product
          WHERE type = 'laptop'



--9. Найдите производителей ПК с процессором не менее 450 Мгц.
--   Вывести: Maker

SELECT DISTINCT maker
           FROM product
		   JOIN pc
		     ON pc.model = product.model
          WHERE type = 'pc'
		    AND speed >= 450
       ORDER BY maker



--10. Найдите модели принтеров, имеющих самую высокую цену.
--    Вывести: model, price

SELECT DISTINCT model,
				price
		   FROM printer
          WHERE price = (
                         SELECT MAX(price)
		                   FROM printer
						)


	
--11. Найдите среднюю скорость ПК.

SELECT AVG(speed)
  FROM pc



--12. Найдите среднюю скорость ПК-блокнотов,
--    цена которых превышает 1000 дол. 

SELECT AVG(speed)
  FROM laptop
 WHERE price > 1000
 
 
 
--13. Найдите среднюю скорость ПК,
--    выпущенных производителем A.

SELECT AVG(speed)
  FROM PC
 WHERE model IN (
				 SELECT model
				   FROM product
				  WHERE maker = 'A'
				)
				
				
				
--14. Найдите класс, имя и страну для кораблей
--    из таблицы Ships, имеющих не менее 10 орудий.

SELECT ships.class,
	   name,
	   classes.country
  FROM classes
  JOIN ships
    ON ships.class = classes.class
 WHERE numguns >= 10
 
 
 
--15. Найдите размеры жестких дисков,
--    совпадающих у двух и более PC.
--    Вывести: HD

SELECT hd
  FROM pc
 GROUP BY hd
HAVING COUNT(model) >= 2



--16. Найдите пары моделей PC, имеющих одинаковые скорость и RAM.
--    В результате каждая пара указывается только один раз,
--    т.е. (i,j), но не (j,i),
--    Порядок вывода: модель с большим номером,
--    модель с меньшим номером, скорость и RAM.

SELECT DISTINCT a.model,
				b.model,
				a.speed,
				a.ram
		   FROM pc AS a,
		        pc AS b
          WHERE (
		        a.speed = b.speed
			AND a.ram = b.ram
			    )
		    AND a.model > b.model
       ORDER BY a.model DESC
	   
	   
	   
--17. Найдите модели ПК-блокнотов, скорость которых
--    меньше скорости каждого из ПК.
--    Вывести: type, model, speed

SELECT DISTINCT type,
				laptop.model,
				speed
		   FROM product
           JOIN laptop
		     ON laptop.model = product.model
          WHERE speed < ALL (
		                     SELECT speed
							 FROM pc
							)
							
							
							
--18. Найдите производителей самых дешевых цветных принтеров.
--    Вывести: maker, price

SELECT DISTINCT maker,
                price
		   FROM product
		   JOIN printer
		     ON printer.model = product.model
		  WHERE color = 'y'
		    AND price = (
						 SELECT MIN(price)
						   FROM printer
						  WHERE color = 'y'
						)



--19. Для каждого производителя, имеющего модели в таблице Laptop, 
--    найдите средний размер экрана выпускаемых им ПК-блокнотов.
--    Вывести: maker, средний размер экрана.

SELECT maker,
	   AVG(screen)
  FROM product
  JOIN laptop
    ON laptop.model = product.model
 WHERE type = 'laptop'
 GROUP BY maker
 
 
 
--20. Найдите производителей, выпускающих по меньшей мере
--    три различных модели ПК. Вывести: Maker, число моделей ПК.
 
SELECT maker,
       COUNT(model)
  FROM product
 WHERE type = 'pc'
 GROUP BY maker
HAVING COUNT(model) >= 3