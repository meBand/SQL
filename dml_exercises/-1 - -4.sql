---1. Из каждой группы ПК с одинаковым номером модели
--    в таблице PC удалить все строки кроме строки
--    с наибольшим для этой группы кодом (столбец code).

DELETE FROM pc
	  WHERE code NOT IN (
						 SELECT max(code) AS code
						   FROM PC
						  GROUP BY model
						)



---2. Добавьте один дюйм к размеру экрана каждого блокнота,
--    выпущенного производителями E и B,
--    и уменьшите его цену на $100.

UPDATE laptop
   SET screen = screen+1,
       price = price-100
 WHERE model IN (
			     SELECT model
				   FROM product
				  WHERE type = 'Laptop'
				    AND (maker = 'E' OR maker = 'B')
				)
				
				
				
---3. Заменить любое количество повторяющихся пробелов
--    в названиях кораблей из таблицы Ships на один пробел.

--    P.S. 1. заменяем любой двойной пробел на ' $'
--         2. заменяем все ситуации '$ ' на '$'
--		   3. убираем '$' из строк
--         Таким образом остаются только первые пробелы после слова   

UPDATE ships
   SET name = REPLACE(REPLACE(REPLACE(name, '  ', ' $'), '$ ', '$'), '$', '')



---4. Удалить из таблицы Product те модели,
--    которые отсутствуют в других таблицах.

DELETE FROM product
 WHERE model NOT IN (
					 SELECT model
					   FROM pc

					  UNION

					 SELECT model
					   FROM laptop

					  UNION
					 
					 SELECT model
					   FROM printer
					)