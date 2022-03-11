-- Informações da versão
SELECT sqlite_version();
SELECT sqlite_source_id();

-- Criando tabela exemplo 
drop table if exists exemplo ;
CREATE TABLE exemplo ( COD INTEGER,	DADO1 INTEGER, DADO2 INTEGER);
INSERT INTO exemplo (COD,DADO1,DADO2) VALUES  (1,34,14), (2,22,62), (3,92,98);

-- Criando a tabela espelho
drop table if exists esp_exemplo;
create table if not exists esp_exemplo as
SELECT	*, ('I') as mode, (datetime()) as ts, (1) AS vigente
FROM exemplo;

-- Trigger INSERT
DROP Trigger if exists tg_insert;
CREATE Trigger tg_insert after INSERT on exemplo for EACH ROW
 BEGIN
	insert into	esp_exemplo SELECT *, ('I') as mode, (datetime()) as ts, (1) AS vigente
	FROM exemplo LIMIT (SELECT COUNT(*)-1 FROM exemplo),1;
END;


-- Trigger UPDATE 
DROP Trigger if exists tg_update;
CREATE Trigger tg_update before update on exemplo for EACH ROW
 BEGIN
	UPDATE esp_exemplo set vigente=0 
	where cod=old.cod and dado1=old.dado1 and dado2=old.dado2;  
	insert into	esp_exemplo
	SELECT new.COD, new.DADO1, new.DADO2,('U') as mode, (datetime()) as ts, (1) AS vigente;
END;

-- Trigger DELETE
DROP Trigger if exists tg_delete;
CREATE Trigger tg_delete before delete on exemplo for EACH ROW
 BEGIN
	UPDATE esp_exemplo set vigente=0 
	where cod=old.cod and dado1=old.dado1 and dado2=old.dado2;  
	insert into	esp_exemplo
	SELECT old.COD, old.DADO1, old.DADO2,('D') as mode, (datetime()) as ts, (0) AS vigente;
END;


-- teste
SELECT * from exemplo;
SELECT * from esp_exemplo;
INSERT into exemplo values (123,1,2);
SELECT * from exemplo;
SELECT * from esp_exemplo;
UPDATE exemplo set cod =20 WHERE  COD = 123;
SELECT * from exemplo;
SELECT * from esp_exemplo;
DELETE from exemplo where COD =20;
SELECT * from exemplo;
SELECT * from esp_exemplo;