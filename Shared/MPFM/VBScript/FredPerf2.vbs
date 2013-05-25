' -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
'
' NAME   : Fred Performance MetraTech Performance Class Plug In
'
' -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

'
' MPFM Constants
'
PUBLIC CONST MPFM_SQL_1000 = "select dt_crt from t_acc_usage where id_sess >= '[ID_SESSION]' order by id_sess asc"
PUBLIC CONST MPFM_SQL_1001 = "select max(id_sess) max from t_acc_usage"
PUBLIC CONST MPFM_SQL_1002 = "select * from t_perfresults"

PUBLIC CONST MPFM_MAX_RMP_SERVER                      = 2
PUBLIC CONST MPFM_CLIENT_WAIT_FOR_PIPELINE_SLEEP_TIME = 3000
PUBLIC CONST MPFM_MAX_ATTEMPT_TO_SEND_BATCH           = 10

INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CDB.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\MetraTech.Test.Library.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CTest.vbs"
INCLUDE MPFM.Environ("MetratechTestDatabase") & "\VBScript.Library\CPropertyBag.vbs"

'
' Constants related to the tests
'
PUBLIC CONST MAX_BATCH                            = 1
PUBLIC CONST MAX_TRANSACTION_PER_BATCH            = 10
PUBLIC CONST ACCOUNT_ID_START_RANGE               = 110
PUBLIC CONST ACCOUNT_ID_END_RANGE                 = 50000000
PUBLIC CONST BATCH_ID_PREFIX                      = "usagetest"

PUBLIC CONST MPFM_ACCOUNT_ID_START_RANGE = 200
PUBLIC CONST MPFM_ACCOUNT_ID_END_RANGE   = 1000000

PUBLIC CONST MT_ERR_SERVER_BUSY = &HE1300026

CLASS CMPFMClient

   Public PropertyBag, Synchronous
   Public staOverAllProcessingTime

   PRIVATE SUB Class_Initialize()

      Synchronous = FALSE
      Set PropertyBag = New CPropertyBag
      PropertyBag.Initialize MPFM.ScriptFileNameOnly

      DEFAULT_SQLSERVER = "pdc"
      MetraTech.OpenDatabase
   END SUB
   PRIVATE SUB Class_Terminate()

   END SUB

  PUBLIC FUNCTION CommitBatch(objBatch)

      Dim lngSleepTime, lngSleepIncrement, lngAttempt, lngErrNum, strErrDesc

      lngSleepTime       = 5
      lngSleepIncrement  = 5
      lngAttempt         = 1
      CommitBatch        = FALSE

      Do
          On Error Resume Next
          objBatch.Close
          If Err.Number Then
              If Err.Number <> MT_ERR_SERVER_BUSY Then ' don't know what this is, reraise it

                 lngErrNum  = Err.Number
                 strErrDesc = Err.Description
                 On Error Goto 0
                 Err.Raise lngErrNum, "VBScript" , strErrDesc
              End If
          Else
              CommitBatch = TRUE
              Exit Do
          End If


          mpfm.Trace  "Commiting Batch - Attempt " & attempt & " - server is busy - sleeping " & sleepTime & " seconds"
          mpfm.Sleep(lngSleepTime * 1000)
          lngSleepTime = lngSleepTime + lngSleepIncrement ' next time wait longer
          lngAttempt   = lngAttempt + 1

          If lngAttempt > MPFM_MAX_ATTEMPT_TO_SEND_BATCH Then Exit Do ' The function will return false we give up
      Loop
  END FUNCTION

   PRIVATE FUNCTION IsAllTransactionProcessed(lngMaxTransaction)

      Dim strSQL,objRst, startMeteringTime, endPipeLineProcessingTime

      strSQL = PreProcess(MPFM_SQL_1000,Array("ID_SESSION",PropertyBag.Value("MeterTransaction.MaxSessionIDBefore")))

      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())

      If lngMaxTransaction Then

         mpfm.Trace "" & (objRst.RecordCount/lngMaxTransaction*100) & "% of the transaction were processed by the pipeline..."
      End If
      IsAllTransactionProcessed = CBool( objRst.RecordCount >= lngMaxTransaction )
   END FUNCTION

   PUBLIC FUNCTION GetMaxTAccUsageSessionID()

      Dim objRst, strSQL

      strSQL = MPFM_SQL_1001

      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())

      GetMaxTAccUsageSessionID = objRst.Fields("max")
   END FUNCTION


   PUBLIC FUNCTION MeterTransaction(lngMaxMetering)

     Dim i, lngServerIndex, lngTransactionIndex, lngBatchIndex, objMeter, objBatch, objSession, lngCurrentAccountID

     MeterTransaction = FALSE

     ' Init the SDK
     lngTransactionIndex  = 1
     Set objMeter         = CreateObject("MetraTechSDK.Meter")
     objMeter.HTTPTimeout = 30
     objMeter.HTTPRetries = 9
     objMeter.AddServer 0, "berlin", 80, 0, "", ""
     objMeter.Startup

     PropertyBag.Clear
     PropertyBag.Value("MeterTransaction.MaxSessionIDBefore") = GetMaxTAccUsageSessionID()
     PropertyBag.Value("MeterTransaction.StartTime")          = MetraTech.GMTNow()
     PropertyBag.Value("MeterTransaction.LocalStartTime")     = Now()

     For lngBatchIndex = 1 To MAX_BATCH

          Set objBatch = objMeter.CreateBatch()

          For i = lngTransactionIndex to MAX_TRANSACTION_PER_BATCH

                Set objSession = objBatch.CreateSession("SAndPDemo/HostedExchange1")

                objSession.RequestResponse = Synchronous

                lngCurrentAccountID = RandomLong(MPFM_ACCOUNT_ID_START_RANGE, MPFM_ACCOUNT_ID_END_RANGE)

                objSession.InitProperty "CompanyID"         , lngCurrentAccountID
                objSession.InitProperty "NameSpace"         , "sp300"
                objSession.InitProperty "AccountName"       , "Freddy" ' RandomString(50)
                objSession.InitProperty "PlanID"            , RandomLong(0,5)
                objSession.InitProperty "ChannelID"         , RandomLong(0,5)
                objSession.InitProperty "BatchID"           , Left(BATCH_ID_PREFIX & " on " & now(),25)
                objSession.InitProperty "CurrentUsage"      , RandomFloat(0, 500)

                If MPFM.CancelScript Then Exit Function
          Next
          lngMaxMetering                                  = MAX_BATCH*MAX_TRANSACTION_PER_BATCH
          PropertyBag.Value("Statistic.TransactionCount") = lngMaxMetering
          CommitBatch objBatch
     Next
     MeterTransaction                                       = TRUE
     PropertyBag.Value("MeterTransaction.EndTime")          = MetraTech.GMTNow()
     PropertyBag.Value("MeterTransaction.LocalEndTime")     = Now()

   END FUNCTION

   ' Public interface to implements...
   PUBLIC FUNCTION Run(strParameter)

      Dim i, lngMaxMetering, datTmpDate, datDateDiff, lngTmpTransactionCounter

      Run            = FALSE
      lngMaxMetering = 10 ' InputBox("","Number of transaction to send",10)
      MPFM.Trace "Metering..."

      If Not IsNumeric(lngMaxMetering) Then Exit Function

      If MeterTransaction(lngMaxMetering) Then

          MPFM.Trace "Client metering done, waiting for the pipeline to finish the transaction processing..."

          Do While Not IsAllTransactionProcessed(lngMaxMetering)

              MPFM.Trace "Sleeping a little..."
              MPFM.Sleep MPFM_CLIENT_WAIT_FOR_PIPELINE_SLEEP_TIME
              If MPFM.CancelScript Then Exit Function
          Loop
          Run = Statistic("")
      End If
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


   ' Public interface to implements...
   PUBLIC FUNCTION Export(strParameter)

      Dim strSQL, strS, i, objRst
      strSQL = MPFM_SQL_1002
      STOP
      Set objRst = MetraTech.DB.SqlRun(strSQL,MetraTech.DB.NewRecordSet())


      Do While Not objRst.EOF

         For i=0 to objRst.Fields.Count-1

             strS = strs & objRst.Fields(i).Value & ","
         Next
         strS = strs & vbNewLine
         objRst.MoveNext
      Loop
      mpfm.TextFile.LogFile strParameter,strs,TRUE
   END FUNCTION
END CLASS

Dim MPFMClient
Set MPFMClient = New CMPFMClient


