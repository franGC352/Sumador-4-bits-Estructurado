
`timescale 1ns/1ps

module testbench;

    reg [3:0] banda1;
    reg [3:0] banda2;
    reg [3:0] banda3;
    reg [3:0] banda4;

    wire [43:0] resistencia;
    wire [11:0] tolerancia;
    wire error;

    integer fallos;

    // Instancia del circuito
    calculadora_resistencia DUT (

        .banda1(banda1),
        .banda2(banda2),
        .banda3(banda3),
        .banda4(banda4),
        .resistencia(resistencia),
        .tolerancia(tolerancia),
        .error(error)

    );

    // Tarea para comprobar cada resistencia
    task prueba;

        input [3:0] b1;
        input [3:0] b2;
        input [3:0] b3;
        input [3:0] b4;

        input [43:0] r_esperada;
        input [11:0] t_esperada;
        input e_esperado;

        begin

            banda1 = b1;
            banda2 = b2;
            banda3 = b3;
            banda4 = b4;

            #10;

            $display(
                "Bandas: %0d %0d %0d %0d | R = %0.2f ohms | Tol = %0.2f%% | Error = %b",
                banda1, banda2, banda3, banda4,
                resistencia / 100.0,
                tolerancia / 100.0,
                error
            );

            if (resistencia !== r_esperada ||
                tolerancia !== t_esperada ||
                error !== e_esperado) begin

                $display("RESULTADO INCORRECTO");
                fallos = fallos + 1;

            end
            else
                $display("RESULTADO CORRECTO");

        end

    endtask

    initial begin

        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);

        fallos = 0;

        // Prueba 1: 220 ohms +/- 5%
        prueba(2, 2, 1, 10, 22000, 500, 0);

        // Prueba 2: 1000 ohms +/- 5%
        prueba(1, 0, 2, 10, 100000, 500, 0);

        // Prueba 3: 4700 ohms +/- 5%
        prueba(4, 7, 2, 10, 470000, 500, 0);

        // Prueba 4: 10000 ohms +/- 1%
        prueba(1, 0, 3, 1, 1000000, 100, 0);

        // Prueba 5: 4.7 ohms +/- 5%
        prueba(4, 7, 10, 10, 470, 500, 0);

        // Prueba 6: 0.22 ohms +/- 10%
        prueba(2, 2, 11, 11, 22, 1000, 0);

        // Prueba 7: Primera banda invalida
        prueba(10, 2, 1, 10, 0, 0, 1);

        // Prueba 8: 1 megaohm +/- 2%
        prueba(1, 0, 5, 2, 100000000, 200, 0);

        $display("---------------------------");
        $display("Total de fallos: %0d", fallos);

        $finish;

    end

endmodule

