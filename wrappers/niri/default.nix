_: {
  options.configFiles.mutators = [ "./." ];
  mutations."/niri".configFiles = { }: [ (toString ./config.kdl) ];
}
