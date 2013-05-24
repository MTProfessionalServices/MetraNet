/* 
 * common unix defs and decl for metratech.
 * billo 09-jul-1998
 */

////////////////////
// mef: override time and size definitions
#define USE_TIME
#define USE_SIZE
#include "unix_hacks.h"
// mef: override time and size definitions
////////////////////

// #include <unistd.h>
#include <sys/timeb.h>
#include <assert.h>

#ifndef BOOL
typedef int BOOL;
#endif

#ifndef DWORD
typedef unsigned long DWORD;
#endif

#ifndef DWORDLONG
typedef long long DWORDLONG;
#endif

#ifndef LONGLONG
typedef long long LONGLONG;
#endif

/* true and false */
#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE 1
#endif

#define MAX_PATH 256

#define Sleep(x) usleep((x)*1000)

#ifdef __cplusplus
extern "C" {
#endif

int usleep(unsigned int useconds); /*   no proto found on Sun ack :-P */

int gethostname(char *name, int namelen);

#ifdef sun4os5
int ftime(struct timeb *tp); /*  more solaris missing proto */
#endif

#ifdef __cplusplus
}
#endif

