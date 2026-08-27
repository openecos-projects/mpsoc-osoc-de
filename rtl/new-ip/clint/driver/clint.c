#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define CLINT_BASE_ADDR     0x02010000
#define CLINT_REG_MSIP      *((volatile uint32_t *)(CLINT_BASE_ADDR))
#define CLINT_REG_MTIMECMPL *((volatile uint32_t *)(CLINT_BASE_ADDR + 0x4000))
#define CLINT_REG_MTIMECMPH *((volatile uint32_t *)(CLINT_BASE_ADDR + 0x4004))
#define CLINT_REG_MTIMEL    *((volatile uint32_t *)(CLINT_BASE_ADDR + 0xbff8))
#define CLINT_REG_MTIMEH    *((volatile uint32_t *)(CLINT_BASE_ADDR + 0xbffc))

int main(){
    uint64_t mtime = 0;
    putstr("clint test\n");
    for(int i = 0; i < 6; i++) {
        mtime = (((uint64_t) CLINT_REG_MTIMEH) << 32) | CLINT_REG_MTIMEL;
        printf("i: %d, mtime: %llx\n", i, mtime);
    }

    mtime += 0x20000;
    CLINT_REG_MTIMECMPH = (mtime >> 32) & 0xffffffffu;
    CLINT_REG_MTIMECMPL = mtime & 0xffffffffu;
    printf("mtimecmp: %llx\n", (((uint64_t) CLINT_REG_MTIMECMPH) << 32) | CLINT_REG_MTIMECMPL);

    for(int i = 0; i < 6; i++) {
        while(1) {
            uint64_t mtime = (((uint64_t) CLINT_REG_MTIMEH) << 32) | CLINT_REG_MTIMEL;
            uint64_t mtimecmp = (((uint64_t) CLINT_REG_MTIMECMPH) << 32) | CLINT_REG_MTIMECMPL;
            if(mtime >= mtimecmp) break;
        }
        CLINT_REG_MTIMECMPL += (uint32_t) 0x10000;
        putstr("time overflow trigger\n");
    }
    putstr("test done\n");

    return 0;
}
