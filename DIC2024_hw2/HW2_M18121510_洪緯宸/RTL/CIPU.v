module CIPU(
    input clk,
    input rst,
    input [7:0] people_thing_in,
    input ready_fifo,
    input ready_lifo,
    input [7:0] thing_in,
    input [3:0] thing_num,
    output reg valid_fifo,
    output reg valid_lifo,
    output reg valid_fifo2,
    output reg [7:0] people_thing_out,
    output reg [7:0] thing_out,
    output reg done_thing,
    output reg done_fifo,
    output reg done_lifo,
    output reg done_fifo2
);

// State definitions
reg [2:0] state, next_state;
parameter IDLE = 3'd0,
          READ = 3'd1,
          FIFO_OUT = 3'd2,
          LIFO_OUT = 3'd3,
          FINISH = 3'd4;

// FIFO and LIFO storage declarations
reg [7:0] passenger_fifo[0:15];
reg [7:0] baggage_lifo[0:15];
reg [4:0] fifo_head, fifo_tail, lifo_top, lifo_tail;
reg [3:0] thing_num_buf;
reg done_flag, read_done_flag, flag;

// State transitions
always @(posedge clk or posedge rst) begin
    if (rst) state <= IDLE;
    else state <= next_state;
end

// Next state logic
always @(*) begin
    if (rst) next_state = IDLE;
    else begin
        case (state)
            IDLE:
                if (ready_fifo) next_state = READ;
                else next_state = IDLE;
            READ:
                if (done_lifo) next_state = FIFO_OUT;
                else next_state = READ;
            FIFO_OUT:
                if (fifo_tail < fifo_head ) next_state = LIFO_OUT;
                else next_state = FIFO_OUT;
            LIFO_OUT:
                if (done_fifo2) next_state = FINISH;
                else next_state = LIFO_OUT;
            FINISH:
                next_state = FINISH;
            default:
                next_state = IDLE;
        endcase
    end
end

// Data processing
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fifo_head <= 0;
        fifo_tail <= 0;
        lifo_top <= 0;
        lifo_tail <= 0;
        valid_fifo <= 0;
        done_fifo <= 0;
        valid_lifo <= 0;
        valid_fifo2 <= 0;
        done_thing <= 0;
        thing_num_buf <= 0;
        done_flag <= 1;
        read_done_flag <= 0;
        flag <= 0;
        done_lifo <= 0;
        done_fifo2 <= 0;
    end else begin
        case (state)
            READ: begin
                if (people_thing_in >= "A" && people_thing_in <= "Z") begin
                    passenger_fifo[fifo_tail] <= people_thing_in;
                    fifo_tail <= fifo_tail + 1;
                end 
                // Handling input into LIFO
                if (thing_in != ";" && thing_in != "$") begin
                    // Store input in LIFO unless it's a separator or termination symbol
                    if (lifo_top < 15) begin  // Ensure there's room in the LIFO
                        lifo_top <= lifo_top + 1;
                        baggage_lifo[lifo_top] <= thing_in;
                    end
                end
                else if (thing_in == ";" && thing_num_buf == 0 && !valid_lifo && !done_thing) begin
                    if(thing_num)
                        thing_num_buf <= thing_num; 
                    else if(flag == 0)
                    begin
                        flag <= 1;
                    end
                        
                end
                else if (thing_in == "$" ) begin
                    read_done_flag <= 1;
                    done_lifo <= 1;

                end

                if (thing_num_buf > 0) begin
                    thing_out <= baggage_lifo[lifo_top -1];
                    lifo_top <= lifo_top - 1;
                    thing_num_buf <= thing_num_buf - 1;  
                    valid_lifo <= 1;  
                    done_flag <= 0;
                end 
                else if(flag)begin
                    thing_out <= "0";
                    valid_lifo <= 1;
                    done_flag <= 0;
                    flag <= 0;
                end
                else if(thing_num_buf == 0 && !done_flag) begin
                    valid_lifo <= 0;
                    done_thing <= 1;
                    done_flag <= 1;
                end
                else begin
                    valid_lifo <= 0;
                    done_thing <= 0;
                end
                
            end
            FIFO_OUT: begin
                if (fifo_head < fifo_tail) begin
                    people_thing_out <= passenger_fifo[fifo_head];
                    
                    valid_fifo <= 1;
                    done_fifo <= 0;
                end
                else if (fifo_head == fifo_tail)begin
                    valid_fifo <= 0;
                    done_fifo <= 1;
                end
                fifo_head <= fifo_head + 1;
            end
            LIFO_OUT:
            begin
                if (lifo_top > lifo_tail) begin
                    thing_out <= baggage_lifo[lifo_tail];
                    lifo_tail <= lifo_tail + 1;
                    valid_fifo2 <= 1;  
                end 
                else  begin
                    valid_fifo2 <= 0;
                    done_fifo2 <= 1;
                end
                
            end
            FINISH: begin
               
                
            end
        endcase
    end
end

endmodule
