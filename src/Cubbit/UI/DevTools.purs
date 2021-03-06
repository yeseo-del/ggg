module Game.Cubbit.Hud.DevTools (openDevTools) where

import Control.Monad.Eff (Eff)
import DOM (DOM)
import Data.Unit (Unit)

foreign import openDevTools :: forall eff. Eff (dom :: DOM | eff) Unit
