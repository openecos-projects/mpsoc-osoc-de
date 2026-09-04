module SimMcycle(
  input ren,
  output reg [63:0] mcycle64
);
import "DPI-C" function longint my_mtime();
always @(*) begin
  mcycle64 = ren ? my_mtime() : 0;
end
endmodule
    
