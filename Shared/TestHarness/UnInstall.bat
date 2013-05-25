regsvr32 /u /s MTTestDatabase.dll
regasm MetraTech.QA.TestHarness.CommentParser.dll /unregister
regasm MetraTech.QA.Tools.dll /unregister
mttestapi /unRegServer