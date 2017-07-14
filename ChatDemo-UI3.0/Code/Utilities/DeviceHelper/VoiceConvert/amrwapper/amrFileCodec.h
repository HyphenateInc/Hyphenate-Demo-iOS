/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#ifndef amrFileCodec_h
#define amrFileCodec_h
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "interf_dec.h"
#include "interf_enc.h"

#define AMR_MAGIC_NUMBER "#!AMR\n"
#define MP3_MAGIC_NUMBER "ID3"

#define PCM_FRAME_SIZE 160 // 8khz 8000*0.02=160
#define MAX_AMR_FRAME_SIZE 32
#define AMR_FRAME_COUNT_PER_SECOND 50

typedef struct
{
	char chChunkID[4];
	int nChunkSize;
}EM_XCHUNKHEADER;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
}EM_WAVEFORMAT;

typedef struct
{
	short nFormatTag;
	short nChannels;
	int nSamplesPerSec;
	int nAvgBytesPerSec;
	short nBlockAlign;
	short nBitsPerSample;
	short nExSize;
}EM_WAVEFORMATX;

typedef struct
{
	char chRiffID[4];
	int nRiffSize;
	char chRiffFormat[4];
}EM_RIFFHEADER;

typedef struct
{
	char chFmtID[4];
	int nFmtSize;
	EM_WAVEFORMAT wf;
}EM_FMTBLOCK;

int EM_EncodeWAVEFileToAMRFile(const char* pchWAVEFilename, const char* pchAMRFileName, int nChannels, int nBitsPerSample);

int EM_DecodeAMRFileToWAVEFile(const char* pchAMRFileName, const char* pchWAVEFilename);

int isMP3File(const char *filePath);

int isAMRFile(const char *filePath);
#endif
