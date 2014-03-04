create or replace PROCEDURE CREATE_PARTITIONS_NAMESPACE(
	namespace 		VARCHAR2
	,namespaceDescription 	VARCHAR2
	,method       		VARCHAR2
	,namespaceType 	VARCHAR2									   
	,invoicePrefix 	VARCHAR2
	,invoiceSuffix     	VARCHAR2
	,invoiceNumDigits 	int
	,invoiceDueDateOffset	int
	,invoiceNumLast 	int
	,errorNumber OUT int 
	,namespaceInsertCount OUT int
	,invoiceNamespaceInsertCount OUT int 
	,errorMessage OUT VARCHAR2)
AS
v_total_rows INT;
BEGIN

 errorNumber := 0;
 errorMessage := '';
 namespaceInsertCount := 0;
 invoiceNamespaceInsertCount := 0;

 select count(*) INTO v_total_rows from t_namespace where nm_space = namespace;

  if (v_total_rows=0) THEN 
    BEGIN
      insert into t_namespace (nm_space, tx_desc, nm_method, tx_typ_space)
      values (namespace, namespaceDescription, method, namespaceType);
    
      namespaceInsertCount := 1;  
    EXCEPTION
    WHEN others THEN
      namespaceInsertCount := -1;
      errorNumber := SQLCODE;
      errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;

 select count(*) INTO v_total_rows  from t_invoice_namespace where namespace = namespace;
 
  if (v_total_rows=0) THEN  
    BEGIN
      insert into t_invoice_namespace
             (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
      values (namespace, invoicePrefix, invoiceSuffix, invoiceNumDigits,  invoiceDueDateOffset, invoiceNumLast);
  
      invoiceNamespaceInsertCount := 1;
    EXCEPTION 
    WHEN others THEN  
      invoiceNamespaceInsertCount := -1;
      errorNumber := SQLCODE;
      errorMessage := SUBSTR(SQLERRM, 1, 200);
    END;
  END IF;

END;
