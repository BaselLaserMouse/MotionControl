classdef (Abstract) linearcontroller < handle & loghandler
%%  linearcontroller 
%
% The linearcontroller abstract class is a software entity that represents the 
% physical linear stage controller object. 
%
% The linearcontroller abstract class declares methods that are used to move linear
% actuators, linear stages, PIFOCs, etc. A small number of methods are defined within 
% this abstract class. Most methods are defined in concrete classes that must inherit 
% linearcontroller. Examples of these include C891 and BSC201. 
%
% Classes that inherit linearcontroller serve as a "glue" or "bridge" between the 
% hardware manufacturer's API and your code. These classes provide a consistent
% interface.
%
%
%
% Rob Campbell - Basel 2015

    properties 

        hC  %A handle to the hardware controller object. e.g. this could be a serial port
            %or another object that actually sends out the commands over serial, USB, or whatever.

        attachedStage % The stage attached to the controller:
                    % myLinearControllerObject.attachedStage = myLinearStageObject
                    % Systems with multiple stages in one physical controller should
                    % have multiple copies of the controller object, each with a different
                    % stage attached. This system isn't tested yet, as no such hardware
                    % is available to us. 

        controllerID % The information required by the method that connects to the 
                     % the controller at connect-time. This can be specified in whatever
                     % way is most suitable for the hardware at hand. 

    end %close public properties


    properties (Hidden)
        parent  %A copy of the parent object (future proofing)
    end

    % These are GUI-related properties. The view class that comproses the GUIi listens to changes in 
    % these properties to know when to update the GUI. It is therefore necessary for these to be updated 
    % as appropriate by classes which inherit linearcontroller. 
    properties (Hidden, SetObservable, AbortSet)

    end %close GUI-related properties


    % All abstract methods must be defined by the child class that inherits this abstract class
    % You should also define a suitable destructor to clean up after you class
    methods (Abstract) %All methods in this block are considered critical and you should define them

        success = connect(obj)
        % connect
        %
        % Behavior
        % This method establishes a connection between the physical controller device
        % and the host PC. The method uses the controllerID  property to establish the 
        % connection. 
        %
        % Outputs
        % success - true or false depending on whether a connection was established

        success = isControllerConnected(obj)
        % isControllerConnected
        %
        % Behavior
        %
        % Outputs
        % success - true or false depending on whether a working connection is present 
        %           with the physical stage controller device. i.e. it is not sufficient 
        %           that, say, a COM port is open. For success to be true, the device must
        %           prove that it can interact in some way with the host PC. 

        pos = axisPosition(obj)
        % Get the position of a given axis
        %
        % Behavior
        % - First check if controller is connected with isControllerConnected. 
        % - Only proceed if this is true.
        % - Reads the current position in the current units.
        % - transform position with linearstage.transformDistance
        % - Write it to the axis currentPosition property and return it as an output argument. 
        %   Note that the *transformed* position should be written here. e.g.
        %     POS = obj.hC.getPosition;
        %     POS = obj.attachedStage.transformdDstance(POS);
        %     obj.attachedStage.currentPosition=POS;
        % - Returns empty if a stage is not connected and so it failed to read the position.
        %
        % Inputs
        % None
        %
        % Output
        % Position of the axis in the currently selected units. False if no reading could be made.



        moving = isMoving(obj)
        % Is a given axis currently moving?
        %
        % Behavior
        % First check if controller is connected with isControllerConnected. Only proceed if this is true.
        % Reads the motion state of a given axis and reports it. 
        % If the controller does not support this feature and there is 
        % no way to implement such a feature in software, then isMoving
        % should return []. Otherwise, it should return true or false.
        % This function can, for instance, be used to build a blocking motion call. 
        %
        % Inputs
        % None
        %
        % Output
        % true - axis is currently moving
        % false - axis is not currently moving

        success = relativeMove(obj, distanceToMove)
        % relativeMove 
        %
        % Behavior
        % First check if controller is connected with isControllerConnected. Only proceed if this is true.
        % Convert distanceToMove with linearstage.transformDistance
        % Call controller API methods or initiate RS232 calls.
        %
        %
        % Inputs
        % distanceToMove - required. signed number defining relative distance to move (in microns?)
        %
        % Outputs
        % success - true if motion command was sent successfully. False otherwise

        success = absoluteMove(obj, targetPosition)
        % absoluteMove
        %
        % Behavior 
        % First check if controller is connected with isControllerConnected. Only proceed if this is true.
        % Convert targetPosition with linearstage.transformDistance
        % Call controller API methods or initiate RS232 calls.
        %
        %
        % Inputs
        % targetPosition - required. signed number defining the position to move to (TODO: in microns?)
        %
        %
        % Outputs
        % success - true if motion command was sent successfully. False otherwise

        success = stopAxis(obj)
        % stopAxis
        %
        % Behavior 
        % First check if controller is connected with isControllerConnected. Only proceed if this is true.
        % Issue stop command (a graceful one if availble) to the named axis.
        %
        %
        % Inputs
        % None
        %
        % Outputs
        % success - true if motion command was sent successfully. False otherwise

       posUnits = getPositionUnits(obj)
        % Get the units in which the controller currently operates for a given axis
        %
        %
        % Outputs
        % 'count' - encoder count (ticks)
        % 'motorStep' - motor steps
        % 'mm' - millimeter
        % 'um' - micrometer
        % 'in' - inches
        % 'UU' - unknown unit
        %  []  - empty: failed to get units

        success = setPositionUnits(obj,controllerUnits)
        % Set the units in which the controller operates.
        %
        % Behavior
        % Sets the controller units. Checks if running the command will
        % indeed change the units (the user didn't ask for the current units)
        % If so, re-read the axis position after changing the units. TODO: get rid of the position field?
        %
        %
        % Inputs
        % controllerUnits must be one of the following:
        %
        % 'count' - encoder count (ticks)
        % 'motorStep' - motor steps
        % 'mm' - millimeter
        % 'um' - micrometer
        % 'in' - inches
        %
        % Outputs
        % true - the units were changed successfully
        % false - the units were not changed successfully



    end %Critical abstract methods



    methods %These are non-critical abstract methods (TODO: check this is true)

        %As positionUnits, but for the stage's target, or maximum, velocity
        velocity = getMaxVelocity(obj)
        success = setMaxVelocity(obj,velocity)
        %true/false

        %As positionUnits, but for the stage's initial velocity
        velocity = getInitialVelocity(obj)
        success = setInitialVelocity(obj,velocity)

        %As positionUnits, but for the stage's acceleration
        accel = getAcceleration(obj)
        success = setAcceleration(obj,acceleration)


        success = enableAxis(obj)
        % enableAxis
        % enable or powerup a given axis
        %
        % Purpose
        % Some controllers require that an axis is enabled in some way before it can moved. 
        % This method performs this. Exactly what it does will depend on the hardware. 
        % Returns true if the enable command succeeded. Returns false otherwise.

        success = disableAxis(obj)
        % enableAxis
        % disable/powerdown/whatever a given axis
        % The exact behavior of this method will depend on the hardware.
        % e.g. when disabled, some stages will remain locked in place whereas
        % others will become free to move. 
    end %non-critical abstract methods



    % The following method definitions will be common to all classes that inherit linearcontroller
    methods
        function obj = attachLinearStage(obj,linearStageObject)
            % Attach a linearstage object to the linearcontroller if it is of the correct type
            %
            % obj = attachLinearStage(obj,linearStageObject)
            %
            % Inputs
            % linearStageObject - an object that inherits linearstage

            if ~isa(linearStageObject,'linearstage')
                error('linearstage object not provided')
            end
            if isempty(linearStageObject.axisName) || ~ischar(linearStageObject.axisName)
                error('axisName property needs to be supplied and should be a string')
            end
            if ~regexp(linearStageObject.axisName,'^[xyz]Axis$')
                error('Field stage.settings.axisName is incorrect. It should be one of: xAxis, yAxis, or zAxis. You supplied %s',linearStageObject.axisName)
            end

            obj.attachedStage = linearStageObject;
        end

        function success = isStageConnected(obj)
        % isStageConnected
        %
        % function success = isStageConnected(obj)
        %
        %
        % Behavior
        % Returns true if a stage has been attached to the controller object.
        %
        % 
        % Inputs
        % none 
        %
        % Outputs
        % success - true or false depending on whether a stage is present

            success=false;
            attachedStage=[];
            if isempty(obj.attachedStage)
                DB=dbstack;
                obj.logMessage(inputname(1),DB(1),7,'No stage object attached. The attachedStage property is empty.')
              return
            end

            success=true;

        end



        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        function ready = isAxisReady(obj)
          % Report whether the controller is ready to execute a command on an axis
          %
          % Behavior
          % Before performing tasks such as getting an axis position or moving an axis we 
          % want to first check whether the controller is correctly set up to do this. 
          % i.e. is the connection to the controller working and is the stage connected?
          % This method's first output argument must return true if everything is set up correctly. 
          % You may define extra output arguments specific for your purposes.
          %
          % Inputs
          % none 
          %
          % Outputs
          % ready - true/false
          %   ready is true if the object is set up and ready to perform axis motions or 
          %   query the axis, etc. false otherwise.


          ready=false;

          % Is a connection established to the hardare and is at least one linearstage connected?
          if ~obj.isControllerConnected || ~obj.isStageConnected 
            obj.logMessage(inputname(1),dbstack,6,'Controller or stages not connected.')
            return
          end

          ready=true;
        end %isAxisReady



        function inBounds = isMoveInBounds(obj,targetPosition)
            %returns true if target position is within the defined bounds
            inBounds=false;

            if nargin<2
                obj.logMessage(inputname(1),dbstack,7,'no targetPosition defined for checking if move is in bounds')
                return
            end

            if ~obj.checkDistanceToMove(targetPosition) %handles the log messages and warnings
                return
            end

            if isempty(obj.getMaxPos) || isempty(obj.getMinPos)
                obj.logMessage(inputname(1),dbstack,6,'Bounds not set for axis. Not moving.')
                inBounds=false;
                return
            end

            if (~isempty(obj.getMaxPos) && targetPosition>obj.getMaxPos) || ...
                (~isempty(obj.getMinPos) && targetPosition<obj.getMinPos) 
                msg = sprintf('target position %0.2f is out of bounds',targetPosition);
                obj.logMessage(inputname(1),dbstack,6,msg)
              return
            end

            inBounds=true;
        end %isMoveInBounds


        function [minPos,axisID] = getMinPos(obj)
            % Determine the minimum allowable position of an axis
            %
            % Purpose/Behavior
            % This abstract class determines if the attached stage has its minPos property 
            % defined, if so this is returned. Child classes that inherit linearcontroller
            % should call this super-class method and, if appropriate, determine from the 
            % controller the minumum stage position using the API. This should only be done
            % if linearcontroller.getMinPos returns empty. 
            %
            % Motion functions will honour the value of getMinPos if it is not empty. If
            % an out range motion was requested, the controller will fail to move and return 
            % false.
            %
            % Outputs
            % The ouputs of this method are:
            % minPos - minimum allowed value of the attached stage in whatever units the stage operates.
            % axisID - the stage ID for API calls
            %
            % child classes will return only minPos

            minPos=[];

            if ~obj.isAxisReady
              obj.logMessage(inputname(1),dbstack,7,'Unable to get minPos.')
              return
            end

            minPos = obj.attachedStage.minPos;
            axisID = obj.attachedStage.axisID;
        end %getMinPos


        function [maxPos,axisID] = getMaxPos(obj)
            % Determine the maximum allowable position of an axis
            %
            % Purpose/Behavior
            % See linearcontroller.minPos
            maxPos=[];

            if ~obj.isAxisReady
              obj.logMessage(inputname(1),dbstack,7,'Unable to get maxPos.')
              return
            end

            maxPos = obj.attachedStage.maxPos;
            axisID = obj.attachedStage.axisID;

        end %getMaxPos

        function success=checkDistanceToMove(obj,thisValue)
            %Returns true if distanceToMove is a numeric scalar
            success=false;

            if ~isnumeric(thisValue) 
                msg=sprintf('Desired move location must be a number, it was a %s',class(thisValue));
                obj.logMessage(inputname(1),dbstack,6,msg)
                return
            end
            if isempty(thisValue) 
                msg=sprintf('Desired move location is empty');
                obj.logMessage(inputname(1),dbstack,6,msg)
                return
            end            
            if ~isscalar(thisValue)                
                msg='Desired move location must be a scalar';
                obj.logMessage(inputname(1),dbstack,6,msg)
                return
            end
            success=true;
        end
    end %close methods

end %close classdef
