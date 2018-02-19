
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Scout do

def start config, lamda, acceptors, b do
  pvalues = []
  for dest <- acceptors do
    send dest, {:p1a, self(), b}
  end
  waitfor = acceptors
  next config, lamda, acceptors, b, pvalues

end # start

def next config, lamda, acceptors, b, pvalues, _waitfor do
  receive do
    {:p1b, acceptor, bnum, r} -> 
    pvalues = 
      if bnum == b do pvalues ++ r 
      else pvalues end
    waitfor = 
      if bnum == b do waitfor -- acceptor 
      else waitfor end
    if bnum == b do 
      if length(wairfor) < length(acceptor) / 2 do
        send lamda, {:adopted, b, pvalues}
      end
    else 
      send lamda, {:preempted, bnum}
    end
  next config, lamda, acceptors, b, pvalues, waitfor
  end
  

end


end # Scout

