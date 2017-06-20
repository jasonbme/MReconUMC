classdef deepCopyable < matlab.mixin.Copyable
%Enabling the superclass hierarchy
%
% 20170717 - T.Bruijnen

    methods(Access = protected)
        function cpObj = copyElement(obj)
            
            % Copy value properties
            cpObj = copyElement @matlab.mixin.Copyable(obj);
            
            % Dynamic properties are not copied as standard, so we might
            % need to add them
            
            props = properties(obj);
            props_cp = properties(cpObj);
            
            isdynamic = any(strcmpi(superclasses(obj), 'dynamicprops'));
            
            for ii = 1:length(props)
                
                % Check if current property is a handle (the first
                % statement can return true if props{ii} is a string with
                % the same name as a class and so we also need to check
                % that it is not of type char.
                
                isHandle = any(strcmpi(superclasses(obj.(props{ii})), 'handle')) && ~ischar(obj.(props{ii})) ;
                
                % Add properties if needed                
                if isdynamic && ~ any(strcmpi(props{ii},props_cp))
                    cpObj.addprop(props{ii});
                    
                    % Copy dynamic value properites (handle properties
                    % dealt with later
                    
                    if ~ isHandle
                        cpObj.(props{ii}) = obj.(props{ii});
                    end
                    
                end
                
                if isHandle
                    
                    % Copy handle properties
                    cpObj.(props{ii}) = copy(obj.(props{ii}));
                    
                end
                
            end
            
        end
        
    end
    
end