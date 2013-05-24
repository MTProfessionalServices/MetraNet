#ifndef __DESIGNTIMECODEGENERATEDCOMPOSITE_H__
#define __DESIGNTIMECODEGENERATEDCOMPOSITE_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

class DataflowScriptInterpreter;

#include "DesignTimeComposite.h"
#include "CompositeDictionary.h"

class DesignTimeCodeGeneratedComposite : public DesignTimeComposite
{
private:
  static std::wstring GenerateCompositeName(const std::wstring& compositeInstanceName);

public:
  /**
   * Create the code generated composite.  Unlike script based composites,
   * each instance of a code generated composite has its own composite name.
   * The reason for this is that the CompositeDefinitionName from the DesignTimeComposite
   * identifies the composite definition that is instantiated into the referring plan.
   * For code generated composites, the composite definition depends on the arguments
   * set in the instance of the composite.  In principle, two instances of a code generated
   * composite that have identical argument values SHOULD be able to share the same 
   * composite definition (and hence CompositeDefinitionName); if not there is non-determinism
   * in the definition of the composite.  There is little to gain in trying to implement sharing
   * in these circumstances and there may even be permissible circumstances for non-determinism
   * (e.g. use of current timestamp) so we don't attempt it.  Thus every instance of code generated
   * composite gets a unique name.
   *
   * TODO: An open question is whether input port and output ports needs to be setup in the
   * constructor.  It would be nice (and perhaps necessary) for configuration of ports to be
   * done only after arguments are all set.  I suspect that we can wait till expand time to
   * setup port configuration.
   */
  METRAFLOW_DECL DesignTimeCodeGeneratedComposite(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeCodeGeneratedComposite();

  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg) =0;

  /**
   * Generate the composite definition based on the set of configured parameters.
   * Tenatively we also set up port specifications at this point as well.
   * Call back into the interpreter to make it aware of the composite definition.
   */
  METRAFLOW_DECL virtual void expand(DataflowScriptInterpreter& interpreter) =0;
};

class DesignTimeAccountResolution : public DesignTimeCodeGeneratedComposite
{
private:
  enum Mode { INTERNAL, EXTERNAL };

  enum BindingValueType { FIELD_REFERENCE, CONSTANT };

  /**
   * Are we looking up account by internal identifer or external name?
   */
  Mode mMode;
  /**
   * Binding to field containing name of payee (if resolving by name) otherwise binding
   * to field containing internal account identifier.
   */
  std::wstring mPayeeField;
  /**
   * Namespace of payee (if resolving by name).
   */
  std::wstring mNamespace;
  /**
   * Describes whether namespace value is a constant or field reference (if resolving by name).
   */
  BindingValueType mNamespaceValueType;
  /**
   * Binding to field containing timestamp (if resolving payer and/or accountstate).
   */
  std::wstring mTimestampField;
  /**
   * Account view binders
   */
  std::vector<std::wstring> mAccountProperties;
  std::vector<std::wstring> mAccountAliases;

public:
  METRAFLOW_DECL DesignTimeAccountResolution(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeAccountResolution();

  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeSubscriptionResolution : public DesignTimeCodeGeneratedComposite
{
public:
  enum BindingValueType { FIELD_REFERENCE, CONSTANT };

private:
  std::wstring mPriceableItemName;
  BindingValueType mPriceableItemNameValueType;
  std::wstring mAccountIDField;
  std::wstring mTimestampField;
  std::wstring mPriceableItemTypeIDField;
  std::wstring mPriceableItemTemplateIDField;
  std::wstring mSubscriptionField;
  
public:
  METRAFLOW_DECL DesignTimeSubscriptionResolution(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeSubscriptionResolution();

  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeRateScheduleResolution : public DesignTimeCodeGeneratedComposite
{
private:
  std::vector<std::wstring> mParameterTables;
  std::wstring mSubscriptionField;

public:
  METRAFLOW_DECL DesignTimeRateScheduleResolution(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeRateScheduleResolution();

  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeRateCalculation : public DesignTimeCodeGeneratedComposite
{
private:
  std::wstring mParameterTable;

  /** If true, schedule information is in record parent. */
  bool mIsScheduleUnderParent;

public:
  METRAFLOW_DECL DesignTimeRateCalculation(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeRateCalculation();

  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeWriteProductView : public DesignTimeCodeGeneratedComposite
{
private:
  std::wstring mProductViewName;

  bool mIsMultipointParent;
  bool mIsMultipointChild;

public:
  METRAFLOW_DECL DesignTimeWriteProductView(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeWriteProductView();

  virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeWriteError : public DesignTimeCodeGeneratedComposite
{
private:
  std::wstring mServiceDefinitionName;
  boost::int32_t mNumInputs;

public:
  METRAFLOW_DECL DesignTimeWriteError(const std::wstring& compositeInstanceName,
                                      boost::int32_t numInputs);

  METRAFLOW_DECL ~DesignTimeWriteError();

  virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeUsageLoader : public DesignTimeCodeGeneratedComposite
{
private:
  std::wstring mProductViewName;
  boost::int32_t mCommitSize;
  boost::int32_t mBatchSize;
  bool mUseMerge;

public:
  METRAFLOW_DECL DesignTimeUsageLoader(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeUsageLoader();

  virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

class DesignTimeLoadError : public DesignTimeCodeGeneratedComposite
{
private:
  std::wstring mServiceDefinitionName;

public:
  METRAFLOW_DECL DesignTimeLoadError(const std::wstring& compositeInstanceName);

  METRAFLOW_DECL ~DesignTimeLoadError();

  virtual void handleArg(const OperatorArg& arg);

  METRAFLOW_DECL void expand(DataflowScriptInterpreter& interpreter);
};

#endif
