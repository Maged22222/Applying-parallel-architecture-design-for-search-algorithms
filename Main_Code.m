clear, clc, close all

sharedData = SharedData();
sharedData.BestSolution = [];
sharedData.IsComplete = false;
sharedData.FirstCityCoords = [0, 0, 0];

n = 10;

intermediateCities = rand(n-2, 3);

firstCity = [0, 0, 0];
lastCity = [1, 1, 1];

cities = [firstCity; intermediateCities; lastCity];

distances = pdist2(cities, cities);

fig = figure;
ax = gca;
ax.XLim = [0, 1];
ax.YLim = [0, 1];
ax.ZLim = [0, 1];
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Genetic Algorithm TSP Optimization');
hold on;
grid on;
view(3);

plot3(cities(:,1), cities(:,2), cities(:,3), 'o', 'Color', [0.4 0.4 0.4], 'MarkerFaceColor', [0.8 0.8 0.8]);

dq = parallel.pool.DataQueue;
afterEach(dq, @(data) updateSharedData(sharedData, data));

f = parfeval(backgroundPool, @() gaFunction(dq, cities, distances, sharedData), 0);

t = timer('ExecutionMode', 'fixedSpacing', 'Period', 0.1, 'TimerFcn', @(src, ~) updateAnimation8(sharedData, cities, src, dq));
set(fig, 'CloseRequestFcn', @(src, ~) cleanUpTimerAndClose(t, src, f));

start(t);

while ~sharedData.IsComplete && (strcmp(f.State, 'running') || strcmp(f.State, 'queued'))
    pause(0.05);
end

if isvalid(t)
    stop(t);
    delete(t);
end

if ~isempty(sharedData.BestSolution)
    disp('Final Best Solution:');
    disp(sharedData.BestSolution);
    disp('Final Best Distance:');
    disp(sharedData.BestDistance);
else
    disp('No Best Solution found.');
end

function cleanUpTimerAndClose(timerObj, figHandle, future)
    if isvalid(timerObj)
        stop(timerObj);
        delete(timerObj);
    end
    if strcmp(future.State, 'running') || strcmp(future.State, 'queued')
        cancel(future);
    end
    delete(figHandle);
end
