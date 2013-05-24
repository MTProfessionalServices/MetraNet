#define NOMINMAX
#include <metra.h>
#include <boost/test/test_tools.hpp>

#include <ctime>
#include <iostream>
#include <string>
#include <boost/bind.hpp>
#include <boost/format.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/enable_shared_from_this.hpp>
#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <asio.hpp>

#include "basic_stream_file.hpp"
#include "detail/win_iocp_file_service.hpp"
#include "AsyncFile.h"

using asio::ip::tcp;

std::string make_daytime_string()
{
  using namespace std; // For time_t, time and ctime;
  time_t now = time(0);
  return ctime(&now);
}

class tcp_connection
  : public boost::enable_shared_from_this<tcp_connection>
{
public:
  typedef boost::shared_ptr<tcp_connection> pointer;

  static pointer create(asio::io_service& io_service)
  {
    return pointer(new tcp_connection(io_service));
  }

  tcp::socket& socket()
  {
    return socket_;
  }

  void start()
  {
    message_ = make_daytime_string();

    asio::async_write(socket_, asio::buffer(message_),
        boost::bind(&tcp_connection::handle_write, shared_from_this(),
          asio::placeholders::error,
          asio::placeholders::bytes_transferred));
  }

private:
  tcp_connection(asio::io_service& io_service)
    : socket_(io_service)
  {
  }

  void handle_write(const asio::error& /*error*/,
      size_t /*bytes_transferred*/)
  {
  }

  tcp::socket socket_;
  std::string message_;
};

class tcp_server
{
public:
  tcp_server(asio::io_service& io_service)
    : acceptor_(io_service, tcp::endpoint(tcp::v4(), 13))
  {
    start_accept();
  }

private:
  void start_accept()
  {
    tcp_connection::pointer new_connection =
      tcp_connection::create(acceptor_.io_service());

    acceptor_.async_accept(new_connection->socket(),
        boost::bind(&tcp_server::handle_accept, this, new_connection,
          asio::placeholders::error));
  }

  void handle_accept(tcp_connection::pointer new_connection,
      const asio::error& error)
  {
    if (!error)
    {
      new_connection->start();
      start_accept();
    }
  }

  tcp::acceptor acceptor_;
};

void test_socket_server()
{
  asio::io_service io_service;
  tcp_server server(io_service);
  io_service.run();
}

class create_sequential_file
{
private:
  enum { TRANSFER_SIZE=32*1024 };
  asio::basic_stream_file<asio::detail::win_iocp_file_service> file_;
  std::string& buffer_;
  std::size_t buffer_pointer_;

  void write_block()
  {
    std::size_t bytes_to_write(std::min<std::size_t>(TRANSFER_SIZE, buffer_.size()-buffer_pointer_));
    file_.async_write(asio::buffer(&buffer_[buffer_pointer_], bytes_to_write), 
                      buffer_pointer_, 
                      boost::bind(&create_sequential_file::handle_write, 
                                  this, 
                                  asio::placeholders::error, 
                                  asio::placeholders::bytes_transferred));
    buffer_pointer_ += bytes_to_write;
  }

public:
  create_sequential_file(asio::io_service & service,
                         boost::filesystem::path& full_path,
                         std::string& buffer)
    :
    file_(service),
    buffer_(buffer),
    buffer_pointer_(0)
  {
    file_.open(full_path.native_file_string());
  
    // Start with some number of outstanding I/Os
    write_block();
    write_block();
    write_block();
  }
  void handle_write(const asio::error& error,
                    size_t bytes_transferred)
  {
//     if (!error)
//     {
//       throw error;
//     }
    // Can we detect short writes?
    if (buffer_pointer_ < buffer_.size())
    {
      write_block();
    }
  }
};

class default_read_scheduler
{
private:
  enum State { START, READ_WAIT };
  State state_;
  std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > > files_;
  boost::uint64_t total_bytes_;
  std::size_t files_eof_;
public:
  default_read_scheduler(const std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > >& files)
    :
    files_(files),
    total_bytes_(0),
    files_eof_(0)
  {
  }

  boost::uint64_t total_bytes() const
  {
    return total_bytes_;
  }

  void start()
  {
    files_eof_ = 0;
    state_ = START;
    handle_read(*files_.back().get(), asio::error(), 0);
  }
  void handle_read(sort_run_read_file<default_read_scheduler>& srrf,
                   const asio::error& err,
                   size_t bytes_transferred)
  {
    switch(state_)
    {
    case START:
    {
      for(std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > >::iterator it = files_.begin();
          it != files_.end();
          ++it)
      {
        (*it)->start(*this);
      }
    }
    // Main reading loop.
    while(files_eof_ < files_.size())
    {
      state_ = READ_WAIT;
      return;
    case READ_WAIT:
      srrf.handle_read(*this, err, bytes_transferred);
      total_bytes_ += bytes_transferred;
      if (err == asio::error::eof)
      {
        files_eof_ += 1;
      }
      // Don't do anything to the buffer.
      srrf.handle_buffer_complete(*this);
    }
    }
  }
  template <typename Async_File, typename Mutable_Buffers, typename Handler>
  void async_read(Async_File& async_file, const Mutable_Buffers& buffers, boost::uint64_t offset, Handler handler)
  {
    async_file.async_read(buffers, offset, handler);
  }                   
};

int test_main( int argc, char * argv[] )
{
  asio::io_service io_service;
//   asio::basic_stream_file<asio::detail::win_iocp_file_service> file(io_service);
//   file.open(full_path.native_file_string());
//   std::string msg1("Welcome Boost ASIO!\n");
//   std::string msg2("Take me to your leader.\n");
  
//   file.async_write(asio::buffer(msg1), 0LL, &handle_file_write);
//   file.async_write(asio::buffer(msg2), msg1.size(), &handle_file_write);
//   test_socket_server();
  boost::filesystem::path full_path( boost::filesystem::initial_path() );
  full_path = boost::filesystem::system_complete(boost::filesystem::path("foo.txt", 
                                                                         boost::filesystem::native));

  {
    std::string msg1("Welcome Boost ASIO!\nTake me to your leader.\n");
    create_sequential_file file(io_service, full_path, msg1);

    boost::filesystem::path full_path2( boost::filesystem::initial_path() );
    full_path2 = boost::filesystem::system_complete(boost::filesystem::path("foo2.txt", 
                                                                            boost::filesystem::native));
    std::string msg2(100*1024*1024,'1');
    create_sequential_file file2(io_service, full_path2, msg2);
    
    io_service.run();
  }
  {
    io_service.reset();
    asio::basic_stream_file<asio::detail::win_iocp_file_service> myfile(io_service);
    myfile.open(full_path.native_file_string());
    std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > > files;
    files.push_back(boost::shared_ptr<sort_run_read_file<default_read_scheduler> >(new sort_run_read_file<default_read_scheduler> (myfile,32*1024)));
    default_read_scheduler drs(files);
    drs.start();
    io_service.run();
    BOOST_REQUIRE_EQUAL(44LL, drs.total_bytes());
  }
  {
    io_service.reset();
    asio::basic_stream_file<asio::detail::win_iocp_file_service> myfile(io_service);
    boost::filesystem::path full_path2(boost::filesystem::system_complete(boost::filesystem::path("foo2.txt", 
                                                                                                  boost::filesystem::native)));
    myfile.open(full_path2.native_file_string());
    std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > > files;
    files.push_back(boost::shared_ptr<sort_run_read_file<default_read_scheduler> >(new sort_run_read_file<default_read_scheduler> (myfile,32*1024)));
    default_read_scheduler drs(files);
    drs.start();
    io_service.run();
    BOOST_REQUIRE_EQUAL(100LL*1024LL*1024LL, drs.total_bytes());
  }
  {
    io_service.reset();
    asio::basic_stream_file<asio::detail::win_iocp_file_service> myfile(io_service);
    boost::filesystem::path full_path2(boost::filesystem::system_complete(boost::filesystem::path("foo2.txt", 
                                                                                                  boost::filesystem::native)));
    myfile.open(full_path2.native_file_string());
    std::vector<boost::shared_ptr<sort_run_read_file<default_read_scheduler> > > files;
    files.push_back(boost::shared_ptr<sort_run_read_file<default_read_scheduler> >(new sort_run_read_file<default_read_scheduler> (myfile,32*1024)));
    asio::basic_stream_file<asio::detail::win_iocp_file_service> myfile2(io_service);
    myfile2.open(full_path.native_file_string());
    files.push_back(boost::shared_ptr<sort_run_read_file<default_read_scheduler> >(new sort_run_read_file<default_read_scheduler> (myfile2,32*1024)));
    default_read_scheduler drs(files);
    drs.start();
    io_service.run();
    BOOST_REQUIRE_EQUAL(100LL*1024LL*1024LL+44L, drs.total_bytes());
  }
  

  return 0;  
}
