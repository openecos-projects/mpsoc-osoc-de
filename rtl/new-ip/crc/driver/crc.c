#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#ifdef FPGA_ENV
#define CRC_BASE_ADDR 0x10005000
#else
#define CRC_BASE_ADDR 0x10301000
#endif

#define CRC_REG_CTRL  *((volatile uint32_t *)(CRC_BASE_ADDR))
#define CRC_REG_INIT  *((volatile uint32_t *)(CRC_BASE_ADDR + 4))
#define CRC_REG_XORV  *((volatile uint32_t *)(CRC_BASE_ADDR + 8))
#define CRC_REG_DATA  *((volatile uint32_t *)(CRC_BASE_ADDR + 12))
#define CRC_REG_STAT  *((volatile uint32_t *)(CRC_BASE_ADDR + 16))

int main(){
    putstr("crc test\n");

    CRC_REG_CTRL = (uint32_t)0;
    CRC_REG_INIT = (uint32_t)0xFFFF;
    CRC_REG_XORV = (uint32_t)0;
    CRC_REG_CTRL = (uint32_t)0b1001001;

    uint32_t val = 0x123456;
    for(int i = 0; i < 50; ++i) {
        CRC_REG_DATA = val + i;
        while(CRC_REG_STAT == (uint32_t)0);
        printf("i: %d CRC: %x\n", i, CRC_REG_DATA);
    }
    putstr("crc done\n");

    return 0;
}
