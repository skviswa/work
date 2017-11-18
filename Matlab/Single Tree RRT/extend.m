function E = extend(qrand, qnear, val, th)  %% Extend the tree in the direction of qnear
   qnew = [0 0 0 0];
   if val > th
       % If the distance between qnear and qrand is greater than our
       % threshold, then extend in the direction of qrand by this margin
       qnew(1) = qnew(1) + (3*(qrand(1)-qnear(1))/11);
       qnew(2) = qnew(2) + (3*(qrand(2)-qnear(2))/11);
       qnew(3) = qnew(3) + (3*(qrand(3)-qnear(3))/11);
       qnew(4) = qnew(4) + (3*(qrand(4)-qnear(4))/11);
   else
       % If distance is within threshold, set the randomly sampled point
       % to be the new node of the tree
       qnew(1) = qrand(1);
       qnew(2) = qrand(2);
       qnew(3) = qrand(3);
       qnew(4) = qrand(4);
   end
   
   E = [qnew(1), qnew(2), qnew(3), qnew(4)];
end