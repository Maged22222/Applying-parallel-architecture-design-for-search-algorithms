function totalDistance = calculateTourDistance(tour, distances)
    totalDistance = sum(distances(sub2ind(size(distances), tour, [tour(2:end), tour(1)])));
end