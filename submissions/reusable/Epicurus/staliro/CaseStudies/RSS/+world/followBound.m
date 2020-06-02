function [shortestPath] = followBound(iStart, shortestPath, innerBound, outerBound)
% followBound - keep following the inner bound of the lane until the next
% inflection point and compute the path variable xi of the shortest path
% (recursive function)
%
% Syntax:
%   [shortestPath] = followBound(iStart, shortestPath, innerBound, outerBound)
%
% Inputs:
%   iStart - index of the vertice of the inner lane at which this shortest
%   path search begins
%   shortestPath - structure of the shortest path (see outputs)
%   innerBound - inner bound of the lane (network)
%   outerBound - outer bound of the lane (network)
%
% Outputs:
%   shortestPath - shortest path through the lane
%           .xi - path variable (path length along the shortest path)
%           .indexBorder - for each path variable the corresponding
%           index of the vertice of inner bound
%           .side - side of the current inner bound (1: left; 0: right)
%
% Other m-files required: calcVectorIntersectionPoint
% Subfunctions: none
% MAT-files required: none
%
% See also: Althoff and Magdici, 2016, Set-Based Prediction of Traffic
% Participants on Arbitrary Road Networks, IV. Occupancy Prediction, B.
% Lane-Following Occupancy (Abstraction M_2), Definition 8
% (Inflection-point segmentation)
%
% References in this function refer to this paper.

% Author:       Markus Koschi
% Written:      14-Oktober-2016
% Last update:  03-August-2017
%
% Last revision:---

%------------- BEGIN CODE --------------

% 2) follow current inner bound until inflection point
% (using syntax of Defintion 8)
i = iStart;
while i < length(innerBound.distances)
    
    % check if at the next vertice the inner bound should change,
    % i.e. curvature < 0 --> right OR curvature > 0 --> left
    if ( ((innerBound.side && innerBound.curvatures(i+1) < 0) || (~innerBound.side && innerBound.curvatures(i+1) > 0)) && (abs(innerBound.curvatures(i+1)) > abs(outerBound.curvatures(i+1))) ) || ...
            ( ((outerBound.side && outerBound.curvatures(i+1) > 0) || (~outerBound.side && outerBound.curvatures(i+1) < 0)) && (abs(outerBound.curvatures(i+1)) > abs(innerBound.curvatures(i+1))) )
        
        % find the previous and next vertice point on inner bound (p)
        piminus1 = innerBound.vertices(:,geometry.getNextIndex(innerBound.vertices, i, 'backward', innerBound.distances));
        piplus1 = innerBound.vertices(:,geometry.getNextIndex(innerBound.vertices, i, 'forward', innerBound.distances));
        
        % construct tangent at vertice i of inner bound (h')
        hPrime = piplus1 - piminus1;
        
        % construct normal vector to tangent at vertice i of inner bound (g)
        g = [-hPrime(2); hPrime(1)];
        
        % construct hCross = gamma + alpha*g
        gamma = innerBound.vertices(:,i);
        hCrossStart = gamma;
        hCrossEnd = gamma + 1*g;
        
        % find point mu_j on outer bound, such that mu_j is the first
        % vertice in front of hCross in driving direction
        % (mu_j is an approximation of mu on the lane grid)
        for j = iStart:size(outerBound.vertices,2)
            mu_j = outerBound.vertices(:,j);
            % due to the specific orientation of hCross, mu_j is always on
            % the right of hCross to be in front in driving direction
            if ~geometry.isLeft(hCrossStart, hCrossEnd, mu_j)
                break;
            end
        end
        % (mu_j = outerBound.vertices(:,i); is not perpendicular projection)
        
        % % % perpentiducal projection of mu_j on hCross (alternative
        % % % to insection below, but not accurate)
        % % v = mu_j - gamma;
        % % c = (g'*v)/(g'*g)*g;
        % % mu_j_proj = gamma + c;
        
        % calculate the distance from mu to mu_j along outer bound
        % (by intersecting hCross and hPrimeOuterBound)
        % (vector equation: mu_j + beta*hPrimeOuterBound)
        if j-1 > 0
            mu_jminus1 = outerBound.vertices(:,geometry.getNextIndex(outerBound.vertices, j, 'backward', outerBound.distances));
            hPrimeOuterBound = (mu_jminus1 - mu_j) / norm(mu_jminus1 - mu_j);
        else
            mu_jplus1 = outerBound.vertices(:,geometry.getNextIndex(outerBound.vertices, j, 'forward', outerBound.distances));
            hPrimeOuterBound = (mu_jplus1 - mu_j) / norm(mu_jplus1 - mu_j);
        end
        [~, beta] = geometry.calcVectorIntersectionPoint(gamma, g, mu_j, hPrimeOuterBound);
        % % % point of intersection of hCross and hPrimeOuterBound:
        % % mu = [mu_j(1)+beta*hPrimeOuterBound(1); mu_j(2)+beta*hPrimeOuterBound(2)];
        % % mu = [gamma(1)+test*g(1); gamma(2)+test*g(2)];
        
        % % DEBUG plot
        % alpha = -1:0.1:2;
        % alpha2 = 0:0.1:1;
        % hCrossX = gamma(1) + alpha*g(1);
        % hCrossY = gamma(2) + alpha*g(2);
        % hPrimeX = piminus1(1) + alpha2*hPrime(1);
        % hPrimeY = piminus1(2) + alpha2*hPrime(2);
        %
        % plot(outerBound.vertices(1,:), outerBound.vertices(2,:), 'k-');
        % hold on
        % plot(innerBound.vertices(1,:), innerBound.vertices(2,:), 'k-');
        %
        % plot(hCrossX, hCrossY, 'g-');
        %
        % plot(gamma(1), gamma(2), 'r*');
        % plot(piminus1(1), piminus1(2), 'ro');
        % plot(piplus1(1), piplus1(2), 'ro');
        % plot(hPrimeX, hPrimeY, 'r-');
        %
        % plot(outerBound.vertices(1,i), outerBound.vertices(2,i), 'b*');
        % plot(outerBound.vertices(1,i-1), outerBound.vertices(2,i-1), 'bo');
        % plot(outerBound.vertices(1,i+1), outerBound.vertices(2,i+1), 'bo');
        %
        % plot(mu_j(1), mu_j(2), 'md', 'MarkerSize', 10);
        % plot(mu_j(1)+beta*hPrimeOuterBound(1), mu_j(2)+beta*hPrimeOuterBound(2), 'ms');
        %
        % axis equal
        % hold off
               
        % update shortestPath:
        if (j > i) % the new inner bound (j) is ahead of the old one (i)
            % add distance beta to path variable xi
            shortestPath.xi(end+1) = shortestPath.xi(end) + beta;
            % the current index is j
            iStartNew = j;
        else % j <= i
            % the new inner bound (j) is behind of the old one (i), so it
            % must follow up, as we have already checked for inflection
            % points until i+1 --> follow up on the outer bound to i+1:
            % add distance beta (i.e. distance mu to mu_j) and the distances
            % from mu_j until (i+1) to path variable xi
            shortestPath.xi(end+1) = shortestPath.xi(end) + beta + ...
                sum(outerBound.distances((j+1):(i+1)));
            % the current index is i+1
            iStartNew = i+1;
        end
        % the current index of the border is the new starting index
        shortestPath.indexBorder(end+1) = iStartNew;
        % after the inflection point, the outer bound is the new inner bound
        shortestPath.side(end+1) = outerBound.side;
        % set the curvature
        shortestPath.curvature(end+1) = outerBound.curvatures(iStartNew);
        
        % DEBUG: check if outer bound should really become the new inner bound
        if shortestPath.side(end) % -> left
            if sign(outerBound.curvatures(i+1)) < 0 && ...
                    abs(outerBound.curvatures(i+1)) > abs(innerBound.curvatures(i+1))
                warning(['The left border will become inner bound at '...
                    'vertice %i, even though its curvature is negative '...
                    'and its absolute value is larger than on the right border. ' ...
                    ' (leftBorder.curvature = %d and '...
                    'rightBorder.curvature = %d)'], i+1, ...
                    outerBound.curvatures(i+1), innerBound.curvatures(i+1));
            end
        else % ~shortestPath.side(end) -> right
            if sign(outerBound.curvatures(i+1)) > 0 && ...
                    abs(outerBound.curvatures(i+1)) > abs(innerBound.curvatures(i+1))
                warning(['The right border will become inner bound at '...
                    'vertice %i, even though its curvature is positive '...
                    'and its absolute value is larger than on the left border. ' ...
                    '(rightBorder.curvature = %d and '...
                    'leftBorder.curvature = %d)'], i+1, ...
                    outerBound.curvatures(i+1), innerBound.curvatures(i+1));
            end
        end
        
        % 5) follow the new inner bound from vertice iStartNew with
        % switched inner and outer lane bound
        % (recursively call followBound() until the end of the inner bound
        % is reached)
        shortestPath = world.followBound(iStartNew, shortestPath, outerBound, innerBound);
        
        % do not continue on the former inner bound, as an inflection point
        % has been reached and the new inner bound has been followed
        break;
        
    else % between the vertices i and (i+1) is no inflection point
        
        % take one step along the current inner bound but omit vertices
        % which are identical (which can be the case for inner bounds)
        j = geometry.getNextIndex(innerBound.vertices, i, 'forward', innerBound.distances);
        
        % adding the distance between the ith and jth vertice to path variable xi        
        shortestPath.xi(end+1) = shortestPath.xi(end) + sum(innerBound.distances((i+1):(j)));
        % the current index is j
        shortestPath.indexBorder(end+1) = j;
        % the side is the inner bound
        shortestPath.side(end+1) = innerBound.side;
        % set the curvature
        shortestPath.curvature(end+1) = innerBound.curvatures(j);
             
        % DEBUG: check if inner bound is really inner bound
        if shortestPath.side(end) % -> left
            if sign(innerBound.curvatures(i+1)) < 0 && ...
                    abs(innerBound.curvatures(i+1)) > abs(outerBound.curvatures(i+1))
                warning(['The left border is inner bound at '...
                    'vertice %i, even though its curvature is negative.'...
                    ], (i+1));
            end
        else % ~shortestPath.side(end) -> right
            if sign(innerBound.curvatures(i+1)) > 0 && ...
                    abs(innerBound.curvatures(i+1)) > abs(outerBound.curvatures(i+1))
                warning(['The right border is inner bound at '...
                    'vertice %i, even though its curvature is positive.'...
                    ], (i+1));
            end
        end
        
        % continue following the bound at j
        i = j;
        
    end %if inflection point found
    
end %while i

end

%------------- END CODE --------------