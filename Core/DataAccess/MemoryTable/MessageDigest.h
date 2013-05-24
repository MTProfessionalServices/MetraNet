#ifndef __MESSAGEDIGEST_H__
#define __MESSAGEDIGEST_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

// Perhaps cleaner would be to add varargs support to MTSQL and then
// implement this as a function.

#include "MetraFlowConfig.h"
#include "Scheduler.h"

class DesignTimeMD5Hash : public DesignTimeOperator
{
private:
  std::vector<std::wstring> mHashKeys;
  std::wstring mOutputKey;

public:
  METRAFLOW_DECL DesignTimeMD5Hash();
  METRAFLOW_DECL ~DesignTimeMD5Hash();

  METRAFLOW_DECL void AddHashKey(const std::wstring& hashKey);
  METRAFLOW_DECL void SetOutputKey(const std::wstring& outputKey);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeMD5Hash* clone(
                                   const std::wstring& name,
                                   std::vector<OperatorArg*>& args, 
                                   int nInputs, int nOutputs) const;
};

class RunTimeMD5Hash : public RunTimeOperator
{
public:
  friend class RunTimeMD5HashActivation;
private:
  RecordMetadata mInputMetadata;
  RecordMetadata mOutputMetadata;
  RecordProjection mProjection;
  std::vector<RunTimeDataAccessor *> mHashKeys;
  RunTimeDataAccessor * mOutputKey;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mInputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mOutputMetadata);
    ar & BOOST_SERIALIZATION_NVP(mProjection);
    ar & BOOST_SERIALIZATION_NVP(mHashKeys);
    ar & BOOST_SERIALIZATION_NVP(mOutputKey);
  } 

  METRAFLOW_DECL RunTimeMD5Hash();
  
public:
  METRAFLOW_DECL RunTimeMD5Hash (const RecordMetadata& inputMetadata,
                                 const RecordMetadata& outputMetadata,
                                 const std::vector<std::wstring>& hashKeys,
                                 const std::wstring& outputKeys);
  METRAFLOW_DECL ~RunTimeMD5Hash();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeMD5HashActivation : public RunTimeOperatorActivationImpl<RunTimeMD5Hash>
{
private:
  // Runtime values
  enum State { START, READ_0, WRITE_0, WRITE_EOF_0 };
  State mState;
  MessagePtr mBuffer;

public:
  METRAFLOW_DECL RunTimeMD5HashActivation(Reactor * reactor, 
                                          partition_t partition, 
                                          RunTimeMD5Hash * runTimeOperator);
  METRAFLOW_DECL ~RunTimeMD5HashActivation();
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
