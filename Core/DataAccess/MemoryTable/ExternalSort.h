#ifndef __EXTERNALSORT_H__
#define __EXTERNALSORT_H__

#include <boost/filesystem/path.hpp>

#include "Scheduler.h"
#include "SortMergeCollector.h"

#include "asio.hpp"
#include "asio/basic_stream_file.hpp"
#include "asio/detail/win_iocp_file_service.hpp"

//#define VALIDATE_SORT

// Forward declaration
namespace boost
{
  class thread;
}
template <class _T, std::size_t N> class concurrent_blocking_bounded_fifo;
class merge_sequential_files;

class sort_order_check
{
private:
  const std::vector<RunTimeSortKey>& keys_;
  const RecordMetadata& metadata_;
  record_t last_message_;

  std::string error_;
public:
  METRAFLOW_DECL sort_order_check(const std::vector<RunTimeSortKey>& keys,
                                  const RecordMetadata& metadata);
  METRAFLOW_DECL ~sort_order_check();
  METRAFLOW_DECL bool check(record_t message);
  METRAFLOW_DECL std::string error() const;
};

template <class _File>
class queue_element
{
public:
  boost::uint32_t key_prefix;
  _File * file;

  queue_element()
    :
    key_prefix(0),
    file(0)
  {
  }
  queue_element(boost::uint32_t kp, _File * f)
    :
    key_prefix(kp),
    file(f)
  {
  }
  _File * active_file() { return file; }
  MessagePtr message() { return file->message(); }
};

template <class _Message>
class queue_element_compare 
{
private:
  const std::vector<RunTimeSortKey>& sort_keys_;

  // Note that this is a subtle because the top of the priority queue is the
  // "greatest" element in the queue and we want the "least".  So have to reverse
  // the sense of the comparisons: return true is rhs < lhs.
  // Even more confusing is that we have to handle ascending vs. descending,
  // so if rhs < lhs (cmp=1) and ascending then true, rhs < lhs and descending then false.
  bool compare_record(MessagePtr lhs, MessagePtr rhs) const
  {
    for(std::vector<RunTimeSortKey>::const_iterator sortKeyIt = sort_keys_.begin(); 
        sortKeyIt != sort_keys_.end(); 
        ++sortKeyIt)
    {
      int cmp = sortKeyIt->GetDataAccessor()->Compare(lhs, sortKeyIt->GetDataAccessor(), rhs);
      switch(cmp)
      {
      case -1:
        return sortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? false : true;
      case 0:
        // Don't know yet
        break;
      case 1:
        return sortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? true : false;
      }
    }
    return false;
  }
  public:
  queue_element_compare(const std::vector<RunTimeSortKey>& runTimeSortKeys)
    :
    sort_keys_(runTimeSortKeys)
  {
  }

  bool operator() (queue_element<_Message> lhs, queue_element<_Message> rhs)
  {
    bool ret = 
      lhs.key_prefix > rhs.key_prefix || 
      (lhs.key_prefix == rhs.key_prefix && compare_record(lhs.message(), rhs.message()));

    return ret;
  }

};

template <class _Message>
class queue_element_factory 
{
public:
  typedef std::priority_queue<queue_element<_Message>, 
                              std::vector<queue_element<_Message> >, 
                              queue_element_compare<_Message> > merger;
  
private:
  const std::vector<RunTimeSortKey>& sort_keys_;  
  SortKeyBuffer sort_key_buffer_;

public:
  queue_element_factory(const std::vector<RunTimeSortKey>& runTimeSortKeys)
    :
    sort_keys_(runTimeSortKeys)
  {
  }

  typename merger::value_type create_queue_element(_Message * file)
  {
    sort_key_buffer_.Clear();
    for(std::vector<RunTimeSortKey>::const_iterator sortKeyIt = sort_keys_.begin(); 
        sortKeyIt != sort_keys_.end(); 
        ++sortKeyIt)
    {
      sortKeyIt->GetDataAccessor()->ExportSortKey(file->message(), 
                                                  sortKeyIt->GetSortOrder(), 
                                                  sort_key_buffer_);      
    }    

    // To compare as boost::uint32_t we need to reorder bytes.
    boost::uint32_t p;
    ((boost::uint8_t *)&p)[0] = sort_key_buffer_.GetKey()[3];
    ((boost::uint8_t *)&p)[1] = sort_key_buffer_.GetKey()[2];
    ((boost::uint8_t *)&p)[2] = sort_key_buffer_.GetKey()[1];
    ((boost::uint8_t *)&p)[3] = sort_key_buffer_.GetKey()[0];

    return merger::value_type(p, file);
  }
};

  
typedef struct tagKey
{
  boost::uint32_t KeyPrefix;
  MessagePtr Record;
} Key;

class KeyPrefixCompare
{
private:
  const std::vector<RunTimeSortKey>& mRunTimeSortKeys;
  // Sort records for in memory for sort runs.
  // This sorts in ascending order (smallest first).
  bool CompareRecord(MessagePtr lhs, MessagePtr rhs) const
  {
    for(std::vector<RunTimeSortKey>::const_iterator sortKeyIt = mRunTimeSortKeys.begin(); 
        sortKeyIt != mRunTimeSortKeys.end(); 
        ++sortKeyIt)
    {
      int cmp = sortKeyIt->GetDataAccessor()->Compare(lhs, sortKeyIt->GetDataAccessor(), rhs);
      switch(cmp)
      {
      case -1:
        return sortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? true : false;
      case 0:
        // Don't know yet
        break;
      case 1:
        return sortKeyIt->GetSortOrder() == SortOrder::ASCENDING ? false : true;
      }
    }
    return false;
  }
  public:
  KeyPrefixCompare(const std::vector<RunTimeSortKey>& runTimeSortKeys)
    :
    mRunTimeSortKeys(runTimeSortKeys)
  {
  }

  bool operator() (Key lhs, Key rhs)
  {
    return 
      lhs.KeyPrefix < rhs.KeyPrefix || 
      (lhs.KeyPrefix == rhs.KeyPrefix && CompareRecord(lhs.Record, rhs.Record));
  }
};
  
class RunTimeExternalSort : public RunTimeOperator
{
public:
  friend class RunTimeExternalSortActivation;
private:
  RecordMetadata mMetadata;
  std::vector<RunTimeSortKey> mRunTimeSortKeys;
  // Where should we create sort run files; this directory must exist on
  // every partition.
  std::wstring mTempDir;
  // Amount of memory we are allowed to use for sorting.
  std::size_t mAllowedMemory;
  KeyPrefixCompare mKeyPrefixCompare;

  //
  // Serialization support
  //
  friend class boost::serialization::access;
  template<class Archive>
  void serialize(Archive & ar, const unsigned int version)
  {
    ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(RunTimeOperator);
    ar & BOOST_SERIALIZATION_NVP(mMetadata);
    ar & BOOST_SERIALIZATION_NVP(mRunTimeSortKeys);
    ar & BOOST_SERIALIZATION_NVP(mTempDir);
    ar & BOOST_SERIALIZATION_NVP(mAllowedMemory);
  }
  METRAFLOW_DECL RunTimeExternalSort();

public:
  METRAFLOW_DECL RunTimeExternalSort(std::wstring& name,
                                       const RecordMetadata& metadata,
                                       const std::vector<RunTimeSortKey>& sortKey,
                                       const std::wstring& tempDir,
                                       std::size_t allowedMemory);
	                                 
        
  METRAFLOW_DECL ~RunTimeExternalSort();
  METRAFLOW_DECL RunTimeOperatorActivation * CreateActivation(Reactor * reactor, partition_t partition);
};

class RunTimeExternalSortActivation : public RunTimeOperatorActivationImpl<RunTimeExternalSort>
{
public:
  enum State { START_SORT_RUNS, READ,
               START_IN_MEMORY_OUTPUT, WRITE_IN_MEMORY_OUTPUT, WRITE_EOF_IN_MEMORY_OUTPUT,
               START_FINAL_MERGE, WRITE_FINAL_MERGE, WRITE_EOF_FINAL_MERGE };
  typedef concurrent_blocking_bounded_fifo<MessagePtr, 3> fifo;
private:
  State mState;

  SortKeyBuffer mSortKeyBuffer;
  MessagePtr mInputMessage;
  // Two buffers for in-memory sort run building.
  // One of these is a completed sort run being written to disk, the other is 
  // building up a new sort run.
  std::vector<Key> mBuffers[2];
  std::vector<Key>::const_iterator mBufferIt;
  std::size_t mCurrentBuffer;
  std::size_t mCurrentSortRunSize;

  // ASIO file service.
  asio::io_service mService;
  // The sort run files.
  std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > > mFiles;
  // Sort run writer thread and merger thread.
  boost::shared_ptr<boost::thread> mWriter;
  // Queue to communicate with merger.
  boost::shared_ptr<fifo> mQueue;
  // Record count
  boost::int64_t mRecordCount;
  // Filenames we have creates
  std::vector<boost::filesystem::path> mFilenames;
  
#ifdef VALIDATE_SORT
  SortKeyBuffer mValidationKeyBuffer[2];
  boost::int32_t mWhichBuffer;
  record_t mLastMessage;
#endif

  void BuildSortRuns(Endpoint * in);
  void WriteInMemorySort(Endpoint * in);
  void WriteFinalMerge(Endpoint * in);
public:
		METRAFLOW_DECL RunTimeExternalSortActivation(Reactor *reactor, 
                                                 partition_t partition,
                                                 const RunTimeExternalSort * runTimeOperator);
        
    METRAFLOW_DECL ~RunTimeExternalSortActivation();
		METRAFLOW_DECL void Start();
		METRAFLOW_DECL void HandleEvent(Endpoint * in); 
};
#endif
