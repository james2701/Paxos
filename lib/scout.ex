
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Scout do

def start config, lamda, acceptors, b do
  pvalues = []
  for dest <- acceptors do
    send dest, {:p1a, self(), b}
  end
  next config, lamda, acceptors, b, pvalues

end # start

def next config, lamda, acceptors, b, pvalues do
  receive do
    {:p1b, leader, bnum, r} -> 
      
  end
  next config, newbnum, newaccepted

end


end # Scout

