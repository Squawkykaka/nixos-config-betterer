# IBAM - Identifier Based Automatic Modules
# A importer that used identifiers to manage modules within a directory tree.

# IBAM works by placing one or more identifier files or directorys inside the file system. This takes the form of
# `@<name of identifier>`. Then all nix modules *directly inside the identifier path*, *underneath* and *adjacent*
# will be returned from the function. As an example:
# .
# ├── desktop
# │   ├── desktop.nix
# │   ├── gnome
# │   │   ├── gnome.nix
# │   │   └── @simba
# │   │       └── hardware-configuration.nix
# │   └── plasma
# │       ├── plasma.nix
# │       └── @sabaton
# ├── root.nix
# └── server
#     └── server.nix
# calling IBAM with this as your module tree, and `simba` as your identifer will return
# `hardware-configuration.nix` `gnome.nix` `desktop.nix` and `root.nix`. This will exclude `server.nix` as it is in a
# different section of the module tree than the identifier.

# When *multiple* identifier files/directorys are present, it will return the found modules from all the seperate paths.

# Save this file somwhere in your config, and use it by
# ```nix
# nixosSystem {
#   modules = import ./path/to/ibam.nix <path to module tree> <host identifier>;
# }
# ```
path: identifier:
let
  inherit (builtins)
    readDir
    attrNames
    substring
    stringLength
    concatMap
    ;

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
      # if indicator found, or a file is found which will be immediately purged
      if substring 0 1 fileName == "@" || files.${fileName} != "directory" then
        # and it is the identifier we are searching for
        if fileName == "@${identifier}" then
          # if a file, ignore and return modules, otherwise import
          # everything under the identifier.
          if files.${fileName} == "regular" then
            collected ++ foundModules
          else
            collected
            ++ foundModules
            # import each file inside @<identifier>
            ++ (map (el: dir + "/${fileName}/${el}") (attrNames (readDir (dir + "/${fileName}"))))
        else
          [ ]
      # if normal directory, continue search
      else
        recurse (collected ++ foundModules) (dir + "/${fileName}")
    ) fileNames;
in
recurse [ ] path
