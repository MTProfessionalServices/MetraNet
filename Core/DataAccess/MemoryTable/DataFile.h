#ifndef __DATAFILE_H__
#define __DATAFILE_H__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
# pragma once
#endif

#include "MetraFlowConfig.h"
#include "Scheduler.h"
#include "ImportFunction.h"
#include "RecordParser.h"
#include "StdioBuffer.h"

class DesignTimeDataFileScan : public DesignTimeOperator
{
private:
  std::wstring mFilename;

public:
  METRAFLOW_DECL DesignTimeDataFileScan();
  METRAFLOW_DECL ~DesignTimeDataFileScan();

  METRAFLOW_DECL void SetFilename(const std::wstring& filename);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDataFileScan* clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args,
                                        int nInputs, int nOutputs) const;
};

template <class _Buffer>
class RunTimeDataFileScan : public RunTimeOperator
{
public:
  // TODO: Find out how to do friend with a template
// private:
  RecordMetadata mMetadata;
  std::wstring mFilename;
  boost::int32_t mViewSize;
  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mFilename);
    ar & BOOST_SERIALIZATION_NVP(mViewSize);
  } 

  METRAFLOW_DECL RunTimeDataFileScan();
  
public:
  METRAFLOW_DECL RunTimeDataFileScan (const std::wstring& name, 
                                      const RecordMetadata& metadata,
                                      const std::wstring& filename,
                                      boost::int32_t viewSize);
  METRAFLOW_DECL ~RunTimeDataFileScan();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _Buffer>
class RunTimeDataFileScanActivation : public RunTimeOperatorActivationImpl<RunTimeDataFileScan<_Buffer> >
{
private:
  enum State { START, WRITE_0 };
  typename _Buffer::file_type * mFileMapping;
  _Buffer * mStream;
  // Importers for all records
  std::vector<RecordDeserializerInstruction> mInstructions;  
  State mState;
  // The output message
  MessagePtr mOutputRecord;

  void Deserialize(record_t recordBuffer, _Buffer& buffer);
public:
  METRAFLOW_DECL RunTimeDataFileScanActivation (Reactor * reactor, 
                                                partition_t partition,
                                                const RunTimeDataFileScan<_Buffer> * runTimeOperator);
  METRAFLOW_DECL ~RunTimeDataFileScanActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeDataFileExport : public DesignTimeOperator
{
private:
  std::wstring mFilename;

public:
  METRAFLOW_DECL DesignTimeDataFileExport();
  METRAFLOW_DECL ~DesignTimeDataFileExport();

  METRAFLOW_DECL void SetFilename(const std::wstring& filename);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDataFileExport* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg*>& args, 
                                          int nInputs, int nOutputs) const;
};

template <class _Buffer>
class RunTimeDataFileExport : public RunTimeOperator
{
public:
  // TODO: find out how declare a template as friend
// private:
  RecordMetadata mMetadata;
  std::wstring mFilename;
  boost::int32_t mViewSize;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mFilename);
    ar & BOOST_SERIALIZATION_NVP(mViewSize);
  } 
  METRAFLOW_DECL RunTimeDataFileExport();
  
public:
  METRAFLOW_DECL RunTimeDataFileExport(const std::wstring& name, 
                                       const RecordMetadata& metadata,
                                       const std::wstring& filename,
                                       boost::int32_t viewSize);
  METRAFLOW_DECL ~RunTimeDataFileExport();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

template <class _Buffer>
class RunTimeDataFileExportActivation : public RunTimeOperatorActivationImpl<RunTimeDataFileExport<_Buffer> >
{
private:
  enum State { START, READ_0 };
  typename _Buffer::file_type * mFileMapping;
  _Buffer * mStream;
  std::vector<RecordSerializerInstruction> mInstructions;  
  State mState;
  void Export(const_record_t recordBuffer, _Buffer& buffer);
public:
  METRAFLOW_DECL RunTimeDataFileExportActivation(Reactor * reactor, 
                                                 partition_t partition,
                                                 const RunTimeDataFileExport<_Buffer> * runTimeOperator);
  METRAFLOW_DECL ~RunTimeDataFileExportActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeDataFileDelete : public DesignTimeOperator
{
private:
  std::wstring mFilename;

public:
  METRAFLOW_DECL DesignTimeDataFileDelete();
  METRAFLOW_DECL ~DesignTimeDataFileDelete();

  METRAFLOW_DECL void SetFilename(const std::wstring& filename);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDataFileDelete* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const;
};

class RunTimeDataFileDelete : public RunTimeOperator
{
public: 
  friend class RunTimeDataFileDeleteActivation;

private:
  std::wstring mFilename;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mFilename);
  } 
  METRAFLOW_DECL RunTimeDataFileDelete();
  
public:
  METRAFLOW_DECL RunTimeDataFileDelete(const std::wstring& name, 
                                       const std::wstring& filename);
  METRAFLOW_DECL ~RunTimeDataFileDelete();
  
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeDataFileDeleteActivation : public RunTimeOperatorActivationImpl<RunTimeDataFileDelete>
{
public:
  METRAFLOW_DECL RunTimeDataFileDeleteActivation(Reactor * reactor, 
                                                 partition_t partition,
                                                 const RunTimeDataFileDelete * runTimeOperator);
  METRAFLOW_DECL ~RunTimeDataFileDeleteActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

class DesignTimeDataFileRename : public DesignTimeOperator
{
private:
  std::wstring mFrom;
  std::wstring mTo;

public:
  METRAFLOW_DECL DesignTimeDataFileRename();
  METRAFLOW_DECL ~DesignTimeDataFileRename();

  METRAFLOW_DECL void SetFrom(const std::wstring& filename);
  METRAFLOW_DECL void SetTo(const std::wstring& filename);
  METRAFLOW_DECL void type_check();
  METRAFLOW_DECL RunTimeOperator * code_generate(partition_t maxPartition);  

  /** Handle the given operator argument specifying operator behavior. */
  METRAFLOW_DECL virtual void handleArg(const OperatorArg& arg);

  /** Clone the initial configured state of an operator. */
  METRAFLOW_DECL virtual DesignTimeDataFileRename* clone(
                                          const std::wstring& name,
                                          std::vector<OperatorArg *>& args, 
                                          int nInputs, int nOutputs) const;
};

class RunTimeDataFileRename : public RunTimeOperator
{
public: 
  friend class RunTimeDataFileRenameActivation;

private:
  std::wstring mFrom;
  std::wstring mTo;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mFrom);
    ar & BOOST_SERIALIZATION_NVP(mTo);
  } 
  METRAFLOW_DECL RunTimeDataFileRename();
  
public:
  METRAFLOW_DECL RunTimeDataFileRename(const std::wstring& name, 
                                       const std::wstring& from,
                                       const std::wstring& to);
  METRAFLOW_DECL ~RunTimeDataFileRename();
  
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeDataFileRenameActivation : public RunTimeOperatorActivationImpl<RunTimeDataFileRename>
{
public:
  METRAFLOW_DECL RunTimeDataFileRenameActivation(Reactor * reactor, 
                                                 partition_t partition,
                                                 const RunTimeDataFileRename * runTimeOperator);
  METRAFLOW_DECL ~RunTimeDataFileRenameActivation();
  
  METRAFLOW_DECL void Start();
  METRAFLOW_DECL void HandleEvent(Endpoint * ep);
};

#endif
