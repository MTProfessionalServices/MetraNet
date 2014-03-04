CREATE PROCEDURE [dbo].[CREATE_PARTITIONS_NAMESPACE]
	@namespace 		VARCHAR(4000)
	,@namespaceDescription 	VARCHAR(4000)
	,@method       		VARCHAR(4000)
	,@namespaceType 	VARCHAR(4000)									   
	,@invoicePrefix 	VARCHAR(4000)
	,@invoiceSuffix     	varchar(4000)
	,@invoiceNumDigits 	int
	,@invoiceDueDateOffset	int
	,@invoiceNumLast 	int
	,@errorNumber int OUTPUT
	,@namespaceInsertCount int OUTPUT
	,@invoiceNamespaceInsertCount int OUTPUT
	,@errorMessage varchar(4000) OUTPUT

AS BEGIN

set @errorNumber = 0
set @errorMessage = ''
set @namespaceInsertCount = 0
set @invoiceNamespaceInsertCount = 0

if not exists (select * from t_namespace where nm_space = @namespace)
begin
  BEGIN TRY
    insert into t_namespace
           (nm_space,   tx_desc,               nm_method, tx_typ_space)
    values (@namespace, @namespaceDescription, @method,   @namespaceType)
  
    set @namespaceInsertCount = @@RowCount
  END TRY
  BEGIN CATCH
    select @namespaceInsertCount = -1, @errorNumber = ERROR_NUMBER(), @errorMessage = ERROR_MESSAGE()
  END CATCH
end

if not exists (select * from t_invoice_namespace where namespace = @namespace)
begin
  BEGIN TRY
    insert into t_invoice_namespace
           (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
    values (@namespace, @invoicePrefix, @invoiceSuffix, @invoiceNumDigits,  @invoiceDueDateOffset, @invoiceNumLast)

    set @invoiceNamespaceInsertCount = @@RowCount
  END TRY
  BEGIN CATCH
    select @namespaceInsertCount = -1, @errorNumber = ERROR_NUMBER(), @errorMessage = ERROR_MESSAGE()
  END CATCH
end


END