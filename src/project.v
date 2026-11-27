
`default_nettype none

module tt_um_calculadora_resistencia (

    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n

);

    // Registros para guardar los cuatro colores
    reg [3:0] banda1;
    reg [3:0] banda2;
    reg [3:0] banda3;
    reg [3:0] banda4;

    // Variables para los resultados
    reg [7:0] digitos;
    reg signed [7:0] exponente;
    reg [11:0] tolerancia;
    reg error;

    // Senales de control
    wire seleccion;
    wire guardar;
    wire [3:0] lectura;

    assign seleccion = uio_in[0];
    assign guardar   = uio_in[1];
    assign lectura   = uio_in[5:2];

    // Configurar pines bidireccionales como entradas
    assign uio_oe  = 8'b00000000;
    assign uio_out = 8'b00000000;

    // Guardar los colores de las bandas
    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            banda1 <= 0;
            banda2 <= 0;
            banda3 <= 0;
            banda4 <= 0;

        end
        else if (ena && guardar) begin

            if (seleccion == 0) begin

                banda1 <= ui_in[3:0];
                banda2 <= ui_in[7:4];

            end
            else begin

                banda3 <= ui_in[3:0];
                banda4 <= ui_in[7:4];

            end

        end

    end

    // Calcular los parametros de la resistencia
    always @(*) begin

        digitos    = 0;
        exponente  = 0;
        tolerancia = 0;
        error      = 0;

        // Validar primeros dos colores
        if (banda1 == 0 || banda1 > 9 || banda2 > 9)
            error = 1;

        // Formar los dos digitos significativos
        digitos = (banda1 * 8'd10) + {4'b0, banda2};

        // Tercera banda: exponente del multiplicador
        case (banda3)

            4'd0:  exponente =  0;
            4'd1:  exponente =  1;
            4'd2:  exponente =  2;
            4'd3:  exponente =  3;
            4'd4:  exponente =  4;
            4'd5:  exponente =  5;
            4'd6:  exponente =  6;
            4'd7:  exponente =  7;
            4'd8:  exponente =  8;
            4'd9:  exponente =  9;
            4'd10: exponente = -1;
            4'd11: exponente = -2;

            default: error = 1;

        endcase

        // Cuarta banda: tolerancia multiplicada por 100
        case (banda4)

            4'd1:  tolerancia = 12'd100;
            4'd2:  tolerancia = 12'd200;
            4'd5:  tolerancia = 12'd50;
            4'd6:  tolerancia = 12'd25;
            4'd7:  tolerancia = 12'd10;
            4'd8:  tolerancia = 12'd5;
            4'd10: tolerancia = 12'd500;
            4'd11: tolerancia = 12'd1000;
            4'd12: tolerancia = 12'd2000;

            default: error = 1;

        endcase

        // Limpiar resultados si existe un error
        if (error) begin

            digitos    = 0;
            exponente  = 0;
            tolerancia = 0;

        end

    end

    // Multiplexor de salida
    always @(*) begin

        case (lectura)

            4'd0: uo_out = digitos;
            4'd1: uo_out = exponente;
            4'd2: uo_out = tolerancia[7:0];
            4'd3: uo_out = {4'b0000, tolerancia[11:8]};
            4'd4: uo_out = {7'b0000000, error};

            default: uo_out = 8'b00000000;

        endcase

    end

    // Evitar advertencias por entradas sin utilizar
    wire _unused = &{uio_in[7:6], 1'b0};

endmodule
