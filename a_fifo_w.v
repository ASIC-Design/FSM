
module a_fifo_c(

input clk
  input rst_n
  input clear
  input inc
  input dir 

  output  cen  
  output  [addr-1:0] addr 
  output  full
  output  empty 

  input [addr:0] ptr_gray_other
  output [addr:0] ptr_bin   
  output [addr:0]  ptr_gray 
  

);

parameter addr_wodth = 5 ;
  parameter depth = 32 ;

  local max_depth = (1 << addr_width); 
  local offset = max_depth - fifo_depth ;


  function [ addr_wid:0] bin2gray;
    input[addr_width:0] bin;
    reg [addr_w:0] bin_adj ;
    reg [addr_w:0] gray  ; 
    begin
      if(bin > FIFO_DEPTH)
        bin_adj = bin + OFFSEFT ;
      else
        bin_adj = bin;
      gray = bin_adj ^(bin_adj >>1);
      bin2gray = gray ;
    end
  endfunction  //bin2gray

  function [addr_w:0] gray2bin;
    input [addr:0] gray ;
    reg [addr_w:0] bin_adj ;
    reg [addr_w:0] bin;
    integer i
    begin 
      for ( i = 0; i<= addr_w; i=i+1)
        bin[i] = ^(gray>>i);
      if(bin> fifo_depth)
          bin_adj = bin - OFFSET;
      else
          bin_adj =bin;
      gray2bin = bin_adj;
    end
  endfunction  //gray2bin 

  assign ptr_bin_other = gray2bin(ptr_gray_other);

//------gray and binary pointer increment --//
  always@(posedge clk or negedge rst_n)
    if(!rst_n) begin
      ptr_bin <= 'b0 ;
      ptr_gray <= 'b0 ; 
      else if(clear) begin
        ptr_bin <= 'b0;
        ptr_gray <= 'b0 ;
      end
      else begin
        ptr_bin <= ptr_bin_next;
        ptr_gray <= ptr_gray_next ; 
      end
     
      assign ptr_bin_next = fifo_cen? ptr_bin: (ptr_bin[addr_w-1:0] == fifo_depth -1)? {~ptr[addr],{addr{1'b0}}}: (ptr_bin+1'b1;

     assign ptr_gray_next = bin2gray(ptr_bin_next); 
//     fifo full logic
     assign fifo_full_c = (ptr_bin_next  == {~ptr_bin_other[addr_w], ptr_bin_other[addr-1:0]});
                                                                                                                   
           always @(posedge clk or negedge rst_n)
            if (!rst_n)
                  fifo_full <= 1'b0 ;
          else if (fifo_clear)
               fifo_full <= 1'b0 ;
           else
         fifo_full <= fifo_full_c;
//fifo empty logic 

     assign fifo_empty = (ptr_gray_next == ptr_gray_other);
 always @(posdge clk or negedge rst_n)
  if(!rst_n)
  fifo_empty <= 1'b1;
   else if(fifo_clear)
 fifo_empty <= 1'b1; 
  else
  fifo_empty <= fifo_empty_c;
                                                                    
  assign fifo_cen = fifo_dir? (~fifo_inc | fifo_full):(~fifo_inc|fifo_empty);
  assign fifo_addr = ptr[addr_w-1:0];
   endmodule
