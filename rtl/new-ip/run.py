#!/bin/python

import os

ip_list = [
    'archinfo',
    'clint',
    'common',
    'crc',
    'gpio',
    'i2c',
    'i2s',
    'plic',
    'ps2',
    'psram',
    'pwm',
    'rcu',
    'rng',
    'rtc',
    'spi',
    'sram',
    'timer',
    'uart',
    'vga',
    'wdg',
]

for v in ip_list:
    # print(f'git clone https://github.com/oscc-ip/{v}.git')
    os.system(f'git clone git@github.com:oscc-ip/{v}.git')
