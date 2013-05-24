#ifndef __ASYNCFILE_H__
#define __ASYNCFILE_H__

#include <deque>

template <class _Scheduler>
class sort_run_read_file
{
public:
  // The underlying file
  asio::basic_stream_file<asio::detail::win_iocp_file_service>& file_;
  // Where are we in the file?
  boost::uint64_t file_pointer_;
  // My two buffers to read into.
  boost::array<std::vector<boost::uint8_t>,2> buffer_;
  // Sector aligned front of the buffer.
  boost::array<boost::uint8_t *, 2> buffer_begin_;
  // End of valid data in the buffers
  boost::array<boost::uint8_t *, 2> buffer_end_;
  // Size of the aligned buffer
  boost::array<std::size_t, 2> buffer_size_;
  // ASIO buffer for reads
  boost::array<asio::mutable_buffer, 2> asio_buffer_;
  // Arrgh!!! The ASIO buffer model is totally annoying!
  boost::array<boost::shared_ptr<asio::mutable_buffer_container_1>, 2> asio_buffer_container_;
//   // State of the underlying buffers.
//   enum BufferState { EMPTY, PENDING, FULL };
//   boost::array<BufferState,2> buffer_state_;
  // Are we at EOF?
  bool eof_;
  // Empty buffers
  std::deque<std::size_t> free_buffers_;
  // Only one outstanding I/O allowed.
  std::deque<std::size_t> pending_buffers_;
  // Which buffer is currently queued for reading.
  std::deque<std::size_t> full_buffers_;
  // Is this file completely read?
  bool eof() const
  {
    return eof_;
  }
  // Is there a full buffer?
  bool has_data() const
  {
    return full_buffers_.size() > 0;
  }
  boost::uint8_t * begin()
  {
    return buffer_begin_[full_buffers_.front()];
  }
  boost::uint8_t * end()
  {
    return buffer_end_[full_buffers_.front()];
  }
  
  
  

  sort_run_read_file(asio::basic_stream_file<asio::detail::win_iocp_file_service>& file,
                     std::size_t transferSize)
    :
    file_(file),
    file_pointer_(0LL),
    eof_(false)
  {
    for(std::vector<boost::uint8_t> * it = buffer_.begin();
        it != buffer_.end();
        ++it)
    {
      // Make sure we have sector aligned buffers.
      it->assign(transferSize+4096-1, 0);
      buffer_begin_[it - buffer_.begin()] = 
        reinterpret_cast<boost::uint8_t *>(4096*((reinterpret_cast<size_t>(&buffer_[it - buffer_.begin()].front()) + 4096 - 1)/4096));
//       buffer_state_[it - buffer_.begin()] = EMPTY;
      buffer_end_[it - buffer_.begin()] = buffer_begin_[it - buffer_.begin()];
      buffer_size_[it - buffer_.begin()] = transferSize;
      free_buffers_.push_back(it - buffer_.begin());
    }
  }

  void read_block(_Scheduler& rsf)
  {
    // Can only read if there are no pending and there is free
    if (free_buffers_.size() > 0 &&
        pending_buffers_.size() == 0 &&
        !eof_)
    {
      std::size_t next_buffer_selector = free_buffers_.front();
      free_buffers_.pop_front();
      asio_buffer_[next_buffer_selector] = asio::mutable_buffer(buffer_begin_[next_buffer_selector], 
                                                                buffer_size_[next_buffer_selector]);
      asio_buffer_container_[next_buffer_selector] = 
        boost::shared_ptr<asio::mutable_buffer_container_1>(new asio::mutable_buffer_container_1(asio_buffer_[next_buffer_selector]));
      rsf.async_read(file_,
                     *asio_buffer_container_[next_buffer_selector].get(),
                     file_pointer_, 
                     boost::bind(&_Scheduler::handle_read, 
                                 &rsf, 
                                 boost::ref(*this),
                                 asio::placeholders::error, 
                                 asio::placeholders::bytes_transferred));
      pending_buffers_.push_back(next_buffer_selector);
    }
  }

  // Start this state machine.
  void start(_Scheduler& rsf)
  {
    read_block(rsf);
  }

  // A read has been serviced.
  void handle_read(_Scheduler& rsf, 
                   const asio::error& err,
                   size_t bytes_transferred)
  {
    ASSERT(pending_buffers_.size() == 1);
    std::size_t tmp = pending_buffers_.front();
    pending_buffers_.pop_front();
    full_buffers_.push_back(tmp);
    buffer_end_[tmp] = buffer_begin_[tmp] + bytes_transferred;
    file_pointer_ += bytes_transferred;
    eof_ = err == asio::error::eof;
    read_block(rsf);
    ASSERT(full_buffers_.size() > 0);
    ASSERT(pending_buffers_.size() <= 1);
  }                   

  // A full buffer has been freed.  
  void handle_buffer_complete(_Scheduler& rsf)
  {
    ASSERT(full_buffers_.size() > 0);
    std::size_t tmp = full_buffers_.front();
    full_buffers_.pop_front();
    free_buffers_.push_back(tmp);
    buffer_end_[tmp] = buffer_begin_[tmp];
    // If there is no read request outstanding and not at eof, then read.
    read_block(rsf);
    ASSERT(pending_buffers_.size() <= 1);
  }
};

#endif
