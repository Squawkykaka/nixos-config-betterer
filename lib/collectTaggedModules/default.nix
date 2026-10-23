let
  inherit (builtins)
    foldl'
    readDir
    attrValues
    attrNames
    substring
    stringLength
    readFileType
    filter
    isPath
    concatMap
    ;

  # same as lib.listFilesRecursive
  listFilesRecursive =
    dir:
    let
      files = readDir dir;
    in
    concatMap (
      name:
      if files.${name} == "directory" then
        listFilesRecursive (dir + "/${name}")
      else
        [
          (dir + "/${name}")
        ]
    ) (attrNames files);

  stringSuffix =
    number: string: substring ((stringLength string) - number) (stringLength string) string;

  listTaggedModules =
    roots: identifier:
    let
      recurse =
        collected: dir:
        let
          files = readDir dir;
          fileNames = attrNames files;
          # TODO: probably more efficent way than recursing twice over the list.
          foundModules = concatMap (
            name:
            if files.${name} == "regular" && (substring 0 1 name) != "@" && (stringSuffix 4 name) == ".nix" then
              [ (dir + "/${name}") ]
            else
              [ ]
          ) fileNames;
        in
        concatMap (
          fileName:
          # if indicator found, which can be file OR directory
          if substring 0 1 fileName == "@" then
            # and it is the identifier we are searching for
            if fileName == "@${identifier}" then
              # if a file, ignore and return modules, otherwise import
              # everything under the identifier.
              if files.${fileName} == "regular" then
                collected ++ foundModules
              else
                collected ++ foundModules ++ (listFilesRecursive (dir + "/${fileName}"))
            else
              [ ]
          # ignore all other files, as we collected them above.
          else if files.${fileName} != "directory" then
            [ ]
          # if normal directory, continue search
          else
            recurse (collected ++ foundModules) (dir + "/${fileName}")
        ) fileNames;
    in
    concatMap (
      path:
      if !isPath path && readFileType path != "directory" then
        throw "`roots` may only contain directorys."
      else
        recurse [ ] path
    ) roots;
in
listTaggedModules [ (toString ./example) ] "simba"
