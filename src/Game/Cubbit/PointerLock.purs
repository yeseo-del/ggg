module Game.Cubbit.PointerLock (requestPointerLock, exitPointerLock) where

import Control.Alt (void)
import Control.Alternative (pure, when)
import Control.Bind (bind)
import Control.Coroutine (Consumer, consumer)
import Control.Monad.Aff (Aff, Canceler(..), launchAff, runAff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, error, errorShow, logShow)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Now (NOW)
import Control.Monad.Eff.Ref (REF, Ref, modifyRef, newRef, readRef, writeRef)
import Control.Monad.Free (liftF)
import DOM (DOM)
import Data.Array (catMaybes, drop, take)
import Data.Foldable (for_)
import Data.Int (toNumber) as Int
import Data.Maybe (Maybe(..), isNothing)
import Data.Nullable (Nullable, toNullable)
import Data.Ord (abs, min)
import Data.Show (show)
import Data.Unit (Unit, unit)
import Data.Void (Void)
import Game.Cubbit.BlockIndex (BlockIndex, runBlockIndex)
import Game.Cubbit.Chunk (MeshLoadingState(MeshNotLoaded, MeshLoaded), disposeChunk)
import Game.Cubbit.ChunkIndex (chunkIndex, runChunkIndex)
import Game.Cubbit.ChunkMap (delete, filterNeighbors, getSortedChunks, size)
import Game.Cubbit.MeshBuilder (createChunkMesh)
import Game.Cubbit.Terrain (Terrain(Terrain), globalPositionToChunkIndex, globalPositionToGlobalIndex, isSolidBlock, lookupBlockByVec, lookupChunk, lookupSolidBlockByVec)
import Game.Cubbit.Types (Effects, CoreEffects, Mode(..), State(State), Materials, ForeachIndex)
import Game.Cubbit.Option (Options)
import Graphics.Babylon.AbstractMesh (abstractMeshToNode, getSkeleton, setIsVisible, setRotation, setVisibility)
import Graphics.Babylon.AbstractMesh (setPosition) as AbstractMesh
import Graphics.Babylon.Camera (setPosition) as Camera
import Graphics.Babylon.Mesh (meshToAbstractMesh, setPosition)
import Graphics.Babylon.Node (getName)
import Graphics.Babylon.PickingInfo (getPickedPoint)
import Graphics.Babylon.Ray (createRayWithLength)
import Graphics.Babylon.Scene (pick, pickWithRay)
import Graphics.Babylon.ShadowGenerator (setRenderList)
import Graphics.Babylon.Skeleton (beginAnimation)
import Graphics.Babylon.TargetCamera (setTarget, targetCameraToCamera)
import Graphics.Babylon.Types (BABYLON, Mesh, Scene, TargetCamera, ShadowMap)
import Graphics.Babylon.Vector3 (createVector3, runVector3, subtract, length)
import Graphics.Canvas (CANVAS)
import Halogen (HalogenEffects, HalogenIO, eventSource)
import Halogen.Query (action)
import Halogen.Query.EventSource (eventSource')
import Math (atan2, cos, max, pi, round, sin, sqrt)
import Network.HTTP.Affjax (AJAX)
import Prelude (negate, ($), (&&), (*), (+), (-), (/), (/=), (<), (<$>), (<>), (==), (||), type (~>))

foreign import requestPointerLock :: ∀eff . ({ movementX :: Number, movementY :: Number } -> Eff (dom :: DOM | eff) Unit) -> Eff (dom :: DOM | eff) Unit -> Eff (dom :: DOM | eff) Unit

foreign import exitPointerLock :: ∀eff . Eff (dom :: DOM | eff) Unit