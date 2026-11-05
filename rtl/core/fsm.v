`ifndef FSM_V
`define FSM_V

module fsm (
    input  wire clk,
    input  wire rst,     // reset síncrono, activo en alto
    input  wire start,

    // Estado proveniente del datapath
    input  wire zero,
    input  wire neq,
    input  wire lt,

    // Control hacia el datapath
    output reg  sel,
    output reg  ldX,
    output reg  ldY,
    output reg  op,

    // Indicador de fin
    output reg  done
);

    // Codificación de estados
    localparam [2:0] S0_IDLE  = 3'd0,
                     S1_LOAD  = 3'd1,
                     S2_CHECK = 3'd2,
                     S3_SUBY  = 3'd3,
                     S4_SUBX  = 3'd4,
                     S5_DONE  = 3'd5;

    reg [2:0] state, next_state;

    // ---------------- Registro de estado ----------------
    always @(posedge clk) begin
        if (rst)
            state <= S0_IDLE;
        else
            state <= next_state;
    end

    // ---------------- Lógica de siguiente estado ----------------
    always @(*) begin
        next_state = state;   // por defecto, se mantiene
        case (state)
            S0_IDLE:  if (start) next_state = S1_LOAD;

            S1_LOAD:  next_state = S2_CHECK;

            S2_CHECK: begin
                if (zero || !neq)
                    next_state = S5_DONE;
                else if (lt)
                    next_state = S3_SUBY;   // X < Y
                else
                    next_state = S4_SUBX;   // X > Y
            end

            S3_SUBY:  next_state = S2_CHECK;
            S4_SUBX:  next_state = S2_CHECK;

            S5_DONE:  if (!start) next_state = S0_IDLE;

            default:  next_state = S0_IDLE;
        endcase
    end

    // ---------------- Lógica de salidas (Moore) ----------------
    always @(*) begin
        // Valores por defecto (evitan latches)
        sel  = 1'b0;
        ldX  = 1'b0;
        ldY  = 1'b0;
        op   = 1'b0;
        done = 1'b0;

        case (state)
            S1_LOAD: begin
                sel = 1'b0;  ldX = 1'b1;  ldY = 1'b1;   // X<-A, Y<-B
            end

            S3_SUBY: begin
                sel = 1'b1;  ldY = 1'b1;  op = 1'b1;    // Y<-Y-X
            end

            S4_SUBX: begin
                sel = 1'b1;  ldX = 1'b1;  op = 1'b0;    // X<-X-Y
            end

            S5_DONE: begin
                done = 1'b1;
            end

            default: ;  // S0 y S2: todo en 0 (op=0 en CHECK)
        endcase
    end

endmodule

`endif