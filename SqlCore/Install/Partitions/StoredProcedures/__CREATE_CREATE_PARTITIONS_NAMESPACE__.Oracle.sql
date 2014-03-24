create or replace
PROCEDURE CREATE_PARTITIONS_NAMESPACE(
	 v_namespace 		VARCHAR2
	,v_namespaceDescription 	VARCHAR2
	,v_method       		VARCHAR2
	,v_namespaceType 	VARCHAR2
	,v_invoicePrefix 	VARCHAR2
	,v_invoiceSuffix     	VARCHAR2
	,v_invoiceNumDigits 	int
	,v_invoiceDueDateOffset	int
	,v_invoiceNumLast 	int
	,v_namespaceInsertCount OUT int
	,v_invoiceNamespaceInsertCount OUT int
    ,v_errorNumber OUT int
	,v_errorMessage OUT VARCHAR2)
AS
v_total_rows_t_namespace INT;
v_total_rows_t_invoice_n INT;
BEGIN

 v_errorNumber := 0;
 v_errorMessage := '';
 v_namespaceInsertCount := 0;
 v_invoiceNamespaceInsertCount := 0;

 select count(*) INTO v_total_rows_t_namespace from t_namespace where nm_space = v_namespace;

  if (v_total_rows_t_namespace=0) THEN
    BEGIN
      insert into t_namespace (nm_space, tx_desc, nm_method, tx_typ_space)
      values (LOWER(v_namespace), v_namespaceDescription, v_method, v_namespaceType);
    
      v_namespaceInsertCount := 1;
    EXCEPTION
    WHEN others THEN
      v_namespaceInsertCount := -1;
      v_errorNumber := SQLCODE;
      v_errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;

 select count(*) INTO v_total_rows_t_invoice_n  from t_invoice_namespace t_in where t_in.namespace = v_namespace;
 
  if (v_total_rows_t_invoice_n=0) THEN
    BEGIN
      insert into t_invoice_namespace
             (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
      values (LOWER(v_namespace), v_invoicePrefix, v_invoiceSuffix, v_invoiceNumDigits,  v_invoiceDueDateOffset, v_invoiceNumLast);
  
      v_invoiceNamespaceInsertCount := 1;
    EXCEPTION
    WHEN others THEN
      v_invoiceNamespaceInsertCount := -1;
      v_errorNumber := SQLCODE;
      v_errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;  
END;
