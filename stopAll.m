function stopAll(timerObj, future, figHandle)
    if ~isempty(timerObj) && isvalid(timerObj)
        stop(timerObj);
        delete(timerObj);
    end

    if ~isempty(future) && isvalid(future) && any(strcmp(future.State, {'running', 'queued'}))
        cancel(future);
    end

    if nargin > 2 && ~isempty(figHandle) && isvalid(figHandle)
        delete(figHandle);
    end
end
