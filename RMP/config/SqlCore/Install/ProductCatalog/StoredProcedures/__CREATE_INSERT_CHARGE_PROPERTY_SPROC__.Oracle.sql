
			CREATE OR REPLACE procedure InsertChargeProperty
   (
   p_a_id_charge t_charge_prop.id_charge%type,
   p_a_id_prod_view_prop t_charge_prop.id_prod_view_prop%type,
   p_a_id_charge_prop out number
   )
   as
      begin
   insert into t_charge_prop
      (
   id_charge_prop,
   id_charge,
   id_prod_view_prop
      )
      values
      (
   seq_charge_prop.nextval,
   p_a_id_charge,
   p_a_id_prod_view_prop
      );
   select seq_charge_prop.currval into p_a_id_charge_prop from dual;
   end;
	