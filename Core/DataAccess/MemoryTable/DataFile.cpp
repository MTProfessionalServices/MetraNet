#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/format.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/fstream.hpp>
#include <boost/algorithm/string/find.hpp>
#include "DataFile.h"
#include "MTUtil.h"
#include "OperatorArg.h"

class ParallelFilePath
{
private:
  std::wstring mFilePartitionPattern;
  std::wstring mFileHeader;
public:
  ParallelFilePath(const std::wstring& parallelFile);
  ~ParallelFilePath();
  std::wstring GetPartitionFile(boost::int32_t partition) const;
  std::wstring GetHeaderFile() const;
};

ParallelFilePath::ParallelFilePath(const std::wstring& parallelFile)
{
  if (boost::algorithm::find_last(parallelFile, L"%1%"))
  {
    mFilePartitionPattern = parallelFile;
    mFileHeader = (boost::wformat(parallelFile) % L"header").str();
  }
  else
  {
    boost::filesystem::wpath filePath(parallelFile);
    mFilePartitionPattern = ((filePath.parent_path() / 
                              boost::filesystem::wpath(filePath.stem() + L"_%1%" + filePath.extension()))).string();
    mFileHeader = parallelFile;
  }
}

ParallelFilePath::~ParallelFilePath()
{
}

std::wstring ParallelFilePath::GetPartitionFile(boost::int32_t partition) const
{
  return (boost::wformat(mFilePartitionPattern) % partition).str();
}

std::wstring ParallelFilePath::GetHeaderFile() const
{
  return mFileHeader;
}

DesignTimeDataFileScan::DesignTimeDataFileScan()
{
  mOutputPorts.insert(this, 0, L"output", false);
}

DesignTimeDataFileScan::~DesignTimeDataFileScan()
{
}

void DesignTimeDataFileScan::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"filename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFilename(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDataFileScan* DesignTimeDataFileScan::clone(
                                    const std::wstring& name,
                                    std::vector<OperatorArg *>& args, 
                                    int nInputs, int nOutputs) const
{
  DesignTimeDataFileScan* result = new DesignTimeDataFileScan();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDataFileScan::SetFilename(const std::wstring& filename)
{
  mFilename=filename;
}

void DesignTimeDataFileScan::type_check()
{
  ParallelFilePath pfp(mFilename);
  // Get the metadata from the header of the file.
  std::wstring headerFile = pfp.GetHeaderFile();
  boost::filesystem::wpath completeHeaderPath = boost::filesystem::system_complete<boost::filesystem::wpath>(headerFile);
  if (!boost::filesystem::exists(completeHeaderPath))
  {
    throw SingleOperatorException(*this, (boost::wformat(L"MetraFlow file header '%1%' does not exist") % 
                                          completeHeaderPath).str());
  }
  boost::filesystem::ifstream ifs(headerFile, std::ios_base::in);
  boost::archive::xml_iarchive oa(ifs);
  RecordMetadata metadata;
  oa >> boost::serialization::make_nvp("format", metadata); 
  mOutputPorts[0]->SetMetadata(new RecordMetadata(metadata));  
}

RunTimeOperator * DesignTimeDataFileScan::code_generate(partition_t maxPartition)
{
  return new RunTimeDataFileScan<StdioReadBuffer<Win32File> >(GetName(), *mOutputPorts[0]->GetMetadata(), mFilename, 1024*128);
//   return new RunTimeDataFileScan<StdioReadBuffer<StdioFile> >(GetName(), *mOutputPorts[0]->GetMetadata(), mFilename, 1024*128);
//   return new RunTimeDataFileScan<PagedParseBuffer<mapped_file> >(GetName(), *mOutputPorts[0]->GetMetadata(), mFilename, 1024*128);
}  

template <class _Buffer>
RunTimeDataFileScan<_Buffer>::RunTimeDataFileScan()
  :
  mViewSize(0)
{
}

template <class _Buffer>
RunTimeDataFileScan<_Buffer>::RunTimeDataFileScan (const std::wstring& name, 
                                                   const RecordMetadata& metadata,
                                                   const std::wstring& filename,
                                                   boost::int32_t viewSize)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mFilename(filename),
  mViewSize(viewSize)
{
}

template <class _Buffer>
RunTimeDataFileScan<_Buffer>::~RunTimeDataFileScan()
{
}
  
template <class _Buffer>
RunTimeOperatorActivation * RunTimeDataFileScan<_Buffer>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDataFileScanActivation<_Buffer>(reactor, partition, this);
}


template <class _Buffer>
RunTimeDataFileScanActivation<_Buffer>::RunTimeDataFileScanActivation (Reactor * reactor, 
                                                                       partition_t partition,
                                                                       const RunTimeDataFileScan<_Buffer> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeDataFileScan<_Buffer> >(reactor, partition, runTimeOperator),
  mFileMapping(NULL),
  mStream(NULL),
  mState(START),
  mOutputRecord(NULL)
{
}

template <class _Buffer>
RunTimeDataFileScanActivation<_Buffer>::~RunTimeDataFileScanActivation()
{
  delete mFileMapping;
  delete mStream;
  if (mOutputRecord) mOperator->mMetadata.Free(mOutputRecord);
}
  
template <class _Buffer>
void RunTimeDataFileScanActivation<_Buffer>::Start()
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<mOperator->mMetadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(mOperator->mMetadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  // Generate the serialization code
  mInstructions.push_back(RecordDeserializerInstruction::DirectMemcpy(mOperator->mMetadata.GetDataOffset()));
  for(std::size_t i=0;i<physicalOrder.size();i++)
  {
    RecordDeserializerInstruction rsi = physicalOrder[i]->GetRecordDeserializerInstruction();
    if (rsi.Ty == RecordDeserializerInstruction::DIRECT_MEMCPY &&
        mInstructions.back().Ty == RecordDeserializerInstruction::DIRECT_MEMCPY)
    {
      // Merge adjacent memcpy's into a single instruction for efficiency.
      mInstructions.back().Len += rsi.Len;
    }
    else
    {
      mInstructions.push_back(rsi);
    }
  }

  // Open for reading.  First test for an empty file since an attempt to
  // create a file mapping for an empty file will fail.  In this case, leave
  // mStream NULL since that will signal that we should write an EOF and exit.
  ParallelFilePath pfp(mOperator->mFilename);
  boost::filesystem::wpath partitionFile(pfp.GetPartitionFile(mPartition));
  partitionFile = boost::filesystem::system_complete(partitionFile);

  if (!boost::filesystem::exists(partitionFile))
  {
    std::string msg;
    ::WideStringToMultiByte(pfp.GetPartitionFile(mPartition),
                            msg,
                            CP_ACP);
    throw std::runtime_error(msg);
  }
  if (!boost::filesystem::is_empty(partitionFile))
  {
    mFileMapping = new typename _Buffer::file_type(pfp.GetPartitionFile(mPartition));
    mStream = new _Buffer(*mFileMapping, mOperator->mViewSize);
  }

  mState = START;
  HandleEvent(NULL);
}

template <class _Buffer>
void RunTimeDataFileScanActivation<_Buffer>::Deserialize(record_t recordBuffer, _Buffer& buffer)
{
  boost::uint8_t * target = recordBuffer;
  boost::uint8_t * buf=NULL;
  for(std::vector<RecordDeserializerInstruction>::iterator it = mInstructions.begin();
      it != mInstructions.end();
      it++)
  {
    switch(it->Ty)
    {
    case RecordDeserializerInstruction::DIRECT_MEMCPY:
      if (buffer.open(it->Len, buf))
      {
        memcpy(target, buf, it->Len);
        target += it->Len;
        buffer.consume(it->Len);
      }
      else
      {
        throw std::runtime_error("file format error");
      }
      break;
    case RecordDeserializerInstruction::ACCESSOR:
    {
      int sz;
      if (buffer.open(sizeof(int), buf))
      {
        memcpy(&sz, buf, sizeof(int));
        buffer.consume(sizeof(int));
        if (-1 != sz)
        {
          if (buffer.open(sz, buf))
          {
            it->Accessor->SetNull(recordBuffer);
            it->Accessor->SetValue(recordBuffer, buf);
            // Increment for the next memcpy (if there is one).
            target += it->Accessor->GetPhysicalFieldType()->GetColumnStorage();
            buffer.consume(sz);
          }
          else
          {
            throw std::runtime_error("file format error");
          }
        }
        else
        {
          it->Accessor->SetNull(recordBuffer);
          // Increment for the next memcpy (if there is one).
          target += it->Accessor->GetPhysicalFieldType()->GetColumnStorage();
        }
      }
      else
      {
        throw std::runtime_error("file format error");
      }
      break;
    }
    }
  }
}

template <class _Buffer>
void RunTimeDataFileScanActivation<_Buffer>::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestWrite(0);
      mState = WRITE_0;
      return;
    case WRITE_0:
    {
      // Check for EOF by trying to open a window of size 1.
      // Handle the case of an empty file which will result in
      // mStream being NULL.
      boost::uint8_t * dummy;
      if (mStream == NULL || !mStream->open(1, dummy)) 
      {
        Write(mOperator->mMetadata.AllocateEOF(), ep, true);
        return;
      }
      
      MessagePtr tmp = mOperator->mMetadata.Allocate();
      Deserialize(tmp, *mStream);
      Write(tmp, ep);
    }
    
    }
  }
}

DesignTimeDataFileExport::DesignTimeDataFileExport()
{
  mInputPorts.insert(this, 0, L"input", false);
}

DesignTimeDataFileExport::~DesignTimeDataFileExport()
{
}

void DesignTimeDataFileExport::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"filename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFilename(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDataFileExport* DesignTimeDataFileExport::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeDataFileExport* result = new DesignTimeDataFileExport();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}


void DesignTimeDataFileExport::SetFilename(const std::wstring& filename)
{
  mFilename=filename;
}

void DesignTimeDataFileExport::type_check()
{
  ParallelFilePath pfp(mFilename);
  // Temporary hack: write the seqeuential file header with the input metadata.
  // Currently programs with multiple steps are type checking all steps up front and
  // that causes a problem when one step references a sequential file created by another.
  std::wstring headerFile=pfp.GetHeaderFile();
  boost::filesystem::wpath parentPath(headerFile, boost::filesystem::native);
  parentPath = boost::filesystem::system_complete(parentPath).parent_path();
  if (!boost::filesystem::exists(parentPath))
  {
    throw SingleOperatorException(*this, (boost::wformat(L"Directory '%1%' does not exist") % 
                                          parentPath).str());
  }
  boost::filesystem::ofstream ofs(headerFile, std::ios_base::out);
  boost::archive::xml_oarchive oa(ofs);
  oa << boost::serialization::make_nvp("format", *mInputPorts[0]->GetMetadata()); 
  
}

RunTimeOperator * DesignTimeDataFileExport::code_generate(partition_t maxPartition)
{
  return new RunTimeDataFileExport<StdioWriteBuffer<StdioFile> >(GetName(), *mInputPorts[0]->GetMetadata(), mFilename, 1024*512);
}  

template <class _Buffer>
RunTimeDataFileExport<_Buffer>::RunTimeDataFileExport()
{
}

template <class _Buffer>
RunTimeDataFileExport<_Buffer>::RunTimeDataFileExport(const std::wstring& name, 
                                             const RecordMetadata& metadata,
                                             const std::wstring& filename,
                                             boost::int32_t viewSize)
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mFilename(filename),
  mViewSize(viewSize)
{
}

template <class _Buffer>
RunTimeDataFileExport<_Buffer>::~RunTimeDataFileExport()
{
}

template <class _Buffer>
RunTimeOperatorActivation * RunTimeDataFileExport<_Buffer>::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDataFileExportActivation<_Buffer>(reactor, partition, this);
}

template <class _Buffer>
RunTimeDataFileExportActivation<_Buffer>::RunTimeDataFileExportActivation(Reactor * reactor, 
                                                                          partition_t partition,
                                                                          const RunTimeDataFileExport<_Buffer> * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeDataFileExport<_Buffer> >(reactor, partition, runTimeOperator),
  mFileMapping(NULL),
  mStream(NULL),
  mState(START)
{
}

template <class _Buffer>
RunTimeDataFileExportActivation<_Buffer>::~RunTimeDataFileExportActivation()
{
}

template <class _Buffer>
void RunTimeDataFileExportActivation<_Buffer>::Start()
{
  std::vector<RunTimeDataAccessor*> physicalOrder;
  for(boost::int32_t i=0;i<mOperator->mMetadata.GetNumColumns();i++)
  {
    physicalOrder.push_back(mOperator->mMetadata.GetColumn(i));
  }  
  std::sort(physicalOrder.begin(), physicalOrder.end(), FieldAddressOffsetOrder());

  // Generate the serialization code
  mInstructions.push_back(RecordSerializerInstruction::DirectMemcpy(mOperator->mMetadata.GetDataOffset()));
  for(std::size_t i=0;i<physicalOrder.size();i++)
  {
    RecordSerializerInstruction rsi = physicalOrder[i]->GetRecordSerializerInstruction();
    if (rsi.Ty == RecordSerializerInstruction::DIRECT_MEMCPY &&
        mInstructions.back().Ty == RecordSerializerInstruction::DIRECT_MEMCPY)
    {
      // Merge adjacent memcpy's into a single instruction for efficiency.
      mInstructions.back().Len += rsi.Len;
    }
    else
    {
      mInstructions.push_back(rsi);
    }
  }

  // Open for writing.  First check if directory exists.
  boost::filesystem::wpath parentPath(mOperator->mFilename);
  parentPath = boost::filesystem::system_complete(parentPath).parent_path();
  if (!boost::filesystem::exists(parentPath))
  {
    std::string utf8Msg;
    ::WideStringToMultiByte((boost::wformat(L"Directory '%1%' does not exist") % 
                             parentPath).str(),
                            utf8Msg,
                            CP_ACP);
    throw std::runtime_error(utf8Msg);
  }

  ParallelFilePath pfp(mOperator->mFilename);
  mFileMapping = new typename _Buffer::file_type(pfp.GetPartitionFile(mPartition), true);
  mStream = new _Buffer(*mFileMapping, mOperator->mViewSize);

  mState = START;
  HandleEvent(NULL);
}

template <class _Buffer>
void RunTimeDataFileExportActivation<_Buffer>::HandleEvent(Endpoint * ep)
{
  switch(mState)
  {
  case START:
    while(true)
    {
      RequestRead(0);
      mState = READ_0;
      return;
    case READ_0:
    {
      record_t tmp;
      Read(tmp, ep);
      if (!mOperator->mMetadata.IsEOF(tmp))
      {
        // TODO: Handle errors.
        Export(tmp, *mStream);
        mOperator->mMetadata.Free(tmp);
      }
      else
      {
        // Done.  Close up shop.
        delete mStream;
        mStream = NULL;
        delete mFileMapping;
        mFileMapping = NULL;

        // if we are partition 0 , then we write out a header file
        // that for the moment only contains the metadata for the data file.
        // TODO: Put this into a sequential operator that can receive
        // all of the results of the different partitions.
        if (mPartition == 0)
        {
          ParallelFilePath pfp(mOperator->mFilename);
          boost::filesystem::ofstream ofs(pfp.GetHeaderFile(), std::ios_base::out);
          boost::archive::xml_oarchive oa(ofs);
          oa << boost::serialization::make_nvp("format", mOperator->mMetadata); 
        }
        return;
      }
    }
    }
  }
}

template <class _Buffer>
void RunTimeDataFileExportActivation<_Buffer>::Export(const_record_t recordBuffer, _Buffer& buffer)
{
  boost::uint8_t * buf=NULL;
  const_record_t source = recordBuffer;
  static const boost::int32_t inPlaceNull(-1);

  for(std::vector<RecordSerializerInstruction>::const_iterator it = mInstructions.begin();
      it != mInstructions.end();
      it++)
  {
    switch(it->Ty)
    {
    case RecordSerializerInstruction::DIRECT_MEMCPY:
      if (buffer.open(it->Len, buf)) 
      {
        memcpy(buf, source, it->Len);
        source += it->Len;
        buffer.consume(it->Len);
        break;
      }
      else
      {
        throw std::runtime_error("error serializing record");
      }
    case RecordSerializerInstruction::INDIRECT_MEMCPY:
      if (!it->Accessor->GetNull(recordBuffer))
      {
        if (buffer.open(sizeof(boost::int32_t)+it->Len, buf)) 
        {
          memcpy(buf, &(it->Len), sizeof(boost::int32_t));
          memcpy(buf + sizeof(boost::int32_t), *((const void **) source), it->Len);
          source += sizeof(void*);
          buffer.consume(sizeof(boost::int32_t)+it->Len);
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }
        
      }
      else
      {
        if (buffer.open(sizeof(boost::int32_t), buf)) 
        {
          memcpy(buf, &inPlaceNull, sizeof(boost::int32_t));
          source += sizeof(void*);
          buffer.consume(sizeof(boost::int32_t));
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }
      }
    case RecordSerializerInstruction::INDIRECT_STRCPY:
    {
      if (!it->Accessor->GetNull(recordBuffer))
      {
        const char * str = *((const char **) source);
        boost::int32_t len = strlen(str) + 1;
        if (buffer.open(sizeof(boost::int32_t)+len, buf)) 
        {
          memcpy(buf, &len, sizeof(boost::int32_t));
          memcpy(buf+sizeof(boost::int32_t), str, len);
          source += sizeof(void*);
          buffer.consume(sizeof(boost::int32_t)+len);
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }        
      }
      else
      {
        if (buffer.open(sizeof(boost::int32_t), buf)) 
        {
          memcpy(buf, &inPlaceNull, sizeof(boost::int32_t));
          source += sizeof(void*);
          buffer.consume(sizeof(boost::int32_t));
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }
      }
    }
    case RecordSerializerInstruction::INDIRECT_WCSCPY:
    {
      if (!it->Accessor->GetNull(recordBuffer))
      {
        const wchar_t * str = ((const PrefixedWideString *) source)->String;
        boost::int32_t len = ((const PrefixedWideString *) source)->Length;
//         const wchar_t * str = *((const wchar_t **) source);
//         boost::int32_t len = (wcslen(str) + 1) * sizeof(wchar_t);
        if (buffer.open(sizeof(boost::int32_t)+len, buf)) 
        {
          memcpy(buf, &len, sizeof(boost::int32_t));
          memcpy(buf + sizeof(boost::int32_t), str, len);
//           source += sizeof(void*);
          source += sizeof(PrefixedWideString);
          buffer.consume(sizeof(boost::int32_t)+len);
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }
      }
      else
      {
        if (buffer.open(sizeof(boost::int32_t),buf))
        {
          memcpy(buf, &inPlaceNull, sizeof(boost::int32_t));
          source += sizeof(PrefixedWideString);
//           source += sizeof(void*);
          buffer.consume(sizeof(boost::int32_t));
          break;
        }
        else
        {
          throw std::runtime_error("error serializing record");
        }
      }
    }
    }
  }
}

DesignTimeDataFileDelete::DesignTimeDataFileDelete()
{
}

DesignTimeDataFileDelete::~DesignTimeDataFileDelete()
{
}

void DesignTimeDataFileDelete::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"filename", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFilename(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDataFileDelete* DesignTimeDataFileDelete::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeDataFileDelete* result = new DesignTimeDataFileDelete();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDataFileDelete::SetFilename(const std::wstring& filename)
{
  mFilename=filename;
}

void DesignTimeDataFileDelete::type_check()
{
}

RunTimeOperator * DesignTimeDataFileDelete::code_generate(partition_t maxPartition)
{
  return new RunTimeDataFileDelete(GetName(), mFilename);
}  

RunTimeDataFileDelete::RunTimeDataFileDelete()
{
}

RunTimeDataFileDelete::RunTimeDataFileDelete (const std::wstring& name, 
                                              const std::wstring& filename)
  :
  RunTimeOperator(name),
  mFilename(filename)
{
}

RunTimeDataFileDelete::~RunTimeDataFileDelete()
{
}
  
RunTimeOperatorActivation * RunTimeDataFileDelete::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDataFileDeleteActivation(reactor, partition, this);
}


RunTimeDataFileDeleteActivation::RunTimeDataFileDeleteActivation (Reactor * reactor, 
                                                                  partition_t partition,
                                                                  const RunTimeDataFileDelete * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeDataFileDelete>(reactor, partition, runTimeOperator)
{
}

RunTimeDataFileDeleteActivation::~RunTimeDataFileDeleteActivation()
{
}
  
void RunTimeDataFileDeleteActivation::Start()
{
  ParallelFilePath pfp(mOperator->mFilename);
  // Delete the actual file
  boost::filesystem::remove_all(pfp.GetPartitionFile(mPartition));
  if (0 == mPartition)
  {
    boost::filesystem::remove_all(pfp.GetHeaderFile());
  }
}

void RunTimeDataFileDeleteActivation::HandleEvent(Endpoint * ep)
{
}

DesignTimeDataFileRename::DesignTimeDataFileRename()
{
}

DesignTimeDataFileRename::~DesignTimeDataFileRename()
{
}

void DesignTimeDataFileRename::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"from", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetFrom(arg.getNormalizedString());
  }
  else if (arg.is(L"to", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetTo(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeDataFileRename* DesignTimeDataFileRename::clone(
                                        const std::wstring& name,
                                        std::vector<OperatorArg *>& args, 
                                        int nInputs, int nOutputs) const
{
  DesignTimeDataFileRename* result = new DesignTimeDataFileRename();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeDataFileRename::SetFrom(const std::wstring& filename)
{
  mFrom=filename;
}

void DesignTimeDataFileRename::SetTo(const std::wstring& filename)
{
  mTo=filename;
}

void DesignTimeDataFileRename::type_check()
{
  ParallelFilePath from(mFrom);
  ParallelFilePath to(mTo);
  // Check that the from file header exists.
  boost::filesystem::wpath fromPath(boost::filesystem::system_complete(from.GetHeaderFile()));
  if (!boost::filesystem::exists(fromPath))
  {
    throw SingleOperatorException(*this,
                                  (boost::wformat(L"MetraFlow file header '%1%' does not exist") % 
                                   fromPath).str());
  }

  // Check that the target directory of the to file exists.
  boost::filesystem::wpath toParentPath(boost::filesystem::system_complete(to.GetHeaderFile()).parent_path());
  if (!boost::filesystem::exists(toParentPath))
  {
    throw SingleOperatorException(*this,
                                  (boost::wformat(L"Directory '%1%' does not exist") % 
                                   toParentPath).str());
  }
}

RunTimeOperator * DesignTimeDataFileRename::code_generate(partition_t maxPartition)
{
  return new RunTimeDataFileRename(GetName(), mFrom, mTo);
}  

RunTimeDataFileRename::RunTimeDataFileRename()
{
}

RunTimeDataFileRename::RunTimeDataFileRename (const std::wstring& name, 
                                              const std::wstring& from,
                                              const std::wstring& to)
  :
  RunTimeOperator(name),
  mFrom(from),
  mTo(to)
{
}

RunTimeDataFileRename::~RunTimeDataFileRename()
{
}
  
RunTimeOperatorActivation * RunTimeDataFileRename::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeDataFileRenameActivation(reactor, partition, this);
}


RunTimeDataFileRenameActivation::RunTimeDataFileRenameActivation (Reactor * reactor, 
                                                                  partition_t partition,
                                                                  const RunTimeDataFileRename * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeDataFileRename>(reactor, partition, runTimeOperator)
{
}

RunTimeDataFileRenameActivation::~RunTimeDataFileRenameActivation()
{
}
  
void RunTimeDataFileRenameActivation::Start()
{
  ParallelFilePath from(mOperator->mFrom);
  ParallelFilePath to(mOperator->mTo);
  // Rename the actual file
  boost::filesystem::rename(from.GetPartitionFile(mPartition), to.GetPartitionFile(mPartition));
  if (0 == mPartition)
  {
    boost::filesystem::rename(from.GetHeaderFile(), to.GetHeaderFile());
  }
}

void RunTimeDataFileRenameActivation::HandleEvent(Endpoint * ep)
{
}

// explicit instantiation - so all the impl doesn't have to be in the header
template class RunTimeDataFileScan<PagedParseBuffer<mapped_file> >;
template class RunTimeDataFileScan<StdioReadBuffer<StdioFile> >;
template class RunTimeDataFileScan<StdioReadBuffer<Win32File> >;
template class RunTimeDataFileExport<StdioWriteBuffer<StdioFile> >;
template class RunTimeDataFileScanActivation<PagedParseBuffer<mapped_file> >;
template class RunTimeDataFileScanActivation<StdioReadBuffer<StdioFile> >;
template class RunTimeDataFileScanActivation<StdioReadBuffer<Win32File> >;
template class RunTimeDataFileExportActivation<StdioWriteBuffer<StdioFile> >;
