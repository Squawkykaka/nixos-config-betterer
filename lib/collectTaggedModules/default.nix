let
  inherit (builtins)
    readDir
    attrNames
    substring
    stringLength
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
in
path: identifier:
let
  recurse =
    collected: dir:
    let
      files = readDir dir;
      fileNames = attrNames files;
      # TODO: probably more efficent way than recursing twice over the list.
      foundModules = concatMap (
        name:
        if
          files.${name} == "regular"
          && (substring 0 1 name) != "@"
          # file is a .nix file
          && substring ((stringLength name) - 4) (stringLength name) name == ".nix"
        then
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
recurse [ ] path
