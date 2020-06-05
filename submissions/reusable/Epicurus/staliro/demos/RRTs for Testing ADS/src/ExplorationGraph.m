classdef ExplorationGraph < PGraph
    %ExplorationGraph Extends PGraph for RRT-like test generation purposes.
    %   See also PGraph
    
    properties

    end
    
    methods
        function g = ExplorationGraph(ndims, varargin)
            g@PGraph(ndims, varargin{:});
        end

        function plot_with_path(g, varargin)
            opt.PathColor = 'b';
            opt.vertices = false;
            opt.samples = false;
            opt.path = true;
            
            [opt,args] = tb_optparse(opt, varargin);
            varargin{end+1} = 'noedges';
            if opt.vertices
                g.plot(varargin{:});
            end
            
            % step through each component
            for c=1:g.nc
                vertices = g.componentnodes(c);
                for v = vertices
                    vdata = g.vdata(v);
%                     if ~isempty(vdata.target_path)
%                         hold on;
%                         plot([vdata.x_hist(1,1), vdata.target_path(1,1)], [vdata.x_hist(1,2), vdata.target_path(2,1)])
%                     end
                    if opt.path
                        if ~isempty(vdata.x_hist)
                            hold on;
                            plot(vdata.x_hist(:,1), vdata.x_hist(:,2), 'Color', opt.PathColor);
                        end
                    end
                    if opt.samples
                        if ~isempty(vdata.target_path)
                            plot(vdata.target_path(1,1), vdata.target_path(2,1), '*');
                        end
                    end
                end
            end
        end
        
        function d = distance_metric(g, x1, x2)
            
            % distance between coordinates x1 and x2 using the relevant metric
            % x2 can be multiple points represented by multiple columns
            if isa(g.measure, 'function_handle')
                d = g.measure(x1(:), x2(:));
            else switch g.measure
                    case 'Euclidean'
                        d = colnorm( bsxfun(@minus, x1, x2) );
                        
                    case 'SE2'
                        d = bsxfun(@minus, x1, x2) * g.dweight;
                        d(3,:) = angdiff(x1(3), x2(3,:));
                        d = colnorm( d );
                        
                    case 'Lattice'
                        d = bsxfun(@minus, x1, x2) * g.dweight;
                        d(3,:) = angdiff(x1(3)*pi/2, x2(3,:)*pi/2);
                        d = colnorm( d );
                    otherwise
                        error('unknown distance measure', g.measure);
                end
            end
        end
        
    end
end

