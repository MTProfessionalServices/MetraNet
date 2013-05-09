/**************************************************************************
 * @doc PARSECOMP
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: billo
 * $Header$
 ***************************************************************************/

#include <metralite.h>
#include "mtcompress.h"

// TODO: remove use of free
#include <stdlib.h>
#include <sdk_msg.h>


BOOL MTCompressor::ParseCompressed(FILE *fp, size_t *nRead)
{
    
    return ParseCompressedInternal(NULL, fp, 0, nRead);
}

BOOL MTCompressor::ParseCompressed(char *buff, size_t bufsize, 
                                   size_t *nRead)
{

    return ParseCompressedInternal(buff, NULL, bufsize, nRead);
}

BOOL MTCompressor::ParseCompressedInternal(char *buff, 
                                           FILE *fp,
                                           size_t insize,
                                           size_t *nRead)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mCodebook);
    char 				   buffer[MTC_MAX_RECORD];
    size_t				   bufsize;
    MT_COMPRESS_CMD 			   *cmd;
    int					   cookie = 0;
    char 				   *ptr = (char *)buff;
    char				   id;
    int					   intval;
    char				   message_name;
    float				   floatval;
    double				   doubleval;
    int					   datasize;
    char 				   *temp1;
    char 				   *temp2;
    int					   temp3;
    BOOL				   repeat_reset = FALSE;
    MT_COMPRESS_CMD 			   *repeat;

    mSessions.clear(); // resets the session list
    mProperties.clear(); // resets the session list

    *nRead = 0;

    while (repeat_reset || cb_iter())
    {
        cmd = cb_iter.key();
        bufsize = MTC_MAX_RECORD;
        

        if (repeat_reset)
        {
            repeat_reset = FALSE;
            // don't re-read command, size if we're looping
            // back
        } else {
            // Read in what should be the command identifier
            if (fp)
            {       
                if (fread(buffer, 1, 1, fp) != 1)
                {
                    SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                             ERROR_LINE,
                             "MTCompressor::ParseCompressedInternal");
                    return FALSE;
                }
                id = *buffer;
                CheckSum(buffer, 1);
            } else {
                if (ptr > (buff + insize))
                {
                    SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                             ERROR_LINE,
                             "MTCompressor::ParseCompressedInternal");
                    return FALSE;
                }
                id = *ptr++;
                CheckSum(&id, 1);
            }
            *nRead += 1;

            if (cmd->id != id)
            {
                if ((cmd->id == MESSAGE_REPEAT_END) &&
                    (id == MESSAGE_SESSION_ID))
                {   
                    // this is OK
                } else {
                    
                    SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                             ERROR_LINE,
                             "MTCompressor::ParseCompressedInternal");
                    return FALSE;
                }           
            }

            // get size
            if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                 &datasize, TRUE))
            {         
                return FALSE;
            }
            assert (datasize < MTC_MAX_RECORD);
        }
        switch (cmd->id) {
          case MESSAGE_CKSUM:
              if (datasize != sizeof(int))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              // Don't include checksum in checksum, just zero
              temp3 = 0;

              // it's zero, so it doesn't matter really
              CheckSum((char *)&temp3, 4); 
              
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &intval, FALSE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              mCheckSumSaved = intval;
              break;
          case MESSAGE_VERSION:
              if (datasize != sizeof(int))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &intval, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              if (intval != cmd->value_int)
              {
                  SetError(MT_ERR_COMPRESS_VERSION, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }

              break;
          case MESSAGE_NAME:
              if (datasize != sizeof(char))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetByte(fp, &ptr, insize - (ptr - buff), nRead,
                                &message_name, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              if ((message_name != QUERY_SERVER) &&
                  (message_name != QUERY_VERSION) &&
                  (message_name != SEND_SESSION))
              {
                  SetError(MT_ERR_COMPRESS_UNKNOWN_MESSAGE, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
                  
              break;
          case MESSAGE_REPEAT_END:
              if (mRepeat.isEmpty())
              {
                  // FIXME SetError repeat end not in repeat loop
                  return FALSE;
              }
              if (id == MESSAGE_SESSION_ID)
              {
                  // we're at the end of a loop in the CODEBOOK, 
                  // and the command in the INPUT STREAM says
                  // here's another session.
                  repeat = mRepeat.pop();
                  cb_iter.reset();
                  cb_iter.findNext(repeat);
                  repeat_reset = TRUE;
              } else {
                  // we're at the end of a loop in the CODEBOOK, 
                  // and there is an END_REPEAT marker in the INPUT
                  // stream.
                  mRepeat.pop();
              }
              break;
          case MESSAGE_SESSION_ID:
              if (datasize <= 0)
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetBytes(fp, &ptr, insize - (ptr - buff), nRead,
                                 buffer, TRUE, datasize))
              {
                  return FALSE;
              }
              temp1 = MemDup(buffer, datasize);
              temp1[datasize] = 0x00;
              temp2 = NULL;
              
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &datasize, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              if (datasize != 0xffffffff)
              {
                  assert (datasize < MTC_MAX_RECORD);

                  // there is a parent ID
                  if (!ParseGetBytes(fp, &ptr, insize - (ptr - buff), nRead,
                                     buffer, TRUE, datasize))
                  {
                      return FALSE;
                  }
                  temp2 = MemDup(buffer, datasize);
                  temp2[datasize] = 0x00;
              }
              cookie++;
              if (cmd->repeat)
              {
                  mRepeat.push(cmd);
              }
              AddSession(cmd->parameter_name, temp1, temp2, (void *)cookie);

              if (temp1) free(temp1);

              if (temp2) free(temp2);
              break;
          case MESSAGE_PROPERTY_INT32:
              if (datasize != sizeof(int))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &intval, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              AddProperty(cmd->parameter_name, intval, (void *)cookie);
              
              break;
          case MESSAGE_PROPERTY_FLOAT:
              if (datasize != sizeof(float))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetFloat(fp, &ptr, insize - (ptr - buff), nRead,
                                   &floatval, TRUE))
              {
                  return FALSE;
              }
              AddProperty(cmd->parameter_name, floatval, (void *)cookie);
              break;
          case MESSAGE_PROPERTY_DOUBLE:
              if (datasize != sizeof(double))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetDouble(fp, &ptr, insize - (ptr - buff), nRead,
                                   &doubleval, TRUE))
              {
                  return FALSE;
              }
              AddProperty(cmd->parameter_name, doubleval, (void *)cookie);
              break;
          case MESSAGE_CBNAME:
              if (datasize < 0)
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetBytes(fp, &ptr, insize - (ptr - buff), nRead,
                                 buffer, TRUE, datasize))
              {     
                  return FALSE;
              }
              buffer[datasize] = 0; // null terminate text

              if (strcmp(buffer, cmd->value_text))
              {
                  // Codebook name mismatch
                  SetError(MT_ERR_COMPRESS_VERSION, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal (NAME)");
                  return FALSE;
              } 

              // eat terminator cb name text only has one string value for now
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &datasize, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              if (datasize != 0xffffffff)
              {
                  return FALSE;
              }
              break;

          case MESSAGE_PROPERTY_TEXT:
              if (datasize < 0)
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetBytes(fp, &ptr, insize - (ptr - buff), nRead,
                                 buffer, TRUE, datasize))
              {     
                  return FALSE;
              }
              buffer[datasize] = 0; // null terminate text
              AddProperty(cmd->parameter_name, buffer, (void *)cookie);

              // eat terminator (propery text only has one string value for now)
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &datasize, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              if (datasize != 0xffffffff)
              {
                  return FALSE;
              }
              
              break;
          case MESSAGE_PROPERTY_TIME:
              if (datasize != sizeof(int))
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetInteger(fp, &ptr, insize - (ptr - buff), nRead,
                                   &intval, TRUE))
              {
                  // error set inside ParseGetInteger
                  return FALSE;
              }
              AddPropertyTime(cmd->parameter_name, intval, (void *)cookie);
              break;
          case MESSAGE_PROPERTY_WTEXT:
              if (datasize < 0)
              {
                  SetError(MT_ERR_COMPRESS_PROTOCOL, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::ParseCompressedInternal");
                  return FALSE;
              }
              if (!ParseGetBytes(fp, &ptr, insize - (ptr - buff), nRead,
                                 buffer, TRUE, datasize))
              {     
                  return FALSE;
              }
              buffer[datasize] = 0; // null terminate text
              buffer[datasize + 1] = 0; // null terminate text
              AddProperty(cmd->parameter_name, (wchar_t *)buffer, (void *)cookie);
              break;
          default:
              SetError(MT_ERR_COMPRESS_UNKNOWN_COMMAND, ERROR_MODULE, 
                       ERROR_LINE,
                       "MTCompressor::ParseCompressedInternal");
              return FALSE;
              break;
        }               
    }
        
    fprintf(stderr, "CHECKSUM COMPUTED = %08x\n", mCheckSum);
    fprintf(stderr, "CHECKSUM SHOULD BE = %08x\n", mCheckSumSaved);
    return TRUE;
}

BOOL MTCompressor::ParseGetInteger(FILE *fp, char **buf, 
                                   size_t insize, size_t *nRead,
                                   int *output, BOOL checksum)
{
    char 				   buffer[16];

    // Read in what should be the command identifier
    if (fp)
    {       
        if (fread(buffer, 1, 4, fp) != 4)
        {
            SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetInteger");
            return FALSE;
        }
    } else {
        if (4 > insize)
        {
            SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetInteger");
            return FALSE;
        }
        memcpy(buffer, *buf, 4);
        *buf += 4;
    }

    if (checksum)
      CheckSum(buffer, 4);

    *nRead += 4;

    *output = (buffer[0] & 0x000000ff) | 
              ((buffer[1] << 8) & 0x0000ff00) | 
              ((buffer[2] << 16) & 0x00ff0000) |
              ((buffer[3] << 24) & 0xff000000);

    return TRUE;
}


BOOL MTCompressor::ParseGetFloat(FILE *fp, char **buf, 
                                 size_t insize, size_t *nRead,
                                 float *output, BOOL checksum)
{
    char 				   buffer[16];

    // Read in what should be the command identifier
    if (fp)
    {       
        if (fread(buffer, 1, sizeof(float), fp) != sizeof(float))
        {
            SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetFloat");
            return FALSE;
        }
    } else {
        if (sizeof(float) > insize)
        {
            SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetFloat");
            return FALSE;
        }
        memcpy(buffer, *buf, sizeof(float));
        *buf += sizeof(float);
    }

    if (checksum)
      CheckSum(buffer, sizeof(float));

    *nRead += sizeof(float);

    memcpy((char *)output, buffer, sizeof(float));

    return TRUE;
}


BOOL MTCompressor::ParseGetDouble(FILE *fp, char **buf, 
                                 size_t insize, size_t *nRead,
                                 double *output, BOOL checksum)
{
    char 				   buffer[16];

    // Read in what should be the command identifier
    if (fp)
    {       
        if (fread(buffer, 1, sizeof(double), fp) != sizeof(double))
        {
            SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetDouble");
            return FALSE;
        }
    } else {
        if (sizeof(double) > insize)
        {
            SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetDouble");
            return FALSE;
        }
        memcpy(buffer, *buf, sizeof(double));
        *buf += sizeof(double);
    }

    if (checksum)
      CheckSum(buffer, sizeof(double));

    *nRead += sizeof(double);

    memcpy((char *)output, buffer, sizeof(double));

    return TRUE;
}


BOOL MTCompressor::ParseGetByte(FILE *fp, char **buf, size_t insize, 
                                size_t *nRead,
                                char *output, BOOL checksum)
{
    char   buffer[16];

    // Read in what should be the command identifier
    if (fp)
    {       
        if (fread(buffer, 1, 1, fp) != 1)
        {
            SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetByte");
            return FALSE;
        }
    } else {
        if (1 > insize)
        {
            SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetByte");
            return FALSE;
        }
        memcpy(buffer, *buf, 1);
        *buf += 1;
    }

    if (checksum)
      CheckSum(buffer, 1);

    *nRead += 1;

    *output = buffer[0];

    return TRUE;
}



BOOL MTCompressor::ParseGetBytes(FILE *fp, char **buf, size_t insize, 
                                 size_t *nRead,
                                 char *output, 
                                 BOOL checksum,
                                 size_t nbytes)
{

    // Read in what should be the command identifier
    if (fp)
    {       
        if (fread(output, 1, nbytes, fp) != nbytes)
        {
            SetError(MT_ERR_COMPRESS_READ_EOF, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetBytes");
            return FALSE;
        }
    } else {
        if (nbytes > insize)
        {
            SetError(MT_ERR_COMPRESS_READ_BUFFER, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::ParseGetBytes");
            return FALSE;
        }
        memcpy(output, *buf, nbytes);
        *buf += nbytes;
    }

    if (checksum)
      CheckSum(output, nbytes);

    *nRead += nbytes;

    return TRUE;
}

