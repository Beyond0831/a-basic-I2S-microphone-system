/** 22T3 COMP3601 Design Project A
 * File name: main.c
 * Description: Example main file for using the audio_i2s driver for your Zynq audio driver.
 *
 * Distributed under the MIT license.
 * Copyright (c) 2022 Elton Shih
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <stdio.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>

#include "audio_i2s.h"

#define FILE_SIZE_OFFSET 4
#define FILE_DATA_SIZE_OFFSET 40
#define FORMAT_PCM 1
#define NUM_CHANNELS 2
#define SAMPLE_RATE 48000
#define SAMPLE_SIZE 16
#define BYTE_RATE ((SAMPLE_RATE * SAMPLE_SIZE * NUM_CHANNELS) / 8)
#define BLOCK_ALIGN ((SAMPLE_SIZE * NUM_CHANNELS) / 8)

#define DURATION 10 // duration in seconds
#define TRANSFER_RUNS ((SAMPLE_RATE * DURATION * NUM_CHANNELS) / TRANSFER_LEN)

/////////////////////////////////////////////////////////
typedef struct wavfile_header_s
{
    char    ChunkID[4];     /*  4   */
    int32_t ChunkSize;      /*  4   */
    char    Format[4];      /*  4   */
    
    char    Subchunk1ID[4]; /*  4   */
    int32_t Subchunk1Size;  /*  4   */
    int16_t AudioFormat;    /*  2   */
    int16_t NumChannels;    /*  2   */
    int32_t SampleRate;     /*  4   */
    int32_t ByteRate;       /*  4   */
    int16_t BlockAlign;     /*  2   */
    int16_t BitsPerSample;  /*  2   */
    
    char    Subchunk2ID[4];
    int32_t Subchunk2Size;
} wavfile_header_t;


void finish_stereo_header(char *pathname);

/*Return 0 on success and -1 on failure*/
int write_PCM16_stereo_header(FILE *file_p)
{
    wavfile_header_t wav_header;
    wav_header.ChunkID[0] = 'R';
    wav_header.ChunkID[1] = 'I';
    wav_header.ChunkID[2] = 'F';
    wav_header.ChunkID[3] = 'F';
    
    wav_header.ChunkSize = 0;
    
    wav_header.Format[0] = 'W';
    wav_header.Format[1] = 'A';
    wav_header.Format[2] = 'V';
    wav_header.Format[3] = 'E';
    
    wav_header.Subchunk1ID[0] = 'f';
    wav_header.Subchunk1ID[1] = 'm';
    wav_header.Subchunk1ID[2] = 't';
    wav_header.Subchunk1ID[3] = ' ';
    
    wav_header.Subchunk1Size = 16;
    wav_header.AudioFormat = FORMAT_PCM;
    wav_header.NumChannels = NUM_CHANNELS;
    wav_header.SampleRate = SAMPLE_RATE;
    wav_header.ByteRate = BYTE_RATE;
    wav_header.BlockAlign = BLOCK_ALIGN;
    wav_header.BitsPerSample = SAMPLE_SIZE;
    
    wav_header.Subchunk2ID[0] = 'd';
    wav_header.Subchunk2ID[1] = 'a';
    wav_header.Subchunk2ID[2] = 't';
    wav_header.Subchunk2ID[3] = 'a';
    wav_header.Subchunk2Size = 0;
    
    int write_count = fwrite(   &wav_header, 
                            sizeof(wavfile_header_t), 1,
                            file_p);
                    
    return (1 != write_count)? -1 : 0;
}

// /*Data structure to hold a single frame with two channels*/
// typedef struct PCM16_stereo_s
// {
//     int32_t left;
//     int32_t right;
// } PCM16_stereo_t;

// PCM16_stereo_t *allocate_PCM16_stereo_buffer(int32_t FrameCount)
// {
//     return (PCM16_stereo_t *)malloc(sizeof(PCM16_stereo_t) * FrameCount);
// }


/*Generate two saw-tooth signals at two frequencies and amplitudes*/
// int generate_dual_sawtooth( double frequency1,
//                             double amplitude1,
//                             //double frequency2,
//                             //double amplitude2,
//                             int32_t SampleRate,
//                             int32_t FrameCount,
//                             PCM16_stereo_t  *buffer_p,
//                             uint32_t **frame)
// {
//     int ret = 0;
//     double SampleRate_d = (double)SampleRate;
//     double SamplePeriod = 1.0 / SampleRate_d;
    
//     double Period1;
//     double phase1;
//     double Slope1;
    
//     int32_t k;
    
//     /*Check for the violation of the Nyquist limit*/
//     if( (frequency1*2 >= SampleRate_d) )
//     {
//         ret = -1;
//         goto error0;
//     }
    
//     /*Compute the period*/
//     Period1 = 1.0 / frequency1;
//     //Period2 = 1.0 / frequency2;
    
//     /*Compute the slope*/
//     Slope1  = amplitude1 / Period1;
//     //Slope2  = amplitude2 / Period2;
    
//     for(k = 0, phase1 = 0.0; 
//         k < FrameCount; 
//         k++)
//     {
//         phase1 += SamplePeriod;
//         phase1 = (phase1 > Period1)? (phase1 - Period1) : phase1;
        
//         //phase2 += SamplePeriod;
//         //phase2 = (phase2 > Period2)? (phase2 - Period2) : phase2;
        
//         buffer_p[k].left    = (int16_t)(phase1 * Slope1);//use values from main.c
//         //buffer_p[k].right   = (int16_t)(phase2 * Slope2);
//         int32_t sample_value = *frame[k] & ((1 << 18) - 1);
//         buffer_p[k].right   =  sample_value;
//         //printf("%04X [%d]\n", buffer_p[k].left, k);
//     }
    
// error0:
//     return ret;
// }
////////////////////////////////////////////////////////


int main() {
    printf("Entered main\n");

    uint32_t *frames[TRANSFER_RUNS];
    for (int i = 0; i < TRANSFER_RUNS; i++) {
        frames[i] = (uint32_t*)malloc(TRANSFER_LEN*sizeof(uint32_t));
    }

    audio_i2s_t my_config;
    if (audio_i2s_init(&my_config) < 0) {
        printf("Error initializing audio_i2s\n");
        return -1;
    }

    printf("mmapped address: %p\n", my_config.v_baseaddr);
    printf("Before writing to CR: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_CR));
    audio_i2s_set_reg(&my_config, AUDIO_I2S_CR, 0x1);
    printf("After writing to CR: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_CR));
    printf("SR: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_SR));
    printf("Key: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_KEY));
    printf("Before writing to gain: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_GAIN));
    audio_i2s_set_reg(&my_config, AUDIO_I2S_GAIN, 0x1);
    printf("After writing to gain: %08x\n", audio_i2s_get_reg(&my_config, AUDIO_I2S_GAIN));

    printf("Initialized audio_i2s\n");
    printf("Starting audio_i2s_recv\n");

    for (int i = 0; i < TRANSFER_RUNS; i++) {
        if (i % 16 == 0) {
            printf("frame [%d]\n", i);
        }
        int32_t *samples = audio_i2s_recv(&my_config);
        memcpy(frames[i], samples, TRANSFER_LEN*sizeof(uint32_t));
        // fwrite(samples,sizeof(uint32_t),TRANSFER_LEN,file_test);
        // parsemem(frames[i], TRANSFER_LEN, file_test);

    }
    printf("Finished %d transfer runs\n", TRANSFER_RUNS);
    
    FILE *file_p = fopen("./V1testwav.wav", "wb");
    if(NULL == file_p)
    {
        perror("fopen failed in main");
        return -1;
    }

    write_PCM16_stereo_header(file_p);

    for (int run = 0; run < TRANSFER_RUNS; run++) {
        for (int i = 0; i < TRANSFER_LEN; i += 2) {
            uint32_t data1 = frames[run][i];
            int16_t d1 = (int16_t)data1 >> 2;
            uint32_t data2 = frames[run][i + 1];
            int16_t d2 = (int16_t)data2 >> 2;
            if (data1 & (1 << 31)) {
                // write left first
                fwrite(&d1, sizeof(int16_t), 1, file_p);
                fwrite(&d2, sizeof(int16_t), 1, file_p);
            } else {
                // write right first
                fwrite(&d2, sizeof(int16_t), 1, file_p);
                fwrite(&d1, sizeof(int16_t), 1, file_p);
            }
        }
    }
    
    audio_i2s_release(&my_config);
    fclose(file_p);

    finish_stereo_header("./V1testwav.wav");

    for (int i = 0; i < TRANSFER_RUNS; i++) {
        free(frames[i]);
    }

    return 0; 
}


void finish_stereo_header(char *pathname) {
    struct stat statbuf;
    lstat(pathname, &statbuf);
    off_t size = statbuf.st_size;
    uint32_t usize = (uint32_t) size;
    int fd = open(pathname, O_RDWR);
    if (fd == -1) {
        printf("Could not open file to finish header\n");
        return;
    }

    uint32_t datasize = size - 40;
    lseek(fd, FILE_SIZE_OFFSET, SEEK_SET);
    write(fd, &usize, 4);

    lseek(fd, FILE_DATA_SIZE_OFFSET, SEEK_SET);
    write(fd, &datasize, 4);

    close(fd);
}