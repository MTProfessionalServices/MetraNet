/* C++ code produced by gperf version 2.7.1 (19981006 egcs) */
/* Command-line: gperf -C -G -t -L C++ -Z MSIXTagHashInternal msix.gperf  */
#include "MSIXHash.h"
struct MSIXHashEntry;

#define TOTAL_KEYWORDS 39
#define MIN_WORD_LENGTH 1
#define MAX_WORD_LENGTH 15
#define MIN_HASH_VALUE 1
#define MAX_HASH_VALUE 91
/* maximum key range = 91, duplicates = 0 */

class MSIXTagHashInternal
{
private:
  static inline unsigned int hash (const char *str, unsigned int len);
public:
  static const struct MSIXHashEntry *in_word_set (const char *str, unsigned int len);
};

inline unsigned int
MSIXTagHashInternal::hash (register const char *str, register unsigned int len)
{
  static const unsigned char asso_values[] =
    {
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 35, 30,
      20, 10,  5, 92, 92, 10, 92, 25, 92, 25,
       0, 92,  0, 92, 92,  0,  0, 25, 45, 92,
       0, 10, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92, 92, 92, 92, 92,
      92, 92, 92, 92, 92, 92
    };
  return len + asso_values[(unsigned char)str[len - 1]] + asso_values[(unsigned char)str[0]];
}

static const struct MSIXHashEntry wordlist[] =
  {
    {""},
    {"p", MSIX_Session_Prop},
    {"ps", MSIX_Session_Props},
    {"txn", MSIX_Message_TransactionID},
    {"stat", MSIX_Status},
    {""},
    {"status", MSIX_Status},
    {""},
    {"sessstat", MSIX_SessionStatus},
    {"timestamp", MSIX_Message_Timestamp},
    {"properties", MSIX_Session_Props},
    {"f", MSIX_Session_Feedback},
    {"en", MSIX_Message_Entity},
    {"sessionstatus", MSIX_SessionStatus},
    {"time", MSIX_Message_Timestamp},
    {""},
    {"insert", MSIX_Session_Insert},
    {""},
    {"property", MSIX_Session_Prop},
    {""}, {""},
    {"i", MSIX_Session_Insert},
    {"dn", MSIX_Dn},
    {"pid", MSIX_Session_ParentId},
    {""}, {""},
    {"entity", MSIX_Message_Entity},
    {"ms", MSIX_Message},
    {"parentid", MSIX_Session_ParentId},
    {"msix", MSIX_Msix},
    {""}, {""},
    {"cs", MSIX_CommitSession},
    {"transactionid", MSIX_Message_TransactionID},
    {"csrs", MSIX_CommitSessionRS},
    {""},
    {"commit", MSIX_Session_Commit},
    {"bs", MSIX_Session},
    {"feedback", MSIX_Session_Feedback},
    {"bsrs", MSIX_BeginSessionRS},
    {""}, {""},
    {"message", MSIX_Message},
    {"commitsession", MSIX_CommitSession},
    {"code", MSIX_Code},
    {"commitsessionrs", MSIX_CommitSessionRS},
    {""},
    {"beginsession", MSIX_Session},
    {"uid", MSIX_Uid},
    {"beginsessionrs", MSIX_BeginSessionRS},
    {""}, {""},
    {"version", MSIX_Message_Version},
    {""}, {""}, {""}, {""}, {""}, {""}, {""},
    {"value", MSIX_Session_Value},
    {"c", MSIX_Session_Commit},
    {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
    {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
    {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}, {""},
    {""}, {""},
    {"v", MSIX_Message_Version}
  };

const struct MSIXHashEntry *
MSIXTagHashInternal::in_word_set (register const char *str, register unsigned int len)
{
  if (len <= MAX_WORD_LENGTH && len >= MIN_WORD_LENGTH)
    {
      register int key = hash (str, len);

      if (key <= MAX_HASH_VALUE && key >= 0)
        {
          register const char *s = wordlist[key].name;

          if (*str == *s && !strcmp (str + 1, s + 1))
            return &wordlist[key];
        }
    }
  return 0;
}

const struct MSIXHashEntry * FindMSIXTag(const char *str, unsigned int len)
{
	return MSIXTagHashInternal::in_word_set(str, len);
}
