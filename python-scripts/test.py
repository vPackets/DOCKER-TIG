#!/usr/bin/python3

import time
import requests
from random import randint


url_string = 'http://127.0.0.1:8086/write?db=uc'



while True:
    i = randint(0, 200)
    data_string = f'RTP_Connection,host=USA_cube01 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)

    i = randint(0, 200)
    data_string = f'RTP_Connection,host=USA_cube02 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)   

    i = randint(0, 200)
    data_string = f'RTP_Connection,host=UK_cube01 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)   

    i = randint(0, 200)
    data_string = f'RTP_Connection,host=UK_cube02 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)   

    i = randint(0, 200)
    data_string = f'RTP_Connection,host=HK_cube01 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)   

    i = randint(0, 200)
    data_string = f'RTP_Connection,host=HK_cube02 value={i}'
    r = requests.post(url_string, data=data_string)
    print("i = " , i)
    print(r)
    time.sleep(2)   

        