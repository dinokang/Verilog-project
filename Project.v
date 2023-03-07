`timescale 1ns / 1ps

module Project(clk, inp, str, rst, FND_car, FND_peo, FND_carSel2, FND_carSel1, FND_peoSel2, FND_peoSel1, peo_o, car_o);
    input       clk, inp, str, rst;
    output [1:0]        peo_o;
    output [2:0]        car_o;
    output [6:0]        FND_peo, FND_car;
    output              FND_carSel2, FND_carSel1, FND_peoSel2, FND_peoSel1;
    
    reg [1:0]       peo;
    reg [2:0]       car;
    reg [6:0]       FND_caro, FND_caro1, FND_caro2, FND_peoo, FND_peoo1,FND_peoo2;
    reg             clk100hz;
    reg             FND_carSel2, FND_carSel1;
    reg             FND_peoSel2, FND_peoSel1;
    
    
    integer         m = 0, k = 0, cnt100hz = 0;  //m = 0.5hz count   k = 0.1hz count
    
    parameter         S0 = 2'b00, S1 = 2'b01, S2 = 2'b10, S3 = 2'b11;
    reg [1:0]       state = S0;     
    
    always @ (posedge clk) begin
        if(cnt100hz >= 4999) begin
            cnt100hz <= 0;
            clk100hz <= ~clk100hz;
        end else
            cnt100hz <= cnt100hz +1;
    end
    
    always @ (posedge clk or negedge rst ) begin
        if(~rst)begin
            state <= S0;
            m <= 0;
            k <= 0;
        end else if(str) begin
                case (state)
                    S0 : state <= S1;
                    S1 :    begin
                        if(~inp)
                            state <= S2;
                    end
                    S2 : 
                        if(m >= 1999999)begin
                            m <= 0;
                            state <= S3;
                        end else begin
                            m <= m+1;
                        end
                    S3 :
                        if(k >= 9999999) begin
                            k <= 0;
                            state <= S1;
                        end else begin
                            k <= k+1;
                        end    
                endcase
        end 
        else begin
            state <= S0;
            m <= 0;
            k <= 0;
        end
    end
    
    always @(state) begin
        case(state)
            S0 : peo <= 2'b00;
            S1 : peo <= 2'b01;
            S2 : peo <= 2'b01;
            S3 : peo <= 2'b10;
        endcase
    end
    
    always @(state) begin
        case(state)
            S0 : car <= 3'b000;
            S1 : car <= 3'b100;
            S2 : car <= 3'b010;
            S3 : car <= 3'b001;
        endcase
    end
    
    assign peo_o = peo;
    assign car_o = car;
    
    always @(posedge clk100hz) begin
        if(str) begin
            case(state)
                S0 : FND_peoo2 <= 7'b0000001;
                S1 : FND_peoo2 <= 7'b1100111;
                S2 : FND_peoo2 <= 7'b1100111;
                S3 : FND_peoo2 <= 7'b1111110;
            endcase
            case(state)
                S0 : FND_peoo1 <= 7'b0000001;
                S1 : FND_peoo1 <= 7'b1011011;
                S2 : FND_peoo1 <= 7'b1011011;
                S3 : FND_peoo1 <= 7'b1111011;
            endcase
            case(state)
                S0 : FND_caro2 <= 7'b0000001;
                S1 : FND_caro2 <= 7'b1111110;
                S2 : FND_caro2 <= 7'b1100111;
                S3 : FND_caro2 <= 7'b1100111;
            endcase
            case (state)
                S0 : FND_caro1 <= 7'b0000001;
                S1 : FND_caro1 <= 7'b1111011;
                S2 : FND_caro1 <= 7'b1011011;
                S3 : FND_caro1 <= 7'b1011011;
            endcase
        end
        else begin
            FND_peoo1 <= 7'b0000001;
            FND_peoo2 <= 7'b0000001;
            FND_caro1 <= 7'b0000001;
            FND_caro2 <= 7'b0000001;
       end
    end

     always @( posedge clk) begin
        if(clk100hz == 1'b1) begin
            FND_carSel1 <= 1'b1;
            FND_carSel2 <= 1'b0;
            FND_peoSel1 <= 1'b1;
            FND_peoSel2 <= 1'b0;
            FND_peoo <= FND_peoo1;
            FND_caro <= FND_caro1;
        end else begin
            FND_carSel1 <= 1'b0;
            FND_carSel2 <= 1'b1;
            FND_peoSel1 <= 1'b0;
            FND_peoSel2 <= 1'b1;
            FND_peoo <= FND_peoo2;
            FND_caro <= FND_caro2;
        end
    end
    
    assign FND_car = FND_caro;
    assign FND_peo = FND_peoo;            
            
endmodule
