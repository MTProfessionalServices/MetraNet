//
// MTMSIXInputStream.java
//
// Used to read in Local Mode File: Reads complete
// <msix>...</msix> tag
//
package com.metratech.sdk.base;

import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.Exception;

class MTMSIXInputStream extends FilterInputStream {

    public MTMSIXInputStream (InputStream in) {
        super(in);
    }

    private char mTarget[] = {'<', '/', 'm', 's', 'i', 'x', '>'};
    private int mTidx = 0;
    private boolean mEndOfStream = false;

    public int read(byte[] b, int off, int len) 
        throws IOException {

	if (mTidx == mTarget.length) {
	    return -1;
	}
	// Skip offset
	if (in.read(b, off, 0) < off) {
	    mEndOfStream = true;
	    return -1;
	} 

	int ch, i;
	for (i = 0; i < len; i++) {
	    // FIXME: This one-byte-at-a-time read sucks, but I'm too
	    // much a lazy-ass to implement a circular buffer to fix
	    // this.
	    ch = in.read();
	    if (ch == -1) { 
		mEndOfStream = true;
		if (i == 0) return -1;
		return i;
	    }
	    b[i] = (byte) ch;

	    if (ch == mTarget[mTidx]) {
		mTidx++;
	    } else {
		mTidx = 0;
	    }
	    if (mTidx == mTarget.length) {
		return i + 1;
	    }
	}
        return i;
    }

    // Only close if really at end of stream
    public void close() throws IOException {
	if (mEndOfStream) in.close();
    }

    // Returns true if reader is at true end of stream
    public boolean getEndOfStream() {
	return mEndOfStream;
    }

    //
    // Resets the reader to look for the next </msix> close tag.
    //
    public void NextMsix() {
	mTidx = 0;
    }

}

