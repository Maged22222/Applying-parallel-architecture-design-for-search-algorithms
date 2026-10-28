function gaFunction(dq, cities, distances, sharedData)
    fileID = fopen('best_solutions.txt', 'w');
    if fileID == -1
        error('Cannot open file for writing.');
    end

    workerQueue = parallel.pool.PollableDataQueue;
    send(dq, struct('message', 'WorkerQueue', 'queue', workerQueue));

    populationSize = 50;
    numCities = size(cities, 1);
    prefix = 1;

    bestTour = [1, randperm(numCities - 2) + 1, numCities];
    bestDistance = calculateTourDistance(bestTour, distances);

    send(dq, struct('tour', bestTour, 'distance', bestDistance, 'generation', 0, 'message', 'BestSolutionUpdated'));
    fprintf(fileID, 'Generation 0: Locked: %d | Best tour: %s | Distance: %.4f\n', prefix(end), num2str(bestTour), bestDistance);

    gen = 0;
    running = true;
    while running
        gen = gen + 1;

        [msg, ok] = poll(workerQueue);
        while ok
            if ischar(msg) && strcmp(msg, 'stop')
                running = false;
                break;
            end
            prefix = msg;
            rest = bestTour(~ismember(bestTour, prefix));
            bestTour = [prefix, rest];
            bestDistance = calculateTourDistance(bestTour, distances);
            fprintf(fileID, 'Generation %d: Locked: %d | Best tour: %s | Distance: %.4f\n', gen, prefix(end), num2str(bestTour), bestDistance);
            send(dq, struct('tour', bestTour, 'distance', bestDistance, 'generation', gen, 'message', 'BestSolutionUpdated'));
            [msg, ok] = poll(workerQueue);
        end

        if ~running
            break;
        end

        k = numel(prefix);
        free = setdiff(2:numCities-1, prefix, 'stable');
        numFree = numel(free);

        if numFree >= 2
            for p = 1:populationSize
                if rand < 0.5
                    newTour = [prefix, free(randperm(numFree)), numCities];
                else
                    newTour = bestTour;
                    idx = randperm(numFree, 2) + k;
                    newTour([idx(1), idx(2)]) = newTour([idx(2), idx(1)]);
                end
                newDistance = calculateTourDistance(newTour, distances);

                if newDistance < bestDistance
                    bestTour = newTour;
                    bestDistance = newDistance;
                    fprintf(fileID, 'Generation %d: Locked: %d | Best tour: %s | Distance: %.4f\n', gen, prefix(end), num2str(bestTour), bestDistance);
                    send(dq, struct('tour', bestTour, 'distance', bestDistance, 'generation', gen, 'message', 'BestSolutionUpdated'));
                end
            end
        end

        pause(0.1);
    end

    send(dq, struct('tour', bestTour, 'distance', bestDistance, 'generation', gen, 'message', 'complete'));
    fclose(fileID);
end
