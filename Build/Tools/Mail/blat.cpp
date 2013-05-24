#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
/* generic socket DLL support */
#include "gensock.h"

using std::cout;
using std::endl;

#ifdef WIN32         
  #define __far far
  #define huge far
  #define __near near
#endif               

#define MAXOUTLINE 255

HANDLE	gensock_lib = 0;

int (FAR PASCAL *pgensock_connect) (char FAR * hostname, char FAR * service, socktag FAR * pst);
int (FAR PASCAL *pgensock_getchar) (socktag st, int wait, char FAR * ch);
int (FAR PASCAL *pgensock_put_data) (socktag st, char FAR * data, unsigned long length);
int (FAR PASCAL *pgensock_close) (socktag st);
int (FAR PASCAL *pgensock_gethostname) (char FAR * name, int namelen);
int (FAR PASCAL *pgensock_put_data_buffered) (socktag st, char FAR * data, unsigned long length);
int (FAR PASCAL *pgensock_put_data_flush) (socktag st);


socktag SMTPSock;
#define SERVER_SIZE	256     // #defines (bleah!) from Beverly Brown "beverly@datacube.com"
#define SENDER_SIZE	256
#define FILENAME_SIZE	256
#define MESSAGE_SIZE	256

char SMTPHost[SERVER_SIZE];
char Sender[SENDER_SIZE];

char sigfilename[FILENAME_SIZE];
char message1[MESSAGE_SIZE+1];
char message2[MESSAGE_SIZE+1];
char message3[MESSAGE_SIZE+1];
char message4[MESSAGE_SIZE+1];
char message5[MESSAGE_SIZE+1];

char *Recipients;
char my_hostname[1024];
char *destination="";
char *cc_list="";
char *bcc_list="";
char *loginname="";
char *senderid="";
char *subject="";
int quiet=0;

char *usage[]=
{
 "Blat v1.4: WinNT console utility to mail a file via SMTP",
 "",
 "syntax:",
 "Blat <filename> -t <recipient> [optional switches (see below)]",
 "Blat -install <server addr> <sender's addr> [-q]",
 "Blat -h [-q]",
 "",
 "-install <server addr> <sender's addr>: set's default SMTP server and sender",
 "",
 "<filename>    : file with the message body ('-' for console input, end with ^Z)",
 "-t <recipient>: recipient list (comma separated)",
 "-s <subj>     : subject line",
 "-f <sender>   : overrides the default sender address (must be known to server)",
 "-i <addr>     : a 'From:' address, not necessarily known to the SMTP server.",
 "-c <recipient>: carbon copy recipient list (comma separated)",
 "-b <recipient>: blind carbon copy recipient list (comma separated)",
 "-h            : displays this help.",
 "-q            : supresses *all* output.",
 "-server <addr>: overrides the default SMTP server to be used.",
 "",
 "Note that if the '-i' option is used, <sender> is included in 'Reply-to:'",
 "and 'Sender:' fields in the header of the message."
};

const NMLINES=22;
 
void
gensock_error (char * function, int retval)
{
 if( ! quiet )
  cout << "error " << retval << " in function '" << function;
}

// loads the GENSOCK DLL file
int load_gensock()
{
  if( (gensock_lib = LoadLibrary("gwinsock.dll")) == NULL )
  {
   if( (gensock_lib = LoadLibrary("gensock.dll")) == NULL )
   {
    if( ! quiet )
     cout << "Couldn't load either 'GWINSOCK.DLL' or 'GENSOCK.DLL'\nInstall one of these in your path.";
    return -1;
   }
  }

  if( 
     ( pgensock_connect = 
      (  int (FAR PASCAL *)(char FAR *, char FAR *, socktag FAR *) )
      GetProcAddress(gensock_lib, "gensock_connect")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_connect\n";
   return -1;
  }

  if (
      ( pgensock_getchar =
       ( int (FAR PASCAL *) (socktag, int, char FAR *) )
       GetProcAddress(gensock_lib, "gensock_getchar")
      ) == NULL
     )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_getchar\n";
   return -1;
  }

  if(
     ( pgensock_put_data =
       ( int (FAR PASCAL *) (socktag, char FAR *, unsigned long) )
       GetProcAddress(gensock_lib, "gensock_put_data")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_put_data\n";
   return -1;
  }

  if(
     ( pgensock_close =
       (int (FAR PASCAL *) (socktag) )
       GetProcAddress(gensock_lib, "gensock_close")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_close\n";
   return -1;
  }

  if(
     ( pgensock_gethostname =
       (int (FAR PASCAL *) (char FAR *, int) )       
       GetProcAddress(gensock_lib, "gensock_gethostname")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_gethostname\n";
   return -1;
  }

  if(
     ( pgensock_put_data_buffered =
       ( int (FAR PASCAL *) (socktag, char FAR *, unsigned long) )
       GetProcAddress(gensock_lib, "gensock_put_data_buffered")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_put_data_buffered\n";
   return -1;
  }

  if(
     ( pgensock_put_data_flush =
       ( int (FAR PASCAL *) (socktag) )
       GetProcAddress(gensock_lib, "gensock_put_data_flush")
     ) == NULL
    )
  {
   if( ! quiet )
    cout << "couldn't getprocaddress for gensock_put_data_flush\n";
   return -1;
  }

  return 0;
}

int open_smtp_socket( void )
{
  int retval;

  /* load the library if it's not loaded */
//  if (!gensock_lib)
    if ( ( retval = load_gensock() ) ) return ( retval );

  if ( (retval = (*pgensock_connect) ((LPSTR) SMTPHost,
				     (LPSTR)"smtp",
				     &SMTPSock)))
  {
    if (retval == ERR_CANT_RESOLVE_SERVICE)
    {
     if ((retval = (*pgensock_connect) ((LPSTR)SMTPHost,
					 (LPSTR)"25",
					 &SMTPSock)))
     {
	   gensock_error ("gensock_connect", retval);
	   return -1;
     }
    }
  // error other than can't resolve service 
    else
    {
     gensock_error ("gensock_connect", retval);
     return -1;
    }
  }

  // we wait to do this until here because WINSOCK is
  // guaranteed to be already initialized at this point.

  // get the local hostname (needed by SMTP) 
  if ((retval = (*pgensock_gethostname) (my_hostname, sizeof(my_hostname))))
  {
    gensock_error ("gensock_gethostname", retval);
    return -1;
  }
  return 0;
}


int close_smtp_socket( void )
{
  int retval;

  if( (retval = (*pgensock_close) (SMTPSock)) )
  {
    gensock_error ("gensock_close", retval);
    return -1;
  }
  FreeLibrary( gensock_lib );
  return (0);
}

int get_smtp_line( void )
{
  char ch = '.';
  char in_data [MAXOUTLINE];
  char * index;
  int retval = 0;

  index = in_data;

  while (ch != '\n')
  {
   if( (retval = (*pgensock_getchar) (SMTPSock, 0, &ch) ) )
   {
      gensock_error ("gensock_getchar", retval);
      return -1;
    }
    else
    {
      *index = ch;
      index++;
    }
  }

  /* this is to support multi-line responses, common with */
  /* servers that speak ESMTP */

  /* I know, I know, it's a hack 8^) */
  if( in_data[3] == '-' ) return( get_smtp_line() );
  else return atoi(in_data);
}

int put_smtp_line( socktag sock, char far * line, unsigned int nchars )
{
  int retval;

  if( (retval = (*pgensock_put_data) (sock, line, (unsigned long) nchars)))
  {
    gensock_error ("gensock_put_data", retval);
    return -1;
  }
  return (0);
}

int putline_internal (socktag sock, char * line, unsigned int nchars)
{
  int retval;

  if ((retval =
       (*pgensock_put_data) (sock,
			    (char FAR *) line,
			    (unsigned long) nchars)))
  {
    switch (retval)
    {
     case ERR_NOT_CONNECTED:
      gensock_error( "SMTP server has closed the connection", retval );
      break;

     default:
      gensock_error ("gensock_put_data", retval);
    }
    return -1;
  }
  return (0);
}

void smtp_error (char * message)
{
 if( ! quiet )
  cout << message << "\n";
 put_smtp_line (SMTPSock, "QUIT\r\n", 6);
 close_smtp_socket();
}


// 'destination' is the address the message is to be sent to
// 'message' is a pointer to a null-terminated 'string' containing the 
// entire text of the message. 

int prepare_smtp_message(char * MailAddress, char * destination)
{
  char out_data[MAXOUTLINE];
  char str[1024];
  char *ptr;
  int len, startLen;

  if ( open_smtp_socket() ) return -1;

  if ( get_smtp_line() != 220 )
  {
    smtp_error ("SMTP server error");
    return(-1);
  }

  sprintf( out_data, "HELO %s\r\n", my_hostname );
  put_smtp_line( SMTPSock, out_data, strlen (out_data) );

  if ( get_smtp_line() != 250 )
  {
    smtp_error ("SMTP server error");
    return -1;
  }

  sprintf (out_data, "MAIL From:<%s>\r\n", loginname);
  put_smtp_line( SMTPSock, out_data, strlen (out_data) );

  if (get_smtp_line() != 250)
  {
    smtp_error ("The mail server doesn't like the sender name,\nhave you set your mail address correctly?");
    return -1;
  }

  // do a series of RCPT lines for each name in address line
  for (ptr = destination; *ptr; ptr += len + 1)
  {
    // if there's only one token left, then len will = startLen,
    // and we'll iterate once only
    startLen = strlen (ptr);
    if ((len = strcspn (ptr, " ,\n\t\r")) != startLen)
    {
      ptr[len] = '\0';			// replace delim with NULL char
      while (strchr (" ,\n\t\r", ptr[len+1]))	// eat white space
        ptr[len++] = '\0';
    }

    sprintf (out_data, "RCPT To: <%s>\r\n", ptr);
    putline_internal( SMTPSock, out_data, strlen (out_data) );

    if (get_smtp_line() != 250)
    {
      sprintf (str, "The mail server doesn't like the name %s.\nHave you set the 'To: ' field correctly?", ptr);
      smtp_error (str);
      return -1;
    }

    if (len == startLen)	// last token, we're done
      break;
  }

  sprintf (out_data, "DATA\r\n");
  put_smtp_line (SMTPSock, out_data, strlen (out_data));

  if (get_smtp_line() != 354)
  {
    smtp_error ("Mail server error accepting message data");
    return -1;
  }

  return(0);

}

int transform_and_send_edit_data( socktag sock, char * editptr )
{
  char *index;
  char *header_end;
  char previous_char = 'x';
  unsigned int send_len;
  int retval;
  BOOL done = 0;

  send_len = lstrlen(editptr);
  index = editptr;

  header_end = strstr (editptr, "\r\n\r\n");

  while (!done)
  {
    // room for extra char for double dot on end case
    while ((unsigned int) (index - editptr) < send_len)
    {
      switch (*index)
      {
       case '.':
	             if (previous_char == '\n')
	              /* send _two_ dots... */
	              if ((retval = (*pgensock_put_data_buffered) (sock, index, 1))) return (retval);
	  	         if ((retval = (*pgensock_put_data_buffered) (sock, index, 1))) return (retval);
	             break;
       case '\r':
	             // watch for soft-breaks in the header, and ignore them
                 if (index < header_end && (strncmp (index, "\r\r\n", 3) == 0))
	               index += 2;
	             else
	              if (previous_char != '\r')
	               if ((retval = (*pgensock_put_data_buffered) (sock, index, 1)))
	                return (retval);
	              // soft line-break (see EM_FMTLINES), skip extra CR */
				 break;
	   default:
	           if ((retval = (*pgensock_put_data_buffered) (sock, index, 1)))
	            return (retval);
      }
      previous_char = *index;
      index++;
    }
    if( (unsigned int) (index - editptr) == send_len) done = 1;
  }

  // this handles the case where the user doesn't end the last
  // line with a <return>

  if (editptr[send_len-1] != '\n')
  {
    if ((retval = (*pgensock_put_data_buffered) (sock, "\r\n.\r\n", 5)))
      return (retval);
  }
  else
    if ((retval = (*pgensock_put_data_buffered) (sock, ".\r\n", 3)))
      return (retval);

  /* now make sure it's all sent... */
  if ((retval = (*pgensock_put_data_flush)(sock))) return (retval);
  return (TRUE);
}



int send_smtp_edit_data (char * message)
{
  transform_and_send_edit_data( SMTPSock, message );

  if (get_smtp_line() != 250)
  {
    smtp_error ("Message not accepted by server");
    return -1;
  }
  return(0);
}


int finish_smtp_message( void )
{
  return put_smtp_line( SMTPSock, "QUIT\r\n", 6 );
}

// create a registry entries for this program 
int CreateRegEntry( void )
{
  HKEY  hKey1;
  DWORD  dwDisposition;
  LONG   lRetCode;

  /* try to create the .INI file key */
  lRetCode = RegCreateKeyEx ( HKEY_LOCAL_MACHINE,
                              "SOFTWARE\\Public Domain\\Blat",
                              0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE,NULL, &hKey1,&dwDisposition
                            );

  /* if we failed, note it, and leave */
  if (lRetCode != ERROR_SUCCESS)
  {
    if( ! quiet ) printf ("Error in creating blat key in the registry\n");
    return 10;
  }

  /* try to set a section value */
  lRetCode = RegSetValueEx( hKey1,"SMTP server",0,REG_SZ, (BYTE *) &SMTPHost[0], (strlen(SMTPHost)+1));

  /* if we failed, note it, and leave */
  if (lRetCode != ERROR_SUCCESS)
  {
    if( ! quiet ) printf ( "Error in setting SMTP server value in the registry\n");
    return 11;
  }
  
  /* try to set another section value */
  lRetCode = RegSetValueEx( hKey1,"Sender",0,REG_SZ, (BYTE *) &Sender[0], (strlen(Sender)+1));

  /* if we failed, note it, and leave */
  if (lRetCode != ERROR_SUCCESS)
  {
   if( ! quiet ) printf ( "Error in setting sender address value in the registry\n");
    return 11;
  }
  
  return 0;
}

// get the registry entries for this program 
int GetRegEntry( void )
{
  HKEY  hKey1;
  DWORD  dwType;
  DWORD  dwBytesRead;
  LONG   lRetCode;

  // open the registry key in read mode
  lRetCode = RegOpenKeyEx( HKEY_LOCAL_MACHINE,
                           "SOFTWARE\\Public Domain\\Blat",
                           0, KEY_READ, &hKey1
                         );
  if( lRetCode != ERROR_SUCCESS )
  {
     if( ! quiet ) printf( "Failed to open registry key for Blat\n" );
     return 12;
  }
  // set the size of the buffer to contain the data returned from the registry
  // thanks to Beverly Brown "beverly@datacube.com" and "chick@cyberspace.com" for spotting it...
  dwBytesRead=SERVER_SIZE;
  // read the value of the SMTP server entry
  lRetCode = RegQueryValueEx( hKey1, "SMTP server", NULL , &dwType, (BYTE *) &SMTPHost, &dwBytesRead); 
  // if we failed, note it, and leave
  if( lRetCode != ERROR_SUCCESS )
  {
    if( ! quiet ) printf( "Failed to read SMTP server value from the registry\n" );
    return 12;
  }

  dwBytesRead=SENDER_SIZE;
  // read the value of the SMTP server entry
  lRetCode = RegQueryValueEx( hKey1, "Sender", NULL , &dwType, (BYTE *) &Sender, &dwBytesRead); 
  // if we failed, note it, and leave
  if( lRetCode != ERROR_SUCCESS )
  {
    if( ! quiet ) printf( "Failed to read senders user name from the registry\n" );
    return 12;
  }

 return 0;
}


int main( int argc,        /* Number of strings in array argv          */
           char *argv[],    /* Array of command-line argument strings   */
           char **envp )    /* Array of environment variable strings    */
{
 int next_arg=2;
 int impersonating = 0;
 int penguin = 0;
 int i, j;
 char tempdir[MAX_PATH+1];
 char tempfile[MAX_PATH+1];
 HANDLE fileh;
 HANDLE sigfileh;
 FILE *tf;
 int hours, minutes;
 OFSTRUCT of;


 // by default Blat is very noisy!
 quiet = 0;

 // no tempfile so far...
 tempfile[0] = '\0';

 if(argc<2)
 {
  // must have at least file name to send
  for(i=0;i<NMLINES;i++) cout<<usage[i]<<'\n';
  return 1;
 }

 for( i=1; i < argc; i++ )
  if( lstrcmpi( "-q",argv[i] ) == 0 ) quiet = 1;
 
 // get file name from argv[1]
 char *filename=argv[1];

 Sender[0] = '\0';
 SMTPHost[0] = '\0';

 sigfilename[0] = '\0';
 message1[0] = '\0';
 message2[0] = '\0';
 message3[0] = '\0';
 message4[0] = '\0';
 message5[0] = '\0';

 GetRegEntry();

 senderid  = Sender;
 loginname = Sender;
    	
 // thanks to Beverly Brown "beverly@datacube.com" for
 // fixing the argument parsing, I "fixed" the brackets
 // to conform approximately to our "style"  :-)
 // Starts here
 for(next_arg=1;next_arg < argc;next_arg++)
 {
	if(lstrcmpi("-h",argv[next_arg])==0)
	{
	 if( ! quiet ) for(int i=0;i<NMLINES;i++) cout<<usage[i]<<'\n';
	 return 1;
	}

   	   // is argv[2] "-install"? If so, indicate error and return
	else if(lstrcmpi("-install",argv[next_arg])==0)
	{
	   if((argc == 3) || (argc == 4)) 
	 	    {
			strcpy( SMTPHost, argv[++next_arg] );
		 	if(argc == 4) 
			 	strcpy( Sender, argv[++next_arg] );
			else
				strcpy( Sender, "" );
	 		if( CreateRegEntry() == 0 ) 
	 		    {
			  	 if( ! quiet ) printf("\nSMTP server set to %s\n", SMTPHost );
		 		 return 0;
	 		    }
	 	    }
	   else
	      {
		   if( ! quiet )
		    printf( "to set the SMTP server's address and the user name at that address do:\nblat -install server username");
	  	   return 6;
	      }
	}

   	 // is argv[2] "-s"? If so, argv[3] is the subject
	else if(lstrcmpi("-s",argv[next_arg])==0)
	{
	 subject=argv[++next_arg];
	}

   	// is argv[2] "-c"? If so, argv[3] is the carbon-copy list
	else if(lstrcmpi("-c",argv[next_arg])==0)
	{
	 cc_list=argv[++next_arg];
	}

   	// is argv[2] "-b"? If so, argv[3] is the blind carbon-copy list
	else if(lstrcmpi("-b",argv[next_arg])==0)
	{
	 bcc_list=argv[++next_arg];
	}

   	 // is next argv "-t"? If so, succeeding argv is the destination
	else if(lstrcmpi("-t",argv[next_arg])==0)
	{
	 destination=argv[++next_arg];
	}

	// is next argv "-server"? If so, succeeding argv is the SMTPHost	
	else if(lstrcmpi("-server",argv[next_arg])==0)
	{
	 strcpy(SMTPHost,argv[++next_arg]);
	}

	// is next argv "-sig"? If so, succeeding argv is the .sig file ref
	else if(lstrcmpi("-sig",argv[next_arg])==0)
	{
	 strcpy(sigfilename,argv[++next_arg]);
	}

	// is next argv "-mess1"? If so, succeeding argv is the message text
	else if(lstrcmpi("-mess1",argv[next_arg])==0)
	{
	 strcpy(message1,argv[++next_arg]);
	}

	// is next argv "-mess2"? If so, succeeding argv is the message text
	else if(lstrcmpi("-mess2",argv[next_arg])==0)
	{
	 strcpy(message2,argv[++next_arg]);
	}

	// is next argv "-mess3"? If so, succeeding argv is the message text
	else if(lstrcmpi("-mess3",argv[next_arg])==0)
	{
	 strcpy(message3,argv[++next_arg]);
	}

	// is next argv "-mess4"? If so, succeeding argv is the message text
	else if(lstrcmpi("-mess4",argv[next_arg])==0)
	{
	 strcpy(message4,argv[++next_arg]);
	}

	// is next argv "-mess5"? If so, succeeding argv is the message text
	else if(lstrcmpi("-mess5",argv[next_arg])==0)
	{
	 strcpy(message5,argv[++next_arg]);
	}

	 //is next argv '-f'? If so, succeeding argv is the loginname
	else if(lstrcmp("-f",argv[next_arg])==0)
 	 loginname=argv[++next_arg];

	else if(lstrcmp("-penguin",argv[next_arg])==0)
	{
	 penguin = 1;
	}
	
	// if next arg is a '-q' just increase and continue looking
	// we have already dealt with -q at the beggining
	else if(lstrcmp("-q",argv[next_arg])==0)
	{
	 next_arg++;
	}

	//is next argv '-i'? If so, succeeding argv is the sender id
	else if(lstrcmp("-i",argv[next_arg])==0)
	{
	 senderid=argv[++next_arg];
	 impersonating = 1;
	}
	else if(next_arg == 1) 
	{
 	 if (lstrcmp(filename, "-") != 0)
	 {
	  if( lstrlen(filename)<=0 || OpenFile(filename,&of,OF_EXIST) == HFILE_ERROR )
	  {
	   if( ! quiet ) cout<<filename<<" does not exist\n";		
	    return 2;
	  }
	 }
	} 
	else 
	{
	 if( ! quiet )
	  for(i=0;i<NMLINES;i++)
		cout<<usage[i]<<'\n';
	 return 1;
	}
 }

	// if we are not impersonating loginname is the same as the sender
	if( ! impersonating )
	  	senderid = loginname;

      // fixing the argument parsing
	  // Ends here

	if ((SMTPHost[0]=='\0')||(loginname[0]=='\0'))
	{
	 if( ! quiet )
	 {
	  printf( "to set the SMTP server's address and the user name at that address do:\nblat -install server username\n");
	  printf( "or use '-server <server name>' and '-f <user name>'\n");
	  printf( "aborting, nothing sent\n" );
	 }
	 return 12;
    }
	
	// make sure filename exists, get full pathname
    if (lstrcmp(filename, "-") != 0)
	 if(lstrlen(filename)<=0 || OpenFile(filename,&of,OF_EXIST)==HFILE_ERROR)
	 {
	  if( ! quiet ) cout<<filename<<" does not exist\n";		
	  return 2;
	 }

	// build temporary recipients list for parsing the "To:" line
	char *temp = new char [ strlen(destination) + strlen(cc_list) + strlen(bcc_list) + 4 ];
	// build the recipients list
	Recipients = new char [ strlen(destination) + strlen(cc_list) + strlen(bcc_list) + 4 ];
	
	// Parse the "To:" line
	for (i = j = 0; i < (int) strlen(destination); i++)
	{
	  // strip white space
      while (destination[i]==' ')
	    i++;
	  // look for comments in brackets, and omit
	  if (destination[i]=='(')
	  {
	    while (destination[i]!=')')
		  i++;
		i++;
      }	  
  	  // look for comments in quotes, and omit
  	  if (destination[i]=='\'')
	  {
	  i++;
	    while (destination[i]!='\'')
		  i++;
		i++;
      }	  
	  
	  temp[j++] = destination[i];
    }
  temp[j++] = '\0';
	strcpy( Recipients, temp);


	// Parse the "Cc:" line
	for (i = j = 0; i < (int) strlen(cc_list); i++)
	{
	 // strip white space
     while (cc_list[i]==' ') i++;
	 // look for comments in brackets, and omit
	 if (cc_list[i]=='(')
	 {
	  while (cc_list[i]!=')') i++;
	  i++;
     }	  
  	 // look for comments in quotes, and omit
  	 if (cc_list[i]=='\'')
	 {
	  i++;
	  while (cc_list[i]!='\'') i++;
	  i++;
     }	  
	 temp[j++] = cc_list[i];
    }
	if( strlen(cc_list) > 0 )
	{
	 strcat(Recipients, "," );
	 strcat(Recipients, temp);
	}

	// Parse the "Bcc:" line
	for (i = j = 0; i < (int) strlen(bcc_list); i++)
	{
	 // strip white space
     while (bcc_list[i]==' ') i++;
	 // look for comments in brackets, and omit
	 if (bcc_list[i]=='(')
	 {
	  while (bcc_list[i]!=')') i++;
	  i++;
     }	  
  	 // look for comments in quotes, and omit
  	 if (bcc_list[i]=='\'')
	 {
	  i++;
	  while (bcc_list[i]!='\'') i++;
	  i++;
     }	  
	 temp[j++] = bcc_list[i];
    }

	if( strlen(bcc_list) > 0 )
	{
	 strcat(Recipients, "," );
	 strcat(Recipients, temp);
	}
   

	// create a header for the message
	char tmpstr[256];
	char header[2048];
	int  headerlen;
    SYSTEMTIME curtime;
	TIME_ZONE_INFORMATION tzinfo;
    char * days[] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
    char * months[] = { "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
	DWORD retval;

    GetLocalTime( &curtime );
	retval = GetTimeZoneInformation( &tzinfo );
	hours = (int) tzinfo.Bias / 60;
	minutes = (int) tzinfo.Bias % 60;
    if( retval == TIME_ZONE_ID_STANDARD ) 
	{
	 hours += (int) tzinfo.StandardBias / 60;
	 minutes += (int) tzinfo.StandardBias % 60;
	}
	else
  	{
	 hours += (int) tzinfo.DaylightBias / 60;
	 minutes += (int) tzinfo.DaylightBias % 60;
	}
	
    // rfc1036 & rfc822 acceptable format
    // Mon, 29 Jun 94 02:15:23 GMT
    sprintf (tmpstr, "Date: %s, %.2d %s %.2d %.2d:%.2d:%.2d ",
      days[curtime.wDayOfWeek],
      curtime.wDay,
      months[curtime.wMonth - 1],
      curtime.wYear,
      curtime.wHour,
      curtime.wMinute,
      curtime.wSecond);
    strcpy( header, tmpstr );

	sprintf( tmpstr, "%+03d%02d", -hours, -minutes );
    //for(i=0;i<32;i++)
	//{
	// if( retval == TIME_ZONE_ID_STANDARD ) tmpstr[i] = (char) tzinfo.StandardName[i];
	// else tmpstr[i] = (char) tzinfo.DaylightName[i];
	//}
    strcat( header, tmpstr );
    strcat( header, "\r\n" );
    sprintf( tmpstr, "From: %s\r\n", senderid );
    strcat( header, tmpstr );
    if( impersonating )
	{
     sprintf( tmpstr, "Sender: %s\r\n", loginname );
     strcat( header, tmpstr );
	if (!(penguin == 1))
	 {
     sprintf( tmpstr, "Reply-to: %s\r\n", loginname );
     strcat( header, tmpstr );
	 }
    }
	if( *subject )
	{
     sprintf( tmpstr, "Subject: %s\r\n", subject );
     strcat( header, tmpstr );
	}
	else
	{
	 if (!(penguin == 1))
	 {
      if (lstrcmp(filename, "-") == 0)
       sprintf( tmpstr, "Subject: Contents of console input\r\n", filename );
	  else
       sprintf( tmpstr, "Subject: Contents of file: %s\r\n", filename );
      strcat( header, tmpstr );
	 }
	}
	
    sprintf( tmpstr, "To: %s\r\n", destination );
    strcat( header, tmpstr );
	if( *cc_list )
	{
	 // Add line for the Carbon Copies
	 sprintf( tmpstr, "Cc: %s\r\n", cc_list );
     strcat( header, tmpstr );
	}
    strcat( header, "X-Mailer: <WinNT's Blat ver 1.4>\r\n" );
    
    if (!(penguin == 1))
    	strcat( header, "\r\n" );

	headerlen = strlen( header );

	// if reading from the console, read everything into a temporary file first
	if (lstrcmp(filename, "-") == 0)
	{
	 // create a unique temporary file name
	 GetTempPath( MAX_PATH, tempdir );
     GetTempFileName( tempdir, "blt", 0, tempfile );

	 // open the file in write mode
	 tf = fopen(tempfile,"w");
	 if( tf==NULL )
	 {
	  if( ! quiet ) cout<<"error opening temporary file "<<filename<<", aborting\n";		
      delete [] Recipients;
	  return 13;
	 }

	 do
	 {
	  i = getc( stdin );
	  putc( i, tf );
	 }
	 while( i != EOF );

	 fclose( tf );
	 filename = tempfile;
	}

	//get the text of the file into a string buffer
	if((fileh=CreateFile(filename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,
	                     FILE_FLAG_SEQUENTIAL_SCAN,NULL))==INVALID_HANDLE_VALUE)
	{
	 if( ! quiet ) cout<<"error reading "<<filename<<", aborting\n";		
     delete [] Recipients;
	 return 3;
	}
	if(GetFileType(fileh)!=FILE_TYPE_DISK)
	{
	 if( ! quiet ) cout<<"Sorry, I can only mail messages from disk files...\n";		
     	 delete [] Recipients;
	 return 4;
	}
	// ******** Sig file stuff
	//get the text of the sig file into a string buffer
	if((sigfileh=CreateFile(sigfilename,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,
	                     FILE_FLAG_SEQUENTIAL_SCAN,NULL))==INVALID_HANDLE_VALUE)
	{
	 if( ! quiet ) cout<<"error reading "<<sigfilename<<", aborting\n";		
     delete [] Recipients;
	 return 3;
	}
	if(GetFileType(sigfileh)!=FILE_TYPE_DISK)
	{
	 if( ! quiet ) cout<<"Sorry, I can only mail messages from disk files...\n";		
     delete [] Recipients;
	 return 4;
	}
	// *********

	DWORD filesize = GetFileSize( fileh,NULL );
	DWORD sigfilesize = GetFileSize(sigfileh,NULL );
	DWORD messagesize = strlen(message1) + strlen(message2) + strlen(message3) + strlen(message4) + strlen(message5);

	char *buffer = new char[filesize + sigfilesize + headerlen + messagesize + 5 + 1];
	char *tmpptr;

	// put the header at the top...
	strcpy( buffer, header );
	// point to the end of the header
	tmpptr = buffer + headerlen;

	// Now put first few messages here before file or input
	DWORD messlen = strlen(message1);
	if (messlen) {
		strcpy(tmpptr, message1);
		strcat(tmpptr, "\n");
		tmpptr = tmpptr + messlen + 1;
	}

	messlen = strlen(message2);
	if (messlen) {
		strcpy(tmpptr, message2);
		strcat(tmpptr, "\n");
		tmpptr = tmpptr + messlen + 1;
	}


	// and put the whole file here
	DWORD dummy;
	if(!ReadFile(fileh,tmpptr,filesize,&dummy,NULL))
	{
	 if( ! quiet ) cout<<"error reading "<<filename<<", aborting\n";
	 CloseHandle(fileh);
	 delete [] buffer;		
     	 delete [] Recipients;
	 return 5;
	}
	CloseHandle(fileh);

	// point to the end of the message body
	tmpptr = tmpptr + filesize - 2;

	messlen = strlen(message3);
	if (messlen) {
		strcpy(tmpptr, message3);
		strcat(tmpptr, "\n");
		tmpptr = tmpptr + messlen + 1;
	}

	messlen = strlen(message4);
	if (messlen) {
		strcpy(tmpptr, message4);
		strcat(tmpptr, "\n");
		tmpptr = tmpptr + messlen + 1;
	}

	messlen = strlen(message5);
	if (messlen) {
		strcpy(tmpptr, message5);
		strcat(tmpptr, "\n");
		tmpptr = tmpptr + messlen + 1;
	}


	// Now put sig file at the end
	if(!ReadFile(sigfileh,tmpptr,sigfilesize,&dummy,NULL))
	{
	 if( ! quiet ) cout<<"error reading "<<sigfilename<<", aborting\n";
	 CloseHandle(sigfileh);
	 delete [] buffer;		
     	 delete [] Recipients;
	 return 5;
	}
	CloseHandle(sigfileh);
	tmpptr = tmpptr + sigfilesize;
  *tmpptr = '\0';
    
	// delete the temporary file if it has been used
	if ( *tempfile ) remove( tempfile );
    	
	// make some noise about what we are doing
	if( ! quiet )
	{	
	 //cout<<"Sending "<<filename<<" to "<< (lstrlen(Recipients) ? Recipients : "<unspecified>")<<'\n';
	 //if(lstrlen(subject)) cout<<"Subject:"<<subject<<'\n';
	 //if(lstrlen(loginname)) cout<<"Login name is "<<loginname<<'\n';
	 // cout<<"Buffer:\n"<<buffer<<'\n';
	}

  // send the message to the SMTP server!
  if( !prepare_smtp_message( loginname, Recipients ) )
  {
   if( !send_smtp_edit_data( buffer ) )
    finish_smtp_message();
   close_smtp_socket();
  }

  delete [] buffer;
  delete [] Recipients;
  return 0;
}

