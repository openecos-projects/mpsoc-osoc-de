#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define ARCHINFO_BASE_ADDR 0x10006000
#define ARCHINFO_REG_SYS   *((volatile uint32_t *)(ARCHINFO_BASE_ADDR))
#define ARCHINFO_REG_IDL   *((volatile uint32_t *)(ARCHINFO_BASE_ADDR + 4))
#define ARCHINFO_REG_IDH   *((volatile uint32_t *)(ARCHINFO_BASE_ADDR + 8))

int main(){
    putstr("archinfo test\n");
    printf("SYS: %x IDL: %x IDH: %x\n", ARCHINFO_REG_SYS, ARCHINFO_REG_IDL, ARCHINFO_REG_IDH);
    putstr("write regs\n");
    ARCHINFO_REG_SYS = (uint32_t)0x4004;
    ARCHINFO_REG_IDL = (uint32_t)0x5F3E;
    ARCHINFO_REG_IDH = (uint32_t)0x6E2;
    printf("SYS: %x IDL: %x IDH: %x\n", ARCHINFO_REG_SYS, ARCHINFO_REG_IDL, ARCHINFO_REG_IDH);
    putstr("test done\n");

    return 0;
}
