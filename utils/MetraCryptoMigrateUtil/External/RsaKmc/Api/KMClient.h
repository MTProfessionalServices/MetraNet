/*****************************************************************************/
/*         COPYRIGHT (C) 2006 by RSA SECURITY, INC.                          */
/*                         ---ALL RIGHTS RESERVED---                         */
/*                                                                           */
/* THIS SOFTWARE IS PROPRIETARY AND CONFIDENTIAL TO RSA SECURITY, INC.,      */
/* IS FURNISHED UNDER A LICENSE AND MAY BE USED AND COPIED                   */
/* ONLY IN ACCORDANCE THE TERMS OF SUCH LICENSE AND WITH THE INCLUSION       */
/* OF THE ABOVE COPYRIGHT NOTICE.  THIS SOFTWARE OR ANY OTHER COPIES THEREOF */
/* MAY NOT BE PROVIDED OR OTHERWISE MADE AVAILABLE TO ANY OTHER PERSON.  NO  */
/* TITLE TO AND OWNERSHIP OF THE SOFTWARE IS HEREBY TRANSFERRED.             */
/*                                                                           */
/* THE INFORMATION IN THIS SOFTWARE IS SUBJECT TO CHANGE WITHOUT NOTICE AND  */
/* SHOULD NOT BE CONSTRUED AS A COMMITMENT BY RSA SECURITY, INC.             */
/*****************************************************************************/

#ifdef _WIN32
// this is needed for MS Visual C++
#pragma warning(disable:4786)
#endif

#ifndef _WIN32
#define __declspec(dllexport)
#endif

#ifndef KMCLIENT_H
#define KMCLIENT_H

#include <stdio.h>
#include "KMSError.h"

typedef void KMCache;
typedef void KMCredentials;
typedef void KMProtocol;

class __declspec(dllexport) KMClient {
 private:
  char                  *certFile;
  char                  *keyFile;
  char                  *rootFile;
  char                  *cacheFile;
  char                  *kmsIPAddr;
  char                  *keyPassword;
  char                  *p12File;
  int                   kmsPort;
  int                   debug;
  int                   cacheEnabled;
  int                   cacheTTL;
  bool                  init;
  int                   useMemCache;
  int                   encryptDisk;
  int                   clientRetries;
  int                   clientDelay;
  int                   connectTimeout;
  int                   GetKey(const char *keyClass, const char *keyID,
                               unsigned char *keyData,
                               const unsigned int keyDataSize,
                               unsigned int *keyLen, char *rKeyID,
                               const unsigned int rKeyIDSize, char *algorithm,
                               const unsigned int algorithmSize);
  KMProtocol            *ph;
  KMCache               *cache;
  KMCredentials         *crds;

 public:
  /*
   * KMClient::KMClient
   *    Initializes the KMClient local data
   *
   * ARGUMENTS
   *    configFile (in) -- path name to config file
   *
   * RETURN VALUE
   *    none
   */
  KMClient(const char *configFile, const char *password = NULL);

  /*
   * KMClient::KMClient
   *    Initialize the KMClient local data
   *
   * ARGUMENTS
   *    none
   * RETURN VALUE

   *    none
   */
  KMClient();

  /*
   * KMClient Destructor
   *    Calls ShutDown
   *
   * ARGUMENTS
   *    none
   * RETURN VALUE
   *    none
   */
  ~KMClient(void);

  /*
   * KMClient::Initialze
   *    Initialize the KM Client. This in turn initializes the
   *    KMSCache subsystem along with the NetworkHandler
   *
   * ARGUMENTS
   *    configFile (in) -- path name to config file
   *
   * RETURN VALUE
   *    KMS_SUCCESS on success
   *    error code on failure
   */
  int   Initialize(const char *configFile, const char *password = NULL);

  /*
   * KMClient::GetKey
   *    Retrieve the specified key from the KMS server
   *
   * ARGUMENTS
   *      keyClass (in) -- Key Class name
   *      keyID (in) -- allocated buffer to store KeyID
   *      keyData (in/out) -- allocated buffer to store key
   *      keyDataSize (in) -- number of bytes allocated to keyData
   *      keyLen (out) -- length of returned key
   *      rKeyID (out) -- key ID of the key retrieved
   *      rKeyIDSize (in) -- size of returned keyID buffer
   */
  int   GetKey(const char *keyClass, const char *keyID,
               unsigned char *keyData, const unsigned int keyDataSize,
               unsigned int *keyLen, char *rKeyID,
               const unsigned int rKeyIDSize);

  /*
   * KMClient::EncryptData
   *    Encrypt the supplied data with a key that was retrieved
   *    from the key server.
   *
   * ARGUMENTS
   *      keyClass (in) -- Key Class name, determins key
   *      clearText (in) -- text to encrypt
   *      clearLen (in) -- length of text
   *      cipherText (in/out) -- Output cipher text allocated by caller
   *      cipherSize (in) -- number of bytes allocated to cipherText
   *      cipherLen (out) -- length of output cipher text
   *      base64Encode (in) -- boolean to base64 encoded output
   *
   * RETURN VALUE
   *      0 on success
   *      error code on failure
   */
  int   EncryptData(const char *keyClass,
                    const unsigned char *clearText,
                    const unsigned int clearLen,
                    unsigned char *cipherText,
                    const unsigned int cipherSize,
                    unsigned int *cipherLen,
                    int base64Encode);

  /*
   * KMClient::DecryptData
   *    Decrypt the supplied data with a key that was retrieved from
   *    the key server. The keyID of the key to use is embeded in the
   *    ciphertext.
   *
   * ARGUMENTS
   *      keyClass (in) -- Application Family name, determins key
   *      cipherText (in) -- text to decrypt
   *      cipherLen (in) -- length of text
   *      clearText (out) -- Output clear text
   *      clearLen (out) -- length of output clear text
   *
   * RETURN VALUE
   *      0 on success
   *      error code on failure
   */
  int   DecryptData(const char *keyClass,
                    const unsigned char *cipherText,
                    const unsigned int cipherLen,
                    unsigned char *clearText,
                    const unsigned int clearSize,
                    unsigned int *clearLen);

  /*
   * KMClient::HMACData
   *    HMAC the supplied data with a key that was retrieved
   *    from the key server.
   *
   * ARGUMENTS
   *      keyClass (in) -- Key Class name, determins key
   *      keyID (in) -- KeyID to of key to HMAC with (NULL for current key)
   *      text (in) -- text to encrypt
   *      textLen (in) -- length of text
   *      hmac (in/out) -- Output cipher text allocated by caller
   *      hmacSize (in) -- number of bytes allocated to cipherText
   *      hmacLen (out) -- length of output cipher text
   *      base64Encode(in) -- boolean to base64 encode output
   *
   * RETURN VALUE
   *      0 on success
   *      error code on failure
   */
  int   HMACData(const char *keyClass,
                 const char *keyID,
                 const unsigned char *text,
                 const unsigned int textLen,
                 unsigned char  *hmac,
                 const unsigned int hmacSize,
                 unsigned int *hmacLen,
                 int base64Encode);

  /*
   * KMClient::FlushCache
   *    Flush the contents of the cache
   *
   * ARGUMENTS
   *    none
   * RETURN VALUE
   *    none
   */
  void  FlushCache(void);

  /*
   * KMClient::DisplayCache
   *    Display the contents of the cache to stdout
   *
   * ARGUMENTS
   *    none
   * RETURN VALUE
   *    none
   */
  void  DisplayCache(void);

  /*
   * KMClient::Shutdown
   *    Shutdown the KMClient. THis frees all memory associated with the client
   *    which includes the cache and the NetworkHandler
   *
   * ARGUMENTS
   *    none
   * RETURN VALUE
   *    none
   */
  void  Shutdown(void);
};

#endif
