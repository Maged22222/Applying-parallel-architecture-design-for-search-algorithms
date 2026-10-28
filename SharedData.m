classdef SharedData < handle
    properties
        BestSolution
        BestDistance
        InitialDistance = []
        Generation = 0
        IsComplete = false
        IsBestSolutionUpdated = false
        FirstCityCoords = [0, 0, 0]
        LockedPrefix = 1
        WorkerQueue = []
        IsMoving = false
        FromCity = 1
        ToCity = 1
        CurrentStep = 0
        NumSteps = 20
        AnimationDone = false
        AgentHandle = []
        VisitedHandle = []
        PlanHandle = []
    end

    methods
        function solution = getBestSolution(obj)
            solution = obj.BestSolution;
        end
    end
end
