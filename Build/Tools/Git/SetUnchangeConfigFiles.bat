@pushd %MTEXTENSIONS%

@echo Adding servers.xml and other config files to ingnore list

@pushd %MTEXTENSIONS%\..\config\ServerAccess
git update-index --assume-unchanged servers.xml
git update-index --assume-unchanged protectedpropertylist.xml
@popd

@pushd %MTEXTENSIONS%\PaymentSvr\config\Gateway
git update-index --assume-unchanged WorldPayConfig.xml
@popd

@pushd %MTEXTENSIONS%\PaymentSvrClient\config\ServerAccess
git update-index --assume-unchanged servers.xml
@popd

@pushd %MTEXTENSIONS%\Reporting\Config\ServerAccess
git update-index --assume-unchanged servers.xml
@popd

@pushd %MTEXTENSIONS%\SmokeTest\config\ServerAccess
git update-index --assume-unchanged servers.xml
@popd

@pushd %MTEXTENSIONS%\TaxWare\config\ServerAccess
git update-index --assume-unchanged servers.xml
@popd

@pushd %ROOTDIR%/utils/MSIX2SQL
git update-index --assume-unchanged msix2sql.vbp
@popd

@pushd %ROOTDIR%/utils/QuickConfig/
git update-index --assume-unchanged QuickConfig.vbp
@popd

@echo DONE!

@popd

if NOT "%1%"=="skip_pause" (
@pause
)

