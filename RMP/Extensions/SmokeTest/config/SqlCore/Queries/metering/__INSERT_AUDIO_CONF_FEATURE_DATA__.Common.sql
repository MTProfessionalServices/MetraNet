
/* ===========================================================
Insert data.
============================================================== */
  insert into mt_audioconffeature 
       (c_ConferenceID,
        c_Payer,
        c_FeatureType,
        c_Metric,
        c_StartTime,
        c_EndTime,
        c_TransactionID,
        c_Duration,
        c_MetricCharge,
        c_RoundedDuration,
        c_SetupCharge,
        c_TimeBasedCharge,
        c_GLCode) 
       values 
       (%%CONFERENCE_ID%%,
        '%%ACCOUNT_NAME%%', -- 'Brushes001',
        'Polling',
        10.000000,
        %%START_TIME%%,
        %%%SYSTEMDATE%%%,
        %%%SYSTEMDATE%%%,
        1800,
        .000000,
        86400,
        7.000000,
        .000000,
        '%%TEST_NAME%%')
      
 