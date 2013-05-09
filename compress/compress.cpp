/**************************************************************************
 * @doc COMPRESS
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

// TODO: remove malloc
#include <stdlib.h>
#include <ctype.h>
#include <wchar.h>
#include <sdk_msg.h>

MTCompressor::MTCompressor(void)
{
    mCodebookPath = NULL;

    mCommands.clear();

    mCodebook.clear();

    mSessions.clear();

    mProperties.clear();

    mRepeat.clear();

    mCheckSumOnly = FALSE;

    mCheckSum = 0;

    mCodebookName = NULL;
    
    mCodebookVersion = 0;

}

MTCompressor::~MTCompressor(void)
{
    list<MT_COMPRESS_CMD *>::iterator iter(mCodebook);
    MT_COMPRESS_CMD 			   *cmd = NULL;

    while (iter())
    {
        cmd = iter.key();
        FreeCommand(cmd);
    }
    iter.reset(mSessions);
    while (iter())
    {
        cmd = iter.key();
        FreeCommand(cmd);
    }
    iter.reset(mProperties);
    while (iter())
    {
        cmd = iter.key();
        FreeCommand(cmd);
    }
    iter.reset(mCommands);
    while (iter())
    {
        cmd = iter.key();
        FreeCommand(cmd);
    }


}

static char *codebook_command_table[] = {
    "VERSION",
    "NAME",
    "CKSUM",
    "SESSION",
    "PROPERTY_TEXT",
    "PROPERTY_WTEXT",
    "PROPERTY_INT32",
    "PROPERTY_FLOAT",
    "PROPERTY_DOUBLE",
    "PROPERTY_TIME",
    "REPEAT_END",
    "CBNAME",
    "END",
    NULL
};
    
    

BOOL MTCompressor::LoadCodebook(const char *path)
{
    FILE *fp;
    char buf[256];

    fp = fopen(path, "r");

    if (fp == NULL)
    {
        SetError(MT_ERR_COMPRESS_CODEBOOK_FILE, ERROR_MODULE, ERROR_LINE,
                 "MTCompressor::LoadCodebook");
        return FALSE;
    }

    while (fgets(buf, 256, fp) != NULL)
    {
        if (!ParseLine(buf))
        {
            fclose(fp);
            return FALSE;
        }
    }

    fclose(fp);
    return TRUE;
}

char *MTCompressor::MemDup(char *s, int n)
{
    char *ret;

    ret = (char *)malloc(n + 2);  // extra bytes allow breathing room for null term

    assert(ret != NULL);

    memcpy(ret, s, n);

    return ret;
}


BOOL MTCompressor::DumpCodebook(FILE *fp)
{
		list<MT_COMPRESS_CMD *>::iterator iter(mCodebook);
    MT_COMPRESS_CMD *cmd;
    
    while (iter())
    {
        cmd = iter.key();
        fprintf(fp, "%s ", codebook_command_table[cmd->id - 0x21]);
        fprintf(fp, "\n");
    }
        
    return TRUE;
}

BOOL MTCompressor::DumpProp(MT_COMPRESS_CMD *prop, FILE *fp)
{
    switch (prop->value_type)
    {
      case MESSAGE_TYPE_NONE:
          fprintf(fp, "%s = NONE\n", prop->parameter_name);
          break;
      case MESSAGE_TYPE_BYTE:
      case MESSAGE_TYPE_INT:
      case MESSAGE_TYPE_TIME:
          fprintf(fp, "%s = %d\n", prop->parameter_name, prop->value_int);
          break;

      case MESSAGE_TYPE_FLOAT:
          fprintf(fp, "%s = %f\n", prop->parameter_name, prop->value_float);
          break;
      case MESSAGE_TYPE_DOUBLE:
          fprintf(fp, "%s = %g\n", prop->parameter_name, prop->value_double);
          break;
      case MESSAGE_TYPE_TEXT:
          fprintf(fp, "%s = %s\n", prop->parameter_name, prop->value_text);
          break;
      case MESSAGE_TYPE_WTEXT:
          fprintf(fp, "%s = <WIDE>\n", prop->parameter_name);
          break;
    }
    return TRUE;
}

BOOL MTCompressor::Dump(FILE *fp)
{
    list<MT_COMPRESS_CMD *>::iterator siter(mSessions);
		list<MT_COMPRESS_CMD *>::iterator piter(mProperties);

    MT_COMPRESS_CMD *cmd;
    MT_COMPRESS_CMD *prop;
    
    while (siter())
    {
        cmd = siter.key();
        if (cmd->id == MESSAGE_SESSION_ID)
        {
            fprintf(fp, "SESSION: %s %s %s\n", cmd->parameter_name, 
                    cmd->value_text,
                    cmd->value_text2);

            piter.reset();
            while (piter())
            {
                prop = piter.key();
                if (prop->cookie == cmd->cookie)
                {
                    DumpProp(prop, fp);
                }
            }

				} else if (cmd->id == MESSAGE_REPEAT_END) {
            fprintf(fp, "END SESSION\n");
        } else {
            fprintf(fp, "BOGUS COMMAND IN SESSION LIST %c", 
                    cmd->id);
        }
    }
        
    return TRUE;
}
    
BOOL MTCompressor::ParseLine(char *line)
{
    char *ptr = line;
    char token[256];
    MT_COMPRESS_CMD *newcmd;
    
    // skip leading whitespace
    while (isspace(*ptr))
      ptr++;

    // comment, bail out
    if (*ptr == '#')
      return TRUE;

    if ((ptr = GetToken(ptr, token, 256)) != NULL)
    {

        if (!strcmp(token, "VERSION"))
        {
            ptr = GetToken(ptr, token, 256);

            if (ptr == NULL)
              return FALSE;

            // add code book version number
            newcmd = NewCommand(MESSAGE_VERSION);
            SetCommandData(newcmd, atoi(token));  
            mCodebook.append(newcmd);

        } else if (!strcmp(token, "CBNAME"))
        {
            ptr = GetToken(ptr, token, 256);

            if (ptr == NULL)
              return FALSE;
            
            // add code book name
            newcmd = NewCommand(MESSAGE_CBNAME);
            SetCommandData(newcmd, token);  
            mCodebook.append(newcmd);

        } else if (!strcmp(token, "NAME"))
        {
            ptr = GetToken(ptr, token, 256);

            if (ptr == NULL)
              return FALSE;

            if (!strcmp(token, "SEND_SESSION"))
            {
                newcmd = NewCommand(MESSAGE_NAME);
                SetCommandData(newcmd, (int)SEND_SESSION);  
                mCodebook.append(newcmd);
                return TRUE;
            } 
            if (!strcmp(token, "QUERY_SERVER"))
            {
                newcmd = NewCommand(MESSAGE_NAME);
                SetCommandData(newcmd, (int)QUERY_SERVER);  
                mCodebook.append(newcmd);
                return TRUE;
            } 
            if (!strcmp(token, "QUERY_VERSION"))
            {
                newcmd = NewCommand(MESSAGE_NAME);
                SetCommandData(newcmd, (int)QUERY_VERSION);  
                mCodebook.append(newcmd);
                return TRUE;
            } 

            // unknown message 
            SetError(MT_ERR_COMPRESS_UNKNOWN_MESSAGE, ERROR_MODULE, ERROR_LINE,
                     "MTCompressor::ParseLine");
            return FALSE;
        } else if (!strcmp(token, "CKSUM"))
        {
            newcmd = NewCommand(MESSAGE_CKSUM);
            mCodebook.append(newcmd);

        } else if (!strcmp(token, "SESSION"))
        {
            ptr = GetToken(ptr, token, 256);
            
            newcmd = NewCommand(MESSAGE_SESSION_ID);

            if (ptr == NULL)
            {
                SetError(MT_ERR_COMPRESS_BAD_CODEBOOK, ERROR_MODULE, 
                         ERROR_LINE,
                         "MTCompressor::ParseLine");
                return FALSE;
            }

            if (!strcmp(token, "REPEAT"))
            {
                newcmd->repeat = TRUE;
            } else {
                newcmd->repeat = FALSE;
            }
                                         
            ptr = GetToken(ptr, token, 256);
                
            if (ptr == NULL)
            {
                SetError(MT_ERR_COMPRESS_BAD_CODEBOOK, ERROR_MODULE, 
                         ERROR_LINE,
                         "MTCompressor::ParseLine");
                return FALSE;
            }

            // This is the session "name"
            // it's used to match up/break down Session hierarchies 
            // into the right organizations.
            SetCommandDataName(newcmd, token);

            mCodebook.append(newcmd);

        } else if (!strcmp(token, "REPEAT_END"))
        {
            ptr = GetToken(ptr, token, 256);
            
            newcmd = NewCommand(MESSAGE_REPEAT_END);

            mCodebook.append(newcmd);

        } else if (!strcmp(token, "PROPERTY"))
        {
            // what type of property is expected?
            ptr = GetToken(ptr, token, 256);

            if (ptr == NULL)
            {   
                SetError(MT_ERR_COMPRESS_BAD_CODEBOOK, ERROR_MODULE, 
                         ERROR_LINE,
                         "MTCompressor::ParseLine");
                return FALSE;
            }

            if (!strcmp(token, "TEXT"))
            {
                newcmd = NewCommand(MESSAGE_PROPERTY_TEXT);
            } else if (!strcmp(token, "WTEXT")) {
                newcmd = NewCommand(MESSAGE_PROPERTY_WTEXT);
            } else if (!strcmp(token, "INT32")) {
                newcmd = NewCommand(MESSAGE_PROPERTY_INT32);
            } else if (!strcmp(token, "FLOAT")) {
                newcmd = NewCommand(MESSAGE_PROPERTY_FLOAT);
            } else if (!strcmp(token, "DOUBLE")) {
                newcmd = NewCommand(MESSAGE_PROPERTY_DOUBLE);
            } else if (!strcmp(token, "TIME")) {
                newcmd = NewCommand(MESSAGE_PROPERTY_TIME);
            }
                
            ptr = GetToken(ptr, token, 256);
            
            // What's the user name of the property?
            SetCommandDataName(newcmd, token);

            mCodebook.append(newcmd);

        } else if (!strcmp(token, "END"))
        {
            
            // is END even necessary?

        } 
    }
    

    return TRUE;
}



char *MTCompressor::GetToken(char *ptr, char *output, int max)
{
    assert (ptr != NULL);
    assert (output != NULL);
    int quoting = 0;
    int count = 0;
    
    while (*ptr && 
           ((!quoting && !isspace(*ptr)) ||
            quoting) &&
           *ptr != '\r' &&
           *ptr != '\n' &&
           (count < max))
    {
        if (*ptr == '\'' && !quoting)
        {
            quoting = 1;
            *ptr++;
        } else if (*ptr == '\'' && quoting)
        {
            quoting = 0;
            *ptr++;
        } else
          *output++ = *ptr++; count++;
    }
    *output = 0;
    if (*ptr && isspace(*ptr))
    {
        while (isspace(*ptr))
          ptr++;
        return ptr;
    } else {
        return NULL;
    }
}

BOOL MTCompressor::SetCommandData(MT_COMPRESS_CMD *cmd, int val)
{
    assert(cmd->value_type == MESSAGE_TYPE_INT || 
           cmd->value_type == MESSAGE_TYPE_TIME || 
           cmd->value_type == MESSAGE_TYPE_BYTE);

    cmd->value_int = val;

    return TRUE;
}

BOOL MTCompressor::SetCommandData(MT_COMPRESS_CMD *cmd, float val)
{
    assert(cmd->value_type == MESSAGE_TYPE_FLOAT);

    cmd->value_float = val;

    return TRUE;
}

BOOL MTCompressor::SetCommandData(MT_COMPRESS_CMD *cmd, double val)
{
    assert(cmd->value_type == MESSAGE_TYPE_DOUBLE);

    cmd->value_double = val;

    return TRUE;
}

BOOL MTCompressor::SetCommandDataName(MT_COMPRESS_CMD *cmd, const char *text)
{
    int len = strlen(text);

    cmd->parameter_size = len;
    cmd->parameter_name = (char *)malloc(len + 1);
    strcpy(cmd->parameter_name, text);

    return TRUE;
}

BOOL MTCompressor::SetCommandData(MT_COMPRESS_CMD *cmd, const char *text)
{
    assert(cmd->value_type == MESSAGE_TYPE_TEXT);
    int len = strlen(text);

    cmd->value_size = len;
    cmd->value_text = (char *)malloc(len + 1);
    strcpy(cmd->value_text, text);

    return TRUE;
}

BOOL MTCompressor::SetCommandData2(MT_COMPRESS_CMD *cmd, const char *text)
{
    assert(cmd->value_type == MESSAGE_TYPE_TEXT);
    int len;

    if (text == NULL)
    {
        cmd->value_size2 = 0;
        cmd->value_text2 = NULL;
        
        return FALSE;
    }
      
    len = strlen(text);

    cmd->value_size2 = len;
    cmd->value_text2 = (char *)malloc(len + 1);
    strcpy(cmd->value_text2, text);

    return TRUE;
}

BOOL MTCompressor::SetCommandData(MT_COMPRESS_CMD *cmd, const wchar_t *wtext)
{
    assert(cmd->value_type == MESSAGE_TYPE_WTEXT);
    int len = wcslen(wtext);

    cmd->value_size = len * sizeof(wchar_t);
    cmd->value_wtext = (wchar_t *)malloc((len + 1) * sizeof(wchar_t));
    wcscpy(cmd->value_wtext, wtext);

    return TRUE;
}

void MTCompressor::FreeCommand(MT_COMPRESS_CMD *cmd)
{
    assert(cmd != NULL);

    if (cmd->value_text != NULL)
      free(cmd->value_text);

    if (cmd->value_text2 != NULL)
      free(cmd->value_text2);

    if (cmd->value_wtext != NULL)
      free(cmd->value_wtext);

    if (cmd->parameter_name != NULL)
      free(cmd->parameter_name);

    free(cmd);
}

MT_COMPRESS_CMD *MTCompressor::NewCommand(MessageCommand mc)
{
    MT_COMPRESS_CMD *cmd = (MT_COMPRESS_CMD *)malloc(sizeof(MT_COMPRESS_CMD));

    cmd->id = mc;

    cmd->parameter_size = 0;
    cmd->parameter_name = NULL;
    cmd->value_wtext = NULL;
    cmd->repeat = FALSE;
    cmd->value_size = 0;
    cmd->value_size2 = 0;
    cmd->value_text = NULL;
    cmd->value_text2 = NULL;
    cmd->value_double = 0.0;
    cmd->value_float = 0.0;
    cmd->value_int = 0;
    cmd->value_type = MESSAGE_TYPE_NONE;
    cmd->cookie = NULL;
    cmd->checked = 0;

    switch (mc) 
    {
      case MESSAGE_NAME:
          cmd->value_size = 1;
          cmd->value_type = MESSAGE_TYPE_BYTE;
          break;
      case MESSAGE_VERSION:
      case MESSAGE_CKSUM:
      case MESSAGE_PROPERTY_INT32:
          cmd->value_size = 4;
          cmd->value_type = MESSAGE_TYPE_INT;
          break;
      case MESSAGE_PROPERTY_FLOAT:
          cmd->value_size = sizeof(float);
          cmd->value_type = MESSAGE_TYPE_FLOAT;
          break;
      case MESSAGE_PROPERTY_TIME:
          cmd->value_size = 4;
          cmd->value_type = MESSAGE_TYPE_TIME;
          break;
      case MESSAGE_PROPERTY_DOUBLE:
          cmd->value_size = sizeof(double);
          cmd->value_type = MESSAGE_TYPE_DOUBLE;
          break;
      case MESSAGE_REPEAT_END:
          cmd->value_type = MESSAGE_TYPE_NONE;
          break;
      case MESSAGE_SESSION_ID:
      case MESSAGE_PROPERTY_TEXT:
      case MESSAGE_CBNAME:
          cmd->value_type = MESSAGE_TYPE_TEXT;
          break;
      case MESSAGE_PROPERTY_WTEXT:
          cmd->value_type = MESSAGE_TYPE_WTEXT;
          break;
          
    }
    return cmd;
}



BOOL MTCompressor::SetName(MessageName name)
{
		list<MT_COMPRESS_CMD *>::iterator iter(mCodebook);
    MT_COMPRESS_CMD *cmd;
    MT_COMPRESS_CMD *name_cmd = NULL;

    while (iter())
    {
        cmd = iter.key();
        if (cmd->id == MESSAGE_NAME)
        {
            name_cmd = cmd;
            break;
        }
    }
    if (name_cmd == NULL)
    {
        name_cmd = NewCommand(MESSAGE_NAME);
        mCommands.append(name_cmd);
    }

    SetCommandData(name_cmd, (int)name);
    return TRUE;    
}

BOOL MTCompressor::AddSession(const char *name, 
                              const char *session_id, 
                              const char *parent_id, 
                              void *cookie)
{
    MT_COMPRESS_CMD *scmd;

    if ((session_id == NULL) &&
        (parent_id == NULL) &&
        (cookie == NULL))
    {
        scmd = NewCommand(MESSAGE_REPEAT_END);
        SetCommandDataName(scmd, name);
    } else {
        scmd = NewCommand(MESSAGE_SESSION_ID);
        SetCommandDataName(scmd, name);
        SetCommandData(scmd, session_id);
        SetCommandData2(scmd, parent_id);
    }

    scmd->cookie = cookie;

    mSessions.append(scmd);

    return TRUE;
}

BOOL MTCompressor::AddProperty(const char *param_name, int val32, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_INT32);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, val32);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::AddPropertyTime(const char *param_name, int val32, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_TIME);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, val32);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::AddProperty(const char *param_name, const char *text, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_TEXT);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, text);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::AddProperty(const char *param_name, const wchar_t *wtext, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_WTEXT);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, wtext);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::AddProperty(const char *param_name, float fval, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_FLOAT);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, fval);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::AddProperty(const char *param_name, double dval, void *cookie)
{
    MT_COMPRESS_CMD *cmd = NewCommand(MESSAGE_PROPERTY_DOUBLE);

    cmd->cookie = cookie;
    SetCommandDataName(cmd, param_name);
    SetCommandData(cmd, dval);
    mProperties.append(cmd);
    return TRUE;
}

BOOL MTCompressor::WriteCommand(MT_COMPRESS_CMD *cmd, 
                                char *buf, size_t *bufsize)
{       
    // This is where XDR-like stuff has to go
    char 	*ptr = buf;
    unsigned long 	netval;


    *ptr++ = cmd->id;

    //netval = htonl(cmd->value_size);
    netval = cmd->value_size;

    // This takes care of both byte ordering and byte-alignment problems.
    *ptr++ = char (netval & 0x000000ff);
    *ptr++ = char ((netval >> 8) & 0x000000ff);
    *ptr++ = char ((netval >> 16) & 0x000000ff);
    *ptr++ = char ((netval >> 24) & 0x000000ff);

    switch (cmd->value_type)
    {
      case MESSAGE_TYPE_NONE:
          break;
      case MESSAGE_TYPE_BYTE:
          *ptr++ = (char)(cmd->value_int);
          break;

      case MESSAGE_TYPE_INT:
      case MESSAGE_TYPE_TIME:
          netval = cmd->value_int;
          
          // This takes care of both byte ordering and byte-alignment problems.
          *ptr++ = char (netval & 0x000000ff);
          *ptr++ = char ((netval >> 8) & 0x000000ff);
          *ptr++ = char ((netval >> 16) & 0x000000ff);
          *ptr++ = char ((netval >> 24) & 0x000000ff);

          break;

					// TODO: is this a problem?
      case MESSAGE_TYPE_FLOAT:
          // is there a byte-ordering issue with IEEE floats?
          // major assumption: everyone we care about uses IEEE floats.
          // If somebody ports this to a VAX, we're screwed.
          memcpy(ptr, &cmd->value_float, sizeof(float));
          ptr += sizeof(float);
          break;
      case MESSAGE_TYPE_DOUBLE:
          // is there a byte-ordering issue with IEEE floats?
          // major assumption: everyone we care about uses IEEE floats.
          // If somebody ports this to a VAX, we're screwed.
          memcpy(ptr, &cmd->value_double, sizeof(double));
          ptr += sizeof(double);
          break;

					// TODO: always a second length
      case MESSAGE_TYPE_TEXT:
          // value_size should not include terminating null char
          memcpy(ptr, cmd->value_text, cmd->value_size);
          ptr += cmd->value_size;
          if (cmd->value_text2 != NULL)
          {
              netval = strlen(cmd->value_text2);

              // special for session parent id

              *ptr++ = char (netval & 0x000000ff);
              *ptr++ = char ((netval >> 8) & 0x000000ff);
              *ptr++ = char ((netval >> 16) & 0x000000ff);
              *ptr++ = char ((netval >> 24) & 0x000000ff);

              memcpy(ptr, cmd->value_text2, netval);
              ptr += netval;
          } else {
              // indicates no second string

              *ptr++ = (char)0xff;
              *ptr++ = (char)0xff;
              *ptr++ = (char)0xff;
              *ptr++ = (char)0xff;
          }
          break;
      case MESSAGE_TYPE_WTEXT:
          // value_size should already be adjust for wide chars.
          // value_size should not include terminating null char
          memcpy(ptr, cmd->value_wtext, cmd->value_size);
          ptr += cmd->value_size;
          break;
    }

    *bufsize = ptr - buf;

    return TRUE;
}


BOOL MTCompressor::WriteFake(size_t *nWritten)
{
    size_t bytes;

    mCheckSumOnly = TRUE;

    WriteCompressed(NULL, 0x7fffff, &bytes); // recursion, sorry.
    
    mCheckSumOnly = FALSE;
    
    return TRUE;
}


BOOL MTCompressor::WriteCompressedInternal(unsigned char *buff, 
                                           FILE *fp,
                                           size_t outsize,
                                           size_t *nWritten)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mCodebook);
    char 				   buffer[MTC_MAX_RECORD];
    size_t				   bufsize;
    MT_COMPRESS_CMD 			   *cmd;
    MT_COMPRESS_CMD 			   *match;
    MT_COMPRESS_CMD 			   *repeat;
    void 				   *cookie;
    char 				   *ptr = (char *)buff;
    BOOL				   repeat_reset = FALSE;
    

    if (!mCheckSumOnly)
    {
			ClearCheckSum();
        WriteFake(nWritten);
        fprintf(stderr, "**DONE WRITE FAKE**\n");
    }

    Reset(); // resets the session list

    *nWritten = 0;

    while (repeat_reset || cb_iter()) // tricky: if repeat reset, don't iterate
    {
        if (repeat_reset)
        {
            repeat_reset = FALSE;
        }
        cmd = cb_iter.key();
        bufsize = MTC_MAX_RECORD;

        switch (cmd->id) {
          case MESSAGE_CKSUM:
              if (mCheckSumOnly)
                cmd->value_int = 0;
              else 
              {
                  cmd->value_int = mCheckSum;
                  fprintf(stderr, "CHECKSUM = %08x\n", mCheckSum);
              }
              // fall through here
          case MESSAGE_VERSION:
          case MESSAGE_NAME:
          case MESSAGE_CBNAME:
              match = cmd;
              break;
          case MESSAGE_SESSION_ID:
              match = GetSession(cmd->parameter_name);
              if (match == NULL)
              {
                  // no more sessions.  could be error
                  break;
              }
              if (cmd->repeat)
              {
                  mRepeat.push(cmd);
              }
                      
              cookie = match->cookie;
              break;
          case MESSAGE_REPEAT_END:
              if (mRepeat.isEmpty())
              {
                  // FIXME SetError repeat end not in repeat loop
                  return FALSE;
              }

              repeat = mRepeat.pop();
              
	      match = PeekSession(repeat->parameter_name);

              if (match == NULL)
              {
                  // somebody forgot to put in a terminating session!
                  return FALSE;
              }
              
              if (match->id == MESSAGE_REPEAT_END)
              {
                  // this is the end of the loop;
                  // make sure to write out the end marker.
                  match = GetSession(repeat->parameter_name);
              } else {
                  cb_iter.reset();
                  cb_iter.findNext(repeat);
                  repeat_reset = TRUE;
              }
              
              break;
          case MESSAGE_PROPERTY_INT32:
          case MESSAGE_PROPERTY_FLOAT:
          case MESSAGE_PROPERTY_TEXT:
          case MESSAGE_PROPERTY_TIME:
          case MESSAGE_PROPERTY_DOUBLE:
          case MESSAGE_PROPERTY_WTEXT:
              match = GetProperty(cmd->parameter_name, cookie);
              if (match == NULL)
              {
                  // didn't find the property. Bad. fail. 
                  SetError(MT_ERR_COMPRESS_PROP_MISSING, ERROR_MODULE, 
                           ERROR_LINE,
                           "MTCompressor::WriteCompressedInternal");
                  return FALSE;
              }
              break;
          default:
              SetError(MT_ERR_COMPRESS_UNKNOWN_COMMAND, ERROR_MODULE, 
                       ERROR_LINE,
                       "MTCompressor::WriteCompressedInternal");
              return FALSE;
              break;
        }               
        if (repeat_reset)
          continue;

        WriteCommand(match, buffer, &bufsize);
        if ((fp == NULL) && *nWritten + bufsize > outsize)
        {
            SetError(MT_ERR_COMPRESS_BUFFER_OVERRUN, ERROR_MODULE, 
                     ERROR_LINE,
                     "MTCompressor::WriteCompressedInternal");
            return FALSE;
        }
        if (mCheckSumOnly)
        {
            CheckSum(buffer, bufsize);
        } else {
            if (fp)
              fwrite(buffer, bufsize, 1, fp);
            else
              memcpy(ptr, buffer, bufsize);
        }

        ptr += bufsize;
        *nWritten += bufsize;
    }
        
    return TRUE;
}


BOOL MTCompressor::WriteCompressed(unsigned char *buff, 
                                   size_t outsize, 
                                   size_t *nWritten)
{
    return WriteCompressedInternal(buff, NULL, outsize, nWritten);
}


BOOL MTCompressor::WriteCompressed(FILE *fp, size_t *nWritten)
{
    return WriteCompressedInternal(NULL, fp, 0, nWritten);
}


void MTCompressor::Reset(void)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mSessions);
    MT_COMPRESS_CMD 			   *cmd;

    while (cb_iter())
    {
        cmd = cb_iter.key();
        cmd->checked = 0;
    }
}


MT_COMPRESS_CMD *MTCompressor::GetSession(char *name)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mSessions);
    MT_COMPRESS_CMD 			   *cmd;
    MT_COMPRESS_CMD 			   *match = NULL;

    while (cb_iter())
    {

        cmd = cb_iter.key();

        if (!cmd->checked && !strcmp(cmd->parameter_name, name))
        {
            cmd->checked = 1;
            match = cmd;
            break;
        }

    }

    return match;
}


MT_COMPRESS_CMD *MTCompressor::PeekSession(char *name)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mSessions);
    MT_COMPRESS_CMD 			   *cmd;
    MT_COMPRESS_CMD 			   *match = NULL;

    while (cb_iter())
    {

        cmd = cb_iter.key();

        if (!cmd->checked && !strcmp(cmd->parameter_name, name))
        {
            match = cmd;
            break;
        }

    }

    return match;
}

MT_COMPRESS_CMD *MTCompressor::GetProperty(char *pname, void *cookie)
{
		list<MT_COMPRESS_CMD *>::iterator cb_iter(mProperties);
    MT_COMPRESS_CMD 			   *cmd = NULL;

    while (cb_iter())
    {
        cmd = cb_iter.key();
        
        if ((cmd->cookie == cookie) &&
            !strcmp(pname, cmd->parameter_name))
        {
            return cmd;
        }
    }
    return NULL;
}

void MTCompressor::ClearCheckSum(void)
{
    mCheckSum = 0;
}

void MTCompressor::CheckSum(char *buf, size_t count)
{
    int i;
    int high;

    //fprintf(stdout, "CKSUM %d: ", count);
    for (i = 0; i < (int) count; i++)
    {
        // fprintf(stdout, "%08x = ", mCheckSum);
        mCheckSum += (unsigned char)buf[i];
        high = mCheckSum & 0x80000000;
        mCheckSum = mCheckSum << 1;
        if (high) 
          mCheckSum += 1;
        //fprintf(stdout, "%02x = %08x\n", (unsigned char)(buf[i]), mCheckSum);
    }
    //fprintf(stdout, " = %08x\n", mCheckSum);
}



BOOL MTCompressor::SessionSort(void)
{
		list<MT_COMPRESS_CMD *>::iterator iter(mCodebook);
		list<MT_COMPRESS_CMD *>::iterator siter(mSessions);
		list<MT_COMPRESS_CMD *> newSessions;

    MT_COMPRESS_CMD 			   *cbcmd = NULL;
    MT_COMPRESS_CMD 			   *scmd = NULL;
    int					   count;

    newSessions.clear();
    while (iter())
    {
        cbcmd = iter.key();
        count = 0;

        switch (cbcmd->id) {
          case MESSAGE_SESSION_ID:
              if ((count > 0) && !cbcmd->repeat)
              {
                  // multiple sessions on a no repeat!
                  return FALSE;
              }
              // Find all the occurences of this session name, 
              // put them next in the new session list, and terminate each
              // with and "end repeat"
              siter.reset();
              while (siter())
              {
                  scmd = siter.key();
                  if (!strcmp(cbcmd->parameter_name, scmd->parameter_name))
                  {
                      newSessions.append(scmd);
                  }
                  count++;
              }
              if (count > 1)
              {
                  // add a repeat terminator if a repeat sequence
                  scmd = NewCommand(MESSAGE_REPEAT_END);
                  SetCommandDataName(scmd, cbcmd->parameter_name);
                  newSessions.append(scmd);
              }
          default:
              break;
        }
            
    }
        
    mSessions = newSessions;
    
    return TRUE;
}
