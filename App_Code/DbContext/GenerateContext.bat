set sqlmetal="C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\sqlmetal.exe"

%sqlmetal% /server:. /user:sa /password:MetraTech1 /database:NetMeter /code:MetraNet.DbContext.NetMeter.cs /namespace:MetraNet.DbContext /context:NetMeter /language:csharp
%sqlmetal% /server:. /user:sa /password:MetraTech1 /database:Subscriptiondatamart /code:MetraNet.DbContext.DataMart.cs /namespace:MetraNet.DbContext /context:DataMart /language:csharp
