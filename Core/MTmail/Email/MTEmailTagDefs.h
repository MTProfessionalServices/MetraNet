#ifndef __MTEmailTagDefs_h_
#define __MTEmailTagDefs_h_

const char EMAIL_SMTP_SET_TAG[]				= "smtp_server";	//marks smtp server information
const char EMAIL_SMTP_SERVER_ADDRESS_TAG[]	= "address";		//tcp/ip address of the server
const char EMAIL_SMTP_SERVER_PORT_TAG[]		= "port";           //tcp/ip port of the server
const char EMAIL_SMTP_SERVER_TIMEOUT_TAG[]		= "timeout";    // communication timeout of the server in seconds

const char EMAIL_SET_TAG[]        = "template";         //marks email template
const char EMAIL_DEF_SET_TAG[]    = "default_headers";  //default headers for object to use
const char EMAIL_NAME[]           = "name";             //marks name of template
const char EMAIL_LANG[]           = "language";         //marks language of template

//Contained in the EMAIL_DEF_SET
const char EMAIL_TO_TAG[]         = "def_to";            //default recipient(s) of email
const char EMAIL_SUBJECT_TAG[]    = "def_subject";       //default message subject
const char EMAIL_FROM_TAG[]       = "def_from";          //default sender of the email
const char EMAIL_BODYFORMAT_TAG[] = "def_bodyformat";    //default body format, 0 or 1
const char EMAIL_MAILFORMAT_TAG[] = "def_mailformat";    //default mail format, 0 or 1
const char EMAIL_CC_TAG[]         = "def_cc";            //default carbon copy recipient(s)
const char EMAIL_BCC_TAG[]        = "def_bcc";           //default blind carbon copies
const char EMAIL_IMPORTANCE_TAG[] = "def_importance";    //default importance, 0, 1, 2
//End EMAIL_DEF_SET_TAGS


//define the message body used for search/replacement of values
const char EMAIL_MESSAGE_BODY_TAG[] = "message_body";    //defines the message body

#endif