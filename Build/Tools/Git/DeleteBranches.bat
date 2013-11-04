@pushd "C:\Users\Administrator\Documents\Panels\Git"

@set submoduleName=%1
@if NOT "%submoduleName%" == "develop" set submoduleName=%submoduleName%@MetraNet


@call DeleteBranch C:\dev\MetraNet %1


@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\MvmAmp %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\MvmCore %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Samples %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Tenants %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\UI %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\WebServices %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\AR %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\ARSample %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\Account %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\AudioConf %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\BillSoft %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\Core %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\DataExport %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\GSMSample %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\MetraTax %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\MetraView %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\PageNav %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\PaymentSvr %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\PaymentSvrClient %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\Reporting %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\SMS %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\SmokeTest %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\SystemConfig %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\Tax %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\TaxWare %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\VertexQ %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\pcsample %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\test %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\workspace %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\config %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\ICE_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\Legacy_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\TestSystem_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\FunctionalTests_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\coreQA_Source_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\TestsDatabase_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\MvmCore_Internal %submoduleName%
@call DeleteBranch C:\dev\MetraNet\DevOps\mtDevOps %submoduleName%
@call DeleteBranch C:\dev\MetraNet\DevOps\PuppetModules %submoduleName%
@call DeleteBranch C:\dev\MetraNet\RMP\Extensions\ExpressionEngine_Internal %submoduleName%



@popd

@pause
