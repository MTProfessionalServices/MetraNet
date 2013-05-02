delete c:/temp/ncover.*.xml

ncover.console //x c:/temp/ncover.1.xml  nunit-console /fixture:MetraTech.Tax.UnitTests.ParamTable /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.2.xml nunit-console /fixture:MetraTech.Tax.UnitTests.OutputTableTests /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.3.xml nunit-console /fixture:MetraTech.Tax.UnitTests.InputTable /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.4.xml nunit-console /fixture:MetraTech.Tax.UnitTests.ProductMappingTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.5.xml nunit-console /fixture:MetraTech.Tax.UnitTests.ProductCodeMapperTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.6.xml nunit-console /fixture:MetraTech.Tax.UnitTests.BillSoftConfigurationTest /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.7.xml nunit-console /fixture:MetraTech.Tax.UnitTests.DetailTableTests /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.8.xml nunit-console /fixture:MetraTech.Tax.Framework.Test.VendorParamsManagerTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll

ncover.console //x c:/temp/ncover.9.xml nunit-console /fixture:MetraTech.Tax.Taxware.Test.TaxwareTests /assembly:O:\debug\bin\MetraTech.Tax.Taxware.Test.dll

ncover.console //x c:/temp/ncover.10.xml nunit-console /fixture:MetraTech.Tax.UnitTests.BillSoft /assembly:o:\debug\bin\MetraTech.Tax.UnitTests.dll

ncover.console //x c:/temp/ncover.11.xml nunit-console /fixture:MetraTech.Tax.MetraTax.Test.MetraTaxTests /assembly:O:\debug\bin\MetraTech.Tax.MetraTax.Test.dll

ncover.console //x c:/temp/ncover.12.xml nunit-console /fixture:MetraTech.Tax.Framework.Test.AssistantTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll

ncover.console //x c:/temp/ncover.13.xml nunit-console /fixture:MetraTech.Tax.Framework.Test.FrameworkTests /assembly:O:\debug\bin\MetraTech.Tax.Framework.Test.dll

ncover.console //x c:/temp/mstest_coverage.nccov/ncover14.xml "C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\MSTest.exe" o:\debug\bin\VertexSocketConsoleTest.dll /detail:testtype

ncover.reporting.exe c:/temp/ncover.*.xml //s c:/temp/ncoverall.xml


