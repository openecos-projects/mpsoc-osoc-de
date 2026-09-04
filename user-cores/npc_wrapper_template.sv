`default_nettype none

// Replace the idle implementation with the user's simple-bus core.
module UserCoreTemplate (
  input  wire        clock,
  input  wire        reset,
  output wire [31:0] io_ifu_addr,
  output wire        io_ifu_reqValid,
  input  wire [31:0] io_ifu_rdata,
  input  wire        io_ifu_respValid,
  output wire [31:0] io_lsu_addr,
  output wire        io_lsu_reqValid,
  output wire [1:0]  io_lsu_size,
  input  wire        io_lsu_respValid,
  input  wire [31:0] io_lsu_rdata,
  output wire        io_lsu_wen,
  output wire [31:0] io_lsu_wdata,
  output wire [3:0]  io_lsu_wmask
);
  assign io_ifu_addr = 32'h0;
  assign io_ifu_reqValid = 1'b0;
  assign io_lsu_addr = 32'h0;
  assign io_lsu_reqValid = 1'b0;
  assign io_lsu_size = 2'h0;
  assign io_lsu_wen = 1'b0;
  assign io_lsu_wdata = 32'h0;
  assign io_lsu_wmask = 4'h0;
  wire unused = ^{clock, reset, io_ifu_rdata, io_ifu_respValid,
                  io_lsu_respValid, io_lsu_rdata};
endmodule

`default_nettype wire
