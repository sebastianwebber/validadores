-- cnpj.sql
-- funções de formatação de CNPJ
-- Algumas mascaras e idéias foram tiradas de uma thread da lista pgbr-geral:
--- http://postgresql.nabble.com/Mascara-de-CPF-td2027551.html

SET client_min_messages = warning;


CREATE OR REPLACE FUNCTION formata_cnpj(NUMERIC) 
RETURNS TEXT AS $$
	SELECT to_char($1,'00"."000"."000"/"0000"-"00') AS cnpj;
$$ LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION formata_cnpj(BIGINT) 
RETURNS TEXT AS $$
	SELECT formata_cnpj(CAST($1 AS NUMERIC)) AS cnpj;
$$ LANGUAGE 'sql';



-- Fonte: https://wiki.postgresql.org/wiki/CNPJ

-- Esta função retorna true se o CNPJ é válido  e falso caso contrário
-- Ela verifica o tamanho e os dígitos verificadores
CREATE OR REPLACE FUNCTION valida_cnpj(text)
RETURNS BOOLEAN AS $$
-- valida se tem o tamanho minimo
SELECT CASE WHEN LENGTH($1) = 14 THEN
(
  -- verifica se os dígitos coincidem com os especificados
  SELECT
      SUBSTR($1, 13, 1) = CAST(digit1 AS text) AND
      SUBSTR($1, 14, 1) = CAST(digit2 AS text)
  FROM
  (
    -- calcula o segundo dígito verificador (digit2)
    SELECT
        -- se o resultado do módulo for 0 ou 1 temos 0
        -- senão temos a subtração de 11 pelo resultado do módulo
        CASE res2
        WHEN 0 THEN 0
        WHEN 1 THEN 0
        ELSE 11 - res2
        END AS digit2,
        digit1
    FROM
    (
      -- soma da multiplicação dos primeiros 9 dígitos por 11, 10, ..., 4, 3
      SELECT MOD(SUM(res2) + digit1 * 2, 11) AS res2,
          digit1
      FROM
      (
        SELECT
            SUM(m * CAST(SUBSTR($1, 7 - m, 1) AS INTEGER)) AS res2
        FROM
        (
          SELECT generate_series(6, 2, -1) AS m
        ) AS m11
        UNION ALL
        SELECT
            SUM(m * CAST(SUBSTR($1, 15 - m, 1) AS INTEGER)) AS res2
        FROM
        (
          SELECT generate_series(9, 3, -1) AS m
        ) AS m12
      ) AS m2,
      (
        -- calcula o primeiro dígito verificador (digit1)
        SELECT
            -- se o resultado do módulo for 0 ou 1 temos 0
            -- senão temos a subtração de 11 pelo resultado do módulo
            CASE res1
            WHEN 0 THEN 0
            WHEN 1 THEN 0
            ELSE 11 - res1
            END AS digit1
        FROM
        (
          -- soma da multiplicação dos primeiros 12 dígitos por 5, 4, 3, 2, 9, 8, 7, ..., 3, 2
          SELECT MOD(SUM(res1), 11) AS res1
          FROM
          (
            SELECT
                SUM(n * CAST(SUBSTR($1, 6 - n, 1) AS INTEGER)) AS res1
            FROM
            (
              SELECT generate_series(5, 2, -1) AS n
            ) AS m11
            UNION ALL
            SELECT
                SUM(n * CAST(SUBSTR($1, 14 - n, 1) AS INTEGER)) AS res1
            FROM
            (
              SELECT generate_series(9, 2, -1) AS n
            ) AS m12
          ) AS m1
        ) AS sum1
      ) AS first_digit
      GROUP BY digit1
    ) AS sum2
  ) AS first_sec_digit
)
ELSE FALSE END AS result;
 
$$ LANGUAGE 'sql';


CREATE OR REPLACE FUNCTION valida_cnpj(NUMERIC) 
RETURNS BOOLEAN AS $$
	SELECT valida_cnpj(CAST($1 AS TEXT)) AS result;
$$ LANGUAGE 'sql';

CREATE OR REPLACE FUNCTION valida_cnpj(BIGINT) 
RETURNS BOOLEAN AS $$
	SELECT valida_cnpj(CAST($1 AS TEXT)) AS result;
$$ LANGUAGE 'sql';

CREATE DOMAIN cnpj AS numeric CHECK ( valida_cnpj(VALUE) );

CREATE OPERATOR ## (
	LEFTARG = NUMERIC,
	PROCEDURE = formata_cnpj
);

CREATE OPERATOR ##? (
  LEFTARG = NUMERIC,
  PROCEDURE = valida_cnpj
);
