
#ifndef ASIO_DETAIL_WIN_IOCP_FILE_SERVICE_HPP
#define ASIO_DETAIL_WIN_IOCP_FILE_SERVICE_HPP

#include "asio/detail/push_options.hpp"
#include "asio/detail/win_iocp_io_service.hpp"
#include "asio/error.hpp"

namespace asio {
namespace detail {

class win_iocp_file_service
  : public asio::io_service::service
{
public:

  // Base class for all operations.
  typedef win_iocp_operation operation;

  typedef HANDLE native_type;

  class implementation_type
  {
  public:
    implementation_type()
      :
      file_(INVALID_HANDLE_VALUE)
    {
    }

    bool operator == (const implementation_type& rhs) const
    {
      return this->file_ == rhs.file_;
    }
    bool operator != (const implementation_type& rhs) const
    {
      return this->file_ != rhs.file_;
    }
  private:
    friend class win_iocp_file_service;
    
    native_type file_;
  };

  static implementation_type null()
  {
    return implementation_type();
  }

  // Constructor.
  win_iocp_file_service(asio::io_service& io_service)
    : asio::io_service::service(io_service),
      iocp_service_(asio::use_service<win_iocp_io_service>(io_service))
  {
  }

  template <typename Error_Handler>
  void open(implementation_type& impl, const std::string& filename, Error_Handler error_handler)
  {
    DWORD desiredAccess = GENERIC_WRITE | GENERIC_READ;
    DWORD sharedMode = FILE_SHARE_WRITE;
    DWORD creation = OPEN_ALWAYS;
    impl.file_ = ::CreateFileA(filename.c_str(), 
                         desiredAccess, 
                         sharedMode, 
                         NULL, 
                         creation, 
                         FILE_ATTRIBUTE_NORMAL | FILE_FLAG_OVERLAPPED, 
                         NULL);
    DWORD err = ::GetLastError();
    if (impl == null())
    {
      error_handler(asio::error(err));
      return;
    }
    iocp_service_.register_socket((socket_type) impl.file_);
  }

  // Destroy all user-defined handler objects owned by the service.
  void shutdown_service()
  {
    // Close all implementations, causing all operations to complete.
//     asio::detail::mutex::scoped_lock lock(mutex_);
//     implementation_type* impl = impl_list_;
//     while (impl)
//     {
//       close(*impl, asio::ignore_error());
//       impl = impl->next_;
//     }
  }

  // Construct a new file implementation.
  void construct(implementation_type& impl)
  {
    impl.file_ = INVALID_HANDLE_VALUE;

    // Insert implementation into linked list of all implementations.
//     asio::detail::mutex::scoped_lock lock(mutex_);
//     impl.next_ = impl_list_;
//     impl.prev_ = 0;
//     if (impl_list_)
//       impl_list_->prev_ = &impl;
//     impl_list_ = &impl;
  }

  // Destroy a socket implementation.
  void destroy(implementation_type& impl)
  {
    close(impl, asio::ignore_error());

    // Remove implementation from linked list of all implementations.
//     asio::detail::mutex::scoped_lock lock(mutex_);
//     if (impl_list_ == &impl)
//       impl_list_ = impl.next_;
//     if (impl.prev_)
//       impl.prev_->next_ = impl.next_;
//     if (impl.next_)
//       impl.next_->prev_= impl.prev_;
//     impl.next_ = 0;
//     impl.prev_ = 0;
  }

  template <typename Error_Handler>
  void close(implementation_type& impl, Error_Handler error_handler)
  {
    if(impl != null()) {
      ::CloseHandle(impl.file_);
      impl = null();
    }
  }

  template <typename Const_Buffers, typename ErrorHandlerT>
  size_t write(implementation_type& impl,  const Const_Buffers& buffers,
               ErrorHandlerT error_handler)
  {
    asio::const_buffer buffer(*buffers.begin());
    const char * lpBuffer = asio::buffer_cast<const char*>(buffer);
    std::size_t bufSz = asio::buffer_size(buffer);
    DWORD nNumberOfBytesToWrite = bufSz < std::numeric_limits<DWORD>::max() ? static_cast<DWORD>(bufSz) : std::numeric_limits<DWORD>::max();
    OVERLAPPED overlapped;
    overlapped.Internal = 0;
    overlapped.InternalHigh = 0;
    overlapped.Offset = 0;
    overlapped.OffsetHigh = 0;
    overlapped.hEvent = 0;

    BOOL ret = ::WriteFile(impl.file_, 
                           lpBuffer, 
                           nNumberOfBytesToWrite,
                           NULL, 
                           &overlapped);
    DWORD err = ::GetLastError();
    if(FALSE == ret) {
      if (err != ERROR_IO_PENDING)
      {
        error_handler(asio::error(err));
        return 0;
      }
    }

    DWORD bytes_written=0;
    ret = ::GetOverlappedResult(impl.file_, &overlapped, &bytes_written, TRUE);
    err = ::GetLastError();
    if (ret != TRUE)
    {
      error_handler(asio::error(err));
      return 0;
    }
    return bytes_written;
  }

  template <typename Mutable_Buffers, typename ErrorHandlerT>
  size_t read(implementation_type& impl, const Mutable_Buffers& buffers,
              ErrorHandlerT error_handler)
  {
    DWORD bytes_read; 
    BOOL ret = ::ReadFile(impl.file_, data, length, &bytes_read, 0);
    DWORD err = ::GetLastError();
    if(FALSE == ret) {
      error_handler(asio::error(err));
      return 0;
    }
    return bytes_read;
  }

  template <typename Const_Buffers, typename Handler>
  class read_write_operation
    : public operation
  {
  public:
    read_write_operation(asio::io_service& io_service,
                         const Const_Buffers& buffers, 
                         Handler handler)
      : operation(
          &read_write_operation<Const_Buffers, Handler>::do_completion_impl,
          &read_write_operation<Const_Buffers, Handler>::destroy_impl),
        work_(io_service),
        buffers_(buffers),
        handler_(handler)
    {
    }

  private:
    static void do_completion_impl(operation* op,
        DWORD last_error, size_t bytes_transferred)
    {
      // Take ownership of the operation object.
      typedef read_write_operation<Const_Buffers, Handler> op_type;
      op_type* handler_op(static_cast<op_type*>(op));
      typedef handler_alloc_traits<Handler, op_type> alloc_traits;
      handler_ptr<alloc_traits> ptr(handler_op->handler_, handler_op);

      // Check for connection closed.
      if (last_error == ERROR_HANDLE_EOF ||
          (last_error == 0 && bytes_transferred == 0))
      {
        last_error = asio::error::eof;
      }
      // Make a copy of the handler so that the memory can be deallocated before
      // the upcall is made.
      Handler handler(handler_op->handler_);

      // Free the memory associated with the handler.
      ptr.reset();

      // Call the handler.
      asio::error error(last_error);
      handler(error, bytes_transferred);
    }

    static void destroy_impl(operation* op)
    {
      // Take ownership of the operation object.
      typedef read_write_operation<Const_Buffers, Handler> op_type;
      op_type* handler_op(static_cast<op_type*>(op));
      typedef handler_alloc_traits<Handler, op_type> alloc_traits;
      handler_ptr<alloc_traits> ptr(handler_op->handler_, handler_op);
    }

    asio::io_service::work work_;
    Const_Buffers buffers_;
    Handler handler_;
  };

  // Starts an asynchronous write. The data being writed must be valid for the
  // lifetime of the asynchronous opereation. (This function was "copied" from
  // the reactive_stream_socket_service::async_send
  template <typename Const_Buffers, typename Handler>
  void async_write(implementation_type& impl, const Const_Buffers& buffers, boost::uint64_t offset,
                   Handler handler)
  {
    if (impl == null()) {
      asio::error error(asio::error::bad_descriptor);
      iocp_service_.post(bind_handler(handler, error, 0));
    }
    else {
      // Allocate and construct an operation to wrap the handler.
      typedef read_write_operation<Const_Buffers, Handler> value_type;
      typedef handler_alloc_traits<Handler, value_type> alloc_traits;
      raw_handler_ptr<alloc_traits> raw_ptr(handler);
      handler_ptr<alloc_traits> ptr(raw_ptr,
                                    owner(),
                                    buffers, 
                                    handler);

      ptr.get()->Offset = (DWORD) (offset & 0x00000000ffffffff);
      ptr.get()->OffsetHigh = (DWORD) ((offset & 0xffffffff00000000) >> 32);
      typename Const_Buffers::const_iterator iter = buffers.begin();
      typename Const_Buffers::const_iterator end = buffers.end();
      asio::const_buffer buffer(*iter);
      DWORD bytes_transferred=0;
      std::size_t bufSz = asio::buffer_size(buffer);
      DWORD nNumberOfBytesToWrite = bufSz < std::numeric_limits<DWORD>::max() ? static_cast<DWORD>(bufSz) : std::numeric_limits<DWORD>::max();
      BOOL ret = ::WriteFile(impl.file_, 
                             asio::buffer_cast<const char*>(buffer), 
                             nNumberOfBytesToWrite, 
                             &bytes_transferred,
                             ptr.get());
      DWORD err = ::GetLastError();
      if(ret != TRUE && err != ERROR_IO_PENDING) {
        ptr.reset();
        asio::error error(err);
        iocp_service_.post(bind_handler(handler, error, bytes_transferred));
      }
      else
      {
        ptr.release();
      }
    }
  }

  // Start an asynchronous read. The buffer for the data being readed
  // must be valid for the lifetime of the asynchronous operation.
  // (This function was "copied" from the
  // reactive_stream_socket_service::async_read)
  template <typename Mutable_Buffers, typename Handler>
  void async_read(implementation_type& impl, const Mutable_Buffers& buffers, boost::int64_t offset,
                  Handler handler)
  {
    if (impl == null()) {
      asio::error error(asio::error::bad_descriptor);
      iocp_service_.post(bind_handler(handler, error, 0));
    }
    else {
      // Allocate and construct an operation to wrap the handler.
      typedef read_write_operation<Mutable_Buffers, Handler> value_type;
      typedef handler_alloc_traits<Handler, value_type> alloc_traits;
      raw_handler_ptr<alloc_traits> raw_ptr(handler);
      handler_ptr<alloc_traits> ptr(raw_ptr,
                                    owner(),
                                    buffers, 
                                    handler);

      ptr.get()->Offset = (DWORD) (offset & 0x00000000ffffffff);
      ptr.get()->OffsetHigh = (DWORD) ((offset & 0xffffffff00000000) >> 32);
      DWORD bytes_transferred=0;
      typename Mutable_Buffers::const_iterator iter = buffers.begin();
      typename Mutable_Buffers::const_iterator end = buffers.end();
      asio::mutable_buffer buffer(*iter);
      std::size_t bufSz = asio::buffer_size(buffer);
      DWORD nNumberOfBytesToRead = bufSz < std::numeric_limits<DWORD>::max() ? static_cast<DWORD>(bufSz) : std::numeric_limits<DWORD>::max();
      BOOL ret = ::ReadFile(impl.file_, 
                            asio::buffer_cast<char*>(buffer), 
                            nNumberOfBytesToRead, 
                            &bytes_transferred,
                            ptr.get());
      DWORD err = ::GetLastError();
      if(ret != TRUE && err != ERROR_IO_PENDING) {
        ptr.reset();
        asio::error error(err);
        iocp_service_.post(bind_handler(handler, error, bytes_transferred));
      }
      else
      {
        ptr.release();
      }
    }
  }

  // size_t in_avail(implementation_type& impl, ErrorHandlerT error_handler)

private:

  // The IOCP service used for running asynchronous operations and dispatching
  // handlers.
  win_iocp_io_service& iocp_service_;
};

} }

#include "asio/detail/pop_options.hpp"
#endif

