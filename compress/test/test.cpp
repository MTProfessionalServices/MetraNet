/**************************************************************************
 * @doc TEST
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
#include <mtcompress.h>
#include <iostream>

using std::cout;
using std::endl;

void test_write(char *codebook)
{
    MTCompressor 	mtc;
    FILE 		*fp;
    size_t		nbytes;

    // Load up the spec.
    mtc.LoadCodebook(codebook);
    mtc.DumpCodebook(stdout);

    // Set all the stuff
    mtc.SetName(MTCompressor::SEND_SESSION);

#if 0  // VERSION 1 of sample code
    mtc.AddSession("billo.com/yak", "session1", "parent2", (void *)0x00001967);
    mtc.AddProperty("SampleFoo", "yak", (void *)0x00001967);
    mtc.AddProperty("SampleBar", "bar", (void *)0x00001967);
    mtc.AddProperty("SampleYahoo", "yahoo", (void *)0x00001967);
    mtc.AddProperty("SampleInternationalFoo", L"bar", (void *)0x00001967);
    mtc.AddProperty("SampleRate", (float)1.45, (void *)0x00001967);
    mtc.AddProperty("SampleThing", (double)1.67, (void *)0x00001967);
    mtc.AddPropertyTime("SampleTime", 0x10000000, (void *)0x00001967);
    mtc.AddProperty("SampleMinutes", 60, (void *)0x00001967);

    mtc.AddSession("billo.com/yak", "session2", "parent2", (void *)0x00001968);
    mtc.AddProperty("SampleFoo", "yak2", (void *)0x00001968);
    mtc.AddProperty("SampleBar", "bar2", (void *)0x00001968);
    mtc.AddProperty("SampleYahoo", "yahoo2", (void *)0x00001968);
    mtc.AddProperty("SampleInternationalFoo", L"bar2", (void *)0x00001968);
    mtc.AddProperty("SampleRate", (float)1.46, (void *)0x00001968);
    mtc.AddProperty("SampleThing", (double)1.68, (void *)0x00001968);
    mtc.AddPropertyTime("SampleTime", 0x10000001, (void *)0x00001968);
    mtc.AddProperty("SampleMinutes", 61, (void *)0x00001968);

    mtc.AddSession("billo.com/yak", NULL, NULL, NULL); // end of repeat.
#endif

#if 1 // VERSION 2 of sample code

    // single session
    mtc.AddSession("billo.com/foo", "a", NULL, (void *)1);
    mtc.AddProperty("SampleFoo", "bar", (void *)1);

    // this one is out-of-order on purpose, to test session sorting.
    mtc.AddSession("billo.com/blork", "c", "b", (void *)5);
    mtc.AddProperty("SampleBlork", "z", (void *)5);

    // single session
    mtc.AddSession("billo.com/yak", "b", "a", (void *)2);
    mtc.AddProperty("SampleYakima", "yak", (void *)2);

    // begin repeat block

    mtc.AddSession("billo.com/blork", "c", "b", (void *)3);
    mtc.AddProperty("SampleBlork", "x", (void *)3);

    mtc.AddSession("billo.com/blork", "c", "b", (void *)4);
    mtc.AddProperty("SampleBlork", "y", (void *)4);

    mtc.AddSession("billo.com/blork", NULL, NULL, NULL); // end of repeat.

    mtc.SessionSort();
#endif

    fp = fopen("test.out", "wb");

    assert (fp != NULL);
        
    mtc.WriteCompressed(fp, &nbytes);
    
    fclose(fp);
}

void test_read(char *codebook, char *infile)
{
    MTCompressor 	mtc;
    FILE 		*fp;
    size_t		nbytes;

    // Load up the spec.
    mtc.LoadCodebook(codebook);

    fp = fopen(infile, "rb");

    assert (fp != NULL);
        
    mtc.ParseCompressed(fp, &nbytes);

    mtc.Dump(stdout);

    fclose(fp);
    
}

int main (int argc, char * argv[])
{
    if (!strcmp(argv[1], "-write"))
    {
        test_write(argv[2]);
        exit(0);
    }

    if (!strcmp(argv[1], "-parse"))
    {
        test_read(argv[2], argv[3]);
        exit(0);
    }

    return 0;
}


