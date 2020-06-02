% Copyright by University of Luxembourg 2019-2020. 
% Developed by Khouloud Gaaloul,khouloud.gaaloul@uni.lu University of Luxembourg. 
% Developed by Claudio Menghi, claudio.menghi@uni.lu University of Luxembourg. 
% Developed by Shiva Nejati, shiva.nejati@uni.lu University of Luxembourg. 
% Developed by Lionel Briand,lionel.briand@uni.lu University of Luxembourg. 

%CONSTR2QCT converts a constraint into readable statment by QVtrace
%INPUTS
%   refined_constr: a constraint
%   input_names: the inputs names.
%   kmax: QVtrace total checking time
%   opt : epicurus_options . epicurus should be of type "epicurus_options". 
%       If the default options are going to be used, then this input may be
%       omitted. For instructions on how to change epicurus options, 
%       see the epicurus_options help file for each desired property.

function qctassumption=Constr2QCT(refined_constr,input_names,kmax,opt)
    qctassumption='';
    qctconstraint='';
    
    kstepsforinteval=round((kmax)/opt.nbrControlPoints);
            
    %  looping over the different inputs
    for input_name=input_names
       split=strsplit(refined_constr{:}); 
       constr_array=split(:,~strcmp(split,'and'));
       % computing a vector that contains all the clauses that refer to all
       % the control points associated with the considered input
       clauses=constr_array(find(contains(constr_array,input_name)));
       
       %% Processing the clauses that refer to the same input
       for control_point_index = 1:opt.nbrControlPoints-1     
            % getst the clauses associated with consecutive control points
            cp1= find(contains(clauses,[input_name{:},num2str(control_point_index)]));
            cp2= find(contains(clauses,[input_name{:},num2str(control_point_index+1)]));
            
            lowkinterval= round((control_point_index-1)*kstepsforinteval);
            upkinterval= round((control_point_index+1)*kstepsforinteval);
            midkeinterval=round(lowkinterval+kstepsforinteval);

            if ~isempty(cp1) && ~isempty(cp2)
                less1=find(contains(clauses(cp1(:)),'<'));
                less2=find(contains(clauses(cp2(:)),'<'));
                more1=find(contains(clauses(cp1(:)),'>='));
                more2=find(contains(clauses(cp2(:)),'>='));
                if ~isempty(less1) && ~isempty(less2) % < <
                % computing the bounds of the control points in terms of k 
                    qctconstraint=tanslate2controlpoints(lowkinterval,upkinterval,midkeinterval,input_name,clauses{cp1(1,less1)},clauses{cp2(1,less2)}); % 6 params 
                    if ~isempty(more1) && ~isempty(more2) % and two >=
                        qctconstraintmore=tanslate2controlpoints(lowkinterval,upkinterval,midkeinterval,input_name,clauses{cp1(1,more1)},clauses{cp2(1,more2)});
                        qctconstraint=strjoin({qctconstraint,qctconstraintmore},' and ');
                    elseif ~isempty(more1) % and one >= (cp1)
                        qctconstraintmore=tanslate1controlpoint(lowkinterval,midkeinterval,input_name,clauses{cp1(1,more1)}); % 4 params
                        qctconstraint=strjoin({qctconstraint,qctconstraintmore},' and ');
                    elseif ~isempty(more2) % and one >= (cp2)
                        qctconstraintmore=tanslate1controlpoint(lowkinterval,midkeinterval,input_name,clauses{cp2(1,more2)}); % 4 params
                        qctconstraint=strjoin({qctconstraint,qctconstraintmore},' and ');
                    end
                elseif ~isempty(more1) && ~isempty(more2) % >= >=
                    qctconstraintmore=tanslate2controlpoints(lowkinterval,upkinterval,midkeinterval,input_name,clauses{cp1(1,more1)},clauses{cp2(1,more2)}); % 6 params 
                    if ~isempty(less1) % and one < (cp1)
                        qctconstraintless=tanslate1controlpoint(lowkinterval,midkeinterval,input_name,clauses{cp1(1,less1)}); % 4 params
                    elseif ~isempty(less2) % and one < (cp2)
                        qctconstraintless=tanslate1controlpoint(lowkinterval,midkeinterval,input_name,clauses{cp2(1,less2)}); % 4 params
                    else
                        qctconstraintless=''; % and no <
                    end
                    if ~isempty(qctconstraintless) % join formula
                        qctconstraint=strjoin({qctconstraintmore,qctconstraintless},' and ');
                    else
                        qctconstraint=qctconstraintmore;
                    end
                else
                    qctconstraint=tanslate2controlpoints(lowkinterval,upkinterval,midkeinterval,input_name,clauses{cp1(1,1)},clauses{cp2(1,1)});
                end
                if  (control_point_index+1==opt.nbrControlPoints-1) % if cp1 and cp2 are the only control points for the input.
                    break  
                end
            else
                if  ~isempty(cp1)
                    for c1=1:size(cp1,2)
                        qctconstraintsign=tanslate1controlpoint(lowkinterval,midkeinterval,input_name,clauses{cp1(1,c1)}); % 4 params
                        if ~isempty(qctconstraint)
                            qctconstraint=strjoin({qctconstraint,qctconstraintsign},' and ');
                        else
                            qctconstraint=qctconstraintsign;
                        end
                    end
                else
                    if  ~isempty(cp2) && (opt.nbrControlPoints<=2)
                        for c2=1:size(cp2,2)
                            qctconstraintsign=tanslate1controlpoint(midkeinterval,upkinterval,input_name,clauses{cp2(1,c2)}); % 4 params
                            if ~isempty(qctconstraint)
                                qctconstraint=strjoin({qctconstraint,qctconstraintsign},' and ');
                            else
                                qctconstraint=qctconstraintsign;
                            end
                        end
                    end                      
                end
            end
            if ~isempty(qctconstraint) &&  ~isempty(qctassumption)
                qctassumption=strjoin({qctassumption,qctconstraint},' and ');
            else
                if ~isempty(qctconstraint)
                    qctassumption=qctconstraint;
                    
                end
            end
            qctconstraint='';
       end
    end
end
