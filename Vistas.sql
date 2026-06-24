--vistas
CREATE OR REPLACE VIEW vw_cant_cuentas_cliente AS
 SELECT dni,
    count(*) AS cantidadcuentas
   FROM cuentas
  GROUP BY dni;

  CREATE OR REPLACE VIEW vw_cantcuentasmenor700 AS
 SELECT nrsuc,
    count(*) AS cantidadcuentas
   FROM cuentas
  WHERE (saldo < 700)
  GROUP BY nrsuc
  ORDER BY nrsuc;

  CREATE OR REPLACE VIEW vw_clientes AS
 SELECT dni,
    apellido,
    ciudad
   FROM clientes;

   CREATE OR REPLACE VIEW vw_clientesporciudad AS
 SELECT ciudad,
    count(*) AS cantclientes
   FROM clientes
  WHERE (ciudad !~~ 'A%'::text)
  GROUP BY ciudad
 HAVING (count(*) >= 3);

 CREATE OR REPLACE VIEW vw_cuentasmas3mov AS
 SELECT nrcuenta,
    count(*) AS cantmov
   FROM movimientos
  WHERE ((fecha >= '2013-03-16'::date) AND (fecha <= '2018-02-20'::date))
  GROUP BY nrcuenta
 HAVING (count(*) > 3);

 CREATE OR REPLACE VIEW vw_empleados_sucursales AS
 SELECT e.legemp,
    e.apellido,
    s.nrsuc
   FROM (empleados e
     JOIN sucursales s ON ((e.nrsuc = s.nrsuc)));

     CREATE OR REPLACE VIEW vw_movimientos AS
 SELECT nrmov,
    nrcuenta,
    monto,
    fecha
   FROM movimientos;

   CREATE OR REPLACE VIEW vw_promedio_tipo_cuenta AS
 SELECT nrcuenta,
    round(avg(saldo), 2) AS promediosaldo
   FROM cuentas
  GROUP BY nrcuenta;

  CREATE OR REPLACE VIEW vw_sucursales_muchas_cuentas AS
 SELECT nrsuc,
    count(*) AS cantidad
   FROM cuentas
  GROUP BY nrsuc
 HAVING (count(*) > 3);

 CREATE OR REPLACE VIEW vw_sumasaldossuc AS
 SELECT nrsuc,
    sum(saldo) AS totalsaldo
   FROM cuentas
  WHERE (nrsuc = ANY (ARRAY[2, 3]))
  GROUP BY nrsuc;

  CREATE OR REPLACE VIEW vw_total_sucursal AS
 SELECT nrsuc,
    sum(saldo) AS totalsaldo
   FROM cuentas
  GROUP BY nrsuc;