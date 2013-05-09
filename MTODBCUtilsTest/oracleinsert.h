#ifndef _OCIARRAYINSERT_H_
#define _OCIARRAYINSERT_H_

#include <oci.h>
sword TestOCIInsertWithReturning();
sword Cleanup();
sword TestOCIInsertNarrow(int numrows, int arraysize);
sword TestOCIInsertWider(int numrows, int arraysize);
sword TestOCIInsertWide(int numrows, int arraysize);
void TestODBCArrayInsertNarrow(int numrows, int arraysize);
void TestODBCArrayInsertWider(int numrows, int arraysize);
void TestODBCArrayInsertWide(int numrows, int arraysize);

#endif