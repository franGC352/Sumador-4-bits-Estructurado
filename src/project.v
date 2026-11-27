// Code your testbench here
// or browse Examples

module calculadora_resistencia (

    input  wire [3:0] banda1,
    input  wire [3:0] banda2,
    input  wire [3:0] banda3,
    input  wire [3:0] banda4,

    output reg [43:0] resistencia,
    output reg [11:0] tolerancia,
    output reg error
);

    reg [6:0] digitos;
    reg [43:0] multiplicador;

    always @(*) begin

        // Valores iniciales
        resistencia = 0;
        tolerancia = 0;
        multiplicador = 0;
        digitos = 0;
        error = 0;

        // Validar las primeras dos bandas
        if (banda1 == 0 || banda1 > 9 || banda2 > 9)
            error = 1;

        // Formar el numero de dos digitos
        digitos = (banda1 * 10) + banda2;

        // Tercera banda: multiplicador x 100
        case (banda3)

            4'd0:  multiplicador = 44'd100;
            4'd1:  multiplicador = 44'd1000;
            4'd2:  multiplicador = 44'd10000;
            4'd3:  multiplicador = 44'd100000;
            4'd4:  multiplicador = 44'd1000000;
            4'd5:  multiplicador = 44'd10000000;
            4'd6:  multiplicador = 44'd100000000;
            4'd7:  multiplicador = 44'd1000000000;
            4'd8:  multiplicador = 44'd10000000000;
            4'd9:  multiplicador = 44'd100000000000;
            4'd10: multiplicador = 44'd10;
            4'd11: multiplicador = 44'd1;

            default: begin
                multiplicador = 0;
                error = 1;
            end

        endcase

        // Cuarta banda: tolerancia x 100
        case (banda4)

            4'd1:  tolerancia = 100;  // 1%
            4'd2:  tolerancia = 200;  // 2%
            4'd5:  tolerancia = 50;   // 0.5%
            4'd6:  tolerancia = 25;   // 0.25%
            4'd7:  tolerancia = 10;   // 0.1%
            4'd8:  tolerancia = 5;    // 0.05%
            4'd10: tolerancia = 500;  // 5%
            4'd11: tolerancia = 1000; // 10%
            4'd12: tolerancia = 2000; // 20%

            default: begin
                tolerancia = 0;
                error = 1;
            end

        endcase

        // Calcular resistencia si los colores son validos
        if (error == 0)
            resistencia = digitos * multiplicador;
        else begin
            resistencia = 0;
            tolerancia = 0;
        end

    end

endmodule
