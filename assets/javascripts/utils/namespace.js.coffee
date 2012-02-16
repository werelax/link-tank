this.Wrlx ||= {}
Wrlx.utils ||= {}

Wrlx.utils.namespace = (root, spaces...)->
  while space = spaces.shift()
    root = (root[space] ||= {})
  return root
