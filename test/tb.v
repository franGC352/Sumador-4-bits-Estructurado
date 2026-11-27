
`timescale 1ns/1ps

module testbench;

    reg [7:0] ui_in;
    reg [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    reg ena;
    reg clk;
    reg rst_n;

    reg [7:0] digitos;
    reg signed [7:0] exponente;
    reg [11:0] tolerancia;
    reg error;

    real resistencia;
    integer fallos;

    // Instancia del circuito
    tt_um_calculadora_resistencia DUT (

        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)

    );

    // Reloj de periodo 10 ns
    always #5 clk = ~clk;

    // Tarea para introducir colores y verificar resultados
    task prueba;

        input [3:0] b1;
        input [3:0] b2;
        input [3:0] b3;
        input [3:0] b4;

        input [7:0] d_esperado;
        input signed [7:0] e_esperado;
        input [11:0] t_esperada;
        input error_esperado;

        begin

            // Guardar primera y segunda banda
            @(negedge clk);
            ui_in = {b2, b1};
            uio_in = 8'b00000010;

            // Guardar tercera y cuarta banda
            @(negedge clk);
            ui_in = {b4, b3};
            uio_in = 8'b00000011;

            // Desactivar escritura
            @(negedge clk);
            uio_in = 0;

            // Leer los digitos
            uio_in[5:2] = 0;
            #1;
            digitos = uo_out;

            // Leer exponente
            uio_in[5:2] = 1;
            #1;
            exponente = uo_out;

            // Leer parte baja de tolerancia
            uio_in[5:2] = 2;
            #1;
            tolerancia[7:0] = uo_out;

            // Leer parte alta de tolerancia
            uio_in[5:2] = 3;
            #1;
            tolerancia[11:8] = uo_out[3:0];

            // Leer bandera de error
            uio_in[5:2] = 4;
            #1;
            error = uo_out[0];

            // Reconstruir resistencia para visualizacion
            resistencia = digitos * (10.0 ** exponente);

            $display("------------------------------");
            $display("Bandas: %0d %0d %0d %0d",
                     b1, b2, b3, b4);

            $display("Digitos: %0d", digitos);
            $display("Exponente: %0d", exponente);
            $display("Resistencia: %0.2f ohms", resistencia);
            $display("Tolerancia: %0.2f%%", tolerancia / 100.0);
            $display("Error: %b", error);

            // Verificacion automatica
            if (digitos !== d_esperado ||
                exponente !== e_esperado ||
                tolerancia !== t_esperada ||
                error !== error_esperado) begin

                fallos = fallos + 1;
                $display("PRUEBA INCORRECTA");

            end
            else
                $display("PRUEBA CORRECTA");

        end

    endtask

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        ena = 1;
        rst_n = 0;
        ui_in = 0;
        uio_in = 0;
        fallos = 0;

        #20;
        rst_n = 1;

        // 220 ohms +/- 5%
        prueba(2, 2, 1, 10, 22, 1, 500, 0);

        // 1000 ohms +/- 5%
        prueba(1, 0, 2, 10, 10, 2, 500, 0);

        // 4700 ohms +/- 5%
        prueba(4, 7, 2, 10, 47, 2, 500, 0);

        // 10000 ohms +/- 1%
        prueba(1, 0, 3, 1, 10, 3, 100, 0);

        // 4.7 ohms +/- 5%
        prueba(4, 7, 10, 10, 47, -1, 500, 0);

        // 0.22 ohms +/- 10%
        prueba(2, 2, 11, 11, 22, -2, 1000, 0);

        // Color invalido
        prueba(10, 2, 1, 10, 0, 0, 0, 1);

        // 1 megaohm +/- 2%
        prueba(1, 0, 5, 2, 10, 5, 200, 0);

        $display("==============================");
        $display("TOTAL DE FALLOS: %0d", fallos);
        $display("==============================");

        $finish;

    end

endmodule
