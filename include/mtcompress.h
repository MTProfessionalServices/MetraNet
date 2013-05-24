/**************************************************************************
* @doc MTCOMPRESS
*
* @module |
*
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
*
* @index | MTCOMPRESS
***************************************************************************/

#ifndef _MTCOMPRESS_H
#define _MTCOMPRESS_H

#include <errobj.h>

#include <list>
#include <stack>
#include <vector>

typedef struct _MtCompressCmd MT_COMPRESS_CMD;

#define MTC_MAX_RECORD 2048


class MTCompressor : public ObjectWithError
{
// @access Public:
public:
    
    enum MessageName
    {
        QUERY_SERVER,
        QUERY_VERSION,
        SEND_SESSION
    };

    enum MessageCommand
    {
        MESSAGE_VERSION = 0x21,     // ! to make debugging easier.
        MESSAGE_NAME,               // doublequote
        MESSAGE_CKSUM,              // #
        MESSAGE_SESSION_ID,         // $
        MESSAGE_PROPERTY_TEXT,      // %
        MESSAGE_PROPERTY_WTEXT,     // &
        MESSAGE_PROPERTY_INT32,     // singlequote
        MESSAGE_PROPERTY_FLOAT,     // left paren
        MESSAGE_PROPERTY_DOUBLE,    // right paren
        MESSAGE_PROPERTY_TIME,      // *
        MESSAGE_REPEAT_END,         // +
        MESSAGE_CBNAME,              // ,
        MESSAGE_END                 // 
    };


    enum MessageType {
        MESSAGE_TYPE_NONE,
        MESSAGE_TYPE_WTEXT,
        MESSAGE_TYPE_TEXT,
        MESSAGE_TYPE_INT,
        MESSAGE_TYPE_FLOAT,
        MESSAGE_TYPE_DOUBLE,
        MESSAGE_TYPE_TIME,
        MESSAGE_TYPE_BYTE
    };

     // @cmember
    // Constructor.
    MTCompressor();

    // @cmember Destructor.
    // @devnote destructors in derived classes should call Close()
    virtual ~MTCompressor();

    BOOL CreateCodebook(const char * apCodeBookPath = NULL);

    BOOL LoadCodebook(const char * apCodeBookPath = NULL);

    BOOL DumpCodebook(FILE *fp);

    BOOL Dump(FILE *fp);

    BOOL DumpProp(MT_COMPRESS_CMD *prop, FILE *fp);

    BOOL SetName(MessageName name);

    BOOL AddCommand(MessageCommand cmd);

    BOOL AddCommand(MessageCommand cmd, int val32, void *cookie);

    BOOL AddCommand(MessageCommand cmd, char *text, void *cookie);

    BOOL AddCommand(MessageCommand cmd, wchar_t *wtext, void *cookie);

    BOOL AddCommand(MessageCommand cmd, float fval, void *cookie);

    BOOL AddCommand(MessageCommand cmd, double dval, void *cookie);
    
    // to end a repeat, pass in a session with all null arguments.
    BOOL AddSession(const char *name, const char *session_id, const char *parent_id,
										void *cookie);

    BOOL AddProperty(const char *param_name, int val32, void *cookie);

    // time and int are the same data type, so need a different 
    // function name to distinguish
    BOOL AddPropertyTime(const char *param_name, int val32, void *cookie);

    BOOL AddProperty(const char *param_name, const char *text, void *cookie);

    BOOL AddProperty(const char *param_name, const wchar_t *wtext, void *cookie);

    BOOL AddProperty(const char *param_name, float fval, void *cookie);

    BOOL AddProperty(const char *param_name, double dval, void *cookie);

    //@cmember write session data to FILE stream given sessions, properties 
    //         and loaded codebook
    BOOL WriteCompressed(FILE *fp, size_t *nWritten);

    //@cmember read session data from FILE stream given loaded codebook.
    //         Creates sessions and streams in the compressor.
    BOOL ParseCompressed(FILE *fp, size_t *nRead);

    //@cmember buffered version of WriteCompressed
    BOOL WriteCompressed(unsigned char *buff, size_t bufsize,
                         size_t *nWritten);

    //@cmember buffered version of ParseCompressed
    BOOL ParseCompressed(char *buff, size_t bufsize, size_t *nRead);

    //@cmember take all sessions in the compressor, and sort them to 
    // match the codebook.
    BOOL SessionSort(void);

    //@cmember pretend to write a session, for the purpose
    //         of computing the checksum.  note that 
    //         the actual checksum value itself is NOT included in 
    //         the computation; a four-byte zero value is substituted.
    BOOL WriteFake(size_t *nWritten);

// @access Protected:
protected:

// @access Private:
private:
    //@cmember clear the checksum
    void ClearCheckSum(void);
    
    //@cmember feed bytes into the checksum computation
    void CheckSum(char *buf, size_t nbytes);

    //@cmember the internal common engine for writing compressed data
    BOOL    WriteCompressedInternal(unsigned char *buff, 
                                    FILE *fp,
                                    size_t outsize,
                                    size_t *nWritten);

    //@cmember the internal common engine for parsing compressed data
    BOOL    ParseCompressedInternal(char *buff, 
                                    FILE *fp,
                                    size_t insize,
                                    size_t *nRead);

    //@cmember read and correct for byte-ordering a four-byte integer,
    //         optionally computing the checksum
    BOOL ParseGetInteger(FILE *fp, char **buf, size_t insize, size_t *nRead,
                         int *output, BOOL checksum);

    //@cmember read a byte, optionally computing the checksum
    BOOL ParseGetByte(FILE *fp, char **buf, size_t insize, size_t *nRead,
                         char *output, BOOL checksum);

    //@cmember read a sequence of bytes, optionally computing the checksum
    BOOL ParseGetBytes(FILE *fp, char **buf, size_t insize, size_t *nRead,
                       char *output, BOOL checksum, size_t nbytes);

    //@cmember read a 4-byte float, optionally computing the checksum
    BOOL ParseGetFloat(FILE *fp, char **buf, size_t insize, size_t *nRead,
                       float *output, BOOL checksum);

    //@cmember read a 8-byte double, optionally computing the checksum
    BOOL ParseGetDouble(FILE *fp, char **buf, size_t insize, size_t *nRead,
                        double *output, BOOL checksum);


    //@cmember utility function for duping byte sequences
    char *MemDup(char *s, int n);

    //@cmember unimplemented
    BOOL    SetExpectedChecksum(unsigned int cksum);

    //@cmember instantiate a new command object in the compressor
    MT_COMPRESS_CMD *NewCommand(MessageCommand cmd);

    //@cmember get the next session instantiation in the compressor.
    MT_COMPRESS_CMD *GetSession(char *name);

    //@cmember peek at the next, but don't forward the marker
    MT_COMPRESS_CMD *PeekSession(char *name);

    //@cmember reset the session sequence for iteration.
    void Reset(void);

    //@cmember find a property instantiation in the property heap.
    MT_COMPRESS_CMD *GetProperty(char *param_name, void *cookie);

    //@cmember create the compressed byte sequence for a given command
    BOOL WriteCommand(MT_COMPRESS_CMD *cmd, char *buf, size_t *bufsize);

    //@cmember Parse a line from the codebook
    BOOL ParseLine(char *line);

    BOOL mCheckSumOnly;
    int  mCheckSum;
    int  mCheckSumSaved;

    char *GetToken(char *ptr, char *token, int max);
                      
    char *mCodebookPath;

    char *mCodebookName;

    int mCodebookVersion;

    // This is a list of command templates in the desired order
    // This is created by loading the codebook.
    list<MT_COMPRESS_CMD *> mCodebook;

    // These is a heap of the commands 
    list<MT_COMPRESS_CMD *> mCommands;

    list<MT_COMPRESS_CMD *> mSessions;

    list<MT_COMPRESS_CMD *> mProperties;

    stack<MT_COMPRESS_CMD *, std::vector<MT_COMPRESS_CMD *> > mRepeat;

    //@cmember free all memory associate with a command instantation.
    void FreeCommand(MT_COMPRESS_CMD *cmd);

    //@cmember set the data values for commands
    BOOL SetCommandData(MT_COMPRESS_CMD *cmd, int val);

    //@cmember set the data values for commands
    BOOL SetCommandData(MT_COMPRESS_CMD *cmd, float val);

    //@cmember set the data values for commands
    BOOL SetCommandData(MT_COMPRESS_CMD *cmd, double val);

    //@cmember set the data values for commands
    BOOL SetCommandData(MT_COMPRESS_CMD *cmd, const char *text);

    //@cmember set the data values for commands
    BOOL SetCommandData(MT_COMPRESS_CMD *cmd, const wchar_t *wtext);

    //@cmember set the secondary data values for commands
    BOOL SetCommandData2(MT_COMPRESS_CMD *cmd, const char *text);

    //@cmember set the parameter name values for commands (like prop name)
    BOOL SetCommandDataName(MT_COMPRESS_CMD *cmd, const char *text);
    
};

struct _MtCompressCmd {
    MTCompressor::MessageCommand id;
    size_t parameter_size;
    size_t value_size;
    size_t value_size2;        // used for parent id
    char *parameter_name;
    MTCompressor::MessageType value_type;
    char *value_text;
    char *value_text2;       // used for parent id
    wchar_t *value_wtext;
    double value_double;
    float         value_float;
    int value_int;
    void *cookie;
    int checked;
    BOOL repeat;
};
        


#endif /* _MTCOMPRESS_H */
