
CREATE DATABASE shift_cftbank_dev;

CREATE TABLE IF NOT EXISTS CLIENTS (
    ID INT(10) PRIMARY KEY,
    NAME VARCHAR(1000),
    PLACE_OF_BIRTH VARCHAR(1000),
    DATE_OF_BIRTH DATE,
    ADDRESS VARCHAR(1000),
    PASSPORT VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS PRODUCTS (
    ID INT(10) PRIMARY KEY,
    PRODUCT_TYPE_ID INT(10),
    NAME VARCHAR(100),
    CLIENT_REF INT(10),
    OPEN_DATE DATE,
    CLOSE_DATE DATE,
    FOREIGN KEY (PRODUCT_TYPE_ID)
        REFERENCES PRODUCT_TYPE (ID),
    FOREIGN KEY (CLIENT_REF)
        REFERENCES CLIENTS (ID)
);

CREATE TABLE IF NOT EXISTS PRODUCT_TYPE (
    ID INT(10) PRIMARY KEY,
    NAME VARCHAR(100),
    BEGIN_DATE DATE,
    END_DATE DATE,
    TARIF_REF INT(10),
    FOREIGN KEY (TARIF_REF)
        REFERENCES TARIFS (ID)
);

CREATE TABLE IF NOT EXISTS ACCOUNTS (
    ID INT(10) PRIMARY KEY,
    NAME VARCHAR(100),
    SALDO INT(10.2),
    CLIENT_REF INT(10),
    OPEN_DATE DATE,
    CLOSE_DATE DATE,
    PRODUCT_REF INT(10),
    ACC_NUM VARCHAR(25),
    FOREIGN KEY (CLIENT_REF)
        REFERENCES CLIENTS (ID),
    FOREIGN KEY (PRODUCT_REF)
        REFERENCES PRODUCTS (ID)
);

CREATE TABLE IF NOT EXISTS RECORDS (
    ID INT(10) PRIMARY KEY,
    DT INT(1),
    SUM INT(10.2),
    ACC_REF INT(10),
    OPER_DATE DATE,
    FOREIGN KEY (ACC_REF)
        REFERENCES ACCOUNTS (ID)
);

CREATE TABLE IF NOT EXISTS TARIFS (
    ID INT(10) PRIMARY KEY,
    NAME VARCHAR(100),
    COST INT(10.2)
);


insert into tarifs values (1,'Тариф за выдачу кредита', 10);
insert into tarifs values (2,'Тариф за открытие счета', 10);
insert into tarifs values (3,'Тариф за обслуживание карты', 10);

insert into product_type values (1, 'КРЕДИТ', '01.01.2018', null, 1);
insert into product_type values (2, 'ДЕПОЗИТ', '01.01.2018', null, 2);
insert into product_type values (3, 'КАРТА', '01.01.2018', null, 3);

insert into clients values (1, 'Сидоров Иван Петрович', 'Россия, Московская облать, г. Пушкин', '01.01.2001', 'Россия, Московская облать, г. Пушкин, ул. Грибоедова, д. 5', '2222 555555, выдан ОВД г. Пушкин, 10.01.2015');
insert into clients values (2, 'Иванов Петр Сидорович', 'Россия, Московская облать, г. Клин', '01.01.2001', 'Россия, Московская облать, г. Клин, ул. Мясникова, д. 3', '4444 666666, выдан ОВД г. Клин, 10.01.2015');
insert into clients values (3, 'Петров Сиодр Иванович', 'Россия, Московская облать, г. Балашиха', '01.01.2001', 'Россия, Московская облать, г. Балашиха, ул. Пушкина, д. 7', '4444 666666, выдан ОВД г. Клин, 10.01.2015');

insert into products values (1, 1, 'Кредитный договор с Сидоровым И.П.', 1, '01.06.2015', null);
insert into products values (2, 2, 'Депозитный договор с Ивановым П.С.', 2, '01.08.2017', null);
insert into products values (3, 3, 'Карточный договор с Петровым С.И.', 3, '01.08.2017', null);


insert into accounts values (1, 'Кредитный счет для Сидоровым И.П.', -2000, 1, '01.06.2015', null, 1, '45502810401020000022');
insert into accounts values (2, 'Депозитный счет для Ивановым П.С.', 6000, 2, '01.08.2017', null, 2, '42301810400000000001');
insert into accounts values (3, 'Карточный счет для Петровым С.И.', 8000, 3, '01.08.2017', null, 3, '40817810700000000001');

insert into records values (1, 1, 5000, 1, '01.06.2015');
insert into records values (2, 0, 1000, 1, '01.07.2015');
insert into records values (3, 0, 2000, 1, '01.08.2015');
insert into records values (4, 0, 3000, 1, '01.09.2015');
insert into records values (5, 1, 5000, 1, '01.10.2015');
insert into records values (6, 0, 3000, 1, '01.10.2015');

insert into records values (7, 0, 10000, 2, '01.08.2017');
insert into records values (8, 1, 1000, 2, '05.08.2017');
insert into records values (9, 1, 2000, 2, '21.09.2017');
insert into records values (10, 1, 5000, 2, '24.10.2017');
insert into records values (11, 0, 6000, 2, '26.11.2017');

insert into records values (12, 0, 120000, 3, '08.09.2017');
insert into records values (13, 1, 1000, 3, '05.10.2017');
insert into records values (14, 1, 2000, 3, '21.10.2017');
insert into records values (15, 1, 5000, 3, '24.10.2017');

commit;

SELECT 
    *
FROM
    clients;

#4.Сформируйте отчет, который содержит все счета, относящиеся к продуктам типа ДЕПОЗИТ, принадлежащих клиентам, у которых нет открытых продуктов типа КРЕДИТ.

SELECT 
    A.*
FROM
    ACCOUNTS A
        JOIN
    PRODUCTS P ON A.PRODUCT_REF = P.ID
        JOIN
    CLIENTS C ON A.CLIENT_REF = C.ID
WHERE
    P.PRODUCT_TYPE_ID = (SELECT 
            ID
        FROM
            PRODUCT_TYPE
        WHERE
            NAME = 'ДЕПОЗИТ')
        AND C.ID NOT IN (SELECT DISTINCT
            CLIENT_REF
        FROM
            PRODUCTS
        WHERE
            PRODUCT_TYPE_ID = (SELECT 
                    ID
                FROM
                    PRODUCT_TYPE
                WHERE
                    NAME = 'КРЕДИТ'));

#5.Сформируйте выборку, который содержит средние движения по счетам в рамках одного произвольного дня, в разрезе типа продукта.
SELECT 
    P.NAME AS PRODUCT_TYPE,
    DATE_FORMAT(R.OPER_DATE, '%Y-%m-%d') AS DATE,
    AVG(R.SUM) AS AVERAGE_MOVEMENT
FROM
    RECORDS R
        JOIN
    ACCOUNTS A ON R.ACC_REF = A.ID
        JOIN
    PRODUCTS PR ON A.PRODUCT_REF = PR.ID
        JOIN
    PRODUCT_TYPE P ON PR.PRODUCT_TYPE_ID = P.ID
GROUP BY PR.PRODUCT_TYPE_ID , DATE_FORMAT(R.OPER_DATE, '%Y-%m-%d');


#6. Сформируйте выборку, в который попадут клиенты, у которых были операции по счетам за прошедший месяц от текущей даты. Выведите клиента и сумму операций за день в разрезе даты.
SELECT 
    C.NAME AS CLIENT_NAME,
    DATE_FORMAT(R.OPER_DATE, '%Y-%m-%d') AS OPERATION_DATE,
    SUM(R.SUM) AS TOTAL_OPERATION_SUM
FROM
    RECORDS R
        JOIN
    ACCOUNTS A ON R.ACC_REF = A.ID
        JOIN
    CLIENTS C ON A.CLIENT_REF = C.ID
WHERE
    R.OPER_DATE BETWEEN DATE_SUB(CURRENT_DATE(),
        INTERVAL 1 MONTH) AND CURRENT_DATE()
GROUP BY C.ID , DATE_FORMAT(R.OPER_DATE, '%Y-%m-%d');

#7.В результате сбоя в базе данных разъехалась информация между остатками и операциями по счетам. Напишите нормализацию (процедуру выравнивающую данные), которая найдет такие счета и восстановит остатки по счету.

CREATE PROCEDURE align_account_balances()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE acc_id INT;
    DECLARE acc_balance DECIMAL(10,2);
    DECLARE total_operation_sum DECIMAL(10,2);

    # Создаем временную таблицу для хранения суммы операций по каждому счету
    CREATE TEMPORARY TABLE IF NOT EXISTS temp_account_operations (
        account_id INT,
        total_sum DECIMAL(10,2)
    );

    # Заполняем временную таблицу суммами операций по каждому счету
    INSERT INTO temp_account_operations (account_id, total_sum)
    SELECT ACC_REF, SUM(SUM)
    FROM RECORDS
    GROUP BY ACC_REF;

	 # Создаем курсор для обхода счетов
    DECLARE cur_accounts CURSOR FOR
        SELECT ID, SALDO
        FROM ACCOUNTS;

    # Обходим счета
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_accounts;
    read_loop: LOOP
        FETCH cur_accounts INTO acc_id, acc_balance;
        IF done THEN
            LEAVE read_loop;
        END IF;

        # Получаем сумму операций по текущему счету
        SELECT total_sum INTO total_operation_sum
        FROM temp_account_operations
        WHERE account_id = acc_id;

        # Обновляем остаток по счету, если не соответствует сумме операций
        IF acc_balance <> total_operation_sum THEN
            UPDATE ACCOUNTS
            SET SALDO = total_operation_sum
            WHERE ID = acc_id;
        END IF;
    END LOOP;

    CLOSE cur_accounts;

    #Удаляем временную таблицу
    DROP TEMPORARY TABLE IF EXISTS temp_account_operations;
END;

#8.Сформируйте выборку, который содержит информацию о клиентах, которые полностью погасили кредит, но при этом не закрыли продукт и пользуются им дальше (по продукту есть операция новой выдачи кредита).

SELECT DISTINCT C.*
FROM CLIENTS C
JOIN ACCOUNTS A ON C.ID = A.CLIENT_REF
JOIN PRODUCTS P ON A.PRODUCT_REF = P.ID
JOIN RECORDS R ON A.ID = R.ACC_REF
WHERE P.PRODUCT_TYPE_ID = (SELECT ID FROM PRODUCT_TYPE WHERE NAME = 'КРЕДИТ')
AND A.ID NOT IN (
    SELECT DISTINCT A2.ID
    FROM ACCOUNTS A2
    JOIN PRODUCTS P2 ON A2.PRODUCT_REF = P2.ID
    WHERE P2.PRODUCT_TYPE_ID = (SELECT ID FROM PRODUCT_TYPE WHERE NAME = 'КРЕДИТ')
    AND A2.ID <> A.ID
)
AND R.SUM = 0;

#9.Закройте продукты (установите дату закрытия равную текущей) типа КРЕДИТ, у которых произошло полное погашение, но при этом не было повторной выдачи.
UPDATE PRODUCTS
SET CLOSE_DATE = CURRENT_DATE()
WHERE ID IN (
    SELECT P.ID
    FROM PRODUCTS P
    JOIN ACCOUNTS A ON P.ID = A.PRODUCT_REF
    JOIN RECORDS R ON A.ID = R.ACC_REF
    WHERE P.PRODUCT_TYPE_ID = (SELECT ID FROM PRODUCT_TYPE WHERE NAME = 'КРЕДИТ')
    AND R.SUM = 0
    AND P.ID NOT IN (
        SELECT P2.ID
        FROM PRODUCTS P2
        JOIN ACCOUNTS A2 ON P2.ID = A2.PRODUCT_REF
        JOIN RECORDS R2 ON A2.ID = R2.ACC_REF
        WHERE P2.PRODUCT_TYPE_ID = (SELECT ID FROM PRODUCT_TYPE WHERE NAME = 'КРЕДИТ')
        AND R2.SUM <> 0
    )
);

#10.Закройте возможность открытия (установите дату окончания действия) для типов продуктов, по счетам продуктов которых, не было движений более одного месяца.

UPDATE PRODUCT_TYPE
SET END_DATE = CURRENT_DATE()
WHERE ID IN (
    SELECT P.PRODUCT_TYPE_ID
    FROM PRODUCTS P
    LEFT JOIN RECORDS R ON P.ID = R.ACC_REF
    WHERE R.OPER_DATE < DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
    GROUP BY P.PRODUCT_TYPE_ID
);

#11. В модель данных добавьте сумму договора по продукту. Заполните поле для всех продуктов суммой максимальной дебетовой операции по счету для продукта типа КРЕДИТ, и суммой максимальной кредитовой операции по счету продукта для продукта типа ДЕПОЗИТ или КАРТА.

#Добавляем поле "сумма договора" в таблицу PRODUCT_TYPE
ALTER TABLE PRODUCT_TYPE
ADD COLUMN CONTRACT_AMOUNT DECIMAL(10,2);

#Заполняем поле "сумма договора" для продуктов типа КРЕДИТ
UPDATE PRODUCT_TYPE PT
SET PT.CONTRACT_AMOUNT = (
    SELECT MAX(ABS(R.SUM))
    FROM RECORDS R
    JOIN ACCOUNTS A ON R.ACC_REF = A.ID
    JOIN PRODUCTS P ON A.PRODUCT_REF = P.ID
    WHERE P.PRODUCT_TYPE_ID = PT.ID
    AND R.SUM < 0
);

#Заполняем поле "сумма договора" для продуктов типа ДЕПОЗИТ и КАРТА
UPDATE PRODUCT_TYPE PT
SET PT.CONTRACT_AMOUNT = (
    SELECT MAX(ABS(R.SUM))
    FROM RECORDS R
    JOIN ACCOUNTS A ON R.ACC_REF = A.ID
    JOIN PRODUCTS P ON A.PRODUCT_REF = P.ID
    WHERE P.PRODUCT_TYPE_ID = PT.ID
    AND R.SUM > 0
);





