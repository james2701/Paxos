
# distributed algorithms, n.dulay 2 feb 18
# coursework 2, paxos made moderately complex

defmodule Acceptor do

def start config do
  bnum = 0
  accepted = []
  next config, bnum, accepted

end # start

def next config, bnum, accepted do
  receive do
    {:p1a, lamda, b} -> 
      newbnum = 
        if b > bnum do b end
        else bnum end
      send lamda, {:p1b, self(), newbnum, accepted}
      next config, newbnum, accepted
    {:p2a, lamda, {b, s, c}} -> 
      newaccepted = if b == bnum do 
          accepted ++ {b, s, c}
        end
        else accepted end
      send lamda, {:p2b, self(), bnum}
      next config, bnum, newaccepted
  end

end


end # Acceptor

