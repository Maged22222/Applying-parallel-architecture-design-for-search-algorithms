function updateAnimation(sharedData, cities, timerObj, dq)
    if sharedData.AnimationDone
        return;
    end

    if isempty(sharedData.BestSolution) || isempty(sharedData.WorkerQueue)
        return;
    end

    n = size(cities, 1);

    if ~isempty(sharedData.AgentHandle) && ~isgraphics(sharedData.AgentHandle)
        sharedData.AnimationDone = true;
        if isvalid(timerObj)
            stop(timerObj);
        end
        return;
    end

    if isempty(sharedData.AgentHandle)
        ax = gca;
        hold(ax, 'on');
        plot3(ax, cities(1,1), cities(1,2), cities(1,3), 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
        plot3(ax, cities(end,1), cities(end,2), cities(end,3), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
        sharedData.PlanHandle = plot3(ax, nan, nan, nan, 'b--', 'LineWidth', 1);
        sharedData.VisitedHandle = plot3(ax, cities(1,1), cities(1,2), cities(1,3), 'r-', 'LineWidth', 2.5);
        sharedData.AgentHandle = plot3(ax, cities(1,1), cities(1,2), cities(1,3), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    end

    ax = ancestor(sharedData.AgentHandle, 'axes');

    if ~sharedData.IsMoving
        P = sharedData.LockedPrefix;
        k = numel(P);
        tour = sharedData.BestSolution;
        if numel(tour) ~= n || ~isequal(tour(1:k), P)
            rest = tour(~ismember(tour, P));
            tour = [P, rest];
            sharedData.BestSolution = tour;
            sharedData.BestDistance = calculateTourDistance(tour, pdist2(cities, cities));
        end
        nextCity = tour(k + 1);
        sharedData.FromCity = P(end);
        sharedData.ToCity = nextCity;
        sharedData.LockedPrefix = [P, nextCity];
        send(sharedData.WorkerQueue, sharedData.LockedPrefix);
        sharedData.CurrentStep = 0;
        sharedData.IsMoving = true;
        if isempty(sharedData.InitialDistance)
            sharedData.InitialDistance = sharedData.BestDistance;
        end
    end

    p1 = cities(sharedData.FromCity, :);
    p2 = cities(sharedData.ToCity, :);
    frac = sharedData.CurrentStep / (sharedData.NumSteps - 1);
    pos = (1 - frac) * p1 + frac * p2;

    set(sharedData.AgentHandle, 'XData', pos(1), 'YData', pos(2), 'ZData', pos(3));
    sharedData.FirstCityCoords = pos;

    visitedCoords = [cities(sharedData.LockedPrefix(1:end-1), :); pos];
    set(sharedData.VisitedHandle, 'XData', visitedCoords(:,1), 'YData', visitedCoords(:,2), 'ZData', visitedCoords(:,3));

    m = numel(sharedData.LockedPrefix);
    plan = sharedData.BestSolution;
    planCoords = [pos; cities(plan(m:end), :)];
    set(sharedData.PlanHandle, 'XData', planCoords(:,1), 'YData', planCoords(:,2), 'ZData', planCoords(:,3));

    if ~isempty(sharedData.InitialDistance)
        title(ax, sprintf('Generation: %d | Locked: %d | Initial Distance: %.4f | Best Distance: %.4f', sharedData.Generation, sharedData.LockedPrefix(end), sharedData.InitialDistance, sharedData.BestDistance), 'FontSize', 9);
    else
        title(ax, sprintf('Generation: %d | Locked: %d | Best Distance: %.4f', sharedData.Generation, sharedData.LockedPrefix(end), sharedData.BestDistance), 'FontSize', 9);
    end

    sharedData.CurrentStep = sharedData.CurrentStep + 1;
    if sharedData.CurrentStep >= sharedData.NumSteps
        sharedData.IsMoving = false;
        if sharedData.ToCity == n
            sharedData.AnimationDone = true;
            send(sharedData.WorkerQueue, 'stop');
            if ~isempty(sharedData.InitialDistance)
                title(ax, sprintf('Complete! Initial Distance: %.4f | Final Best Distance: %.4f', sharedData.InitialDistance, sharedData.BestDistance), 'FontSize', 9);
            else
                title(ax, sprintf('Complete! Final Best Distance: %.4f', sharedData.BestDistance), 'FontSize', 9);
            end
            drawnow;
            if isvalid(timerObj)
                stop(timerObj);
            end
            return;
        end
    end

    drawnow limitrate;
end
