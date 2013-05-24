
/*
 * simple socket wrappers for unix.
 *
 * billo 13-jul-1998
 */

#include <mtssl.h>

#ifdef __cplusplus
extern "C" {
#endif


extern int mtsocket_write(int sock, const unsigned char *buf, int size);
extern int mtsocket_read(int sock, unsigned char *buf, int size);
extern int mtsocket_open(const char *host, int portnum, unsigned int timeout, unsigned int numretry);
extern void mtsocket_close(int sock);

/* SSL interface */
int mtsocket_open_ssl(const char *host, int portnum, SSL *ssl, unsigned int timeout, unsigned int numretry);

#ifdef __cplusplus
}
#endif
