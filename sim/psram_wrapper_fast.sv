// Simulation-only APB memory model based on the related SoC's FAST_PSRAM
// implementation. Bus-visible addressing and byte strobes match the original
// PSRAMWrapper; only pin-level QPI transfers are skipped.
module PSRAMWrapper(
  input         clock,
                reset,
                io_in_psel,
                io_in_penable,
                io_in_pwrite,
  input  [31:0] io_in_paddr,
                io_in_pwdata,
  input  [3:0]  io_in_pstrb,
  output        io_in_pready,
  output [31:0] io_in_prdata,
  output        io_qspi_sck_o,
  output [2:0]  io_qspi_nss_o,
  output [3:0]  io_qspi_io_oe_o,
  input  [3:0]  io_qspi_io_di_i,
  output [3:0]  io_qspi_io_do_o
);

  localparam integer MEM_BYTES = 4 * 1024 * 1024;
  reg [7:0] mem [0:MEM_BYTES-1];
  reg [21:0] byte_addr_reg;
  reg [31:0] wdata_reg;
  reg [3:0] wstrb_reg;
  reg write_reg;
  reg active;
  wire setup = io_in_psel & ~io_in_penable;
  wire addr_in_range = byte_addr_reg <= 22'h3ffffc;

  integer index;
  initial begin
    for (index = 0; index < MEM_BYTES; index = index + 1)
      mem[index] = 8'h00;
  end

  always @(posedge clock) begin
    if (setup) begin
      byte_addr_reg <= {io_in_paddr[21:2], 2'h0};
      wdata_reg <= io_in_pwdata;
      wstrb_reg <= io_in_pwrite ? io_in_pstrb : 4'h0;
      write_reg <= io_in_pwrite;
    end
    if (reset)
      active <= 1'h0;
    else
      active <= setup;
    if (active & write_reg & addr_in_range) begin
      if (wstrb_reg[0]) mem[byte_addr_reg] <= wdata_reg[7:0];
      if (wstrb_reg[1]) mem[byte_addr_reg + 22'd1] <= wdata_reg[15:8];
      if (wstrb_reg[2]) mem[byte_addr_reg + 22'd2] <= wdata_reg[23:16];
      if (wstrb_reg[3]) mem[byte_addr_reg + 22'd3] <= wdata_reg[31:24];
    end
  end

  assign io_in_pready = 1'h1;
  assign io_in_prdata = addr_in_range
    ? {mem[byte_addr_reg + 22'd3], mem[byte_addr_reg + 22'd2],
       mem[byte_addr_reg + 22'd1], mem[byte_addr_reg]}
    : 32'h0;
  assign io_qspi_sck_o = 1'h0;
  assign io_qspi_nss_o = 3'h7;
  assign io_qspi_io_oe_o = 4'h0;
  assign io_qspi_io_do_o = 4'h0;

  wire unused = &{1'b0, io_qspi_io_di_i};
endmodule
