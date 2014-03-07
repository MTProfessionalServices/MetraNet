CREATE PROCEDURE [dbo].[CREATE_PARTITIONS_NAMESPACE]
	@v_namespace 		VARCHAR(4000)
	,@v_namespaceDescription 	VARCHAR(4000)
	,@v_method       		VARCHAR(4000)
	,@v_namespaceType 	VARCHAR(4000)									   
	,@v_invoicePrefix 	VARCHAR(4000)
	,@v_invoiceSuffix     	varchar(4000)
	,@v_invoiceNumDigits 	int
	,@v_invoiceDueDateOffset	int
	,@v_invoiceNumLast 	int
	,@v_errorNumber int OUTPUT
	,@v_namespaceInsertCount int OUTPUT
	,@v_invoiceNamespaceInsertCount int OUTPUT
	,@v_errorMessage varchar(4000) OUTPUT

AS BEGIN

set @v_errorNumber = 0
set @v_errorMessage = ''
set @v_namespaceInsertCount = 0
set @v_invoiceNamespaceInsertCount = 0

if not exists (select * from t_namespace where nm_space = @v_namespace)
begin
  BEGIN TRY
    insert into t_namespace
           (nm_space,   tx_desc,               nm_method, tx_typ_space)
    values (@v_namespace, @v_namespaceDescription, @v_method,   @v_namespaceType)
  
    set @v_namespaceInsertCount = @@RowCount
  END TRY
  BEGIN CATCH
    select @v_namespaceInsertCount = -1, @v_errorNumber = ERROR_NUMBER(), @v_errorMessage = ERROR_MESSAGE()
  END CATCH
end

if not exists (select * from t_invoice_namespace where namespace = @v_namespace)
begin
  BEGIN TRY
    insert into t_invoice_namespace
           (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
    values (@v_namespace, @v_invoicePrefix, @v_invoiceSuffix, @v_invoiceNumDigits,  @v_invoiceDueDateOffset, @v_invoiceNumLast)

    set @v_invoiceNamespaceInsertCount = @@RowCount
  END TRY
  BEGIN CATCH
    select @v_namespaceInsertCount = -1, @v_errorNumber = ERROR_NUMBER(), @v_errorMessage = ERROR_MESSAGE()
  END CATCH
end


END