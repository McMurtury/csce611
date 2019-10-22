---
title: Register File Pre-Lab
author: "Copyright 2019 Charles Daniels, Jason Bakos"
disable-header-and-footer: false
header-center: "Due: Wednesday, Oct. 2 2019"
header-right: "CSCE611: Advanced Digital Design"
---

Review the lab sheet first, then respond to the problems below.

# Problem 1

Given this sequence of RPN operations, what is the expected result (all values
shown in decimal): `1 3 + 5 * 6 - 3 +`

* a. 3
* b. 10
* c. 11
* d. 14
* e. 15
* f. 17

# Problem 2

Given this sequence of RPN operations, what is the expected result (all values
shown in decimal): `6 7 4 8 + * 6 - +`

* a. 12
* b. 25
* c. 39
* d. 40
* e. 84
* f. 132

# Problem 3

Given this sequence of register accesses, what is the expected value (stored in
the register file's backing memory) of register 5 on the rising clock edge of
cycle 3. All values are given in decimal.

| cycle # | write enable | write address | write data |
|-|-|-|-|
| 0 | 0 | 5 | 37 |
| 1 | 1 | 4 | 28 |
| 2 | 1 | 5 | 54 |
| 3 | 1 | 5 | 32 |

* a. 28
* b. 32
* c. 37
* d. 54
* e. undefined
* f. 3

# Problem 4

Given this sequence of register accesses, what is the expected value of read
data 1 on the rising clock edge cycle 5 (assuming read address 1 is locked to
7). All values are given in decimal.

| cycle # | write enable | write address | write data |
|-|-|-|-|
| 0 | 0 | 6 | 32 |
| 1 | 1 | 5 | 17 |
| 2 | 0 | 7 | 53 |
| 3 | 1 | 4 | 24 |
| 4 | 1 | 7 | 35 |
| 5 | 1 | 7 | 77 |

* a. 32
* b. 17
* c. 53
* d. 24
* e. 35
* f. 77

# Problem 5

Given the following sequence of RPN operations, what value will be shown on the
hex displays on the rising clock edge of cycle 4? All values are given in
decimal. Assume the user is a super-humanly fast robot that presses one KEY per
clock cycle. Assume the first value is entered on cycle 0.

`24 5 2 - * 4 + 6 3 - +`

* a. 24
* b. 5
* c. 2
* d. 67
* e. 72
* f. 4
