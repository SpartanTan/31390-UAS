% close all
% clear all
% clc
%% Setup the map
% Load the map from the wall file. Each line, except the two last, in the
% wall file is an obstacle. The position of the obstacle is defined in the
% wall file by its x y z coordinates. The three last elements is
% the size of the maze, the starting position and goal position
load('auto_wall.txt')
% If a different named file is used, then write it into the wall variable
% e.g. wall = maze_2;
% wall = wall;
wall = auto_wall;

% Define the map size
max_x = wall(length(wall) - 2, 1);
max_y = wall(length(wall) - 2, 2);
max_z = wall(length(wall) - 2, 3);
map = zeros(max_x, max_y, max_z);

% Input the obstacles into the map
for i = 1:(length(wall) - 3)
    map = gen_square3d([wall(i, 1) wall(i, 1) + 1;...
                        wall(i, 2) wall(i, 2) + 1;...
                        wall(i, 3) wall(i, 3) + 1], map);
    
end

% Define the starting and end position
start = wall(length(wall) - 1, :);
end_ = wall(length(wall), :);

% Make sure the start and end is not an obstacle
map(start(1), start(2), start(3)) = 0;
map(end_(1), end_(2), end_(3)) = 0;

% %% Generate a map
% % Define the map size
% max_x = 4;
% max_y = 5;
% max_z = 3; 
% map = zeros(max_x, max_y, max_z);
% 
% % Generate random obstacles. A 1 in the map is regarded as
% % an obstacle
% obs_per = 0.3;
% for x = 1:max_x
%     for y = 1:max_y
%         for z = 1:max_z
%             if rand > 1 - obs_per
%                 map(x,y,z) = 1;
%             end
%         end
%     end
% end
% 
% % Define the starting and end position
% start = [1, 1, 1];
% end_ = [4, 5, 1];
% 
% % Make sure the start and end is not an obstacle
% map(start(1), start(2), start(3)) = 0;
% map(end_(1), end_(2), end_(3)) = 0;

%% Run the algorithm to obtain the route
route = astar_3d(map, start, end_)

% route = greedy_3d(map, start, end_)

% %% Create wall variable from the map
% wall = []
% for x = 1:max_x
%     for y = 1:max_y
%         for z = 1:max_z
%             if map(x,y,z) == 1
%                 wall = [wall; x y z];
%             end
%         end
%     end
% end
% wall = [wall; max_x max_y max_z; start; end_];

%% Draw the map
% Draw a figure to show the map and process
hold off
figure(1)
% Mark the start with green
scatter3(start(1)+0.5, start(2)+0.5, start(3)+0.5, ...
         500, [0,1,0],'filled')
hold on

% Mark the end with red
scatter3(end_(1)+0.5, end_(2)+0.5, end_(3)+0.5, ...
         500, [1,0,0], 'filled')
hold on

% Draw the obstacles
for i = 1:(length(wall) - 3)
    map = gen_square3d([wall(i, 1) wall(i, 1) + 1;...
                        wall(i, 2) wall(i, 2) + 1;...
                        wall(i, 3) wall(i, 3) + 1], map, 1);
    
end

% Set the axes
axis([1 max_x+1 1 max_y+1 1 max_z+1])
% Make the grid lines more visible
ax = gca;
ax.GridAlpha = 1.0;
grid on
set(gca, 'xtick', [0:1:max_x])
set(gca, 'ytick', [0:1:max_y])
set(gca, 'ztick', [0:1:max_z])

%% Draw the route
pause on;
for i = 2:length(route)
    plot3([route(i-1,1)+0.5,route(i,1)+0.5], ...
          [route(i-1,2)+0.5,route(i,2)+0.5], ...
          [route(i-1,3)+0.5,route(i,3)+0.5], ...
          'color',[0,0,0],'linewidth',5)
    hold on
    pause(0.1)
    route(i,:)
end
hold off

%% Scale the route
x_scale = 2.3/max_x;
y_scale = 2.6/max_y;
z_scale = 1.6/max_z;

x_offset = 0.35;
y_offset = 0.5;
z_offset = 0.45;

% Make a copy of the route
route_scaled = route;

% Scale the copy
route_scaled(:,1) = (route_scaled(:,1) - 1) * x_scale + x_offset;
route_scaled(:,2) = (route_scaled(:,2) - 1) * y_scale + y_offset;
route_scaled(:,3) = (route_scaled(:,3) - 1) * z_scale + z_offset;

route = route_scaled

%discard intermidiate steps
% == only stop for turns
size = height(route);
new_route = [route(1,:)];
for i = 2:size -1
    direction = route(i,:) - route(i-1,:);
    next_direction = route(i+1,:) - route(i,:);
    if dot(direction, next_direction) == 0
        new_route = [new_route; route(i,:)];
    end
end
new_route = [new_route; route(size,:)];
route = new_route




%DELETE THIS BEFORE DEMO FLIGHT!!!
% route_back = route;
% route_back = flip(route_back);
% route = [route; route_back];


%tell the drone to touch down
route = [route; route(end, 1) route(end, 2) 0.05];
route = [route; 0 0 0];
% Print the scaled route
route

