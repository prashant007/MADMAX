# A DSL for explainable AHP
A DSL for encoding AHP problems as well as generating explanations for the output that is generated (GPCE,2021).

This package is an executable, i.e it can be used when installed. The installation step of the package are as follows:

1) Download the package and navigate to the folder of the package containing the cabal file.
2) Execute "cabal configure"
3) Execute "cabal install" 
4) The package is now installed and can be used in a Haskell file like a normal import. For example - if we wanted to use the functions defined for shortest path example (Examples.SPDP file) then we can import the following:
import Examples.SP
Similarly any other files could be importe
