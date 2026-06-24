--funciones

CREATE OR REPLACE FUNCTION public.descontar_saldo_325()
 RETURNS text
 LANGUAGE plpgsql
AS $function$
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

        RETURN 'Descuento realizado correctamente';
    ELSE
        RETURN 'Saldo insuficiente';
    END IF;
END;
$function$

CREATE OR REPLACE FUNCTION public.fn_actualizar_saldo()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

    UPDATE CUENTAS
    SET Saldo = Saldo + NEW.Monto
    WHERE NrCuenta = NEW.NrCuenta;

    RETURN NEW;

END;
$function$

CREATE OR REPLACE FUNCTION public.fn_audit_cuentas()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

    INSERT INTO AUDITORIA_CUENTAS
    (NrCuenta,Accion,Fecha)
    VALUES
    (NEW.NrCuenta,TG_OP,NOW());

    RETURN NEW;

END;
$function$

CREATE OR REPLACE FUNCTION public.fn_audit_movimientos()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN

    INSERT INTO AUDITORIA_MOVIMIENTOS
    (NrMov,Accion,Fecha)
    VALUES
    (NEW.NrMov,TG_OP,NOW());

    RETURN NEW;

END;
$function$
