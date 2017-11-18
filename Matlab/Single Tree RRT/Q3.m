% Smooth path given in qMilestones
% input: qMilestones -> nx4 vector of n milestones. 
%        sphereCenter -> 3x1 position of center of spherical obstacle
%        sphereRadius -> radius of obstacle
% output -> qMilestones -> 4xm vector of milestones. A straight-line interpolated
%                    path through these milestones should result in a
%                    collision-free path. You should output a number of
%                    milestones m<=n.
function qMilestonesSmoothed = Q3(rob,qMilestones,sphereCenter,sphereRadius)

[n,c] = size(qMilestones);
start_node = qMilestones(1,:);  % The node to start our analysis with
dest_node = qMilestones(n,:); % Final destination
i = n;
qMilestonesSmoothed = start_node;  % Initial configuration

while (~isequal(start_node,dest_node)) % Our target test condition
    
      if(i==1)
          break;
      end    
      dest_node_c = qMilestones(i,:);  % Current destination which we are interested in
      collision = Q1(rob,start_node,dest_node_c,sphereCenter,sphereRadius);
      if(collision == 1)
        i = i-1;  % If there is collision then move to the point down the line
      else
        if(isequal(dest_node_c,start_node)) % If you arrive at a condition thats been previously seen, we are done
            break;
        end    
        flag = 0;
        [r,c] = size(qMilestonesSmoothed);
        for j = 1:r
           flag = isequal(start_node,qMilestonesSmoothed(j,:)); % Always store only distinct points in the final matrix
        end
        if(flag == 1)
          qMilestonesSmoothed = [qMilestonesSmoothed; dest_node_c];
        end    
        start_node = dest_node_c; % Once we find the first non collision point, time to reset the problem from there
        i = n;
      end
      
end

if(i==1)
qMilestonesSmoothed = qMilestones; % If every point causes collision, we already have the best possible path
end

end