// ctype.h
//

#ifndef __CTYPE_H_
#define __CTYPE_H_

extern char _ctype[];

#define kCharType_Uppercase     0x01
#define kCharType_Lowercase     0x02
#define kCharType_IsDigit       0x04
#define kCharType_Control       0x08
#define kCharType_Punctuation   0x10
#define kCharType_Whitespace    0x20
#define kCharType_Hex           0x40
#define kCharType_Hardspace     0x80

#endif//__CTYPE_H_
