--Procedimientos

CREATE OR REPLACE PROCEDURE public.sp_buscar_cliente_apellido(IN p_apellido character)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_cliente RECORD;
BEGIN
    SELECT * FROM CLIENTES WHERE Apellido = p_apellido INTO v_cliente;
    RAISE NOTICE 'Cliente encontrado: %', v_cliente;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_buscar_cliente_dni(IN p_dni integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE p_resultado RECORD;
BEGIN
    SELECT * into p_resultado FROM CLIENTES WHERE DNI = p_dni;

RAISE NOTICE 'Cliente Encontrado: %', p_resultado;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_buscar_cuenta(IN p_nrcuenta integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE p_resultado RECORD;
BEGIN
    SELECT * into p_resultado FROM CUENTAS WHERE NrCuenta = p_nrcuenta;

RAISE NOTICE 'Cuenta Encontrada: %', p_resultado;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_cliente_cuentas(IN p_dni integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE p_resultado RECORD;
BEGIN
    SELECT C.Apellido, CU.NrCuenta, CU.Saldo INTO p_resultado FROM CLIENTES C JOIN CUENTAS CU ON C.DNI = CU.DNI  
    WHERE C.DNI = p_dni;
    RAISE NOTICE 'Cliente: %, Cuenta: %, Saldo: %', p_resultado.Apellido, p_resultado.NrCuenta, p_resultado.Saldo;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_credito(IN p_cuenta integer, IN p_monto integer, IN p_fecha date, IN p_codop integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    UPDATE cuentas
    SET saldo = saldo + p_monto
    WHERE nrcuenta = p_cuenta;

    INSERT INTO movimientos
    VALUES(
        (SELECT COALESCE(MAX(nrmov),0)+1 FROM movimientos),
        p_cuenta,
        p_monto,
        p_fecha,
        p_codop
    );

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_debito(IN p_cuenta integer, IN p_monto integer, IN p_fecha date, IN p_codop integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    v_saldo INT;
BEGIN

    SELECT saldo
    INTO v_saldo
    FROM cuentas
    WHERE nrcuenta = p_cuenta;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cuenta inexistente';
    END IF;

    IF v_saldo < p_monto THEN
        RAISE EXCEPTION 'Saldo insuficiente';
    END IF;

    UPDATE cuentas
    SET saldo = saldo - p_monto
    WHERE nrcuenta = p_cuenta;

    INSERT INTO movimientos
    VALUES (
        (SELECT COALESCE(MAX(nrmov),0)+1 FROM movimientos),
        p_cuenta,
        -p_monto,
        p_fecha,
        p_codop
    );

END;
$procedure$


CREATE OR REPLACE PROCEDURE public.sp_delete_ciudad(IN p_codciud integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM CIUDADES WHERE CodCiud = p_codciud;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_delete_cliente(IN p_dni integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM CLIENTES WHERE DNI = p_dni;
END;
$procedure$


CREATE OR REPLACE PROCEDURE public.sp_delete_cuenta(IN p_nrcuenta integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    DELETE FROM CUENTAS
    WHERE NrCuenta = p_nrcuenta;

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_delete_empleado(IN p_legemp integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM EMPLEADOS WHERE LegEmp = p_legemp;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_delete_provincia(IN p_codprov integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM PROVINCIAS WHERE CodProv = p_codprov;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_delete_sucursal(IN p_nrsuc integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    DELETE FROM SUCURSALES WHERE NrSuc = p_nrsuc;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_deposito(IN p_nrcuenta integer, IN p_monto integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    UPDATE CUENTAS
    SET Saldo = Saldo + p_monto
    WHERE NrCuenta = p_nrcuenta;

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_descontar_saldo_325()
 LANGUAGE plpgsql
AS $procedure$
DECLARE
    saldo_actual INT;
BEGIN
    SELECT saldo INTO saldo_actual
    FROM cuentas
    WHERE nrcuenta = 325;

    IF saldo_actual >= 700 THEN
        UPDATE cuentas
        SET saldo = saldo - 700
        WHERE nrcuenta = 325;

        RAISE NOTICE 'Descuento realizado correctamente';
    ELSE
        RAISE NOTICE 'Saldo insuficiente';
    END IF;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_empleados_sucursal(IN p_nrsuc integer)
 LANGUAGE plpgsql
AS $procedure$
DECLARE p_resultado RECORD;
BEGIN
    SELECT * INTO p_resultado FROM EMPLEADOS WHERE NrSuc = p_nrsuc;
    RAISE NOTICE 'Empleado: %, Sucursal: %', p_resultado.Apellido, p_resultado.NrSuc;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_extraccion(IN p_nrcuenta integer, IN p_monto integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE CUENTAS SET Saldo = Saldo - p_monto WHERE NrCuenta = p_nrcuenta;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_ciudad(IN p_codciud integer, IN p_ciudad character, IN p_codprov integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO CIUDADES VALUES(p_codciud, p_ciudad, p_codprov);
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_cliente(IN p_dni integer, IN p_apellido character, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO CLIENTES(DNI, Apellido, Ciudad) VALUES(p_dni, p_apellido, p_ciudad);
END;
$procedure$


CREATE OR REPLACE PROCEDURE public.sp_insert_cliente_control(IN p_dni integer, IN p_apellido character, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    IF p_dni <= 0 THEN
        RAISE EXCEPTION 'DNI inválido';
    END IF;
    INSERT INTO CLIENTES VALUES(p_dni, p_apellido, p_ciudad);
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_cuenta(IN p_nrcuenta integer, IN p_dni integer, IN p_nrsuc integer, IN p_tipocuenta integer, IN p_saldo integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    IF p_saldo < 0 THEN
        RAISE EXCEPTION 'El saldo no puede ser negativo';
    END IF;

    INSERT INTO CUENTAS
    VALUES(
        p_nrcuenta,
        p_dni,
        p_nrsuc,
        p_tipocuenta,
        p_saldo
    );

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_empleado(IN p_legemp integer, IN p_apellido character, IN p_nombre character, IN p_codcateg integer, IN p_nrsuc integer, IN p_codciud integer, IN p_fecha date)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    INSERT INTO EMPLEADOS
    VALUES(
        p_legemp,
        p_apellido,
        p_nombre,
        p_codcateg,
        p_nrsuc,
        p_codciud,
        p_fecha
    );

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_provincia(IN p_codprov integer, IN p_provincia character)
 LANGUAGE plpgsql
AS $procedure$
    BEGIN

        INSERT INTO PROVINCIAS
        VALUES(p_codprov,p_provincia);

    END;
    $procedure$

CREATE OR REPLACE PROCEDURE public.sp_insert_sucursal(IN p_nrsuc integer, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO SUCURSALES VALUES(p_nrsuc, P_ciudad);
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_registrar_extraccion(IN p_nrmov integer, IN p_nrcuenta integer, IN p_monto integer, IN p_fecha date)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO MOVIMIENTOS(NrMov, NrCuenta, Monto, Fecha)
    VALUES (p_nrmov, p_nrcuenta, p_monto, p_fecha);

    UPDATE CUENTAS SET Saldo = Saldo - (p_monto::numeric)::integer WHERE NrCuenta = p_nrcuenta;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_registrar_movimiento(IN p_nrmov integer, IN p_nrcuenta integer, IN p_monto integer, IN p_fecha date)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO MOVIMIENTOS(
        NrMov,
        NrCuenta,
        Monto,
        Fecha
    )
    VALUES(
        p_nrmov,
        p_nrcuenta,
        p_monto,
        p_fecha
    );

    UPDATE CUENTAS
    SET Saldo = Saldo + p_monto
    WHERE NrCuenta = p_nrcuenta;

    RAISE NOTICE 'Movimiento registrado correctamente';
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_registrar_movimiento_controlado(IN p_nrmov integer, IN p_nrcuenta integer, IN p_monto money, IN p_fecha time without time zone)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO MOVIMIENTOS VALUES(p_nrmov, p_nrcuenta, p_monto, p_fecha);
    UPDATE CUENTAS SET Saldo = Saldo + p_monto WHERE NrCuenta = p_nrcuenta;
END;
$procedure$


CREATE OR REPLACE PROCEDURE public.sp_registrar_operacion(IN p_nroperacion integer, IN p_nrcuenta integer, IN p_tipo character varying, IN p_fecha date)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    INSERT INTO OPERACIONES(
        NrOperacion,
        NrCuenta,
        TipoOperacion,
        Fecha
    )
    VALUES(
        p_nroperacion,
        p_nrcuenta,
        p_tipo,
        p_fecha
    );

    RAISE NOTICE 'Operacion registrada correctamente';
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_transferencia(IN p_cuenta_origen integer, IN p_cuenta_destino integer, IN p_monto money)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE CUENTAS SET Saldo = Saldo - p_monto WHERE NrCuenta = p_cuenta_origen;
    UPDATE CUENTAS SET Saldo = Saldo + p_monto WHERE NrCuenta = p_cuenta_destino;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_ciudad(IN p_codciud integer, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE CIUDADES SET Ciudad = p_ciudad WHERE CodCiud = p_codciud;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_cliente(IN p_dni integer, IN p_apellido character, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE CLIENTES SET Apellido = p_apellido, Ciudad = p_ciudad WHERE DNI = p_dni;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_cuenta(IN p_nrcuenta integer, IN p_saldo money)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    UPDATE CUENTAS
    SET Saldo = p_saldo
    WHERE NrCuenta = p_nrcuenta;

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_empleado(IN p_legemp integer, IN p_apellido character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE EMPLEADOS SET Apellido = p_apellido WHERE LegEmp = p_legemp;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_empleado_control(IN p_legemp integer, IN p_apellido character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    IF p_apellido IS NULL OR p_apellido = '' THEN
        RAISE EXCEPTION 'El campo apellido no puede quedar vacío';
    END IF;
    UPDATE EMPLEADOS SET Apellido = p_apellido WHERE LegEmp = p_legemp;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_provincia(IN p_codprov integer, IN p_provincia character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE PROVINCIAS SET Provincia = p_provincia WHERE CodProv = p_codprov;
END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_saldo_control(IN p_nrcuenta integer, IN p_saldo money)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    IF p_saldo < 0 THEN
        RAISE EXCEPTION 'Saldo invalido';
    END IF;

    UPDATE CUENTAS
    SET Saldo = p_saldo
    WHERE NrCuenta = p_nrcuenta;

END;
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_sucursal(IN p_nrsuc integer, IN p_ciudad character)
 LANGUAGE plpgsql
AS $procedure$
BEGIN
    UPDATE SUCURSALES SET Ciudad = p_ciudad WHERE NrSuc = p_nrsuc;
END
$procedure$

CREATE OR REPLACE PROCEDURE public.sp_update_sucursal(IN p_nrsuc integer, IN p_codciud integer)
 LANGUAGE plpgsql
AS $procedure$
BEGIN

    UPDATE SUCURSALES
    SET CodCiud = p_codciud
    WHERE NrSuc = p_nrsuc;

END;
$procedure$


