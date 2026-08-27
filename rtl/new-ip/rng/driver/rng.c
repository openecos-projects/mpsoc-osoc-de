#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define RNG_BASE_ADDR 0x10300000
#define RNG_REG_CTRL  *((volatile uint32_t *)(RNG_BASE_ADDR))
#define RNG_REG_SEED  *((volatile uint32_t *)(RNG_BASE_ADDR + 4))
#define RNG_REG_VAL   *((volatile uint32_t *)(RNG_BASE_ADDR + 8))

int main(){
    putstr("rng test\n");

    RNG_REG_CTRL = (uint32_t)1;      // en the core
    RNG_REG_SEED = (uint32_t)0xFE1C; // set the init seed
    for(int i = 0; i < 10; ++i) {
        printf("[normal]random val: %x\n", RNG_REG_VAL);
    }

    putstr("reset the seed\n");
    RNG_REG_SEED = (uint32_t)0;
    for(int i = 0; i < 3; ++i) {
        printf("[reset]zero val: %x\n", RNG_REG_VAL);
    }

    return 0;
}
