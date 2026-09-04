module SimMem(
  input         clock,
  input  [31:0] imem_addr,
  input         imem_reqValid,
  output reg [31:0] imem_rdata,
  output reg        imem_respValid,

  input  [31:0] dmem_addr,
  input         dmem_reqValid,
  input  [1:0]  dmem_size,
  input  [31:0] dmem_wdata,
  input  [ 3:0] dmem_wmask,
  input         dmem_wen,
  output reg    dmem_respValid,
  output reg [31:0] dmem_rdata
);
`ifdef __ICARUS__
`define PMEM_READ  $pmem_read
`define PMEM_WRITE $pmem_write
`else
`define PMEM_READ  pmem_read
`define PMEM_WRITE pmem_write
import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(input int waddr, input int wdata, input byte wmask);
`endif
always @(posedge clock) begin
  imem_rdata <= imem_reqValid ? `PMEM_READ(imem_addr) : 32'b0;
  dmem_rdata <= (dmem_reqValid && !dmem_wen) ? `PMEM_READ(dmem_addr) : 32'b0;
  if (dmem_reqValid && dmem_wen) begin
    `PMEM_WRITE(dmem_addr, dmem_wdata, {4'b0, dmem_wmask});
  end
  imem_respValid <= imem_reqValid;
  dmem_respValid <= dmem_reqValid;
end
endmodule
    
