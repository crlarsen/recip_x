# Compute Reciprocal Using Newton's Method

## Description

SystemVerilog module to compute binary16/-32/-64/-128 reciprocals. Multiplying by the reciprocal can be used to avoid division. Avoiding division is a good thing because it's so slow. The module uses Newton's Method to find the reciprocal.

The code is explained in the video series [Building an FPU in Verilog](https://www.youtube.com/playlist?list=PLlO9sSrh8HrwcDHAtwec1ycV-m50nfUVs).
See the video *Building an FPU In Verilog: Floating Point Division, Part 5*.

## Manifest

|     Filename      |                        Description                           |
|-------------------|--------------------------------------------------------------|
| README.md         | This file.                                                   |
| fp_class.sv       | Utility module to identify the type of the IEEE 754 value passed in, and extract the exponent & significand fields for use by other modules. |
| ieee-754-flags.vh | Verilog header file to define constants for datum type (NaN, Infinity, Zero, Subnormal, and Normal), rounding attributes, and IEEE exceptions. |
| makeRecipLut      | Python script to generate X0.v. See the caveat described in the video. |
| padder11.v        | Prefix adder used by round module.                           |
| padder113.v       | Prefix adder used by round module.                           |
| padder24.v        | Prefix adder used by round module.                           |
| padder53.v        | Prefix adder used by round module.                           |
| PijGij.v          | Utility routines needed by the various prefix adder modules. |
| recipX0           | Sample solution to study question from previous video.       |
| recip_x.sv        | Top level module to compute reciprocal.                      |
| recip_x_tb.v      | Test bench for reciprocal module.                            |
| round.v           | Parameterized rounding module.                               |
| simulate.log      | Baseline test results for test bench.                        |
| X0.v              | Module to generate initial guess for Newton's Method.        |

## Copyright

:copyright: Chris Larsen, 2019-2022
