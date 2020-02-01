let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.13.6-20200127/packages.dhall sha256:06a623f48c49ea1c7675fdf47f81ddb02ae274558e29f511efae1df99ea92fb8

let overrides = {=}

let additions =
      { yarn =
          { dependencies =
              [ "strings", "arrays", "generics-rep", "partial", "unicode" ]
          , repo =
              "https://github.com/thimoteus/purescript-yarn"
          , version =
              "v4.0.0"
          }
      , template-strings =
          { dependencies =
              [ "functions", "tuples" ]
          , repo =
              "https://github.com/purescripters/purescript-template-strings"
          , version =
              "v5.1.0"
          }
      }

in  upstream // overrides // additions
