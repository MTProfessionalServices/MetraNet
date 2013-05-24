option explicit

Dim bulkFailed ' as IBulkFailedTransactions
Set bulkFailed = CreateObject("MetraTech.Pipeline.BulkFailedTransactions")
dim messageLabelSet ' as IMessageLabelSet
set messageLabelSet = CreateObject("MetraTech.Pipeline.MessageLabelSet")

dim sessionFailures ' as IMTSessionFailures
set sessionFailures = CreateObject("MetraPipeline.MTSessionFailures.1")
sessionFailures.Refresh

dim sessionError ' as IMTSessionError
for each sessionError in sessionFailures
    wscript.echo "resubmitting " & sessionError.RootSessionID
    messageLabelSet.Add sessionError.RootSessionID
Next

bulkFailed.Resubmit(messageLabelSet)

' or to delete
'bulkFailed.Delete(messageLabelSet)

