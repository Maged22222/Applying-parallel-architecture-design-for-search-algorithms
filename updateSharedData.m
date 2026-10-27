function updateSharedData(sharedData, data)
    disp(data.message);

    if strcmp(data.message, 'WorkerQueue')
        sharedData.WorkerQueue = data.queue;
        return;
    end

    if isfield(data, 'generation')
        sharedData.Generation = data.generation;
    end

    if strcmp(data.message, 'complete')
        sharedData.IsComplete = true;
    end

    if isfield(data, 'tour') && ~isempty(data.tour)
        P = sharedData.LockedPrefix;
        k = numel(P);
        if numel(data.tour) >= k && isequal(data.tour(1:k), P)
            sharedData.BestSolution = data.tour;
            if isfield(data, 'distance')
                sharedData.BestDistance = data.distance;
            end
            if strcmp(data.message, 'BestSolutionUpdated')
                sharedData.IsBestSolutionUpdated = true;
            end
        end
    end
end
