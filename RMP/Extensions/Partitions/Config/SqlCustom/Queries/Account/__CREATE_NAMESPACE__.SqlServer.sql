declare @errorNumber int
declare @errorMessage nvarchar(4000)
select @errorNumber = 0, @errorMessage = ''

declare @namespaceInsertCount int
set @namespaceInsertCount = 0

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


declare @invoiceNamespaceInsertCount int
set @invoiceNamespaceInsertCount = 0

if not exists (select * from t_invoice_namespace where namespace = @namespace)
begin
  BEGIN TRY
    insert into t_invoice_namespace
           (namespace,  invoice_prefix, invoice_suffix, invoice_num_digits, invoice_due_date_offset, id_invoice_num_last)
    values (@namespace, @invoicePrefix, @invoiceSuffix, @invoiceNumDigits,  @invoiceDueDateOffset,   @invoiceNumLast)

    set @invoiceNamespaceInsertCount = @@RowCount
  END TRY
  BEGIN CATCH
    select @namespaceInsertCount = -1, @errorNumber = ERROR_NUMBER(), @errorMessage = ERROR_MESSAGE()
  END CATCH
end

select 
	@namespaceInsertCount        'namespaceInsertCount', 
	@invoiceNamespaceInsertCount 'invoiceNamespaceInsertCount',
	@errorNumber                 'errorNumber',
	@errorMessage                'errorMessage'
