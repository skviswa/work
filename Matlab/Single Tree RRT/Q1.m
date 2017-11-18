% 
% This function takes two joint configurations and the parameters of the
% obstacle as input and calculates whether a collision free path exists
% between them.
% 
% input: q1, q2 -> start and end configuration, respectively. Both are 1x4
%                  vectors.
%        sphereCenter -> 3x1 position of center of sphere
%        r -> radius of sphere
%        rob -> SerialLink class that implements the robot
% output: collision -> binary number that denotes whether this
%                      configuration is in collision or not.
function collision = Q1(rob,q1,q2,sphereCenter,r)

qLine = q1;
num_points = 10;
for i = 1:(num_points)  
q = q1 + ((q2 - q1)*i)/(num_points+1);  % Create 10 points along the line joining  q1 and q2
qLine = [q; qLine];
end
qLine = [q2; qLine];
collision = 0;
for i = 1:(length(qLine))
    collision_check = robotCollision(rob,qLine(i,:),sphereCenter,r); % Use given function to check for collision
    if(collision_check == 1)    
    collision = 1;
    end
end  
end

