#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define PS2_BASE_ADDR 0x10105000
#define PS2_REG_CTRL  *((volatile uint32_t *)(PS2_BASE_ADDR))
#define PS2_REG_DATA  *((volatile uint32_t *)(PS2_BASE_ADDR + 4))
#define PS2_REG_STAT  *((volatile uint32_t *)(PS2_BASE_ADDR + 8))

int main(){
    putstr("ps2 test\n");

    PS2_REG_CTRL = (uint32_t)0b11;
    uint32_t kdb_code, i = 0;
    while(1) {
        kdb_code = PS2_REG_DATA;
        if(kdb_code != 0) {
            printf("[%d] dat: %x\n", i++, kdb_code);
        }
    }
    return 0;
}
