#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define PWM_BASE_ADDR   0x10106000
#define PWM_REG_CTRL    *((volatile uint32_t *)(PWM_BASE_ADDR))
#define PWM_REG_PSCR    *((volatile uint32_t *)(PWM_BASE_ADDR + 4))
#define PWM_REG_CNT     *((volatile uint32_t *)(PWM_BASE_ADDR + 8))
#define PWM_REG_CMP     *((volatile uint32_t *)(PWM_BASE_ADDR + 12))
#define PWM_REG_CR0     *((volatile uint32_t *)(PWM_BASE_ADDR + 16))
#define PWM_REG_CR1     *((volatile uint32_t *)(PWM_BASE_ADDR + 20))
#define PWM_REG_CR2     *((volatile uint32_t *)(PWM_BASE_ADDR + 24))
#define PWM_REG_CR3     *((volatile uint32_t *)(PWM_BASE_ADDR + 28))
#define PWM_REG_STAT    *((volatile uint32_t *)(PWM_BASE_ADDR + 32))

#define TIMER_BASE_ADDR 0x10108000
#define TIMER_REG_CTRL  *((volatile uint32_t *)(TIMER_BASE_ADDR + 0))
#define TIMER_REG_PSCR  *((volatile uint32_t *)(TIMER_BASE_ADDR + 4))
#define TIMER_REG_CNT   *((volatile uint32_t *)(TIMER_BASE_ADDR + 8))
#define TIMER_REG_CMP   *((volatile uint32_t *)(TIMER_BASE_ADDR + 12))
#define TIMER_REG_STAT  *((volatile uint32_t *)(TIMER_BASE_ADDR + 16))

void pwm_init() {
    PWM_REG_CTRL = (uint32_t)0;
    PWM_REG_PSCR = (uint32_t)(50 - 1);    // 50M / 50 = 1MHz
    PWM_REG_CMP  = (uint32_t)(1000 - 1);  // 1KHz
    printf("PWM_REG_CTRL: %d PWM_REG_PSCR: %d PWM_REG_CMP: %d\n", PWM_REG_CTRL, PWM_REG_PSCR, PWM_REG_CMP);
}

void timer_init() {
    TIMER_REG_CTRL = (uint32_t)0x0;
    while(TIMER_REG_STAT == 1);           // clear irq
    TIMER_REG_CMP  = (uint32_t)(50000-1); // 50MHz for 1ms
}

void delay_ms(uint32_t val) {
    TIMER_REG_CTRL = (uint32_t)0xD;
    for(int i = 1; i <= val; ++i) {
        while(TIMER_REG_STAT == 0);
    }
    TIMER_REG_CTRL = (uint32_t)0x0;
}

void simple_delay(int delay) {
    volatile int dummy = delay;
    while(dummy--);
}

int main(){
    putstr("pwm test\n");

    pwm_init();
    timer_init();

    while(1) {
        for(int i = 10; i <= 990; i++) {
            PWM_REG_CTRL = (uint32_t)4;
            PWM_REG_CR0 = i;
            PWM_REG_CTRL = (uint32_t)3;
            PWM_REG_PSCR = 49;
            delay_ms(5);
        }

        for(int i = 990; i >= 10; i--) {
            PWM_REG_CTRL = (uint32_t)4;
            PWM_REG_CR0 = i;
            PWM_REG_CTRL = (uint32_t)3;
            PWM_REG_PSCR = 49;
            delay_ms(5);
        }
    }
    return 0;
}
