#include <sstream>
#include "DesignTimeCodeGeneratedComposite.h"
#include "DatabaseCatalog.h"
#include "UsageLoader.h"
#include "ScriptInterpreter.h"

#import <GenericCollection.tlb>
#import <mscorlib.tlb> rename("ReportEvent", "MSReportEvent") rename ("_Module", "_ModuleCorlib")
#import <MetraTech.Dataflow.Template.tlb> inject_statement("using namespace mscorlib;")

std::wstring DesignTimeCodeGeneratedComposite::GenerateCompositeName(const std::wstring& compositeInstanceName)
{
  // For the moment, we guarantee uniqueness.
  DatabaseCommands cmds;
  return cmds.GetTempTableName(compositeInstanceName);
}

DesignTimeCodeGeneratedComposite::DesignTimeCodeGeneratedComposite(const std::wstring& compositeInstanceName)
  :
  DesignTimeComposite(GenerateCompositeName(compositeInstanceName))
{
}

DesignTimeCodeGeneratedComposite::~DesignTimeCodeGeneratedComposite()
{
}

DesignTimeAccountResolution::DesignTimeAccountResolution(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName),
  mMode(EXTERNAL),
  mNamespaceValueType(FIELD_REFERENCE),
  mTimestampField(L"_Timestamp")
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mOutputPorts.push_back(this, L"error", false);
}

DesignTimeAccountResolution::~DesignTimeAccountResolution()
{
}

void DesignTimeAccountResolution::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"identifier", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mPayeeField = arg.getNormalizedString();
  }
  else if (arg.is(L"lookup", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), L"external"))
    {
      mMode = EXTERNAL;
    }
    else if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), L"internal"))
    {
      mMode = INTERNAL;
    }
    else
      throw SingleOperatorException(*this, L"Value of lookup argument is internal or external");
  }
  else if (arg.is(L"namespace", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mNamespace = arg.getNormalizedString();
  }
  else if (arg.is(L"namespaceValueType", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), "fieldReference"))
    {
      mNamespaceValueType = FIELD_REFERENCE;
    }
    else if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), "constant"))
    {
      mNamespaceValueType = CONSTANT;
    }
    else
      throw SingleOperatorException(*this, L"Value of namespaceValueType argument is fieldReference or constant");
  }
  else if (arg.is(L"timestamp", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mTimestampField = arg.getNormalizedString();
  }
  else if (arg.is(L"property", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mAccountProperties.push_back(arg.getNormalizedString());
  }
  else if (arg.is(L"as", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mAccountAliases.push_back(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeAccountResolution::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  try
  {
    // Sanity check on argument configuration.
    if (mMode == EXTERNAL && mNamespace.size() == 0)
      throw SingleOperatorException(*this, L"Must specify namespace when looking up account by external identifier");
    if (mMode == INTERNAL && mNamespace.size() > 0)
      throw SingleOperatorException(*this, L"Cannot specify namespace when looking up account by internal identifier");

    // Call over to a template that takes the parameter table list as parameters.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));

    GENERICCOLLECTIONLib::IMTCollectionPtr coll( __uuidof(GENERICCOLLECTIONLib::MTCollection));

    if (mAccountProperties.size() != mAccountAliases.size())
      throw SingleOperatorException(*this, L"Must specify property argument and as argument for every account lookup retrieval property");

    for(std::size_t i = 0; i<mAccountProperties.size(); i++)
    {
      MetraTech_Dataflow_Template::IAccountResolutionBindingPtr b(__uuidof(MetraTech_Dataflow_Template::AccountResolutionBinding));
      b->Name = mAccountProperties[i].c_str();
      b->Alias = mAccountAliases[i].c_str();
      coll->Add(b.Detach());
    }
    std::wstring operatorDef((const wchar_t *)(
                                    t->GetAccountResolutionTemplate(
                                      getCompositeDefinitionName().c_str(),
                                      GetName().c_str(),
                                      mPayeeField.c_str(),
                                      mNamespaceValueType == FIELD_REFERENCE ? mNamespace.c_str() : L"",
                                      mNamespaceValueType == CONSTANT ? mNamespace.c_str() : L"",
                                      mTimestampField.c_str(),
                                      coll.GetInterfacePtr())));

    logger->logDebug(L"AccountResolution script: " + operatorDef);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeSubscriptionResolution::DesignTimeSubscriptionResolution(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName),
  mPriceableItemName(L"_PriceableItemName"),
  mPriceableItemNameValueType(FIELD_REFERENCE),
  mAccountIDField(L"_AccountID"),
  mTimestampField(L"_Timestamp"),
  mPriceableItemTypeIDField(L"_PriceableItemTypeID"),
  mPriceableItemTemplateIDField(L"_PriceableItemTemplateID"),
  mSubscriptionField(L"Subscription")
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mOutputPorts.push_back(this, L"error", false);
}

DesignTimeSubscriptionResolution::~DesignTimeSubscriptionResolution()
{
}

void DesignTimeSubscriptionResolution::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"priceableItemName", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mPriceableItemName = arg.getNormalizedString();
  }
  else if (arg.is(L"priceableItemNameValueType", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), L"fieldReference"))
    {
      mPriceableItemNameValueType = FIELD_REFERENCE;
    }
    else if (boost::algorithm::iequals(arg.getNormalizedString().c_str(), L"constant"))
    {
      mPriceableItemNameValueType = CONSTANT;
    }
    else
      throw SingleOperatorException(*this, L"Value of priceableItemNameValueType argument is fieldReference or constant");
  }
  else if (arg.is(L"accountId", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mAccountIDField = arg.getNormalizedString();
  }
  else if (arg.is(L"timestamp", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mTimestampField = arg.getNormalizedString();
  }
  else if (arg.is(L"priceableItemTypeId", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mPriceableItemTypeIDField = arg.getNormalizedString();
  }
  else if (arg.is(L"priceableItemTemplateId", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mPriceableItemTemplateIDField = arg.getNormalizedString();
  }
  else if (arg.is(L"subscription", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mSubscriptionField = arg.getNormalizedString();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeSubscriptionResolution::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  // TODO: Escape ' in priceable item name literal.
  
  // Call over to a template that takes the parameter table list as parameters.
  MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
  
  std::wstring operatorDef((const wchar_t *)(
                                  t->GetSubscriptionResolutionTemplate(
                                    getCompositeDefinitionName().c_str(),
                                    mPriceableItemNameValueType==FIELD_REFERENCE ? mPriceableItemName.c_str() : L"",
                                    mPriceableItemNameValueType==CONSTANT ? mPriceableItemName.c_str() : L"",
                                    mAccountIDField.c_str(),
                                    mTimestampField.c_str(),
                                    mPriceableItemTypeIDField.c_str(),
                                    mPriceableItemTemplateIDField.c_str(),
                                    mSubscriptionField.c_str())));

  logger->logDebug(L"SubscriptionResolution script: " + operatorDef);

  interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                    operatorDef,
                                    mName);
}

DesignTimeRateScheduleResolution::DesignTimeRateScheduleResolution(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName),
  mSubscriptionField(L"Subscription")
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mOutputPorts.push_back(this, L"error", false);
}

DesignTimeRateScheduleResolution::~DesignTimeRateScheduleResolution()
{
}

void DesignTimeRateScheduleResolution::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"parameterTable", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mParameterTables.push_back(arg.getNormalizedString());
  }
  else if (arg.is(L"subscription", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mSubscriptionField = arg.getNormalizedString();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeRateScheduleResolution::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");
  try
  {
    // Call over to a template that takes the parameter table list as parameters.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
    GENERICCOLLECTIONLib::IMTCollectionPtr coll( __uuidof(GENERICCOLLECTIONLib::MTCollection));
    for(std::vector<std::wstring>::const_iterator it = mParameterTables.begin();
        it != mParameterTables.end();
        ++it)
    {
      coll->Add(it->c_str());
    }
  
    std::wstring operatorDef((const wchar_t *)(t->GetRateScheduleResolutionTemplate(
                                                    getCompositeDefinitionName().c_str(),
                                                    GetName().c_str(),
                                                    mSubscriptionField.c_str(),
                                                    coll)));

    logger->logDebug(L"RateScheduleResolution script: " + operatorDef);

    int result = interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                                   operatorDef,
                                                   mName);
    if (result != 0)
    {
      // I am going to log this as WARNING since we really shouldn't allow this to happen.
      logger->logWarning(L"Parse error in code generated composite: " + operatorDef);
      throw SingleOperatorException(*this, L"Parse error in code generated composite: " + operatorDef);
    }
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeRateCalculation::DesignTimeRateCalculation(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName)
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mOutputPorts.push_back(this, L"error", false);
  mIsScheduleUnderParent = false;
}

DesignTimeRateCalculation::~DesignTimeRateCalculation()
{
}

void DesignTimeRateCalculation::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"parameterTable", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mParameterTable = arg.getNormalizedString();
  }
  else if (arg.is(L"IsScheduleUnderParent", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mIsScheduleUnderParent = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeRateCalculation::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  try
  {
    // Call over to a template that takes the parameter table as its parameter.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
    std::wstring operatorDef((const wchar_t *)(t->GetRateApplicationTemplate(getCompositeDefinitionName().c_str(),
                                                                               GetName().c_str(),
                                                                               mParameterTable.c_str(),
									       mIsScheduleUnderParent)));

    logger->logDebug(L"RateCalculation script: " + operatorDef);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeWriteProductView::DesignTimeWriteProductView(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName)
{
  mInputPorts.push_back(this, L"input", false);
  mOutputPorts.push_back(this, L"output", false);
  mOutputPorts.push_back(this, L"error", false);
  mIsMultipointParent = false;
  mIsMultipointChild = false;
}

DesignTimeWriteProductView::~DesignTimeWriteProductView()
{
}

void DesignTimeWriteProductView::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"productView", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mProductViewName = arg.getNormalizedString();
  }
  else if (arg.is(L"multipoint", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mIsMultipointParent = arg.isValue(L"parent");
    mIsMultipointChild  = arg.isValue(L"child");
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeWriteProductView::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  try
  {
    // Call over to a template that takes the parameter table as its parameter.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
    std::wstring operatorDef((const wchar_t *)(t->GetWriteProductViewTemplate(getCompositeDefinitionName().c_str(),
                                                                                GetName().c_str(),
                                                                                mProductViewName.c_str(),
                                                                                mIsMultipointParent,
										mIsMultipointChild)));

    logger->logDebug(L"WriteProductView Script: " + operatorDef);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeWriteError::DesignTimeWriteError(const std::wstring& compositeInstanceName,
                                           boost::int32_t numInputs)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName),
  mNumInputs(numInputs)
{
  for(boost::int32_t i = 0; i<mNumInputs; i++)
  {
    mInputPorts.push_back(this, (boost::wformat(L"input_%1%") % i).str(), false);
  }
}

DesignTimeWriteError::~DesignTimeWriteError()
{
}

void DesignTimeWriteError::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"service", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mServiceDefinitionName = arg.getNormalizedString();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeWriteError::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  try
  {
    // Call over to a template that takes the parameter table as its parameter.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
    std::wstring operatorDef((const wchar_t *)(t->GetWriteErrorTemplate(getCompositeDefinitionName().c_str(),
                                                                          mServiceDefinitionName.c_str(),
                                                                          mNumInputs)));

    logger->logDebug(L"WriteError Script: " + operatorDef);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeLoadError::DesignTimeLoadError(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName)
{
  mInputPorts.push_back(this, L"message", false);
  mInputPorts.push_back(this, L"session_set", false);
  mInputPorts.push_back(this, L"failed_transaction", false);
  mInputPorts.push_back(this, L"service", false);
}

DesignTimeLoadError::~DesignTimeLoadError()
{
}

void DesignTimeLoadError::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"service", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mServiceDefinitionName = arg.getNormalizedString();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeLoadError::expand(DataflowScriptInterpreter& interpreter)
{
  MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("DesignTimeCodeGeneratedComposite");

  try
  {
    // Call over to a template that takes the parameter table as its parameter.
    MetraTech_Dataflow_Template::IOperatorTemplateFactoryPtr t(__uuidof(MetraTech_Dataflow_Template::OperatorTemplateFactory));
    std::wstring operatorDef((const wchar_t *)(t->GetLoadErrorTemplate(getCompositeDefinitionName().c_str(),
                                                                         mServiceDefinitionName.c_str())));

    logger->logDebug(L"LoadError Script: " + operatorDef);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}

DesignTimeUsageLoader::DesignTimeUsageLoader(const std::wstring& compositeInstanceName)
  :
  DesignTimeCodeGeneratedComposite(compositeInstanceName),
  mCommitSize(50000),
  mBatchSize(50000),
  mUseMerge(false)
{
  mInputPorts.push_back(this, L"input", false);
}

DesignTimeUsageLoader::~DesignTimeUsageLoader()
{
}

void DesignTimeUsageLoader::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"productView", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    mProductViewName=arg.getNormalizedString();
  }
  else if (arg.is(L"commitSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    mCommitSize = arg.getIntValue();
  }
  else if (arg.is(L"batchSize", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    mBatchSize = arg.getIntValue();
  }
  else if (arg.is(L"merge", OPERATOR_ARG_TYPE_BOOLEAN, GetName()))
  {
    mUseMerge = arg.getBoolValue();
  }
  else
  {
    handleCommonArg(arg);
  }
}

void DesignTimeUsageLoader::expand(DataflowScriptInterpreter& interpreter)
{
  try
  {
    std::string utf8PV;
    ::WideStringToUTF8(mProductViewName, utf8PV);
    std::string utf8Name;
    ::WideStringToUTF8(getCompositeDefinitionName(), utf8Name);
    std::string foo = ::GenerateLoaderEx("", 
                                     utf8PV, 
                                     mCommitSize, 
                                     mBatchSize, 
                                     mUseMerge, 
                                     utf8Name);
    std::wstring operatorDef;
    ::ASCIIToWide(operatorDef, foo.c_str(), -1, CP_UTF8);

    interpreter.codeGenerateComposite(getCompositeDefinitionName(),
                                      operatorDef,
                                      mName);
  }
  catch(_com_error & err)
  {
    throw SingleOperatorException(*this, (const wchar_t *) err.Description());
  }
}
