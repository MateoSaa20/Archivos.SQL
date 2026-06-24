--triggers
CREATE OR REPLACE TRIGGER tr_audit_cuentas AFTER INSERT OR UPDATE ON public.cuentas FOR EACH ROW EXECUTE FUNCTION fn_audit_cuentas();

CREATE OR REPLACE TRIGGER tr_audit_cuentas AFTER INSERT OR UPDATE ON public.cuentas FOR EACH ROW EXECUTE FUNCTION fn_audit_cuentas();