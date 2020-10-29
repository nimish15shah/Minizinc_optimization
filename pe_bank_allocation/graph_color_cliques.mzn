
int: N;

int: MAX_R=32; 
array[1..N] of var 0..MAX_R: col; % 0 is a dummy color
%array[1..N] of var 0..MAX_R: div_8= [col[n] div 8| n in 1..N];
%array[1..N] of var 0..MAX_R: div_4= [col[n] div 4| n in 1..N];
%array[1..N] of var 0..MAX_R: div_2= [col[n] div 2| n in 1..N];

array[1..N] of var 0..5: div_8;
array[1..N] of var 0..9: div_4;
array[1..N] of var 0..17: div_2;

% range constraints
constraint forall (n in 1..N) (
    div_8[n] * 2 <= div_4[n]
  );
constraint forall (n in 1..N) (
    div_8[n] * 2 + 1 >= div_4[n]
  );

constraint forall (n in 1..N) (
    div_4[n] * 2 <= div_2[n]
  );
constraint forall (n in 1..N) (
    div_4[n] * 2 + 1 >= div_2[n]
  );

constraint forall (n in 1..N) (
    div_2[n] * 2 <= col[n]
  );
constraint forall (n in 1..N) (
    div_2[n] * 2 + 1 >= col[n]
  );

%
constraint col[1] == 1;  

include "globals.mzn";
%include "../../no_backup/graph_color_cliques_asia.mzn";
include "../../no_backup/graph_color_cliques_alarm.mzn";

% symmetry breaking
%constraint seq_precede_chain(col);
constraint seq_precede_chain(div_8);

constraint forall (i in 1..15) (
    value_precede_chain([2*i, 2*i + 1], col)
  );

array [1..MAX_R] of var 0..N: count_allocated = [count(col, c) | c in 1..MAX_R];
var int: total_unallocated = count(col, 0);

var int: obj;
%obj= 10*total_unallocated;
obj= max(count_allocated) - min(count_allocated) + 10*total_unallocated;
%obj= max(count_allocated) + 10*total_unallocated;

ann: search_ann;
%search_ann = int_search(col, first_fail, indomain_max);
%search_ann = int_search(col, first_fail, indomain_random);

%solve :: search_ann minimize obj;            
solve :: search_ann minimize obj;            

%solve ::  seq_search ( [search_ann,
%        int_search(allocation_cnt, first_fail, indomain_random),
%    ] ) 
%    minimize total_unallocated;            

output [ 
    "total_unallocated = \(total_unallocated) \n"
    , "count_allocated= \(count_allocated) \n"
%   , "col= \(col)\n"
  ];
