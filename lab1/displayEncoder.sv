
module displayEncoder(
input logic [19:0] result,
output logic [3:0] numberBits [3:0]
    );
logic [19:0] res1;
logic [19:0] res2;
logic [19:0] res3;
always_comb begin
numberBits[0] = result % 10;
res1 = result / 10;
numberBits[1] = res1 % 10;
res2 = res1 / 10;
numberBits[2] = res2 % 10;
res3 = res2 / 10;
numberBits[3] = res3 % 10;
end
endmodule
