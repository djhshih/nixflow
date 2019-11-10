let
  bns = builtins;
  utl = import ./utils.nix;

  # vars is a set of variables and their types
  # e.g. { infile = "File"; a = "string"; b = "int"; }
  mkInputAttrs = vars:
    let
      f = attr: {
        name = attr;
        value = { type = bns.getAttr attr vars; };
      };
      pairs = map f (bns.attrNames vars);
    in (bns.listToAttrs pairs);

  # vars is a set of variables and list containing type and glob
  # e.g. { outfile = ["File" "$(inputs.outfname)"], outval = "string" }
  mkOutputAttrs = inVars: outVars:
    let
      f = attr: {
        name = attr;
        value =
          let
            x = bns.getAttr attr outVars;
          in
            if bns.isList x
            then rec {
              type = bns.elemAt x 0;
              outputBinding = {
                glob = utl.interpolate (bns.elemAt x 1) inVars;
                #loadContents = (type != "File");
                #outputEval = if type == "File" then null else "$(self[0].contents)";
              };
            }
            else { type = x; }
          ;
      };
      pairs = map f (bns.attrNames outVars);
    in bns.listToAttrs pairs;

  mkWorkflowInputAttrs = mkInputAttrs;

  variablePath = str: bns.replaceStrings ["."] ["/"] str;

  mkWorkflowOutputAttrs = outVars:
    let
      f = attr: {
        name = attr;
        value =
          let
            x = bns.getAttr attr outVars;
          in
            if bns.isList x
            then {
              type = bns.elemAt x 0;
              outputSource = variablePath (bns.elemAt x 1);
            }
            else { type = x; }
          ;
      };
      pairs = map f (bns.attrNames outVars);
    in bns.listToAttrs pairs;

  linkSteps = steps: depends:
    let
      f = stepName: {
        name = stepName;
        value =
          let
            step = bns.getAttr stepName steps;
            taskName = step.task;
            tasks = bns.filter (x: x.name == taskName) depends;
            task = if bns.length tasks > 0 then bns.elemAt tasks 0
              else abort "Dependency ${taskName} is missing";
          in
            {
              run = "${taskName}.cwl";
              "in" =
                let
                  h = var: {
                    name =  var;
                    value = variablePath (bns.getAttr var step.inputs);
                  };
                  pairs = map h (bns.attrNames step.inputs);
                in bns.listToAttrs pairs;
              out = bns.attrNames task.cwl.outputs;
            }
          ;
      };
      pairs = map f (bns.attrNames steps);
    in bns.listToAttrs pairs;

  script = "script.sh";

  cwlVersion = "v1.0";

in
rec {
  callDefWith = defaults: fp: args:
    let
      f = if bns.isFunction fp then fp else import fp;
      auto = bns.intersectAttrs (bns.functionArgs f) defaults;
    in utl.makeOverridable f (auto // args);

  mkTask = { name, inputs, outputs, command, runtime }: {
    inherit name;
    type = "task";
    cwl = {
      inherit cwlVersion;
      class = "CommandLineTool";
      baseCommand = [ "bash" script ];
      inputs = mkInputAttrs inputs;
      outputs = mkOutputAttrs inputs outputs;
      requirements = {
        InitialWorkDirRequirement.listing = [
          {
            entryname = script;
            entry = utl.interpolate command inputs;
          }
        ];
        ResourceRequirement = {
          # required number of CPU cores
          coresMin = runtime.cpu;
          # required memory in MiB
          ramMin = runtime.memory;
          # required disk space in MiB
          outdirMin = runtime.disk; 
        };
        # TimeLimit specification is not complete yet
        #TimeLimit = {
        #  # convert from min to s
        #  timelimit = runtime.duration * 60;
        #};
      };
    };
  };

  isTask = x: x.type == "task";

  isWorkflow = x: x.type == "workflow";

  mkWorkflow = { name, inputs, outputs, depends, steps }: {
    inherit name;
    type = "workflow";
    inherit depends;
    cwl = {
      inherit cwlVersion;
      class = "Workflow";
      requirements = if bns.any isWorkflow depends
        then { SubworkflowFeatureRequirement = {}; }
        else {};
      inputs = mkWorkflowInputAttrs inputs;
      outputs = mkWorkflowOutputAttrs outputs;
      steps = linkSteps steps depends;
    };
  };
}
