// Simulation-only SPI register model. It preserves the register handshakes
// used by APBSPI while replacing pin-level flash shifting with the flash DPI.
module spi_top_apb #(
  parameter flash_addr_start = 32'h30000000,
  parameter flash_addr_end   = 32'h3fffffff,
  parameter spi_ss_num       = 8
) (
  input                         clock,
  input                         reset,
  input  [31:0]                 in_paddr,
  input                         in_psel,
  input                         in_penable,
  input  [2:0]                  in_pprot,
  input                         in_pwrite,
  input  [31:0]                 in_pwdata,
  input  [3:0]                  in_pstrb,
  output                        in_pready,
  output [31:0]                 in_prdata,
  output                        in_pslverr,
  output                        spi_sck,
  output [spi_ss_num-1:0]       spi_ss,
  output                        spi_mosi,
  input                         spi_miso,
  output                        spi_irq_out
);

  wire [31:0] data;
  reg  [31:0] fast_addr;
  reg         read_ready;
  wire        write_access = in_psel && in_penable && in_pwrite;
  wire        read_access = in_psel && in_penable && !in_pwrite && !read_ready;

  always @(posedge clock or posedge reset) begin
    if (reset) begin
      fast_addr <= 32'h0;
      read_ready <= 1'b0;
    end else begin
      read_ready <= read_access;
      if (write_access && in_pwdata[31:24] == 8'h03)
        fast_addr <= {8'h0, in_pwdata[23:0]};
    end
  end

  flash_cmd flash_cmd_i (
    .clock (clock),
    .valid (read_access),
    .cmd   (8'h03),
    .addr  (fast_addr),
    .data  (data)
  );

  assign spi_sck = 1'b0;
  assign spi_ss = {spi_ss_num{1'b0}};
  assign spi_mosi = 1'b1;
  assign spi_irq_out = 1'b1;
  assign in_pslverr = 1'b0;
  assign in_pready = write_access || read_ready;
  assign in_prdata = {data[7:0], data[15:8], data[23:16], data[31:24]};

  wire unused = &{1'b0, flash_addr_start, flash_addr_end, in_paddr, in_pprot,
                  in_pstrb, spi_miso};
endmodule
