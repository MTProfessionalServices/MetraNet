' -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'
' NAME   : Fred Performance MetraTech Performance Class Plug In
'
' -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CDB.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\MetraTech.Test.Library.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CTest.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CPropertyBag.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CSDK.vbs"

PUBLIC CONST MPFM_SQL_1000 = "select dt_crt from t_acc_usage where id_sess >= '[ID_SESSION]' order by id_sess asc"
PUBLIC CONST MPFM_SQL_1001 = "select max(id_sess) max from t_acc_usage"

PUBLIC CONST MAX_RMP_SERVER = 1
PUBLIC CONST MPFM_CLIENT_WAIT_FOR_PIPELINE_SLEEP_TIME = 3000

PUBLIC CONST PIPELINE_SERVER = "deuteron"'"f-torres"
PUBLIC CONST SQLSERVER       = "deuteron"'"f-torres"

CLASS CMPFMClient

   Public PropertyBag
   Public staOverAllProcessingTime

   PRIVATE SUB Class_Initialize()

      Set PropertyBag = New CPropertyBag
      PropertyBag.Initialize MPFM.ScriptFileNameOnly

      MetraTech.DB.TraceOn = FALSE

      DEFAULT_SQLSERVER = SQLSERVER
      MetraTech.OpenDatabase

      MPFM.Trace "Property Bag:" & PropertyBag.FileName
   END SUB

   PRIVATE SUB Class_Terminate()

   END SUB

   PRIVATE FUNCTION IsAllTransactionProcessed(lngMaxTransaction)

      Dim strSQL,objRst, startMeteringTime, endPipeLineProcessingTime

      strSQL = PreProcess(MPFM_SQL_1000,Array("ID_SESSION",PropertyBag.Value("MeterTransaction.MaxSessionIDBefore")))

      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())

      If lngMaxTransaction Then

         mpfm.Trace "" & (objRst.RecordCount/lngMaxTransaction*100) & "% of the transaction were processed by the pipeline..."
      End If
      IsAllTransactionProcessed = CBool( objRst.RecordCount >= lngMaxTransaction )
   END FUNCTION

   PUBLIC FUNCTION MeterTransaction(lngMaxMetering)

     Dim objSDK(2)
     Dim i, lngServerIndex

     MeterTransaction = FALSE

     PropertyBag.Clear
     PropertyBag.Value("MeterTransaction.MaxSessionIDBefore") = GetMaxTAccUsageSessionID()
     PropertyBag.Value("MeterTransaction.StartTime")          = MetraTech.GMTNow()
     PropertyBag.Value("MeterTransaction.LocalStartTime")     = Now()

     '
     ' Init the SDKs
     '
     For lngServerIndex = 0 To MAX_RMP_SERVER - 1

         Set objSDK(lngServerIndex) = New CMTSDK
         objSDK(lngServerIndex).Initialize PIPELINE_SERVER , "metratech.com/addcharge"

         If Not objSDK(lngServerIndex).LoadAutoSDKFile("D:\MetraTech\Development\Shared\MPFM\VBScript\FredPerf.files\AddCharge1.xml") Then Exit Function
     Next
     '
     ' Meter to the SDKs
     '
     For lngServerIndex = 0 To MAX_RMP_SERVER - 1

         For i = 1 To lngMaxMetering

            objSDK(lngServerIndex).AutoSDKFile.Inputs("chargedate").Value = MetraTech.GMTNowInGMTFormat()
            objSDK(lngServerIndex).CopyAutoSDKPropertyToSession
            objSDK(lngServerIndex).Meter
            If MPFM.CancelScript Then Exit Function
         Next
     Next
     
     PropertyBag.Value("MeterTransaction.MeteredTransaction")          = lngMaxMetering*MAX_RMP_SERVER
     PropertyBag.Value("MeterTransaction.EndTime")                     = MetraTech.GMTNow()
     PropertyBag.Value("MeterTransaction.LocalEndTime")                = Now()
     PropertyBag.Value("MeterTransaction.MeterTime")                   = DateDiff("s",PropertyBag.Value("MeterTransaction.StartTime"),PropertyBag.Value("MeterTransaction.EndTime"))

     If PropertyBag.Value("MeterTransaction.MeterTime") > 0 Then

        PropertyBag.Value("MeterTransaction.MeteredTransactionPerSecond") = (lngMaxMetering*MAX_RMP_SERVER)/PropertyBag.Value("MeterTransaction.MeterTime")
     Else
        PropertyBag.Value("MeterTransaction.MeteredTransactionPerSecond") = -1 ' Invalid Value
     End If

     mpfm.Trace "MeterTransaction.MeterTime:"                    & PropertyBag.Value("MeterTransaction.MeterTime") & " S"
     mpfm.Trace "MeterTransaction.MeteredTransaction:"           & PropertyBag.Value("MeterTransaction.MeteredTransaction")
     mpfm.Trace "MeterTransaction.MeteredTransactionPerSecond:"  & PropertyBag.Value("MeterTransaction.MeteredTransactionPerSecond") & "/S"

     MeterTransaction = TRUE

   END FUNCTION

   ' Public interface to implements...
   PUBLIC FUNCTION Run(strParameter)

      Dim i, lngMaxMetering, datTmpDate, datDateDiff, lngTmpTransactionCounter

      Run            = FALSE
      If Len(strParameter)then
        lngMaxMetering = CLNG(strParameter)
      Else
        lngMaxMetering = InputBox("","Number of transaction to send",10)
      End If

      If Not IsNumeric(lngMaxMetering) Then Exit Function

      MPFM.Trace "Metering " & lngMaxMetering & " transactions..."

      If MeterTransaction(lngMaxMetering) Then

          MPFM.Trace "Client metering done, waiting for the pipeline to finish the transaction processing..."

          Do While Not IsAllTransactionProcessed(lngMaxMetering*MAX_RMP_SERVER)

              MPFM.Trace "Sleeping a little..."
              MPFM.Sleep MPFM_CLIENT_WAIT_FOR_PIPELINE_SLEEP_TIME
              If MPFM.CancelScript Then Exit Function
          Loop
          PropertyBag.Value("MeterTransaction.MaxSessionIDAfter") = GetMaxTAccUsageSessionID()
          Run = Statistic(strParameter)
      End If
   END FUNCTION

   PUBLIC FUNCTION GetMaxTAccUsageSessionID()

      Dim objRst, strSQL

      strSQL = MPFM_SQL_1001

      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())

      GetMaxTAccUsageSessionID = objRst.Fields("max")
   END FUNCTION

   ' Public interface to implements...
   PUBLIC FUNCTION Statistic(strParameter)

      Dim strSQL,objRst, startMeteringTime, endPipeLineProcessingTime, strCSV, dblDateDiffMS

      MPFM.Trace "Computing Statistics..."

      strSQL = PreProcess(MPFM_SQL_1000,Array("ID_SESSION",PropertyBag.Value("MeterTransaction.MaxSessionIDBefore")))

      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())

      If Not IsValidObject(objRst) Then mpfm.Trace "Recordset not valid",mpfmERROR : Exit Function
      If objRst.RecordCount=0      Then mpfm.Trace "Recordset is empty" ,mpfmERROR : Exit Function

      objRst.MoveFirst
      startMeteringTime           = objRst.Fields("dt_crt")
      objRst.MoveLast
      endPipeLineProcessingTime   = objRst.Fields("dt_crt")

      MPFM.Trace "Statistics ready."

      PropertyBag.Value("Statistic.TransactionCount")      = objRst.RecordCount
      PropertyBag.Value("Statistic.overAllProcessingTime") = DateDiff("s",startMeteringTime,endPipeLineProcessingTime)

      If CLng(PropertyBag.Value("Statistic.OverAllProcessingTime"))>0 Then
        PropertyBag.Value("Statistic.OverAllAverageProcessingTransactionTime") = CLng(PropertyBag.Value("Statistic.TransactionCount"))/CLng(PropertyBag.Value("Statistic.OverAllProcessingTime"))
      Else
        mpfm.Trace "Cannot compute transaction/s because there were not enough transactions metered. Process time is less than one second time", mpfmERROR
        PropertyBag.Value("Statistic.OverAllAverageProcessingTransactionTime") = -1 ' Invalid value
      End If

      MPFM.Trace "MeterTransaction.StartTime:"        & PropertyBag.Value("MeterTransaction.StartTime")
      MPFM.Trace "MeterTransaction.EndTime:"          & PropertyBag.Value("MeterTransaction.EndTime")

      MPFM.Trace "Statistic.TransactionCount:"        & PropertyBag.Value("Statistic.TransactionCount")
      MPFM.Trace "Statistic.OverAllProcessingTime:"   & PropertyBag.Value("Statistic.OverAllProcessingTime") & "s"
      MPFM.Trace "Statistic.OverAllAverageProcessingTransactionTime:"   & PropertyBag.Value("Statistic.OverAllAverageProcessingTransactionTime") & "/s"

      strCSV = strCSV & PropertyBag.Value("MeterTransaction.LocalEndTime") & ","
      strCSV = strCSV & PropertyBag.Value("MeterTransaction.LocalStartTime") & ","
      strCSV = strCSV & PropertyBag.Value("MeterTransaction.EndTime") & ","
      strCSV = strCSV & PropertyBag.Value("MeterTransaction.StartTime") & ","
      strCSV = strCSV & PropertyBag.Value("Statistic.TransactionCount") & ","
      strCSV = strCSV & PropertyBag.Value("Statistic.OverAllAverageProcessingTransactionTime") & ","

      MPFM.TextFile.LogFile MPFM.Environ("TEMP") & "\mpfm.result.csv", strCSV

      Statistic = TRUE
   END FUNCTION
END CLASS

Dim MPFMClient
Set MPFMClient = New CMPFMClient


