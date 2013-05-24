@echo press for start
pause
		SET CountTransaction=100
		
		cd TestData
		::creating files FOR CURRENT date
		gsar.exe -s"MMDDYYYY" -r"%DATE:~4,2%/%DATE:~7,2%/%DATE:~-4%" -f subscriptionTemplate.xml Subscription.xml
		gsar.exe -s"YYYYMMDD" -r"%DATE:~-4%-%DATE:~4,2%-%DATE:~7,2%" -f AudioConfCallTemplate.xml AudioConfCall.xml

		net start msmq
		net start iisadmin /y
		net start w3svc
		net start activityservices
		net start pipeline
		net start billingserver
		iisreset /start
		
		@echo  import PO
		pcimportexport -ipo -file "Localized-Audio-Adj-PO-USD.xml" -username su -password su123 -namespace system_user -skipintegrity
		@echo  import subscription
		pcimportexport -is -file "subscription.xml" -username su -password su123 -namespace SYSTEM_USER -skipintegrity
		@echo  meter DATA
		
		
		FOR /L %%i IN (1,1,%CountTransaction%) DO autosdk localhost "AudioConfCall.xml"
		
		
@echo ready
pause