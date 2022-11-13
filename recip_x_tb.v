`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright: Chris Larsen, 2022
//
// Create Date: 11/07/2022 09:36:28 AM
// Design Name:
// Module Name: recip_x_tb
// Project Name:
// Target Devices:
// Tool Versions:
// Description: Testbench to verify that recip_x can successfully find the
//              reciprocal for binary16/-32 values.
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module recip_x_tb();
  localparam NEXP = 5;
  localparam NSIG = 10;
  `include "ieee-754-flags.vh"

  localparam hNEXP = 5;
  localparam hNSIG = 10;
  localparam hBIAS = ((1 << (hNEXP - 1)) - 1); // IEEE 754, section 3.3
  localparam hEMAX = hBIAS; // IEEE 754, section 3.3
  localparam hEMIN = (1 - hEMAX); // IEEE 754, section 3.3
  reg [hNEXP+hNSIG:0] dh;
  wire [hNEXP+hNSIG:0] rh;
  wire [NTYPES-1:0] rhFlags;
  wire [NEXCEPTIONS-1:0] exceptionH;

  localparam sNEXP = 8;
  localparam sNSIG = 23;
  localparam sBIAS = ((1 << (sNEXP - 1)) - 1); // IEEE 754, section 3.3
  localparam sEMAX = sBIAS; // IEEE 754, section 3.3
  localparam sEMIN = (1 - sEMAX); // IEEE 754, section 3.3
  reg [sNEXP+sNSIG:0] ds;
  wire [sNEXP+sNSIG:0] rs;
  wire [NTYPES-1:0] rsFlags;
  wire [NEXCEPTIONS-1:0] exceptionS;

  // roundTiesToEven roundTowardZero roundTowardPositive roundTowardNegative
  reg [NRAS-1:0] ra = 1 << roundTiesToEven;

  parameter X0WIDTH = 8;

  integer i;

  initial
  begin
    // Add tests for sNaN, qNaN, +Infinity, -Infinity, +Zero, -Zero

    dh = (((1 << hNEXP) - 1) << hNSIG) | (1 << (hNSIG-2)); // sNaN
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (((1 << hNEXP) - 1) << hNSIG) | (1 << (hNSIG-1)); // qNaN
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (((1 << hNEXP) - 1) << hNSIG); // +Infinity
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)) | (((1 << hNEXP) - 1) << hNSIG); // -Infinity
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 0; // +Zero
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)); // -Zero
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = ((2*hBIAS) << hNSIG) | ((1 << hNSIG) - 1); // Largest binary16 value
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    // Test subnormal values
    for (i = 0; i < hNSIG; i = i + 1)
      begin
        dh = 1 << i;
        #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);
      end

    dh = (hBIAS << hNSIG); // 3c00
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)) | (hBIAS << hNSIG); // bc00
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h0514; // 724d
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h4248; // Reciprocal of PI: 3518
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h5710; // 2088
    #100 $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    ds = (((1 << sNEXP) - 1) << sNSIG) | (1 << (sNSIG-2)); // sNaN
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (((1 << sNEXP) - 1) << sNSIG) | (1 << (sNSIG-1)); // qNaN
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (((1 << sNEXP) - 1) << sNSIG); // +Infinity
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)) | (((1 << sNEXP) - 1) << sNSIG); // -Infinity
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 0; // +Zero
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)); // -Zero
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = ((2*sBIAS) << sNSIG) | ((1 << sNSIG) - 1); // Largest binary16 value
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    // Test subnormal values
    for (i = 0; i < sNSIG; i = i + 1)
      begin
        ds = 1 << i;
        #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);
      end

    ds = (sBIAS << sNSIG); // 3c00
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)) | (sBIAS << sNSIG); // bc00
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

//    ds = 16'h0514; // 724d
//    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 32'h40490fdb; // Reciprocal of PI: 3ea2f983
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 32'h42e20000; // 3c10fdbc
    #100 $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);
  end

  recip_x #(hNEXP,hNSIG) U0(dh, ra, rh, rhFlags, exceptionH);
  recip_x #(sNEXP,sNSIG) U1(ds, ra, rs, rsFlags, exceptionS);
endmodule
