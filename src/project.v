// Code your testbench here
// or browse Examples
`timescale 1ns/1ns
module testbench;
 reg [3:0] a;
 reg [3:0] b;
 wire [4:0] s; // resultado de 5 bits
 
// Instanciación del DUT
 fourBit_adder uut (
 .a(a),
 .b(b),
 .s(s)
 );
 initial begin
 $dumpfile("dump.vcd");
 $dumpvars(1, testbench);
 $monitor($time, " a=%b , b=%b , s=%b",
a, b, s);

 // Estímulos
       a = 4'b0000; b = 4'b0000;
 #5 a = 4'b0001; b = 4'b0001;
 #5 a = 4'b1111; b = 4'b0000;
 #5 a = 4'b1010; b = 4'b0101;
 #5 a = 4'b1001; b = 4'b0010;
 #5 a = 4'b0101; b = 4'b1100;
 #5 $finish; 

// Termina la simulación
 end
endmodule
