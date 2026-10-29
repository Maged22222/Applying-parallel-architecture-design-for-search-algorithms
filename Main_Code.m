%% setting
delete(timerfindall);
delete(findall(groot, 'Type', 'figure'));
bgPool = backgroundPool;
cancel(bgPool.FevalQueue.QueuedFutures);
cancel(bgPool.FevalQueue.RunningFutures);
clear, clc, close all

sharedData = runMain();

if ~isempty(sharedData.BestSolution)
    disp('Final Best Solution:');
    disp(sharedData.BestSolution);
    disp('Initial Distance:');
    disp(sharedData.InitialDistance);
    disp('Final Best Distance:');
    disp(sharedData.BestDistance);
else
    disp('No Best Solution found.');
end
%% main code 
function sharedData = runMain()
    sharedData = SharedData();
    sharedData.BestSolution = [];
    sharedData.IsComplete = false;
    sharedData.FirstCityCoords = [0, 0, 0];

    n = 30; % deciding num. of cities 

    intermediateCities = rand(n-2, 3);% locate the coordinates of cities
    % decide the first and th last city coordinates
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
    title('Genetic Algorithm TSP Optimization', 'FontSize', 9);
    hold on;
    grid on;
    view(3);

    plot3(cities(:,1), cities(:,2), cities(:,3), 'o', 'Color', [0.4 0.4 0.4], 'MarkerFaceColor', [0.8 0.8 0.8]);

    dq = parallel.pool.DataQueue;
    afterEach(dq, @(data) updateSharedData(sharedData, data));

    f = parfeval(backgroundPool, @() gaFunction(dq, cities, distances, sharedData), 0);

    t = timer('ExecutionMode', 'fixedSpacing', 'Period', 0.1, 'TimerFcn', @(src, ~) updateAnimation(sharedData, cities, src, dq));
    set(fig, 'CloseRequestFcn', @(src, ~) stopAll(t, f, src));

    cleanupObj = onCleanup(@() stopAll(t, f));

    start(t);

    while ~sharedData.IsComplete && isvalid(fig) && any(strcmp(f.State, {'running', 'queued'}))
        pause(0.05);
    end
end
