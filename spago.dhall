{ name = "affjax-node"
, dependencies = [ "aff", "affjax", "console", "prelude" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
