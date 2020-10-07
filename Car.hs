{-# LANGUAGE DeriveAnyClass #-}
module Car where

import qualified Data.Map.Strict as M
import Data.Tuple.OneTuple (OneTuple(..))

import Record
import Info
import Valuation
import MDS
import Focus
import Transformation


-- Car Example
--
data Car     = Honda | BMW | Toyota deriving (Eq,Ord,Show,Enum,Bounded,Set)
data Feature = Price | MPG | Safety deriving (Eq,Ord,Show,Enum,Bounded,Set)
data Opinion = Personal | Expert deriving (Eq,Ord,Show,Enum,Bounded,Set)
data Weight  = Weighted deriving (Eq,Ord,Show,Enum,Bounded,Set)

instance Valence Feature where
  valence Price = False
  valence _     = True

instance Valence Opinion
instance Valence Weight


-- (1) Mapping carFeatures to opinions
--
carFeatures :: Info Car Feature
carFeatures = info [Honda --> [Price --> 34000, MPG --> 30, Safety --> 9.8],
                    BMW   --> [Price --> 36000, MPG --> 32, Safety --> 9.1]]


-- (2) Creating a valuation from data (only for opinions)
--
vCarF :: Val Car Feature
vCarF = valuation carFeatures

{-
*Car> total vCarF
{Honda -> 150.90, BMW -> 149.10}
-}


-- (3) Some variation: adding/deleting/modifying a feature attribute
--
threeCars :: Info Car Feature
threeCars = carFeatures `union`
            info [Toyota --> [Price --> 27000, MPG --> 30, Safety --> 9.4]]

v3CarF :: Val Car Feature
v3CarF = valuation threeCars

-- opinions3 = delAttribute Price carFeatures
-- opinions4 = modAttribute Price Honda 45000 carFeatures

-- using "0" here because vd is redefined later
--
vd0 :: Rec Feature
vd0 = diff vCarF Honda BMW

vd3 :: Rec Feature
vd3 = diff (valuation threeCars) Honda BMW



-- (4) Value difference impact
--
vdi2 :: Focus Feature ()
vdi2 = impact vd0

vdi3 :: Focus Feature ()
vdi3 = impact vd3


-- (5) Adding dimensions and extending valuation
--
featureOpinions :: Info Feature Opinion
featureOpinions = info [Price  --> [Personal --> 5, Expert --> 3],
                        MPG    --> [Personal --> 3, Expert --> 5],
                        Safety --> [Personal --> 2, Expert --> 2]]


featureVal :: Val Car (OneTuple Feature)
featureVal = mkOneTuple vCarF

carOpinions :: Val Car (Feature,Opinion)
carOpinions = featureVal `extendBy` featureOpinions

{-
*Car> total carOpinions
{Honda -> 99.98, BMW -> 100.02}

*Car> total $ only Personal carOpinions
{Honda -> 50.37, BMW -> 49.63}

*Car> total $ only Expert carOpinions
{Honda -> 49.61, BMW -> 50.39}
-}


-- (6) Top-level: Weighting opinions
--
weight :: a -> [(Weight,a)]
weight x = [Weighted --> x]

weights :: Info Opinion Weight
weights = info [Personal --> weight 0.6,Expert --> weight 0.4]

cars :: Val Car (Feature,Opinion,Weight)
cars = carOpinions `extendBy` info [Personal --> weight 0.6,Expert --> weight 0.4]

{-
*Car> total cars
{Honda -> 50.07, BMW -> 49.93}
-}

cars' :: Val Car (Feature,Opinion)
cars' = shrinkVal cars


-- (7) Explaining decisions
--

{-
vdCars :: Rec (Feature,Opinion,Weight)
vdCars = diff cars Honda BMW

an0 :: Analysis (Feature,Opinion,Weight)
an0@(sup0,bar0,doms0,mds0:_) = analyze vdCars

an1 :: Analysis Opinion
an1 = generalize vdCars

an2 :: Analysis Feature
an2 = generalize vdCars
-}


vd :: Rec (Feature,Opinion)
vd = diff (shrinkVal cars) Honda BMW

domi :: Dominance (Feature,Opinion)
domi = dominance vd

expl :: Explanation Car (Feature,Opinion)
expl = explain cars


an0' :: Analysis (Feature,Opinion)
an0'@(sup0',bar0',doms0',mds0':_) = analyze vd

an1' :: Analysis Opinion
an1' = generalize vd

-- mds0r :: Rec (Feature,Opinion)
-- mds0r = shrinkRec mds0 -- == mds0'

featureFocus = factorize mds0' :: Focus Feature Opinion
opinionFocus = factorize mds0' :: Focus Opinion Feature


factorize' = factorize.mkOneTupleRec

vdTwoCars = diff (valuation carFeatures) Honda BMW
factTwoCars = factorize' vdTwoCars :: Focus Feature ()
factThreeCars = factorize' vd3 :: Focus Feature ()
