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
//              reciprocal for binary16/-32/-64/-128 values.
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

  localparam dNEXP = 11;
  localparam dNSIG = 52;
  localparam dBIAS = ((1 << (dNEXP - 1)) - 1); // IEEE 754, section 3.3
  localparam dEMAX = dBIAS; // IEEE 754, section 3.3
  localparam dEMIN = (1 - dEMAX); // IEEE 754, section 3.3
  reg [dNEXP+dNSIG:0] dd;
  wire [dNEXP+dNSIG:0] rd;
  wire [NTYPES-1:0] rdFlags;
  wire [NEXCEPTIONS-1:0] exceptionD;

  localparam qNEXP = 15;
  localparam qNSIG = 112;
  localparam qBIAS = ((1 << (qNEXP - 1)) - 1); // IEEE 754, section 3.3
  localparam qEMAX = qBIAS; // IEEE 754, section 3.3
  localparam qEMIN = (1 - qEMAX); // IEEE 754, section 3.3
  reg [qNEXP+qNSIG:0] dq;
  wire [qNEXP+qNSIG:0] rq;
  wire [NTYPES-1:0] rqFlags;
  wire [NEXCEPTIONS-1:0] exceptionQ;

  // roundTiesToEven roundTowardZero roundTowardPositive roundTowardNegative
  reg [NRAS-1:0] ra = 1 << roundTiesToEven;

  parameter X0WIDTH = 8;

  integer i;

  reg clk=1, startH=0, startS=0, startD=0, startQ=0, dlH, dlS, dlD, dlQ;
  initial
  begin
    forever
      #10 clk = ~clk;
  end

  always @(negedge clk) // Assert start signal on falling edge of clock for 1 cycle
  begin
    if (~startH && dlH)
      startH = 1;
    else if (startH)
      startH = 0;
    if (~startS && dlS)
      startS = 1;
    else if (startS)
      startS = 0;
    if (~startD && dlD)
      startD = 1;
    else if (startD)
      startD = 0;
    if (~startQ && dlQ)
      startQ = 1;
    else if (startQ)
      startQ = 0;
  end
  wire doneH, doneS, doneD, doneQ;

  initial
  begin
    // Add tests for sNaN, qNaN, +Infinity, -Infinity, +Zero, -Zero

    dh = (((1 << hNEXP) - 1) << hNSIG) | (1 << (hNSIG-2)); // sNaN
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (((1 << hNEXP) - 1) << hNSIG) | (1 << (hNSIG-1)); // qNaN
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (((1 << hNEXP) - 1) << hNSIG); // +Infinity
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)) | (((1 << hNEXP) - 1) << hNSIG); // -Infinity
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 0; // +Zero
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)); // -Zero
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = ((2*hBIAS) << hNSIG) | ((1 << hNSIG) - 1); // Largest binary16 value
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    // Test subnormal values
    for (i = 0; i < hNSIG; i = i + 1)
      begin
        dh = 1 << i;
        dlH = 1;
        wait(startH)
          dlH = 0;
        wait(doneH&clk)
          $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);
      end

    dh = (hBIAS << hNSIG); // 3c00
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = (1 << (hNEXP+hNSIG)) | (hBIAS << hNSIG); // bc00
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h0514; // 724d
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h4248; // Reciprocal of PI: 3518
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    dh = 16'h5710; // 2088
    dlH = 1;
    wait(startH)
      dlH = 0;
    wait(doneH&clk)
      $display("%x %b %x %b %b", dh, ra, rh, rhFlags, exceptionH);

    ds = (((1 << sNEXP) - 1) << sNSIG) | (1 << (sNSIG-2)); // sNaN
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (((1 << sNEXP) - 1) << sNSIG) | (1 << (sNSIG-1)); // qNaN
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (((1 << sNEXP) - 1) << sNSIG); // +Infinity
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)) | (((1 << sNEXP) - 1) << sNSIG); // -Infinity
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 0; // +Zero
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)); // -Zero
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = ((2*sBIAS) << sNSIG) | ((1 << sNSIG) - 1); // Largest binary32 value
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    // Test subnormal values
    for (i = 0; i < sNSIG; i = i + 1)
      begin
        ds = 1 << i;
        dlS = 1;
        wait(startS)
          dlS = 0;
        wait(doneS&clk)
          $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);
      end

    ds = (sBIAS << sNSIG); // 3c00
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = (1 << (sNEXP+sNSIG)) | (sBIAS << sNSIG); // bc00
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

//    ds = 16'h0514; // 724d
//    dlS = 1;
//    wait(startS)
//      dlS = 0;
//    wait(doneS&clk)
//      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 32'h40490fdb; // Reciprocal of PI: 3ea2f983
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    ds = 32'h42e20000; // 3c10fdbc
    dlS = 1;
    wait(startS)
      dlS = 0;
    wait(doneS&clk)
      $display("%x %b %x %b %b", ds, ra, rs, rsFlags, exceptionS);

    dd = (((1 << dNEXP) - 1) << dNSIG) | (1 << (dNSIG-2)); // sNaN
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = (((1 << dNEXP) - 1) << dNSIG) | (1 << (dNSIG-1)); // qNaN
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = (((1 << dNEXP) - 1) << dNSIG); // +Infinity
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = (1 << (dNEXP+dNSIG)) | (((1 << dNEXP) - 1) << dNSIG); // -Infinity
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = 0; // +Zero
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = (1 << (dNEXP+dNSIG)); // -Zero
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = ((2*dBIAS) << dNSIG) | ((1 << dNSIG) - 1); // Largest binary16 value
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    // Test subnormal values
    for (i = 0; i < dNSIG; i = i + 1)
      begin
        dd = 1 << i;
        dlD = 1;
        wait(startD)
          dlD = 0;
        wait(doneD&clk)
          $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);
      end

    dd = (dBIAS << dNSIG); // 3ff0000000000000
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = (1 << (dNEXP+dNSIG)) | (dBIAS << dNSIG); // bff0000000000000
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

//    dd = 16'h0514; // 724d
//    dlD = 1;
//    wait(startD)
//      dlD = 0;
//    wait(doneD&clk)
//      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = 64'h400921fb54442d18; // Reciprocal of PI: 3fd45f306dc9c883
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dd = 64'h405c400000000000; // 3f821fb78121fb78
    dlD = 1;
    wait(startD)
      dlD = 0;
    wait(doneD&clk)
      $display("%x %b %x %b %b", dd, ra, rd, rdFlags, exceptionD);

    dq = (((1 << qNEXP) - 1) << qNSIG) | (1 << (qNSIG-2)); // sNaN
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = (((1 << qNEXP) - 1) << qNSIG) | (1 << (qNSIG-1)); // qNaN
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = (((1 << qNEXP) - 1) << qNSIG); // +Infinity
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = (1 << (qNEXP+qNSIG)) | (((1 << qNEXP) - 1) << qNSIG); // -Infinity
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = 0; // +Zero
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = (1 << (qNEXP+qNSIG)); // -Zero
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = ((2*qBIAS) << qNSIG) | ((1 << qNSIG) - 1); // Largest binary16 value
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    // Test subnormal values
    for (i = 0; i < qNSIG; i = i + 1)
      begin
        dq = 1 << i;
        dlQ = 1;
        wait(startQ)
          dlQ = 0;
        wait(doneQ&clk)
          $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);
      end

    dq = (qBIAS << qNSIG); // 3fff0000000000000000000000000000
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = (1 << (qNEXP+qNSIG)) | (qBIAS << qNSIG); // bfff0000000000000000000000000000
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

//    dq = 16'h0514; // 724d
//    #100 $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = 128'h4000921fb54442d18469898cc51701b8; // Reciprocal of PI: 3ffd45f306dc9c882a53f84eafa3ea6a
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    dq = 128'h4005c400000000000000000000000000; // 3ff821fb78121fb78121fb78121fb781
    dlQ = 1;
    wait(startQ)
      dlQ = 0;
    wait(doneQ&clk)
      $display("%x %b %x %b %b", dq, ra, rq, rqFlags, exceptionQ);

    #100 $display("\nEnd of tests : %t", $time);
    $stop;
  end

  recip_x #(hNEXP,hNSIG) U0(clk, startH, dh, ra, rh, rhFlags, exceptionH, doneH);
  recip_x #(sNEXP,sNSIG) U1(clk, startS, ds, ra, rs, rsFlags, exceptionS, doneS);
  recip_x #(dNEXP,dNSIG) U2(clk, startD, dd, ra, rd, rdFlags, exceptionD, doneD);
  recip_x #(qNEXP,qNSIG) U3(clk, startQ, dq, ra, rq, rqFlags, exceptionQ, doneQ);
endmodule
