
#ifndef ASIO_BASIC_STREAM_FILE_HPP
#define ASIO_BASIC_STREAM_FILE_HPP

#include "asio/detail/push_options.hpp"

#include <boost/noncopyable.hpp>
#include <boost/static_assert.hpp>

namespace asio {

template <typename Service>
class basic_stream_file
  : public basic_io_object<Service>
{
public:
  /// The type used for reporting errors.
  typedef asio::error error_type;

  // A basic_stream_file is always the lowest layer
  typedef basic_stream_file<Service> lowest_layer_type;

  // The native representation of a file.
  typedef typename Service::native_type native_type;

  basic_stream_file(asio::io_service& io_service)
    : basic_io_object<Service>(io_service)
  {}

  ~basic_stream_file()
  {
    close();
  }

  void close()
  {
    this->service.close(this->implementation, throw_error());
  }

  /// Get a reference to the lowest layer.
  lowest_layer_type& lowest_layer()
  {
    return *this;
  }

  /// Get the underlying implementation in the native type.
  implementation_type impl()
  {
    return this->implementation;
  }

  /// Set the underlying implementation in the native type.
  void open(const std::string& filename)
  {
    this->service.open(this->implementation, filename, throw_error());
  }

  /// Start an asynchronous write.
  template <typename Const_Buffers, typename Handler>
  void async_write(const Const_Buffers& buffers, boost::uint64_t offset, Handler handler)
  {
    this->service.async_write(this->implementation, buffers, offset, handler);
  }

  template <typename Const_Buffers>
  size_t write(const Const_Buffers& buffers)
  {
    return this->service.write(this->implementation, buffers, throw_error());
  }

  template <typename Const_Buffers, typename ErrorHandlerT>
  size_t write(const Const_Buffers& buffers, ErrorHandlerT error_handler)
  {
    return this->service.write(this->implementation, buffers, error_handler);
  }

  template <typename Mutable_Buffers, typename Handler>
  void async_read(const Mutable_Buffers& buffers, boost::uint64_t offset, Handler handler)
  {
    this->service.async_read(this->implementation, buffers, offset, handler);
  }

  template <typename Mutable_Buffers>
  size_t read(const Mutable_Buffers& buffers)
  {
    return this->service.read(this->implementation, buffers, throw_error());
  }

  template <typename Mutable_Buffers, typename ErrorHandlerT>
  size_t read(const Mutable_Buffers& buffers, ErrorHandlerT error_handler)
  {
    return this->service.read(this->implementation, buffers, error_handler);
  }

  // size_t in_avail(ErrorHandlerT error_handler)
};

} // namespace asio

#include "asio/detail/pop_options.hpp"
#endif
