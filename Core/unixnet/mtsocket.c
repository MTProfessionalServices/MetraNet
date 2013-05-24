/*
 * simple unix socket wrappers -billo
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>

#include <assert.h>

#define USE_SIZE
#define USE_TIME
#include "unix_hacks.h"

#include <sys/socket.h>
#include <sys/select.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>

#include <fcntl.h>
#include <sys/time.h>

#include <errno.h>
#include <sys/errno.h>
#include <stropts.h>
#include <sys/filio.h>

#include "mtsocket.h"

#define BUFSIZE	8192

static int debug = 0;

static void mtsocket_debug_file(int sock, int rw, const unsigned char *buf, int n)
{
  char path[256];
  FILE	*fp;

  sprintf(path, "/tmp/mt.%d.%d", rw, sock);
  fp = fopen(path, "a");
  if(fp)
  {
    fwrite(buf, 1, n, fp);
    fclose(fp);
  }

  return;
}

int mtsocket_write(int sock, const unsigned char *buf, int size)
{
  int n;
  
  n = write(sock, buf, size);
#ifdef DEBUG
  if (n > 0)
    mtsocket_debug_file(sock, 1, buf, n);
#endif
  return n;
}

int mtsocket_read(int sock, unsigned char *buf, int size)
{
  int n;
  
  n = read(sock, buf, size);
#ifdef DEBUG
  if (n > 0)
    mtsocket_debug_file(sock, 0, buf, n);
#endif
  return n;
}

int mtsocket_open_ssl(const char *host, int portnum, SSL *ssl, unsigned int timeout, unsigned int numretry)
{
  int sock;

  sock = mtsocket_open(host, portnum, timeout, numretry);

  if (sock < 0)
    return sock;

  SSL_set_fd(ssl, sock);

  if (!SSL_connect(ssl))
  {
    mtsocket_close(sock);
    return -1;
  }
  
  return sock;
}

int mtsocket_open(const char *host, int portnum, unsigned int timeout, unsigned int numretry)
{
  struct hostent 			*hent;
  struct in_addr 			in_addr;
  struct sockaddr_in 	saddr;
  int                 sock;
	int                 res; // General error-checking var
	int                 nb_bool; // the non-blocking flag

	nb_bool = 1;

  if (isalpha(host[0])) 
		{
			if ((hent = gethostbyname(host)) == NULL)
				return(-1);
			memcpy(&in_addr.s_addr, hent->h_addr, hent->h_length);
		} 
	else 
		{
			in_addr.s_addr = inet_addr(host);
		}

  if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0)
    return(-1);

	if (timeout > 0)
		{
			res = ioctl(sock, FIONBIO, &nb_bool);
			if (res != 0)
				{
					fprintf(stderr, "%s\n", "Error: Could not set socket to non-blocking.");
					fflush(stderr);
					return -1;
				}
		}

  bzero((char*)&saddr, sizeof(saddr));
  saddr.sin_family = AF_INET;
  saddr.sin_port = ntohs(portnum);
  saddr.sin_addr = in_addr;

	res = connect(sock, (struct sockaddr*)&saddr, sizeof(struct sockaddr));
	
	if (res == 0)
		{
			fprintf(stderr, "Connect succeeded\n");
			fflush(stderr);
		}
	else if (errno == EINPROGRESS)
		{
			fd_set writeable, error;
			struct timeval t_out;

			printf("Running select to wait for socket availability\n");
			fflush(stdout);

			// timeout is in milliseconds - we have to convert it to timeval
			t_out.tv_sec = (long) (timeout/1000);
			t_out.tv_usec = (long) (timeout%1000);

			fprintf(stderr, " Timeout = %d %d\n", t_out.tv_sec, t_out.tv_usec);
			fflush(stderr);

			printf("running fd ops\n");
			fflush(stdout);
			
			// Clear the file descriptor set
			FD_ZERO(&writeable);
			FD_ZERO(&error);
			// Flag the fd_set to test our socket for writing
			FD_SET(sock, &writeable);
			FD_SET(sock, &error);

			printf("running select\n");
			fflush(stdout);
			
			res = select(sock+1, NULL, &writeable, &error, &t_out);
			
			if (res == -1)
				{
					fprintf(stderr, "%s\n","Select returned an error while trying to access the socket for writing.\n");
					fflush(stderr);
					return -1;
				}
			else
				{
					if (FD_ISSET(sock, &error))
						{
							fprintf(stderr, "%s\n", "Connection error on select\n");
							return -1;
						}
					printf("Testing fd_isset\n");
					fflush(stdout);
					if (FD_ISSET(sock, &writeable))
						{
							fprintf(stderr, "%s\n" ,"Socket is writeable\n");
							fflush(stderr);
							// I will leave this test here for now, for debugging purposes.
							// If we got in here, then the socket can be written
						}
					else
						{
							fprintf(stderr, "%s\n", "Connection timed out\n");
							fflush(stderr);
              return -1;
						}
				}
		}
	else
		{
			fprintf(stderr, "%s\n", "Connect failed\n");
			fflush(stderr);
			return -1;
		}

  // set the socket back to blocking I/O  
  nb_bool = 0;
	
	if (timeout > 0)
		{
			res = ioctl (sock, FIONBIO, &nb_bool);
			// TODO : figure out why we can get a socket but we can't reset it to blocking if the webserver is down.
			if ( res != 0 )
				{
					// fprintf (stderr, "%s\n", "Error: Could not reset socket to blocking.\n");
					fprintf (stderr, "%s\n", "Error: Couldn't connect to socket.\n");
					fflush(stderr);
					return -1;
				}
		}

	return sock;
}

void mtsocket_close(int sock)
{
  assert(sock > 0);
  close(sock);
}









