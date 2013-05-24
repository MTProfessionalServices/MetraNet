#include "DesignTimeExternalSort.h"
#include "ExternalSort.h"
#include "OperatorArg.h"
#include <set>
#include <boost/format.hpp>
#include <boost/array.hpp>
#include <boost/bind.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/thread.hpp>
#include <boost/thread/condition.hpp>
#include "AsyncFile.h"
#include "DatabaseCatalog.h"
#include "LogAdapter.h"
#include "RecordSerialization.h"
#include "SEHException.h"

#include <boost/random/linear_congruential.hpp>
#include <boost/random/uniform_int.hpp>
#include <boost/random/variate_generator.hpp>

static const boost::int32_t SERIALIZATION_INPUT_EXHAUSTED(-1);
static const boost::int32_t SERIALIZATION_OK(0);

sort_order_check::sort_order_check(const std::vector<RunTimeSortKey>& keys,
                                   const RecordMetadata& metadata)
  :
  keys_(keys),
  metadata_(metadata),
  last_message_(NULL)
{
}
sort_order_check::~sort_order_check()
{
  if (last_message_) metadata_.Free(last_message_);
}
bool sort_order_check::check(record_t message)
{
  // Save a copy of the last message.
  if (last_message_)
  {
    // Validate that we are sorted properly.
    for(std::vector<RunTimeSortKey>::const_iterator sortKeyIt = keys_.begin(); 
        sortKeyIt != keys_.end(); 
        ++sortKeyIt)
    {
      int cmp = sortKeyIt->GetDataAccessor()->Compare(last_message_, sortKeyIt->GetDataAccessor(), message);
      if((1==cmp && sortKeyIt->GetSortOrder() == SortOrder::ASCENDING) ||
         (-1==cmp && sortKeyIt->GetSortOrder() == SortOrder::DESCENDING))
      {
        error_ = (boost::format("Out of order sort run: \n%1%\n%2%\n") % 
                  metadata_.PrintMessage(last_message_) %
                  metadata_.PrintMessage(message)).str();
        // Out of order
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
        logger->logError(error_);
        // WE ARE ASSUMING FIXED LENGTH RECORD (TRUE FOR NOW).
        // I think this memcpy is no longer valid!  We have to clone.
        ASSERT(FALSE);
        memcpy(last_message_, message, metadata_.GetRecordLength());
        return false;
      }
      else if (cmp != 0)
      {
        // We have validated correct order.  If cmp==0 then we need to keep going.
        // WE ARE ASSUMING FIXED LENGTH RECORD (TRUE FOR NOW).
        memcpy(last_message_, message, metadata_.GetRecordLength());
        return true;
      }
    }
  }
  else
  {
    last_message_ = metadata_.Allocate();
  }
  // WE ARE ASSUMING FIXED LENGTH RECORD (TRUE FOR NOW).
  memcpy(last_message_, message, metadata_.GetRecordLength());
  return true;
}

std::string sort_order_check::error() const
{
  return error_;
}

DesignTimeExternalSort::DesignTimeExternalSort()
  :
  mAllowedMemory(10*1024*1024),
  mTempDir(L"C:\\Temp")
{
  if (getenv("TEMP") != NULL)
  {
    ::ASCIIToWide(mTempDir, getenv("TEMP"));
  }
  else if (getenv("TMP") != NULL)
  {
    ::ASCIIToWide(mTempDir, getenv("TMP"));
  }  

  mInputPorts.push_back(this, L"input", false);  
  mOutputPorts.push_back(this, L"output", false);  
}

DesignTimeExternalSort::~DesignTimeExternalSort()
{
}

void DesignTimeExternalSort::handleArg(const OperatorArg& arg)
{
  if (arg.is(L"key", OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    AddSortKey(DesignTimeSortKey(arg.getNormalizedString(),
                                 SortOrder::ASCENDING));
  }
  else if (arg.is(L"allowedMemory", OPERATOR_ARG_TYPE_INTEGER, GetName()))
  {
    SetAllowedMemory(arg.getIntValue());
  }
  else if (arg.is(L"temp_dir", OPERATOR_ARG_TYPE_STRING, GetName()) ||
           arg.is(L"tempDir",  OPERATOR_ARG_TYPE_STRING, GetName()))
  {
    SetTempDirectory(arg.getNormalizedString());
  }
  else
  {
    handleCommonArg(arg);
  }
}

DesignTimeExternalSort* DesignTimeExternalSort::clone(
                                                  const std::wstring& name,
                                                  std::vector<OperatorArg *>& args, 
                                                  int nInputs, int nOutputs) const
{
  DesignTimeExternalSort* result = new DesignTimeExternalSort();

  result->SetName(name);
  clonePendingArgs(*result);
  result->applyPendingArgs(args);

  return result;
}

void DesignTimeExternalSort::type_check()
{
  const RecordMetadata * inputMetadata = mInputPorts[0]->GetMetadata();

  // Validate that the first input has the sort key.
  CheckSortKeys(0, mSortKey);

  mOutputPorts[0]->SetMetadata(new RecordMetadata(*mInputPorts[0]->GetMetadata()));  
}

void DesignTimeExternalSort::SetAllowedMemory(std::size_t allowedMemory)
{
  mAllowedMemory = allowedMemory;
}

void DesignTimeExternalSort::AddSortKey(const DesignTimeSortKey& aKey)
{
  mSortKey.push_back(aKey);
}

void DesignTimeExternalSort::SetTempDirectory(const std::wstring& tempDir)
{
  mTempDir = tempDir;
}

RunTimeOperator * DesignTimeExternalSort::code_generate(partition_t maxPartition)
{
  std::vector<RunTimeSortKey> runTimeSortKey;
  for(std::vector<DesignTimeSortKey>::iterator it = mSortKey.begin();
      it != mSortKey.end();
      it++)
  {
    runTimeSortKey.push_back(RunTimeSortKey(it->GetSortKeyName(), 
                                            it->GetSortOrder(), 
                                            mInputPorts[0]->GetMetadata()->GetColumn(it->GetSortKeyName())));
  }

  return new RunTimeExternalSort(GetName(), 
                                 *mInputPorts[0]->GetMetadata(),
                                 runTimeSortKey,
                                 mTempDir,
                                 mAllowedMemory);
}

template <class _T, std::size_t N>
class concurrent_blocking_bounded_fifo
{
private:
  boost::timed_mutex guard_;
  boost::condition condvar_;
  std::deque<_T > queue_;
  std::string error_;
public:

  concurrent_blocking_bounded_fifo()
  {
  }

  ~concurrent_blocking_bounded_fifo()
  {
  }

  void error(const std::string& error)
  {
    boost::timed_mutex::scoped_lock lk(guard_);
    error_ = error;
    condvar_.notify_one();
  }

  void push(_T ptr)
  {
    boost::timed_mutex::scoped_lock lk(guard_);
    while(queue_.size() == N)
    {
      boost::xtime xt;
      boost::xtime_get(&xt, boost::TIME_UTC);
      xt.sec += 30;
      condvar_.timed_wait(lk, xt);
      if (queue_.size() == N)
      {
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
        logger->logInfo("External sort merger waiting for operator...");
      }
    }
    ASSERT(queue_.size() < N);

    queue_.push_back(ptr);
    if(queue_.size() == 1)
      condvar_.notify_one();
  }
  void pop(_T& ptr)
  {
    boost::timed_mutex::scoped_lock lk(guard_);
    while (queue_.size() == 0 && error_.size() == 0)
    {
      boost::xtime xt;
      boost::xtime_get(&xt, boost::TIME_UTC);
      xt.sec += 30;
      condvar_.timed_wait(lk, xt);
      if (queue_.size() == 0)
      {        
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
        logger->logInfo("External sort waiting for merge...");
      }
    }
    if (error_.size())
    {
      throw std::runtime_error(error_);
    }
    else
    {
      ptr = queue_.front();
      queue_.pop_front();
      if (queue_.size() == N-1)
        condvar_.notify_one();
    }
  }
};

class sort_run_file
{
public:
  typedef std::pair<asio::basic_stream_file<asio::detail::win_iocp_file_service> * , const std::vector<Key> *> write_request;
private:
  enum { TRANSFER_SIZE=128*1024 };
  asio::basic_stream_file<asio::detail::win_iocp_file_service>& file_;
  bool write_done_;
  boost::uint64_t file_offset_;
  const std::vector<Key>& sort_run_;
  std::vector<Key>::const_iterator begin_;
  std::vector<Key>::const_iterator end_;
  std::vector<Key>::const_iterator it_;
  boost::array<boost::uint8_t, TRANSFER_SIZE+4096-1> buffer_;
  boost::uint8_t * buffer_begin_;
  boost::uint8_t * buffer_end_;
  const RecordMetadata& mMetadata;
  RawBufferArchive mArchive;

  void write_block()
  {
    // Protect against empty write.
    if (it_ == end_) return;

    // Fill up a block and write to disk.
    std::size_t bytes_to_write(0);
    mArchive.Bind(buffer_begin_+sizeof(boost::int32_t), buffer_end_);
    while(it_ != end_)
    {
      boost::uint8_t * nbuf = mArchive.Serialize(it_->Record, mMetadata.IsEOF(it_->Record));
      if (nbuf != NULL)
      {
        it_++;
      }
      else
      {
        break;
      }
    }
    boost::uint8_t * used = mArchive.Unbind();
    // Record the amount of the block that is actually used.
    *((boost::int32_t *)buffer_begin_) = (boost::int32_t) (used - buffer_begin_);
    // For the moment, we write complete blocks (except for the last one).
    // This allows reader to reference complete records from block memory.
    // Fill with zeros to mark end of data in the block
    memset(used, 0, buffer_end_-used);
    bytes_to_write =  TRANSFER_SIZE;
    file_.async_write(asio::buffer(buffer_begin_, bytes_to_write),
                      file_offset_, 
                      boost::bind(&sort_run_file::handle_write, 
                                  this, 
                                  asio::placeholders::error, 
                                  asio::placeholders::bytes_transferred));
    file_offset_ += bytes_to_write;
  }

public:
  sort_run_file(asio::basic_stream_file<asio::detail::win_iocp_file_service>& file, 
                const RecordMetadata& metadata,
                const std::vector<Key>& sortRun)
    :
    file_(file),
    write_done_(false),
    file_offset_(0LL),
    sort_run_(sortRun),
    begin_(sortRun.begin()),
    end_(sortRun.end()),
    it_(sortRun.begin()),
    mMetadata(metadata),
    mArchive(metadata)
  {
    buffer_begin_ = 
        reinterpret_cast<boost::uint8_t *>(4096*((reinterpret_cast<size_t>(buffer_.begin()) + 4096 - 1)/4096));
    buffer_end_ = buffer_begin_ + TRANSFER_SIZE;
    ASSERT(buffer_end_ <= buffer_.end());
    // Start with some number of outstanding I/Os
    write_block();
//     write_block();
//     write_block();
  }
  void handle_write(const asio::error& error,
                    size_t bytes_transferred)
  {
//     if (!error)
//     {
//       throw error;
//     }
    // Can we detect short writes?  Are they possible?
    if (it_ != end_)
    {
      write_block();
    }
    else
    {
      write_done_ = true;
    }
  }

  bool write_done() const
  {
    return write_done_; 
  }

  static void write(asio::basic_stream_file<asio::detail::win_iocp_file_service>& file, 
                    const RecordMetadata& metadata,
                    const std::vector<Key>& sortRun)
  {
    sort_run_file srf(file, metadata, sortRun);
    file.io_service().run();
    file.io_service().reset();
  }

  static void write(const RecordMetadata& metadata,
                    concurrent_blocking_bounded_fifo<write_request, 3>& request_queue)
  {
    while(true)
    {
      write_request wr((asio::basic_stream_file<asio::detail::win_iocp_file_service> *)0, (std::vector<Key> *)0);
      request_queue.pop(wr);
      if (wr.first != NULL && wr.second != NULL)
      {
        sort_run_file srf(*wr.first, metadata, *wr.second);
        wr.first->io_service().run();
        wr.first->io_service().reset();        
      }
    }
  }                 
};


template <class _Scheduler>
class active_file
{
private:
  // The underlying file and block
  boost::shared_ptr<sort_run_read_file<_Scheduler> > file_;
  // Binding state
  bool bound_;
  // Metadata
  const RecordMetadata& metadata_;
  // Deserializer
  RawBufferDearchive archive_;
  // Message in progress
  MessagePtr message_;
#ifdef VALIDATE_SORT
  // Validate sort order
  sort_order_check check_;
#endif

  bool deserialize()
  {
    if (message_ == NULL)
      message_ = metadata_.Allocate();
    int result = archive_.Deserialize(message_);
    if(SERIALIZATION_INPUT_EXHAUSTED == result)
    {
      // Only have a partial message.  What to do?
      return false;
    }
    else if (SERIALIZATION_OK != result)
    {
      throw std::runtime_error((boost::format("Serialization error: %1%") % result).str());
    }
    return true;
  }

public:
#ifdef VALIDATE_SORT
  active_file(boost::shared_ptr<sort_run_read_file<_Scheduler> > file,
              const std::vector<RunTimeSortKey>& keys,
              const RecordMetadata& metadata)
    :
    file_(file),
    bound_(false),
    metadata_(metadata),
    archive_(metadata),
    message_(NULL),
    check_(keys, metadata)
  {
  }
#else
  active_file(boost::shared_ptr<sort_run_read_file<_Scheduler> > file,
              const std::vector<RunTimeSortKey>&,
              const RecordMetadata& metadata)
    :
    file_(file),
    bound_(false),
    metadata_(metadata),
    archive_(metadata),
    message_(NULL)
  {
  }
#endif

  ~active_file()
  {
  }

  // The underlying file
  boost::shared_ptr<sort_run_read_file<_Scheduler> > file() { return file_; }
  // The message we are pointing to
  MessagePtr message() 
  {
    return message_;
  }

  void handle_read(_Scheduler& sched,
                   const asio::error& err,
                   size_t bytes_transferred)
  {
    file_->handle_read(sched, err, bytes_transferred);
    if (!bound_ && err == asio::error::success)
    {
      if (file_->begin() != file_->end())
      {
        boost::int32_t used = *((boost::int32_t *)file_->begin());
        if (used > sizeof(boost::int32_t))
        {
          bound_ = true;
          archive_.Bind(file_->begin() + sizeof(boost::int32_t), file_->begin() + used);
          // We have a complete message
          bool result = deserialize();
          if (!result)
          {
            MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
            logger->logError("active_file::handle_read: deserialize failed");
            throw std::runtime_error("active_file::handle_read: deserialize failed");
          }
        }
        else 
        {
          handle_buffer_complete(sched);
        }
      }
      else
      {
        handle_buffer_complete(sched);
      }
    }
  }
  // Advance to the next message.  Return true if one exists, false if end of block.
  bool advance()
  {
#ifdef VALIDATE_SORT
    if (!check_.check(message_))
    {
      throw std::runtime_error(check_.error());
    }
#endif
    message_ = NULL;
    // Now look to see if this is the last message in the block.
    return deserialize();
  }
  // Finished with the underlying block.
  void handle_buffer_complete(_Scheduler& scheduler)
  {
    archive_.Unbind();
    bound_ = false;
    file_->handle_buffer_complete(scheduler);
    if (file_->has_data())
    {
      if (file_->begin() != file_->end())
      {
        boost::int32_t used = *((boost::int32_t *)file_->begin());
        if (used > sizeof(boost::int32_t))
        {
          bound_ = true;        
          archive_.Bind(file_->begin() + sizeof(boost::int32_t), file_->begin() + used);
          // TODO: What to do about failure here?
          bool result = deserialize();
          if (!result)
          {
            MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
            logger->logError("active_file::handle_buffer_complete: deserialize failed");
            throw std::runtime_error("active_file::handle_buffer_complete: deserialize failed");
          }
        }
        else 
        {
          handle_buffer_complete(scheduler);
        }
      }
      else
      {
        handle_buffer_complete(scheduler);
      }
    }
  }
};

// Double buffered block-based reading of a set of sequential files.
class merge_sequential_files
{
public:
  enum State { START, INIT_WAIT_FOR_COMPLETION, WRITE, WAIT_FOR_COMPLETION, DONE };
private:
  typedef std::priority_queue<queue_element<active_file<merge_sequential_files> >, 
                              std::vector<queue_element<active_file<merge_sequential_files> > >, 
                              queue_element_compare<active_file<merge_sequential_files> > > merger;
  
  State state_;
  enum { TRANSFER_SIZE=128*1024, MAX_IOS_OUTSTANDING=32 };

  // Record Metadat
  const RecordMetadata& metadata_;
  // Sort keys.
  const std::vector<RunTimeSortKey>& sort_keys_;
  // Buffer for exporting sort keys and generating key prefix.
  SortKeyBuffer sort_key_buffer_;
  // Files that we are merging.
  std::vector<boost::shared_ptr<active_file<merge_sequential_files> > > files_;
  // Reverse lookup from file to buffer.
  std::map<sort_run_read_file<merge_sequential_files> *, active_file<merge_sequential_files>*> file_buffer_index_;
  // Files that we are waiting on first block.
  std::set<active_file<merge_sequential_files> *> no_initial_data_;
  // Files that have active data.
  std::set<active_file<merge_sequential_files> *> active_files_;
  // Ordinary read requests.
  std::deque<boost::function0<void> > read_queue_;
  // I/Os outstanding
  std::size_t ios_outstanding_;
  // Count of number of records
  boost::uint64_t loop_;
  // Queue to which to output messages.
  MessagePtr local_message_end_;  
  std::size_t locally_queued_;
  boost::shared_ptr<RunTimeExternalSortActivation::fifo> output_queue_;

  // Merge
  queue_element_compare<active_file<merge_sequential_files> > comparer_;
  merger merger_;
  merger::value_type top_;

#ifdef VALIDATE_SORT
  // Sanity checking
  sort_order_check check_;
#endif

  merger::value_type create_queue_element(active_file<merge_sequential_files> * file)
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

public:
  static void run(asio::io_service & service,
                  std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > >& async_files,
                  const RecordMetadata& metadata,
                  const std::vector<RunTimeSortKey>& sort_keys,
                  boost::shared_ptr<RunTimeExternalSortActivation::fifo> output_queue)
  {
    MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSortMerger]");
#ifdef WIN32
    _set_se_translator(&SEHException::TranslateStructuredExceptionHandlingException);
#endif
    try
    {
      logger->logDebug((boost::format("Starting Merger with %1% files") % async_files.size()).str());
      merge_sequential_files msf (service, async_files, metadata, sort_keys, output_queue);
      msf.start();
      service.run();
      logger->logDebug("Stopping Merger");
    }
    catch(std::exception & e)
    {    
      logger->logError(e.what());
      output_queue->error(e.what());
      return;
    }
#ifdef WIN32
    catch(SEHException & e)
    {    
      logger->logError(e.what());
      logger->logError(e.callStack());
      output_queue->error(e.what());
      return;
    }
#endif
    catch(...)
    {
      logger->logError("Unknown exception");
      output_queue->error("Unknown exception");
      return;
    }
  }

  merge_sequential_files(asio::io_service & service,
                         std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > >& async_files,
                         const RecordMetadata& metadata,
                         const std::vector<RunTimeSortKey>& sort_keys,
                         boost::shared_ptr<RunTimeExternalSortActivation::fifo> output_queue)
    :
    metadata_(metadata),
    sort_keys_(sort_keys),
    ios_outstanding_(0),
    loop_(0LL),
    comparer_(sort_keys),
    merger_(comparer_),
    output_queue_(output_queue),
    local_message_end_(NULL),  
    locally_queued_(0)
#ifdef VALIDATE_SORT
    ,check_(sort_keys, metadata)
#endif
  {
    for(std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > >::iterator it = async_files.begin();
        it != async_files.end();
        ++it)
    {
      boost::shared_ptr<sort_run_read_file<merge_sequential_files> > myfile(new sort_run_read_file<merge_sequential_files>(*(it->get()), TRANSFER_SIZE));
      boost::shared_ptr<active_file<merge_sequential_files> > file(new active_file<merge_sequential_files>(myfile, sort_keys_, metadata_));
      files_.push_back(file);
      file_buffer_index_[myfile.get()] = file.get();
    }

  }

  // This generic thing doesn't compile as the Handler type seems to confuse boost::bind.  Removing the
  // Handler template parameter seems to fix the problem.
  // TODO: Understand the issue better and see if we can restore the Handler template parameter.
//   template <typename Async_File, typename Mutable_Buffers, typename Handler>
//   void async_read(Async_File& async_file, const Mutable_Buffers& buffers, boost::uint64_t offset, Handler handler)
//   {
//     read_queue_.push_back(boost::bind(&Async_File::async_read<Mutable_Buffers, Handler>,
//                                       &async_file,
//                                       boost::cref(buffers),
//                                       offset, 
//                                       handler));
//   }   

  typedef boost::function2<void, asio::error, std::size_t> my_handler;
  template <class Async_File, class Mutable_Buffers>
  void async_read(Async_File& async_file, 
                  const Mutable_Buffers & buffers,
                  boost::uint64_t offset, 
                  my_handler handler)
  {
    read_queue_.push_back(boost::bind(
                            &Async_File::async_read<Mutable_Buffers, my_handler>,
                            &async_file,
                            boost::cref(buffers),
                            offset, 
                            handler));
  }       

  void start()
  {
    state_ = START;
    handle_read(*files_.front()->file().get(), 0, 0);
  }

  void resume_write()
  {
    ASSERT(state_ == WRITE);
    handle_read(*files_.front()->file().get(), 0, 0);
  }

  void handle_read(sort_run_read_file<merge_sequential_files>& file,
                   const asio::error& err,
                   size_t bytes_transferred)
  {
    // State machine.
    switch(state_)
    {
    case START:
      // Fill up initial request queue.
    {
      for(std::vector<boost::shared_ptr<active_file<merge_sequential_files> > >::iterator it = files_.begin();
          it != files_.end();
          ++it)
      {
        (*it)->file()->start(*this);
        no_initial_data_.insert(it->get());
      }
    }

    // First things first.  Wait for every file to
    // get a block.
    while(no_initial_data_.size() > 0)
    {
      if (ios_outstanding_ >= MAX_IOS_OUTSTANDING || 
          read_queue_.size() == 0)
      {
        state_ = INIT_WAIT_FOR_COMPLETION;
        return;
      case INIT_WAIT_FOR_COMPLETION:
        if (err != asio::error::success &&
            err != asio::error::eof)
        {
          throw err;
        }
        active_file<merge_sequential_files> * afile = file_buffer_index_.find(&file)->second;
        afile->handle_read(*this, err, bytes_transferred);
        no_initial_data_.erase(afile);
        active_files_.insert(afile);
        ios_outstanding_ -= 1;
      }
      if (read_queue_.size() > 0)
      {
        read_queue_.front()();
        read_queue_.pop_front();
        ios_outstanding_ += 1;
      }
    }

    // Pull first record from each block and initialize the priority queue
    {
      for(std::set<active_file<merge_sequential_files> *>::iterator it = active_files_.begin();
          it != active_files_.end();
          ++it)
      {
        merger_.push(create_queue_element(*it));
      }
    }


    while(active_files_.size() > 0)
    {
      // Extract records from the buffers and perform 
      // merge.  When a buffer is exhausted, wait for 
      // callback to give a new one.
      loop_ += 1;

      // Output the message.
      top_ = merger_.top();

#ifdef VALIDATE_SORT
      // Check that sort order is obtained
      if(!check_.check(message()))
      {
        // Dump state of merge 
        std::stringstream ss;
        dump(ss);
        MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
        logger->logError(ss.str());
        throw std::logic_error(check_.error());
      }
#endif

      // Use intrusive list of message to send a list into the
      // queue (amortize concurrency overhead).
      // Clone the record to get it out of I/O buffer.
      // This is also clearing the next message member which
      // was being used for size on disk.
      // Careful to preserve the order of records by appending to end.
      // This is done with a circular list.
      {
//         MessagePtr tmp = metadata_.Clone(message());
        MessagePtr tmp = message();
        if (local_message_end_ != NULL)
        {
          RecordMetadata::SetNext(tmp, RecordMetadata::GetNext(local_message_end_));
          RecordMetadata::SetNext(local_message_end_, tmp);
        }
        else
        {
          RecordMetadata::SetNext(tmp, tmp);
        }
        local_message_end_ = tmp;
        if (++locally_queued_ >= 100)
        {
          // We are using a circular list here.  When sending it over it should not be.
          MessagePtr head = RecordMetadata::GetNext(local_message_end_);
          RecordMetadata::SetNext(local_message_end_, NULL);
          local_message_end_ = NULL;
          locally_queued_ = 0;
          output_queue_->push(head);
        }
      }

      // Pop the top.
      merger_.pop();
      // Advance cursor, checking to see if we are at the last message.
      if (top_.active_file()->advance())
      {
        // Create a new key element/calculate new key prefix.
        top_ = create_queue_element(top_.active_file());
        // Push the next element in the block.
        merger_.push(top_);
      }
      else
      {
        top_.active_file()->handle_buffer_complete(*this);
        // If this last block was EOF, remove from active and continue.
        if (!top_.active_file()->file()->has_data() &&
            top_.active_file()->file()->eof())
        {
          active_files_.erase(top_.active_file());
        }
        else
        {
          // Can't do anything until more data is here, so pump away.
          // Note that we complete with a 0 length read/EOF.
          while(!top_.active_file()->file()->has_data() &&
                !top_.active_file()->file()->eof())
          {
            if (ios_outstanding_ >= MAX_IOS_OUTSTANDING || 
                read_queue_.size() == 0)
            {
              state_ = WAIT_FOR_COMPLETION;
              return;
            case WAIT_FOR_COMPLETION:
              active_file<merge_sequential_files> * afile = file_buffer_index_.find(&file)->second;
              afile->handle_read(*this, err, bytes_transferred);
              ios_outstanding_ -= 1;
            }
            if (read_queue_.size() > 0)
            {
              read_queue_.front()();
              read_queue_.pop_front();
              ios_outstanding_ += 1;
            }
          }

          // Push the first record in the block.
          if (!top_.active_file()->file()->eof())
          {
            // Create a new key element/calculate new key prefix.
            top_ = create_queue_element(top_.active_file());
            merger_.push(top_);
          }
          else
          {
            active_files_.erase(top_.active_file());
          }
        }
      }
    }
    }

    // Write any final local stuff and then write null.
    if (local_message_end_ != NULL)
    {
      // We are using a ciruclar list here.  When sending it over it should not be.
      MessagePtr head = RecordMetadata::GetNext(local_message_end_);
      RecordMetadata::SetNext(local_message_end_, NULL);
      local_message_end_ = NULL;
      locally_queued_ = 0;
      output_queue_->push(head);
    }
    output_queue_->push(NULL);
  }

  State state() const
  {
    return state_;
  }

  MessagePtr message()
  {
    return merger_.top().active_file()->message();
  }

  void dump(std::ostream& ostr)
  {
    ostr << "======================================================================" << std::endl;
    ostr << "======================= Merge Dump ===================================" << std::endl;
    ostr << "======================================================================" << std::endl;
    ostr << "======================= Merge Top ===================================" << std::endl;
    if (NULL != message())
    {
      ostr << metadata_.PrintMessage(message()) << std::endl;
    }
    else
    {
      ostr << "No Record At Top" << std::endl;
    }
    
    ostr << "======================= Merge Records ===================================" << std::endl;
    // For each active file, spit out its current record
    for(std::vector<boost::shared_ptr<active_file<merge_sequential_files> > >::iterator it = files_.begin();
        it != files_.end();
        ++it)
    {
      if (NULL != (*it)->message())
      {
        if (active_files_.end() == active_files_.find(it->get()))
        {
          if (no_initial_data_.end() == no_initial_data_.find(it->get()))
          {
            ostr << "ERROR: record in file that is neither active nor pending first read." << std::endl;
          }
          else
          {
            ostr << "ERROR: record on pending first read file." << std::endl;
          }
        }
        ostr << metadata_.PrintMessage((*it)->message()) << std::endl;
      }
      else
      {
        if (active_files_.end() == active_files_.find(it->get()))
        {
          ostr << "No Record: Pending first read" << std::endl;
        }
        else
        {
          ostr << "ERROR: No Record on Active File" << std::endl;
        }
      }
    }
  }
};

RunTimeExternalSort::RunTimeExternalSort(std::wstring& name,
                                         const RecordMetadata& metadata,
                                         const std::vector<RunTimeSortKey>& sortKey,
                                         const std::wstring& tempDir,
                                         std::size_t allowedMemory)                           
  :
  RunTimeOperator(name),
  mMetadata(metadata),
  mRunTimeSortKeys(sortKey),
  mTempDir(tempDir),
  mKeyPrefixCompare(mRunTimeSortKeys),
  mAllowedMemory(allowedMemory)
{
}	

RunTimeExternalSort::RunTimeExternalSort()                        
  :
  mAllowedMemory(10*1024*1024),
  mKeyPrefixCompare(mRunTimeSortKeys)
{
}	

RunTimeExternalSort::~RunTimeExternalSort()
{
}

RunTimeOperatorActivation * RunTimeExternalSort::CreateActivation(Reactor * reactor, partition_t partition)
{
  return new RunTimeExternalSortActivation(reactor, partition, this);
}

RunTimeExternalSortActivation::RunTimeExternalSortActivation(Reactor *reactor, 
                                                             partition_t partition,
                                                             const RunTimeExternalSort * runTimeOperator)
  :
  RunTimeOperatorActivationImpl<RunTimeExternalSort>(reactor, partition, runTimeOperator),
  mState(START_SORT_RUNS),
  mInputMessage(NULL),
  mCurrentBuffer(0),
  mCurrentSortRunSize(0),
  mRecordCount(0LL)
{
}	

RunTimeExternalSortActivation::~RunTimeExternalSortActivation()
{
  for(std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > >::iterator it= mFiles.begin();
      it != mFiles.end();
      ++it)
  {
    if ((*it).get() != 0)
    {
      (*it)->close();
      boost::filesystem::remove(mFilenames[it - mFiles.begin()]);
      *it = boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> >();
    }
  }
}

void RunTimeExternalSortActivation::Start()
{
  mState = START_SORT_RUNS;
  HandleEvent(NULL);
}

void RunTimeExternalSortActivation::BuildSortRuns(Endpoint * in)
{
  switch (mState)
  { 
  case START_SORT_RUNS:
    // Generate sort runs
    while(true)
    {
      RequestRead(0);
      mState = READ;
      return;
    case READ:
      Read(mInputMessage, in);
      

      if (mOperator->mMetadata.IsEOF(mInputMessage))
      {
        // Finished reading.  Either we write a final sort run or
        // we have a pure in memory sort and can skip I/O altogether.
        mOperator->mMetadata.Free(mInputMessage);
        std::sort(mBuffers[mCurrentBuffer].begin(), mBuffers[mCurrentBuffer].end(), mOperator->mKeyPrefixCompare);

        // Are we doing an in-memory sort or are we do we already have sort runs
        // on disk.
        if (mFiles.size() > 0)
        {
          if (mBuffers[mCurrentBuffer].size() > 0)
          {
            DatabaseCommands cmds;
            std::wstring tempFile = cmds.GetTempTableName(L"\\mf_sort_");
            tempFile += L".tmp";
            tempFile = mOperator->mTempDir + tempFile;
            std::string utf8TempFile;
            ::WideStringToUTF8(tempFile, utf8TempFile);

            boost::filesystem::path full_path(utf8TempFile,
                                              boost::filesystem::native);
            while(boost::filesystem::exists(full_path))
            {
              // This should never happen since we are using UUIDs
              tempFile = cmds.GetTempTableName(L"\\mf_sort_");
              tempFile += L".tmp";
              tempFile = mOperator->mTempDir + tempFile;
              ::WideStringToUTF8(tempFile, utf8TempFile);

              full_path = boost::filesystem::path(utf8TempFile,
                                                  boost::filesystem::native);
            }
            mFiles.push_back(boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> >(new asio::basic_stream_file<asio::detail::win_iocp_file_service>(mService)));

            // Make sure we can create this file
            try
            {
              mFiles.back()->open(full_path.native_file_string());
            }
            catch(std::exception &e)
            {
              MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger(
                                            "[ExternalSort]");
              std::string err = "";
              if (e.what() != NULL)
              {
                err = e.what();
              }
              err = "An error occurred attempting to open: " +
                    full_path.native_file_string() + ". " + err;
              logger->logError(err);
              throw std::logic_error(err);
            }

            mFilenames.push_back(full_path);

            // Complete any pending async output of run file.
            if (mWriter.get() != NULL)
            {
              mWriter->join();
              mWriter = boost::shared_ptr<boost::thread> ();
            }
            // Start a new write.
            boost::function0<void> thread_func(boost::bind(&sort_run_file::write,
                                                           boost::ref(*mFiles.back().get()),
                                                           boost::cref(mOperator->mMetadata),
                                                           boost::cref(mBuffers[mCurrentBuffer])));
            mWriter = boost::shared_ptr<boost::thread>(new boost::thread(thread_func));
            mCurrentBuffer = (mCurrentBuffer + 1) % 2;
            // Rip through the buffer and free message memory.
            for(std::vector<Key>::iterator it = mBuffers[mCurrentBuffer].begin();
                it != mBuffers[mCurrentBuffer].end();
                ++it)
            {
              mOperator->mMetadata.Free(it->Record);
            }
            mBuffers[mCurrentBuffer].resize(0);
          }
          mState = START_FINAL_MERGE;
          WriteFinalMerge(NULL);
          return;
        }
        else
        {
          mState = START_IN_MEMORY_OUTPUT;
          WriteInMemorySort(NULL);
          return;
        }
      }

      // Keep statistics.
      mRecordCount += 1LL;

      // Export sort key prefix into quicksort buffer.
      if (mCurrentSortRunSize + mOperator->mMetadata.GetRecordLength() > mOperator->mAllowedMemory)
      {
        mCurrentSortRunSize = 0;
        // Perform the quicksort and async output the run file to disk.
        std::sort(mBuffers[mCurrentBuffer].begin(), mBuffers[mCurrentBuffer].end(), mOperator->mKeyPrefixCompare);
        // Create a new temp file on disk.
        // TODO: Configuration for swap space.
        // TODO: Async open of file.
        DatabaseCommands cmds;

        std::wstring tempFile = cmds.GetTempTableName(L"\\mf_sort_");
        tempFile += L".tmp";
        tempFile = mOperator->mTempDir + tempFile;
        std::string utf8TempFile;
        ::WideStringToUTF8(tempFile, utf8TempFile);

        boost::filesystem::path full_path(utf8TempFile,
                                          boost::filesystem::native);

        // If file already exists, remove it.
        while(boost::filesystem::exists(full_path))
        {
          tempFile = cmds.GetTempTableName(L"\\mf_sort_");
          tempFile += L".tmp";
          tempFile = mOperator->mTempDir + tempFile;
          ::WideStringToUTF8(tempFile, utf8TempFile);

          full_path = boost::filesystem::path(utf8TempFile,
                                              boost::filesystem::native);
        }

        mFiles.push_back(boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> >(new asio::basic_stream_file<asio::detail::win_iocp_file_service>(mService)));

        // Make sure we can create this file
        try
        {
          mFiles.back()->open(full_path.native_file_string());
        }
        catch(std::exception &e)
        {
          MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger(
                                        "[ExternalSort]");
          std::string err = "";
          if (e.what() != NULL)
          {
            err = e.what();
          }
          err = "An error occurred attempting to open: " +
                full_path.native_file_string() + ". " + err;
          logger->logError(err);
          throw std::logic_error(err);
        }

        mFilenames.push_back(full_path);

        // Complete any pending async output of run file.
        if (mWriter.get() != NULL)
        {
          mWriter->join();
          mWriter = boost::shared_ptr<boost::thread> ();
        }
        // Start a new write.
        boost::function0<void> thread_func (boost::bind(&sort_run_file::write,
                                                        boost::ref(*mFiles.back().get()),
                                                        boost::cref(mOperator->mMetadata),
                                                        boost::cref(mBuffers[mCurrentBuffer])));
        mWriter = boost::shared_ptr<boost::thread>(new boost::thread(thread_func));
        // Reuse other buffer.
        mCurrentBuffer = (mCurrentBuffer + 1) % 2;
        // Rip through the buffer and free message memory.
        for(std::vector<Key>::iterator it = mBuffers[mCurrentBuffer].begin();
            it != mBuffers[mCurrentBuffer].end();
            ++it)
        {
          mOperator->mMetadata.Free(it->Record);
        }
        mBuffers[mCurrentBuffer].resize(0);
      }

      // Export the conditioned key prefix
      for (std::vector<RunTimeSortKey>::const_iterator sortKeyIt = mOperator->mRunTimeSortKeys.begin();
           sortKeyIt != mOperator->mRunTimeSortKeys.end();
           sortKeyIt++)
      {
        sortKeyIt->GetDataAccessor()->ExportSortKey(mInputMessage, sortKeyIt->GetSortOrder(), mSortKeyBuffer);
      }

      // Copy the conditioned key prefix and the record pointer into the quicksort buffer.
      mCurrentSortRunSize += mOperator->mMetadata.GetRecordLength();
      // To compare as boost::uint32_t we need to reorder bytes.
      boost::uint32_t p;
      ((boost::uint8_t *)&p)[0] = mSortKeyBuffer.GetKey()[3];
      ((boost::uint8_t *)&p)[1] = mSortKeyBuffer.GetKey()[2];
      ((boost::uint8_t *)&p)[2] = mSortKeyBuffer.GetKey()[1];
      ((boost::uint8_t *)&p)[3] = mSortKeyBuffer.GetKey()[0];

      Key k = {p, mInputMessage};
      mBuffers[mCurrentBuffer].push_back(k);
      mSortKeyBuffer.Clear();
    }
  }
}

void RunTimeExternalSortActivation::WriteInMemorySort(Endpoint * in)
{
  switch (mState)
  { 
  case START_IN_MEMORY_OUTPUT:
    // Output the result of an in-memory sort operation directly from sorted buffer.
    while(true)
    {
      for(mBufferIt = mBuffers[mCurrentBuffer].begin();
          mBufferIt != mBuffers[mCurrentBuffer].end();
          ++mBufferIt)
      {
				mReactor->RequestWrite(this, mOutputs[0]);
				mState = WRITE_IN_MEMORY_OUTPUT;
				return;
      case WRITE_IN_MEMORY_OUTPUT:
        Write(mBufferIt->Record, in);
      }
      
      mReactor->RequestWrite(this, mOutputs[0]);
      mState = WRITE_EOF_IN_MEMORY_OUTPUT;
      return;
    case WRITE_EOF_IN_MEMORY_OUTPUT:
      Write(mOperator->mMetadata.AllocateEOF(), in, true);
      return;
    }
  }
}

void RunTimeExternalSortActivation::WriteFinalMerge(Endpoint * in)
{
  switch(mState)
  {
  case START_FINAL_MERGE:
    if (mWriter)
    {
      mWriter->join();
      mWriter = boost::shared_ptr<boost::thread>();
    }
    {
        mCurrentBuffer = (mCurrentBuffer + 1) % 2;
        // Rip through the buffer and free message memory.
        for(std::vector<Key>::iterator it = mBuffers[mCurrentBuffer].begin();
            it != mBuffers[mCurrentBuffer].end();
            ++it)
        {
          mOperator->mMetadata.Free(it->Record);
        }
        mBuffers[mCurrentBuffer].resize(0);
    }
    mQueue = boost::shared_ptr<fifo> (new fifo());
    {
    boost::function0<void> thread_func (boost::bind(&merge_sequential_files::run,
                                                    boost::ref(mService),
                                                    boost::ref(mFiles),
                                                    boost::cref(mOperator->mMetadata),
                                                    boost::cref(mOperator->mRunTimeSortKeys),
                                                    mQueue));
    mWriter = boost::shared_ptr<boost::thread>(new boost::thread(thread_func));
    }
#ifdef VALIDATE_SORT
    mWhichBuffer=-1;
#endif
    while(true)
    {
      mQueue->pop(mInputMessage);
      if (NULL != mInputMessage)
      {
        while(mInputMessage != NULL)
        {
          RequestWrite(0);
          mState = WRITE_FINAL_MERGE;
          return;
        case WRITE_FINAL_MERGE:
        {
#ifdef VALIDATE_SORT
          // Validate that we are sorted.
          for (std::vector<RunTimeSortKey>::const_iterator sortKeyIt = mOperator->mRunTimeSortKeys.begin();
               sortKeyIt != mOperator->mRunTimeSortKeys.end();
               sortKeyIt++)
          {
            sortKeyIt->GetDataAccessor()->ExportSortKey(mInputMessage, 
                                                        sortKeyIt->GetSortOrder(), 
                                                        mValidationKeyBuffer[mWhichBuffer < 0 ? 0 : mWhichBuffer]);
          }
          if (mWhichBuffer >= 0)
          {
            if (0 < SortKeyBuffer::Compare(mValidationKeyBuffer[(mWhichBuffer + 1) % 2], mValidationKeyBuffer[mWhichBuffer]))
            {
              std::string err = (boost::format("SortKeyBuffer comparison failure: \n%1%\n%2%")
                                 % mOperator->mMetadata.PrintMessage(mLastMessage)
                                 % mOperator->mMetadata.PrintMessage(mInputMessage)).str();
              MetraFlowLoggerPtr logger = MetraFlowLoggerManager::GetLogger("[ExternalSort]");
              logger->logError(err);
              throw std::logic_error(err);
            }
            mWhichBuffer = (mWhichBuffer + 1) % 2;
            mValidationKeyBuffer[mWhichBuffer].Clear();
            // The code below is broken because we can't memcpy if there are strings.
            // We need to do a real Clone here.  Not sure why we are not calling Clone.
            ASSERT(FALSE);
            memcpy(mLastMessage, mInputMessage, mOperator->mMetadata.GetRecordLength());
          }
          else
          {
            mWhichBuffer = 1;
            mLastMessage = mOperator->mMetadata.Clone(mInputMessage);
          }
#endif

          MessagePtr tmp = mInputMessage;
          mInputMessage = RecordMetadata::GetNext(mInputMessage);
          RecordMetadata::SetNext(tmp, NULL);
          Write(tmp, in);
          mRecordCount -= 1LL;
          ASSERT(mRecordCount >= 0);
        }
        }
      } 
      else 
      {
        ASSERT(mRecordCount == 0);
        RequestWrite(0);
        mState = WRITE_EOF_FINAL_MERGE;
        return;
      case WRITE_EOF_FINAL_MERGE:
        Write(mOperator->mMetadata.AllocateEOF(), in, true);

        // Close and Free files
        for(std::vector<boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> > >::iterator it= mFiles.begin();
            it != mFiles.end();
            ++it)
        {
          if ((*it).get() != 0)
          {
            (*it)->close();
            boost::filesystem::remove(mFilenames[it - mFiles.begin()]);
            *it = boost::shared_ptr<asio::basic_stream_file<asio::detail::win_iocp_file_service> >();
          }
        }

        return;
      }
    }
  }
}

void RunTimeExternalSortActivation::HandleEvent(Endpoint * in) 
{
  // This is structured as a collection of sub-coroutines/sub-state machines.
  // Luckily the I/O patterns here are very simple so this decomposition is
  // relatively clean.  Note that in a given run, we'll either use IN_MEMORY_OUTPUT
  // or FINAL_MERGE, but never both.
  switch(mState)
  {
  case START_SORT_RUNS:
  case READ:
    return BuildSortRuns(in);
  case START_IN_MEMORY_OUTPUT:
  case WRITE_IN_MEMORY_OUTPUT:
  case WRITE_EOF_IN_MEMORY_OUTPUT:
    return WriteInMemorySort(in);
    // Intermediate merge passes write to new merge file.
    // TODO: Implement multi-pass sort.
  case START_FINAL_MERGE:
  case WRITE_FINAL_MERGE:
  case WRITE_EOF_FINAL_MERGE:
    return WriteFinalMerge(in);
  }
}

  
