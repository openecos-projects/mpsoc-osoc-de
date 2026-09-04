module NPCTrap(
  input valid,
  input isMMIO,
  input isEbreak,
  input [31:0] code
);
`ifdef __ICARUS__
always @(*) begin
  if (valid && isEbreak) begin
    if (code == 0) begin $display("HIT GOOD TRAP!"); $finish; end
    else begin $display("HIT BAD TRAP with code = %d", code); $fatal; end
  end
end
`else
import "DPI-C" function void set_commit(input bit valid, input bit isEbreak,
  input int code, input bit isMMIO);
always @(*) begin
  set_commit(valid, isEbreak, code, isMMIO);
end
`endif
endmodule
    
