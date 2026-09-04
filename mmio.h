#ifndef __MMIO_H__
#define __MMIO_H__

#define APB4CLINT_BASE       0x02010000
#define APBUart16550_BASE    0x10000000
#define APBSPI_BASE          0x10001000
#define APB4RCU_BASE         0x10002000
#define APB4RTC_BASE         0x10004000
#define APB4WDG_BASE         0x10005000
#define APB4ArchInfo_BASE    0x10006000
#define APB4GPIO_BASE        0x10100000
#define APB4UART_BASE        0x10103000
#define APB4I2C_BASE         0x10104000
#define APB4PWM_BASE         0x10106000
#define APB4Timer_BASE       0x10108000
#define APB4Timer_1_BASE     0x10109000
#define APB4Timer_2_BASE     0x1010a000
#define APB4Timer_3_BASE     0x1010b000
#define APB4QSPI_BASE        0x10200000
#define APB4RNG_BASE         0x10300000
#define APB4CRC_BASE         0x10301000
#define APBPSRAM_BASE        0x80000000

#define APB4CLINT_LEN        0x10000
#define APBUart16550_LEN     0x8
#define APBSPI_LEN           0x20
#define APB4RCU_LEN          0x1000
#define APB4RTC_LEN          0x20
#define APB4WDG_LEN          0x20
#define APB4ArchInfo_LEN     0x10
#define APB4GPIO_LEN         0x40
#define APB4UART_LEN         0x20
#define APB4I2C_LEN          0x20
#define APB4PWM_LEN          0x40
#define APB4Timer_LEN        0x20
#define APB4Timer_1_LEN      0x20
#define APB4Timer_2_LEN      0x20
#define APB4Timer_3_LEN      0x20
#define APB4QSPI_LEN         0x20
#define APB4RNG_LEN          0x10
#define APB4CRC_LEN          0x20
#define APBPSRAM_LEN         0x400000

#endif