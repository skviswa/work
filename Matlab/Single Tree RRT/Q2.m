% Calculate a path from qStart to xGoal
% input: qStart -> 1x4 joint vector describing starting configuration of
%                   arm
%        xGoal -> 3x1 position describing desired position of end effector
%        sphereCenter -> 3x1 position of center of spherical obstacle
%        sphereRadius -> radius of obstacle
% output -> qMilestones -> 4xn vector of milestones. A straight-line interpolated
%                    path through these milestones should result in a
%                    collision-free path. You may output any number of
%                    milestones. The first milestone should be qStart. The
%                    last milestone should place the end effector at xGoal.
function qMilestones = Q2(rob,sphereCenter,sphereRadius,qStart,xGoal)

flag = 0; % To resample in case we have not got a satisfactory result

while(flag == 0)
clearvars -except rob sphereCenter sphereRadius qStart xGoal flag
scale = 8;  % represents the scaling to move around the entire space
th = 5;     %    The distance threshold to decide how to extend the tree 
numNodes = 1000;     % Max no of times we are sampling    

qstart.coord = qStart; % Create a tree structure with joint co ordinates and parent
qstart.parent = 0;
Q = zeros(1,4);
M = [1;1;1;0;0;0];
qGoal.coord = rob.ikine(transl(xGoal),Q,M);
qMilestones = qGoal.coord;

nodes(1) = qstart;
for i = 1:numNodes
    qRand = [rand(1)*scale, rand(1)*scale, rand(1)*scale, rand(1)*scale];  % Randomly sample point in configuration space
    % Break if goal node is already reached
    for j = 1:length(nodes)
        if nodes(j).coord == qGoal.coord
            break
        end
    end
    
    % Pick the closest node from existing list to branch out from
    ndist = [];
    for j = 1:length(nodes)
        n = nodes(j);
        tmp = norm(n.coord - qRand);
        ndist = [ndist tmp];
    end
    [val, idx] = min(ndist);  % Try to find the nearest point in the tree to the sampled point.
    qNear = nodes(idx);
    
       qNew.coord = extend(qRand, qNear.coord, val, th);
       %Assign this node to the tree only if it doesnt come in the way of
       %the obstacle
   if (~Q1(rob,qNear.coord,qNew.coord,sphereCenter,sphereRadius))
       qNew.parent = idx;
       nodes = [nodes qNew];
   end
end 
D = [];
% Now from the list of computed nodes of the tree, pick one which is
% closest to the Goal such that the path from this point to the goal is
% obstacle free
for j = 2:length(nodes)
    if(~Q1(rob,nodes(j).coord,qGoal.coord,sphereCenter,sphereRadius))
    minpt.tmpdist = norm(nodes(j).coord - qGoal.coord);
    minpt.node = j;
    D = [D minpt];
    end
end
if(isempty(D))
    flag = 0;  % If there is no such element present, then go back and start sampling from the beginning
else
[val, idx1] = min([D.tmpdist]);
idx = D(idx1).node;  % If there is such a point, use that to start the backtracking
qGoal.parent = idx;
qEnd = qGoal;
while qEnd.parent ~= 0
    start = qEnd.parent;
    qEnd = nodes(start);
    qMilestones = [qEnd.coord; qMilestones]; % Backtracking to find a potential path
end

    flag = 1;

end
end
end

